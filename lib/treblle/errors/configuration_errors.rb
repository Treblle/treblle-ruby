module Treblle
  module Errors
    class ConfigurationError < StandardError
      def initialize(msg = "Configuration error")
        super
      end
    end

    class MissingApiKeyError < ConfigurationError
      def initialize(msg = "API key is missing")
        super
      end
    end

    class MissingProjectIdError < ConfigurationError
      def initialize(msg = "Project ID is missing")
        super
      end
    end
  end
end
