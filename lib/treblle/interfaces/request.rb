# frozen_string_literal: true

require 'json'
require 'action_dispatch'

module Treblle
  module Interfaces
    class Request
      HEADER_PREFIXES = %w[
        HTTP AUTHORIZATION QUERY CONTENT REMOTE
        REQUEST SERVER ACCEPT USER HOST X PATH
      ].freeze

      def initialize(env)
        @metadata = ActionDispatch::Request.new(env)
        @headers = request_headers
        @body = parse_request_body
      end

      attr_reader :metadata, :headers, :body

      private

      def request_headers
        metadata.headers.select { |header, _value| header_to_include?(header) }.to_h
                .transform_keys { |header| normalize_header(header) }
      end

      def normalize_header(header)
        header.delete_prefix('HTTP_').gsub('_', '-')
      end

      def header_to_include?(header)
        return false if header.start_with?('rack', 'puma')

        HEADER_PREFIXES.any? do |prefix|
          header.to_s.start_with?(prefix)
        end
      end

      def parse_request_body
        JSON.parse(metadata.raw_post)
      rescue JSON::ParserError, NoMethodError
        {}
      end
    end
  end
end
