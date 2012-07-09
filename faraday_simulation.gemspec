# -*- encoding: utf-8 -*-
require File.expand_path('../lib/faraday_simulation/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ['Joseph Pearson']
  gem.email = ['joseph@booki.sh']
  gem.description = 'A Faraday extension to provide dynamic stubbing.'
  gem.summary = 'Dynamic stubbing in Faraday'
  gem.homepage = ''

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.name = 'faraday_simulation'
  gem.require_paths = ['lib']
  gem.version = FaradaySimulation::VERSION
  gem.add_dependency('rake')
  gem.add_dependency('faraday')
end
