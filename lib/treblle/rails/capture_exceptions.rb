# frozen_string_literal: true

require 'treblle/dispatcher'
require 'treblle/request_builder'
require 'treblle/response_builder'
require 'treblle/generate_payload'
require 'treblle/logging'
require 'treblle'

module Treblle
  module Rails
    class CaptureExceptions
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

      def call_with_treblle_monitoring(env)
        started_at = Time.now

        response = @app.call(env)
        status, _headers, _rack_response = response

        handle_monitoring(env, response, started_at) if status >= 400

        response
      end

      private

      attr_reader :configuration

      def handle_monitoring(env, rack_response, started_at)
        configuration.validate_credentials!

        request = RequestBuilder.new(env).build
        response = ResponseBuilder.new(rack_response).build
        payload = GeneratePayload.new(request: request, response: response, started_at: started_at,
          exception: true).call

        Dispatcher.new(payload: payload).call
      rescue StandardError => e
        log_error(e.message)
      end

      def should_monitor?(env)
        configuration.monitoring_enabled?(env['PATH_INFO'])
      end
    end
  end
end
