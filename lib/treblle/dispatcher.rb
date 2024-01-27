# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'securerandom'

module Treblle
  class Dispatcher
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
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(build_request)
        end
        Rails.logger.info("Successfully sent to Treblle: #{response.body}")
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
