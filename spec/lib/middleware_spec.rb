# frozen_string_literal: true

require 'treblle/middleware'

RSpec.describe Treblle::Middleware do
  subject { described_class.new(app, configuration: configuration) }

  let(:configuration) { instance_double(Treblle::Configuration, valid?: true, monitoring_enabled?: true) }

  before do
    skip
  end

  context 'when request is valid and treblle is configured' do
    let(:rack_env) { { "key" => "value" } }
    let(:app) { ->(_env) { ['response', {}, rack_env] } }

    it "calls the upstream rack app with the environment" do
      response = subject.call(rack_env)

      expect(response).to eq(['response', {}, rack_env])
    end

    it 'sends monitoring data to treblle' do
      expect(subject).to have_requested(:post, "/treblle.com/")
    end
  end

  context 'when exception is raised in treblle middleware' do
    it 'returns original rack response' do
    end

    it "does not monitor data to" do
    end
  end

  context 'when exception is raised in rack middleware' do
    subject { Treblle::Middleware.new(app, configuration: configuration) }

    let(:rack_env) { { "key" => "value" } }
    let(:exception) { StandardError.new("It crashed") }
    let(:app) { ->(_env) { raise exception } }

    it 'returns original rack response' do
      response = subject.call(rack_env)

      expect(response).to eq(['response', {}, rack_env])
    end

    it 're-rase exception' do
      expect { subject.call(rack_env) }.to raise_error(StandardError)
    end

    it 'sends monitoring data to treblle' do
      expect(subject).to have_requested(:post, "/treblle.com/")
    end
  end
end
