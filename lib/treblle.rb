# frozen_string_literal: true

require 'treblle/middleware'
require 'treblle/configuration'
require 'treblle/rails/railtie'

# Treblle middleware for request interception and gathering.
module Treblle
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)

      configuration.validate_credentials! if configuration.enabled_environment?
    end
  end
end
