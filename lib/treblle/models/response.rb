# frozen_string_literal: true

module Treblle
  module Models
    class Response
      attr_accessor :status, :headers, :body, :size, :exception
    end
  end
end
