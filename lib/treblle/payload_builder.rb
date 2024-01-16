# frozen_string_literal: true

require 'json'
require 'socket'
require 'treblle/version'
require 'treblle/interfaces/request'
require 'treblle/interfaces/response'
require 'treblle/utility/hash_sanitizer'

# Gathers and builds body payload to be sent to Treblle in json format.
# Hides sensitive data based on default values and additional ones provided via env variable.
module Treblle
  class PayloadBuilder
    TREBLLE_VERSION = '0.6'
    SDK_LANG = 'ruby'

    def initialize(env:, response:, started_at:, exception: nil, configuration: Treblle.configuration)
      @started_at = started_at
      @ended_at = Time.current
      @request = Interfaces::Request.new(env)
      @response = Interfaces::Response.new(response)
      @exception = exception
      @configuration = configuration
    end

    def call
      payload.to_json
    end

    private

    attr_accessor :request, :response, :configuration, :started_at, :ended_at, :exception

    def sanitize(body)
      Utility::HashSanitizer.sanitize(body, configuration.sensitive_attrs)
    end

    def server_ip
      Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
    end

    # rubocop:disable Metrics/AbcSize
    def payload
      {
        api_key: configuration.api_key,
        project_id: configuration.project_id,
        version: TREBLLE_VERSION,
        sdk: SDK_LANG,
        data: {
          server: {
            ip: server_ip,
            timezone: Time.zone.name,
            software: request.metadata.server_software,
            signature: '',
            protocol: request.metadata.server_protocol,
            os: {
              name: '',
              release: '',
              architecture: ''
            }
          },
          language: {
            name: SDK_LANG,
            version: RUBY_VERSION
          },
          request: {
            timestamp: started_at.to_formatted_s(:db),
            ip: request.metadata.ip,
            url: request.metadata.original_url,
            user_agent: request.metadata.user_agent,
            method: request.metadata.method,
            headers: request.headers,
            body: request.body
          },
          response: {
            headers: response.headers,
            code: response.status,
            size: response.size,
            load_time: Time.current - started_at,
            body: response.body,
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
          file: exception.backtrace.try(:first) || ''
        }
      ]
    end
  end
end
