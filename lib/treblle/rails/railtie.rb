require 'treblle/middleware'
require 'rails'

module Treblle
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'treblle.install_middleware' do |app|
        app.config.middleware.insert_after ActionDispatch::ShowExceptions, Treblle::Middleware
      end
    end
  end
end
