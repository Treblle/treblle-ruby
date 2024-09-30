# frozen_string_literal: true

require 'treblle/version'
require 'treblle/utils/hash_sanitizer'

module Treblle
  class GeneratePayload
    SDK_LANG = 'ruby'
    TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

    def initialize(request:, response:, started_at:, load_time:, configuration: Treblle.configuration)
      @request = request
      @response = response
      @started_at = started_at
      @load_time = load_time
      @configuration = configuration
    end

    def call
      payload.to_json
    end

    private

    attr_reader :request, :response, :started_at, :load_time, :configuration

    def sanitize(body)
      Utils::HashSanitizer.sanitize(body, configuration.sensitive_attrs)
    end

    def timestamp
      started_at.utc.strftime(TIME_FORMAT)
    end

    def payload
      {
        api_key: configuration.api_key,
        project_id: configuration.project_id,
        version: Treblle::API_VERSION,
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
            body: response.body,
            errors: errors
          }
        }
      }
    end

    def errors
      return [] if response.exception.nil?

      [{
        source: 'onError',
        type: response.exception.type,
        message: response.exception.message,
        file: response.exception.file_path,
        line: response.exception.line_number
      }]
    end
  end
end
