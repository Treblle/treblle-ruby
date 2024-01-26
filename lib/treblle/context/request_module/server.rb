# frozen_string_literal: true

require "rbconfig"

module Treblle
  module Context
    module RequestModule
      class Server
        def initialize(request)
          @software = request.server_software
          @protocol = request.server_protocol
          @os_name = RbConfig::CONFIG['host_os']
          @os_architecture = RUBY_PLATFORM
          @remote_addr = request.env['REMOTE_ADDR']
        end

        attr_reader :software, :protocol, :os_name, :os_architecture, :remote_addr
      end
    end
  end
end
