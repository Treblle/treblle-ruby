# frozen_string_literal: true

require 'treblle/models/response'
require 'active_support'
require 'json'

module Treblle
  class ResponseBuilder
    def initialize(rack_response)
      @rack_response = rack_response
    end

    def build
      Models::Response.new.tap do |response|
        apply_to_response(response)
      end
    end

    private

    attr_reader :rack_response

    def apply_to_response(response)
      status, headers, response_data = rack_response || [500, [], nil]

      response.status = status
      response.headers = headers
      response.body = parse_body(response_data)
      response.size = calculate_size(response.body)
      response
    end

    def calculate_size(body)
      body ? ActiveSupport::JSON.encode(body).size : 0
    end

    def parse_body(response_data)
      response_data ? JSON.parse(response_data.body) : nil
    end
  end
end
