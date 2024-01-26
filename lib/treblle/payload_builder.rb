# frozen_string_literal: true

require 'json'
require 'socket'
require 'treblle/version'
require 'treblle/context/request'
require 'treblle/context/response'
require 'treblle/utils/hash_sanitizer'

# Gathers and builds body payload to be sent to Treblle in json format.
# Hides sensitive data based on default values and additional ones provided via env variable.
module Treblle
  class PayloadBuilder
    TREBLLE_VERSION = '0.6'
    SDK_LANG = 'ruby'

    def initialize(env:, response:, started_at:, exception: nil, configuration: Treblle.configuration)
      @started_at = started_at
      @ended_at = Time.current
      @request = Context::Request.new(env)
      @response = Context::Response.new(response)
      @exception = exception
      @configuration = configuration
    end

    def call
      payload.to_json
    end

    private

    attr_accessor :request, :response, :configuration, :started_at, :ended_at, :exception

    def sanitize(body)
      Utils::HashSanitizer.sanitize(body, configuration.sensitive_attrs)
    end

    def payload
      {
        api_key: configuration.api_key,
        project_id: configuration.project_id,
        version: TREBLLE_VERSION,
        sdk: SDK_LANG,
        data: {
          server: {
            ip: request.server.remote_addr,
            timezone: Time.zone.name,
            software: request.server.software,
            signature: '',
            protocol: request.server.protocol,
            os: {
              name: request.server.os_name,
              architecture: request.server.os_architecture
            }
          },
          language: {
            name: SDK_LANG,
            version: RUBY_VERSION
          },
          request: {
            timestamp: started_at.to_formatted_s(:db),
            ip: request.client.ip,
            url: request.client.url,
            user_agent: request.client.user_agent,
            method: request.method,
            headers: request.headers,
            body: sanitize(request.body)
          },
          response: {
            headers: response.headers,
            code: response.status,
            size: response.size,
            load_time: Time.current - started_at,
            body: sanitize(response.body),
            errors: build_error_object
          }
        }
      }
    end

    def build_error_object
      return [] if exception.blank?

      [
        {
          source: 'onError',
          type: exception.class.to_s || 'Unhandled error',
          message: exception.message,
          file: exception.backtrace
        }
      ]
    end
  end
end
