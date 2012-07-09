require 'test_helper'

class FaradaySimulation::TestReadme < Test::Unit::TestCase

  def test_routed_example
    conn = Faraday::Connection.new { |builder|
      builder.use(FaradaySimulation::Adapter) { |stub|
        stub.get('/drink/:name.json') { |env|
          [200, {}, "Drinking #{env[:params]['name']}"]
        }
      }
    }

    resp = conn.get('/drink/sake.json')
    assert_equal('Drinking sake', resp.body)

    resp = conn.get('/drink/ale.json')
    assert_equal('Drinking ale', resp.body)
  end


  def test_segmented_example
    conn = Faraday::Connection.new { |builder|
      builder.use(FaradaySimulation::Adapter) { |stub|
        stub.get(/\/foo\/([A-Z]+)\//) { |env|
          [200, {}, "Segment is #{env[:segments][0]}"]
        }
      }
    }

    resp = conn.get('/foo/BAR')
    assert_equal('Segment is BAR', resp.body)

    assert_raises(Faraday::Adapter::Test::Stubs::NotFound) {
      resp = conn.get('/foo/bar')
    }
  end

end
