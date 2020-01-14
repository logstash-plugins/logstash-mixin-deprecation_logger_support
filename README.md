# Deprecation Logger Support Mixin

This gem provides an API-compatible implementation of the Logstash Deprecation
Logger introduced in Logstash v7.6. It can be added as a dependency of any
plugin that wishes to use the deprecation logger while still supporting older
Logstash versions.

## Usage

1. Add this gem as a runtime dependency of your plugin:

    ~~~ ruby
    Gem::Specification.new do |s|
      # ...

      s.add_runtime_dependency 'logstash-mixin-deprecation_logger_support', '~>1.0'
    end
    ~~~

2. In your plugin code, require this library and include it into your class or
   module that already inherits `LogStash::Util::Loggable`:

    ~~~ ruby
    require 'logstash/plugin_mixins/deprecation_logger_support'

    class LogStash::Inputs::Foo < Logstash::Inputs::Base
      include LogStash::PluginMixins::DeprecationLoggerSupport

      # ...
    end
    ~~~

3. Use the deprecation logger; your plugin does not need to know whether the
   deprecation logger was provided by Logstash core or by this gem.

    ~~~ ruby
      def register
        deprecation_logger.deprecate("your message")
      end
    ~~~

## Development

This gem:
 - *MUST* remain API-stable at 1.x
 - *MUST NOT* introduce additional runtime dependencies
