# frozen_string_literal: true

require 'treblle/version'
require 'treblle/utils/hash_sanitizer'

module Treblle
  class GeneratePayload
    SDK_LANG = 'ruby'
    TIME_FORMAT = '%Y-%m-%d %H:%M:%S'

    def initialize(request:, response:, started_at:, exception: false, configuration: Treblle.configuration)
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
      Time.now - started_at
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
            errors: build_error_object
          }
        }
      }
    end

    def build_error_object
      return [] if exception == false || response.body.nil?

      trace = response.body.dig("traces", "Application Trace")&.first&.[]("trace")
      file_path, line_number = get_exception_path_and_line(trace)

      [
        {
          source: 'onError',
          type: response.body["error"] || response.body["errors"] || 'Unhandled error',
          message: response.body["exception"] || response.body["error"] || response.body["errors"],
          file: file_path,
          line: line_number
        }
      ]
    end

    def get_exception_path_and_line(trace)
      return [nil, nil] if trace.nil?

      match_data = trace.match(/^(.*):(\d+):in `.*'$/)
      file_path = match_data[1]
      line_number = match_data[2]

      [file_path, line_number]
    end
  end
end
