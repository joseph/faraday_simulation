class FaradaySimulation::Adapter < Faraday::Adapter::Test

  def initialize(app, stubs=nil, &block)
    stubs = stubs || FaradaySimulation::Stubs.new
    super(app, stubs, &block)
  end

end
