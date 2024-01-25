# frozen_string_literal: true

require 'treblle/middleware'
require 'treblle/interfaces/configuration'

# Treblle middleware for request interception and gathering.
module Treblle
  class << self
    def configuration
      @configuration ||= Interfaces::Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
