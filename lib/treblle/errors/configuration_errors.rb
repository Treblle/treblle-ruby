module Treblle
  module Errors
    class ConfigurationError < StandardError
      def initialize(msg = "Configuration error")
        super(msg)
      end
    end

    class MissingApiKeyError < ConfigurationError
      def initialize(msg = "API key is missing")
        super(msg)
      end
    end

    class InvalidEndpointError < ConfigurationError
      def initialize(msg = "Invalid endpoint")
        super(msg)
      end
    end
  end
end
