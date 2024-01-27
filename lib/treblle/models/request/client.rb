# frozen_string_literal: true

module Treblle
  module Models
    class Request
      class Client
        def initialize(request)
          @ip = request.ip
          @url = request.original_url
          @user_agent = request.user_agent
        end

        attr_reader :ip, :url, :user_agent
      end
    end
  end
end
