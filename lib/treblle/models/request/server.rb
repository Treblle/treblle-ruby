# frozen_string_literal: true

require "rbconfig"

module Treblle
  module Models
    class Request
      class Server
        def initialize(request)
          @software = request.server_software
          @protocol = request.server_protocol
          @os_architecture = get_platform
          @os_name = get_host_os
          @timezone = get_timezone
          @remote_addr = get_remote_addr(request)
        end

        attr_reader :software, :protocol, :os_name, :os_architecture, :remote_addr, :timezone

        private

        def get_host_os
          RbConfig::CONFIG.fetch('host_os', 'unknown')
        end

        def get_platform
          Gem::Platform.local.os
        end

        def get_remote_addr(request)
          request.env.fetch('REMOTE_ADDR', '')
        end

        def get_timezone
          Time.now.zone
        end
      end
    end
  end
end
