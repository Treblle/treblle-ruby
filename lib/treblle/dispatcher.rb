# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'securerandom'
require 'treblle/logging'

module Treblle
  class Dispatcher
    include Logging

    TREBLLE_URIS = %w[
      https://rocknrolla.treblle.com
      https://punisher.treblle.com
      https://sicario.treblle.com
    ].freeze

    def initialize(payload:, configuration: Treblle.configuration)
      @payload = payload
      @uri = get_uri
      @configuration = configuration
    end

    def call
      send_payload_to_treblle
    end

    private

    attr_reader :payload, :uri, :configuration

    def get_uri
      URI(TREBLLE_URIS.sample)
    end

    def send_payload_to_treblle
      Thread.new do
        begin
          response = make_http_request

          if response.code.to_i >= 400
            log_error(response.body)
          else
            log_success(response.body)
          end
        rescue StandardError => e
          log_error(e.message)
        end
      end
    end

    def make_http_request
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      http.read_timeout = 2
      http.open_timeout = 2

      http.start do |http_instance|
        http_instance.request(build_request)
      end
    end

    def build_request
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req['x-api-key'] = configuration.api_key
      req['x-treblle-trace-id'] = SecureRandom.uuid
      req.body = payload
      req
    end
  end
end
