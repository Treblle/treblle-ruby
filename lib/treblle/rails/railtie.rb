require 'rails'
require 'treblle/rails/capture_exceptions'

module Treblle
  module Rails
    class TreblleRailtie < ::Rails::Railtie
      initializer 'treblle_railtie.configure_rails_initialization' do |app|
        Rails.logger.debug("debug::" + "TEST #{app.inspect}")
        app.config.middleware.insert_after ActionDispatch::ShowExceptions, Treblle::Rails::CaptureExceptions
      end
    end
  end
end
