# Encoding: UTF-8

Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'refinerycms-elasticsearch'
  s.version           = '1.0'
  s.description       = 'Elasticseach support for Refinery CMS.'
  s.date              = '2014-04-07'
  s.authors           = ['Christian Aust']
  s.license           = %w{MIT}
  s.summary           = 'Elasticseach support for Refinery CMS'
  s.require_paths     = %w(lib)
  s.files             = Dir["{app,config,db,lib}/**/*"] + ["readme.md"]
  s.test_files        = `git ls-files -- spec/*`.split("\n")
  s.required_ruby_version = '>= 1.9.3'

  # Runtime dependencies
  s.add_dependency 'refinerycms-core', '~> 2.1.2'
  s.add_dependency 'patron'
  s.add_dependency 'elasticsearch',    '~> 1.0'
  s.add_dependency 'hashie'

  # Development dependencies (usually used for testing)
  s.add_development_dependency 'refinerycms-testing', '~> 2.1.2'
end
