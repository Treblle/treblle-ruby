# frozen_string_literal: true

require 'treblle/models/request'
require 'treblle/models/request/server'
require 'treblle/models/request/client'
require 'action_dispatch'

module Treblle
  class RequestBuilder
    MAX_BODY_LENGTH = 2048

    HEADER_PREFIXES = %w[
      HTTP AUTHORIZATION QUERY CONTENT REMOTE
      REQUEST SERVER ACCEPT USER HOST X PATH
      VARY REFERRER
    ].freeze

    def initialize(rack_env)
      @rack_env = rack_env
    end

    def build
      Models::Request.new.tap do |request|
        apply_to_request(request)
      end
    end

    private

    attr_reader :rack_env

    def apply_to_request(request)
      request_metadata = ActionDispatch::Request.new(rack_env)

      request.server = Models::Request::Server.new(request_metadata)
      request.client = Models::Request::Client.new(request_metadata)
      request.method = request_metadata.method
      request.headers = get_headers(request_metadata)
      request.body = get_body(request_metadata)

      request
    end

    def get_headers(request_metadata)
      request_metadata.headers.select { |header, _value| header_to_include?(header) }.to_h
                      .transform_keys { |header| normalize_header(header) }
    end

    def normalize_header(header)
      header.delete_prefix('HTTP_').tr('_', '-')
    end

    def header_to_include?(header)
      return false if header.start_with?('rack', 'puma')

      HEADER_PREFIXES.any? do |prefix|
        header.to_s.start_with?(prefix)
      end
    end

    def get_body(request_metadata)
      return if request_metadata.body.nil?

      case request_metadata.media_type
      when 'application/x-www-form-urlencoded', 'multipart/form-data'
        request_metadata.POST.dup
      else
        body = request_metadata.body.read
        request_metadata.body.rewind
        body.byteslice(0, MAX_BODY_LENGTH).force_encoding('utf-8').scrub

        request_metadata.media_type == 'application/json' ? JSON.parse(body) : body
      end
    end
  end
end
