# frozen_string_literal: true

module Treblle
  module Models
    class Response
      class Exception
        def initialize(response)
          @response = response
          @trace = fetch_trace
          @type = fetch_type
          @message = fetch_message
          @file_path, @line_number = get_exception_path_and_line
        end

        attr_reader :file_path, :line_number, :message, :type, :trace

        private

        attr_reader :response

        def fetch_trace
          response.body.dig("traces", "Application Trace")&.first&.[]("trace")
        end

        def fetch_type
          response.body["error"] || response.body["errors"] || 'Unhandled error'
        end

        def fetch_message
          response.body["exception"] || response.body["error"] || response.body["errors"]
        end

        def get_exception_path_and_line
          return [nil, nil] if trace.nil?

          match_data = trace.match(/^(.*):(\d+):in `.*'$/)
          return [nil, nil] if match_data.nil?

          file_path = match_data[1]
          line_number = match_data[2]

          [file_path, line_number]
        end
      end
    end
  end
end
