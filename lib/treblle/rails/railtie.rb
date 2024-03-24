require 'treblle/rails/capture_exceptions'
require 'rails'

module Treblle
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'treblle.install_middleware' do |app|
        app.config.middleware.insert_before ActionDispatch::ShowExceptions, Treblle::Rails::CaptureExceptions
      end
    end
  end
end
