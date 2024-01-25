# frozen_string_literal: true

require 'json'
require 'active_support/json'

module Treblle
  module Interfaces
    class Response
      def initialize(response)
        @status, @headers, @response = response || [500, {}, {}]
        @body = parse_response_body
        @size = response_size
      end

      attr_reader :status, :headers, :response, :body, :size

      private

      def response_size
        ActiveSupport::JSON.encode(body).size
      end

      def parse_response_body
        JSON.parse(response.body)
      rescue JSON::ParserError, NoMethodError
        {}
      end
    end
  end
end
