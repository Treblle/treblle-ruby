require 'rails'
require 'treblle/rails/capture_exceptions'

module Treblle
  module Init
    module Rails
      class Railtie < ::Rails::Railtie
        initializer 'treblle.install_middleware' do |app|
          app.config.middleware.insert_after ActionDispatch::ShowExceptions, Treblle::Rails::CaptureExceptions
        end
      end
    end
  end
end
