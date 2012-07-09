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
    @stubs.post('/post-endpoint') { |env|
      assert_equal('bar', env[:params]['foo'])
    }
    @conn.post('/post-endpoint', 'foo=bar')
  end


  def test_query_params
    @stubs.get('/get-endpoint') { |env|
      assert_equal('garply', env[:params]['foo'])
    }
    @conn.get('/get-endpoint?foo=garply')
  end


  def test_segment_params
    @stubs.get(/\/get-endpoint\/([^\/]+)\//) { |env|
      assert_equal('id', env[:segments][0])
    }
    @conn.get('/get-endpoint/id')
  end

end
