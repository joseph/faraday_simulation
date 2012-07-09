class FaradaySimulation::Stubs < Faraday::Adapter::Test::Stubs

  def new_stub(request_method, path, body=nil, &block)
    stub = FaradaySimulation::Stub.new(path, body, block)
    (@stack[request_method] ||= []) << stub
  end

end
