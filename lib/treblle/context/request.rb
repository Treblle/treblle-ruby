# frozen_string_literal: true

require 'json'
require 'action_dispatch'
require_relative 'request_module/server'
require_relative 'request_module/client'

module Treblle
  module Context
    class Request
      MAX_BODY_LENGTH = 2048

      HEADER_PREFIXES = %w[
        HTTP AUTHORIZATION QUERY CONTENT REMOTE
        REQUEST SERVER ACCEPT USER HOST X PATH
      ].freeze

      def initialize(env)
        @request_metadata = ActionDispatch::Request.new(env)
        @server = RequestModule::Server.new(request_metadata)
        @client = RequestModule::Client.new(request_metadata)
        @headers = request_headers
        @body = parse_request_body
        @method = request_metadata.method
      end

      attr_reader :server, :socket, :client, :headers, :body, :method

      private

      attr_reader :request_metadata

      def request_headers
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

      def parse_request_body
        case request_metadata.media_type
        when 'application/x-www-form-urlencoded', 'multipart/form-data'
          request_metadata.POST.dup
        else
          body = request_metadata.body.read
          request_metadata.body.rewind
          body.byteslice(0, MAX_BODY_LENGTH).force_encoding('utf-8').scrub
        end
      end
    end
  end
end
