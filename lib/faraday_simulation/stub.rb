class FaradaySimulation::Stub < Faraday::Adapter::Test::Stub

  attr_accessor(:segments, :segment_names)


  def initialize(full, body, block)
    self.segment_names = []
    query = nil
    if full.kind_of?(String)
      self.path, query = full.split('?')
      process_path
    else
      self.path = full
    end
    self.params = query ? Faraday::Utils.parse_nested_query(query) : {}
    self.body = body
    self.block = Proc.new { |env|
      env[:params].update(body_params(env))
      segment_names.each { |name|
        env[:params][name] = self.segments.shift
      }
      env[:segments] = self.segments
      block.call(env)
    }
  end


  def matches?(request_uri, request_body)
    request_path, request_query = request_uri.split('?')
    request_params = request_query ?
      Faraday::Utils.parse_nested_query(request_query) :
      {}
    md = request_path.match(self.path)
    if (
      (md && md[0] == request_path) &&
      params_match?(request_params) &&
      (body.to_s.size.zero? || request_body == body)
    )
      self.segments = md.to_a.slice(1, md.size)
      true
    else
      false
    end
  end


  def process_path
    self.path += '/'  unless path.match(/\/$/)
    self.path.gsub!(/:([^\/\.]+)/) {
      self.segment_names << $1
      '([^\/\.]+)'
    }
    self.path = Regexp.new(self.path)  if segment_names.any?
  end


  protected

    def body_params(env)
      case env[:request_headers]["Content-Type"]
      when /\bjson$/
        JSON.load(env[:body])
      else
        Faraday::Utils.send(:parse_nested_query, env[:body])
      end
    end

end
