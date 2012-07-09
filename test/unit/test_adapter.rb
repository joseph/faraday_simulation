require 'test_helper'

class FaradaySimulation::TestAdapter < Test::Unit::TestCase

  def setup
    @stubs = FaradaySimulation::Stubs.new
    @conn = Faraday::Connection.new { |builder|
      builder.use(FaradaySimulation::Adapter, @stubs)
    }
  end


  def test_simplest_case_of_stubbed_routing
    conn = Faraday::Connection.new { |builder|
      builder.use(FaradaySimulation::Adapter) { |stub|
        stub.get('/nigiri/sake.json') {
          [200, {}, 'hi world']
        }
      }
    }

    resp = conn.get('/nigiri/sake.json')
    assert_equal('hi world', resp.body)
  end


  def test_body_params
    @stubs.post('/endpoint') { |env|
      assert_equal('bar', env[:params]['foo'])
    }
    @conn.post('/endpoint', 'foo=bar')
  end


  def test_query_params
    @stubs.get('/endpoint') { |env|
      assert_equal('garply', env[:params]['foo'])
    }
    @conn.get('/endpoint?foo=garply')
  end


  def test_query_params_when_defined_do_not_match
    @stubs.get('/endpoint?foo=baz') { |env| }
    assert_raises(Faraday::Adapter::Test::Stubs::NotFound) {
      @conn.get('/endpoint?foo=woz')
    }
  end


  def test_segment_params
    @stubs.get(/\/endpoint\/([^\/]+)\//) { |env|
      assert_equal('slug', env[:segments][0])
    }
    @conn.get('/endpoint/slug')
  end


  def test_multiple_segment_params
    @stubs.get(/\/endpoint\/([^\/]+)\/junk\/(.*)/) { |env|
      assert_equal('slug', env[:segments][0])
      assert_equal('wildcard/string/', env[:segments][1])
    }
    @conn.get('/endpoint/slug/junk/wildcard/string/')
  end


  def test_segment_params_with_query_params
    @stubs.get(/\/endpoint\/([^\/]+)\//) { |env|
      assert_equal('bar', env[:params]['foo'])
    }
    @conn.get('/endpoint/slug?foo=bar')
  end


  def test_routed_params
    @stubs.get('/endpoint/:slug') { |env|
      assert_equal('faraday_simulation', env[:params]['slug'])
    }
    assert_nothing_raised {
      @conn.get('/endpoint/faraday_simulation')
    }
  end


  def test_routed_params_with_extension
    @stubs.get('/endpoint/:slug.:format') { |env|
      assert_equal('faraday_simulation', env[:params]['slug'])
      assert_equal('json', env[:params]['format'])
    }
    assert_nothing_raised {
      @conn.get('/endpoint/faraday_simulation.json')
    }
  end

end
