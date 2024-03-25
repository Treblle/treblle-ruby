require 'rails'
require 'treblle/rails/railtie'

RSpec.describe Treblle::Rails::Railtie do
  describe 'initializer' do
    let(:app) { double('app', config: config) }
    let(:config) { double('config', middleware: middleware) }
    let(:middleware) { double('middleware') }

    it 'inserts Treblle::Rails::CaptureExceptions middleware after ActionDispatch::ShowExceptions' do
      expect(middleware).to receive(:insert_after).with(ActionDispatch::ShowExceptions, Treblle::Middleware)
      described_class.initializers.find do |initializer|
        initializer.name == 'treblle.install_middleware'
      end.block.call(app)
    end
  end
end
