require 'rails'
require 'treblle/rails/railtie'

RSpec.describe Treblle::Rails::Railtie do
  describe 'initializer' do
    let(:app) { double('app', config: config) }
    let(:config) { double('config', middleware: middleware) }
    let(:middleware) { double('middleware') }

    it 'inserts Treblle::Rails::CaptureExceptions middleware after ActionDispatch::ShowExceptions' do
      expect(middleware).to receive(:insert_before).with(ActionDispatch::ShowExceptions,
        Treblle::Rails::CaptureExceptions)
      described_class.initializers.find do |initializer|
        initializer.name == 'treblle.install_middleware'
      end.block.call(app)
    end
  end
end
