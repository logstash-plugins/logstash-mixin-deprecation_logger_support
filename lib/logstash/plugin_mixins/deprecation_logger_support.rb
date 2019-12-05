# encoding: utf-8

require 'logstash/version'
require 'logstash/namespace'

require 'rubygems/requirement'
require 'rubygems/version'

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

      ##
      # Mixing the `DeprecationLogger` into any module or class that is
      # a `LogStash::Util::Loggable` ensures that the result provides a
      # `Loggable#deprecation_logger` that is API-compatible
      # with the one introduced to `Loggable` in Logstash 7.6.
      #
      # @param base [Module]: a module or class that includes the Logstash
      #                       Loggable utility
      def self.included(base)
        fail(ArgumentError, "`#{base}` must be LogStash::Util::Loggable") unless base <= LogStash::Util::Loggable
      end

      # In Logstash >= 7.6.0, `Loggable#deprecation_logger` is provided by core,
      # so there is no need to provide it here.
      unless Gem::Requirement.new('>= 7.6.0').satisfied_by?(Gem::Version.new(LOGSTASH_VERSION))
        ##
        # The `DeprecationLoggerLegacyAdapter` implementes the deprecation logger
        # API by falling through to the existing logger.
        #
        # @api private
        class DeprecationLoggerLegacyAdapter
          def initialize(base_logger)
            @base_logger = base_logger
          end

          ##
          # @overload deprecated(message)
          #   @param message [String]: a complete message string
          #
          # @overload deprecated(template, replacement)
          #   @param template [String]: a template string contiaining exactly
          #                             one `{}` placeholder
          #   @param replacement [Object]: an object to be stringified and
          #                                inserted in place of the placeholder
          def deprecated(message, *args)
            @base_logger.warn("DEPRECATED: #{message}", *args)
          end
        end
        private_constant :DeprecationLoggerLegacyAdapter

        def initialize(*args)
          super if defined?(super)

          deprecation_logger # memoize
        end

        ##
        # @return [#deprecated]
        def deprecation_logger
          @deprecation_logger ||= DeprecationLoggerLegacyAdapter.new(logger)
        end
      end
    end
  end
end