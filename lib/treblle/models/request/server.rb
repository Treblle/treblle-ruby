# frozen_string_literal: true

require "rbconfig"

module Treblle
  module Models
    class Request
      class Server
        def initialize(request)
          @request = request
          @software = get_server_software
          @protocol = get_server_protocol
          @os_architecture = get_platform
          @os_name = get_host_os
          @timezone = get_timezone
          @remote_addr = get_remote_addr
        end

        attr_reader :software, :protocol, :os_name, :os_architecture, :remote_addr, :timezone

        private

        attr_reader :request

        def get_host_os
          RbConfig::CONFIG.fetch('host_os', 'unknown')
        end

        def get_platform
          Gem::Platform.local.os
        end

        def get_remote_addr
          request.env.fetch('REMOTE_ADDR', '')
        end

        def get_server_software
          request.env.fetch('SERVER_SOFTWARE', '')
        end

        def get_server_protocol
          request.env.fetch('SERVER_PROTOCOL', '')
        end

        def get_timezone
          Time.now.zone
        end
      end
    end
  end
end
