# encoding: utf-8

module LogStash
  module PluginMixins
    module DeprecationLoggerSupport

      ##
      # The `LegacyInitAdapter` is used to hook into the initialization of
      # Logstash Plugins to ensure that a `@deprecation_logger` instance
      # variable is initialized.
      #
      # @api internal (@see DeprecationLoggerSupport::included)
      module LegacyInitAdapter
        ##
        # @api internal
        # @since 1.0.0
        def initialize(*args)
          super if defined?(super)

          @deprecation_logger ||= self.deprecation_logger
        end
      end
    end
  end
end
