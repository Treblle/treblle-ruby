# frozen_string_literal: true

require 'treblle/middleware'
require 'treblle/configuration'
require 'treblle/rails/treblle_railtie'

# Treblle middleware for request interception and gathering.
module Treblle
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
