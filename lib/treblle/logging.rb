# frozen_string_literal: true

module Treblle
  module Logging
    def logger
      ::Rails.logger
    end

    def log_error(message)
      logger.error("Treblle monitoring failed: #{message}")
    end

    def log_success(message)
      logger.info("Successfully sent to Treblle: #{message}")
    end
  end
end
