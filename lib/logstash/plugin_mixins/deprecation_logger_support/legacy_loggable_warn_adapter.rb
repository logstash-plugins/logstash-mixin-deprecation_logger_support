# encoding: utf-8

require 'thread' # Mutex

module LogStash
  module PluginMixins
    module DeprecationLoggerSupport

      ##
      # The `LegacyLoggableWarnAdapter` provides a `#deprecation_logger`
      # returning a `DeprecationLogger` that is implemented via `Loggable#warn`.
      # @api internal (@see DeprecationLoggerSupport::included)
      module LegacyLoggableWarnAdapter
        ##
        # the `DeprecationLogger` is API-compatible with the one provided in
        # Logstash 7.6
        class DeprecationLogger
          ##
          # @api private
          # @param base_logger [LogStash::Logger]
          def initialize(base_logger)
            @base_logger = base_logger
          end

          ##
          # @overload deprecated(message)
          #   @since 1.0.0
          #   @param message [String]: a complete message string
          #   @return [void]
          #
          # @overload deprecated(template, replacement)
          #   @since 1.0.0
          #   @param template [String]: a template string contiaining exactly
          #                             one `{}` placeholder
          #   @param replacement [Object]: an object to be stringified and
          #                                inserted in place of the placeholder
          #   @return [void]
          def deprecated(message, *args)
            @base_logger.warn("DEPRECATED: #{message}", *args)
          end
        end
        private_constant :DeprecationLogger

        ##
        # @api private
        MEMOIZE_MUTEX = Mutex.new
        private_constant :MEMOIZE_MUTEX

        ##
        # @return [DeprecationLogger]
        def deprecation_logger
          # threadsafe at-most-once memoize
          # NOTE: the instance variable used here is _not_ a public part of the API.
          @_deprecation_logger_legacy_adapter || MEMOIZE_MUTEX.synchronize do
            @_deprecation_logger_legacy_adapter ||= DeprecationLogger.new(logger)
          end
        end
      end
    end
  end
end
