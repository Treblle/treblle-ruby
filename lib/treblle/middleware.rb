# frozen_string_literal: true

require 'treblle/payload_builder'
require 'treblle/dispatcher'

module Treblle
  class Middleware
    def initialize(app, configuration: Treblle.configuration)
      @app = app
      @configuration = configuration
    end

    def call(env)
      if should_monitor?(env)
        call_with_treblle_monitoring(env)
      else
        @app.call(env)
      end
    end

    private

    attr_reader :configuration

    def call_with_treblle_monitoring(env)
      started_at = Time.current

      begin
        response = @app.call(env)
      rescue StandardError => e
        Rails.logger.error(e.message)
        raise e
      end

      handle_monitoring(env, response, started_at)
      response
    end

    def handle_monitoring(env, response, started_at)
      payload = PayloadBuilder.new(env:, response:, started_at:).call
      Dispatcher.new(payload:).call
    rescue StandardError => e
      Rails.logger.error(e.message)
    end

    def should_monitor?(env)
      configuration.monitoring_enabled?(env['PATH_INFO'])
    end
  end
end
