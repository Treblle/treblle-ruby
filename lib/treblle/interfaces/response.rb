module Treblle
  module Interfaces
    class Response
      def initialize(response)
        @status, @headers, @response = response
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
      rescue JSON::ParserError
        {}
      end
    end
  end
end
