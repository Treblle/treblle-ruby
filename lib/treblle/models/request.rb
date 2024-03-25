# frozen_string_literal: true

module Treblle
  module Models
    class Request
      attr_accessor :server, :client, :method, :headers, :body
    end
  end
end
