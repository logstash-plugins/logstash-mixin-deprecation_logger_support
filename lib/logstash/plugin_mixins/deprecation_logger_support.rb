# encoding: utf-8

require 'logstash/version'
require 'logstash/namespace'

require 'logstash/plugin'

require_relative 'deprecation_logger_support/legacy_loggable_warn_adapter'
require_relative 'deprecation_logger_support/legacy_init_adapter'

module LogStash
  module PluginMixins
    ##
    # This `DeprecationLoggerSupport` can be mixed into any `LogStash::Util::Loggable`,
    # and will ensure that the result provides an API-compatible implementation of the
    # deprecation logger introduced in Logstash 7.6.0
    #
    # This allows plugins to use the new deprecation logging API without
    # imposing new version constraints on those plugins.
    #
    # When used in an older Logstash, the implementation provided by this
    # mixin falls through to send a WARN-level message to the Logger provided
    # by `Loggable#logger`.
    module DeprecationLoggerSupport

      NATIVE_SUPPORT_PROVIDED = LogStash::Util::Loggable.method_defined?(:deprecation_logger)

      ##
      # Including the `DeprecationLoggerSupport` into any module or class that
      # is already a `LogStash::Util::Loggable` ensures that the result provides
      # a `Loggable#deprecation_logger` that is API-compatible with the one
      # introduced to `Loggable` in Logstash 7.6.
      #
      # @param base [Module]: a module or class that already includes the
      #                       Logstash Loggable utility
      def self.included(base)
        fail(ArgumentError, "`#{base}` must be LogStash::Util::Loggable") unless base < LogStash::Util::Loggable

        unless NATIVE_SUPPORT_PROVIDED
          base.send(:include, LegacyLoggableWarnAdapter)
          base.send(:include, LegacyInitAdapter) if base <= LogStash::Plugin
        end
      end

      ##
      # Extending the `DeprecationLoggerSupport` into any`LogStash::Util::Loggable`
      # will ensure that it provides a `Loggable#deprecation_logger` that is
      # API-compatible with the one introduced in `Loggable` in Logstash 7.6
      #
      # @param base [LogStash::Util::Loggable]: an object whose class already
      #                                         includes the Logstash Loggable
      #                                         utility
      def self.extended(base)
        fail(ArgumentError, "`#{base}` must be LogStash::Util::Loggable") unless base.kind_of?(LogStash::Util::Loggable)

        base.extend(LegacyLoggableWarnAdapter) unless NATIVE_SUPPORT_PROVIDED
      end
    end
  end
end
