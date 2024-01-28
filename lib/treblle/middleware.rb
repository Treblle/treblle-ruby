# frozen_string_literal: true

require 'treblle/dispatcher'
require 'treblle/request_builder'
require 'treblle/response_builder'
require 'treblle/generate_payload'

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
      started_at = Time.now

      begin
        response = @app.call(env)
      rescue Exception => e
        handle_monitoring(env, response, started_at, e)
        raise e
      end

      handle_monitoring(env, response, started_at)

      response
    end

    def handle_monitoring(env, rack_response, started_at, exception: nil)
      request = RequestBuilder.new(env).build
      response = ResponseBuilder.new(rack_response).build
      payload = GeneratePayload.new(request: request, response: response, started_at: started_at,
        exception: exception).call

      Dispatcher.new(payload: payload).call
    rescue StandardError => e
      Rails.logger.error("Treblle monitoring failed due to: #{e.message}")
    end

    def should_monitor?(env)
      configuration.monitoring_enabled?(env['PATH_INFO'])
    end
  end
end
