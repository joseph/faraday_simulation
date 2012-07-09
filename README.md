# FaradaySimulation

A [Faraday]() extension to provide dynamic stubbing. This makes it possible 
to simulate more of the behavior of the target service in your tests and when
your app is running in development mode.


## Usage

The `FaradaySimulation::Adapter` class is the equivalent of Faraday's own
test adapter, but you can do a bit more with the stubs:

    conn = Faraday::Connection.new { |builder|
      builder.use(FaradaySimulation::Adapter) { |stub|
        stub.get('/drink/:name.json') { |env|
          [200, {}, "Drinking #{env[:params]['name']}"]
        }
      }
    }

    resp = conn.get('/drink/sake.json')
    # resp.body => 'Drinking sake'

    resp = conn.get('/drink/ale.json')
    # resp.body => 'Drinking ale'

Put simply, any stub path you define that includes `:foo` will match to
any string, and that string will be the value of `env[:params]['foo']` in
your stub block.

For more complex routes, you can define the stub with a regular expression.
Any regex group (you know, parenthesized pattern) in the matching regex will
be placed in env[:segments]. For example:

    stub.get(/\/foo\/([A-Z]+)\//) { |env|
      [200, {}, "Segment is #{env[:segments][0]}"]
    }

    resp = conn.get('/foo/BAR')
    # resp.body => 'Segment is BAR'

    resp = conn.get('/foo/bar')
    # => Stubs::NotFound error


## Copyright

Copyright (c) 2012 Joseph Pearson, released under the MIT License. 
See MIT-LICENSE for details.
