# frozen_string_literal: true

require 'treblle/version'
require 'treblle/utils/hash_sanitizer'

module Treblle
  class GeneratePayload
    TREBLLE_VERSION = '0.6'
    SDK_LANG = 'ruby'
    TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

    def initialize(request:, response:, started_at:, exception: nil, configuration: Treblle.configuration)
      @request = request
      @response = response
      @started_at = started_at
      @exception = exception
      @configuration = configuration
    end

    def call
      payload.to_json
    end

    private

    attr_reader :request, :response, :started_at, :configuration, :exception

    def sanitize(body)
      Utils::HashSanitizer.sanitize(body, configuration.sensitive_attrs)
    end

    def timestamp
      started_at.strftime(TIME_FORMAT)
    end

    def load_time
      ((Time.now - started_at) * 1_000_000).round
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
            timezone: request.server.timezone,
            software: request.server.software,
            signature: '',
            protocol: request.server.protocol,
            os: {
              name: request.server.os_name,
              release: '',
              architecture: request.server.os_architecture
            }
          },
          language: {
            name: SDK_LANG,
            version: RUBY_VERSION
          },
          request: {
            timestamp: timestamp,
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
            load_time: load_time,
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
