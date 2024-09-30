# frozen_string_literal: true

require 'treblle/dispatcher'
require 'treblle/request_builder'
require 'treblle/response_builder'
require 'treblle/generate_payload'
require 'treblle/logging'
require 'treblle'

module Treblle
  class Middleware
    include Logging

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
      started_at = Time.now.utc

      response = @app.call(env)

      load_time = Time.now.utc - started_at
      handle_monitoring(env, response, started_at, load_time)

      response
    end

    def handle_monitoring(env, rack_response, started_at, load_time)
      request = RequestBuilder.new(env).build
      response = ResponseBuilder.new(rack_response).build
      payload = GeneratePayload.new(
        request: request,
        response: response,
        started_at: started_at,
        load_time: load_time
      ).call

      Dispatcher.new(payload: payload).call
    rescue StandardError => e
      log_error(e.message)
    end

    def should_monitor?(env)
      configuration.enabled_environment? && configuration.monitoring_enabled?(env['PATH_INFO'])
    end
  end
end
