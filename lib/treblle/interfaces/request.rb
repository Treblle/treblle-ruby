# frozen_string_literal: true

module Treblle
  module Interfaces
    class Request
      HEADER_PREFIXES = %w[HTTP AUTHORIZATION QUERY CONTENT REMOTE REQUEST SERVER ACCEPT USER HOST X].freeze

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
        header.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
      end

      def header_to_include?(header)
        return false if header.starts_with?('rack', 'puma')

        HEADER_PREFIXES.any? do |prefix|
          header.to_s.start_with?(prefix)
        end
      end

      def parse_request_body
        JSON.parse(metadata.raw_post)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
