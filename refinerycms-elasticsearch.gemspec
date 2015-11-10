require File.expand_path('../lib/refinery/elasticsearch/version', __FILE__)

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-elasticsearch'
  s.version           = Refinery::Elasticsearch::VERSION
  s.description       = 'Elasticseach support for Refinery CMS.'
  s.authors           = ['Christian Aust']
  s.license           = %q{MIT}
  s.summary           = 'Elasticseach support for Refinery CMS'
  s.require_paths     = %w(lib)
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- spec/*`.split("\n")
  s.required_ruby_version = '>= 1.9.3'

  # Runtime dependencies
  s.add_dependency 'refinerycms-core', '~> 3.0.0'
  s.add_dependency 'patron'
  s.add_dependency 'elasticsearch'
  s.add_dependency 'hashie'

  # Development dependencies (usually used for testing)
  s.add_development_dependency 'refinerycms-testing', '~> 3.0.0'
end
