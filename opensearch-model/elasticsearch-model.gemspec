# coding: utf-8

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opensearch/model/version'

Gem::Specification.new do |s|
  s.name          = 'opensearch-model'
  s.version       = OpenSearch::Model::VERSION
  s.authors       = ['Ryan Bigg']
  s.email         = ['me@ryanbigg.com']
  s.description   = 'ActiveModel/Record integrations for OpenSearch.'
  s.summary       = 'ActiveModel/Record integrations for OpenSearch.'
  s.homepage      = 'https://github.com/radar/elasticsearch-rails/'
  s.license       = 'Apache 2'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.extra_rdoc_files  = ['README.md', 'LICENSE.txt']
  s.rdoc_options      = ['--charset=UTF-8']

  s.required_ruby_version = '>= 2.4'

  s.add_dependency 'activesupport', '> 3'
  s.add_dependency 'opensearch-ruby', '~> 2'
  s.add_dependency 'hashie'
  s.add_dependency 'zeitwerk'

  s.add_development_dependency 'activemodel', '> 3'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'cane'
  s.add_development_dependency 'kaminari'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '~> 12'
  s.add_development_dependency 'require-prof'
  s.add_development_dependency 'shoulda-context'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'turn'
  s.add_development_dependency 'will_paginate'
  s.add_development_dependency 'yard'
  unless defined?(JRUBY_VERSION)
    s.add_development_dependency 'oj'
    s.add_development_dependency 'ruby-prof'
    s.add_development_dependency 'sqlite3'
  end
end
