Gem::Specification.new do |s|
  s.name          = 'logstash-mixin-deprecation_logger_support'
  s.version       = '1.0.0.alpha'
  s.licenses      = %w(Apache-2.0)
  s.summary       = "Support for the Deprecation Logger introduced in Logstash 7.6, for plugins wishing to use this API on older Logstashes"
  s.description   = "This gem is meant to be a dependency of any Logstash plugin that wishes to use the Deprecation Logger introduced in 7.x while maintaining backward-compatibility with earlier Logstashes. It provides its own deprecation logger, whose interface matches the one introduced in Logstash 7.6, and will use the fallback logger if the deprecation logger is not present."
  s.authors       = %w(Elastic)
  s.email         = 'info@elastic.co'
  s.homepage      = 'https://github.com/logstash-plugins/logstash-mixin-deprecation_logger_support'
  s.require_paths = %w(lib)

  s.files = %w(lib spec vendor).flat_map{|dir| Dir.glob("#{dir}/**/*")}+Dir.glob(["*.md","LICENSE"])

  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.platform = RUBY_PLATFORM

  s.add_runtime_dependency 'logstash-core', '>= 5.0.0'

  s.add_development_dependency 'rspec', '~> 3.9'
end
