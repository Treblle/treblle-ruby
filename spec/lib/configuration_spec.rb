# frozen_string_literal: true

require 'rspec'
require 'treblle/configuration'
require 'rails'

RSpec.describe Treblle::Configuration do
  describe '.configuration' do
    it 'returns a Treblle::Configuration instance' do
      expect(Treblle.configuration).to be_an_instance_of(Treblle::Configuration)
    end
  end

  describe '.configure' do
    it 'yields the configuration block' do
      Treblle.configure do |config|
        expect(config).to be_an_instance_of(Treblle::Configuration)
      end
    end

    it 'configures Treblle with provided values' do
      Treblle.configure do |config|
        config.api_key = 'your_api_key'
        config.project_id = 'your_project_id'
        config.enabled_environments = %w[production staging]
        config.whitelisted_endpoints = '/api/'
      end

      expect(Treblle.configuration.api_key).to eq('your_api_key')
      expect(Treblle.configuration.project_id).to eq('your_project_id')
      expect(Treblle.configuration.enabled_environments).to eq(%w[production staging])
      expect(Treblle.configuration.whitelisted_endpoints).to eq('/api/')
    end
  end

  subject(:config) { described_class.new(api_key: api_key, project_id: project_id) }
  let(:api_key) { 'your_api_key' }
  let(:project_id) { 'your_project_id' }

  context '#monitoring_enabled?' do
    subject { config.monitoring_enabled?(request_url) }

    context 'when request_url is valid' do
      let(:request_url) { '/api/some_endpoint' }

      it { is_expected.to be true }
    end

    context 'when request_url is invalid' do
      let(:request_url) { '/non_api/some_endpoint' }

      it { is_expected.to be false }
    end
  end

  context '#sensitive_attrs' do
    subject { config.sensitive_attrs }

    it { is_expected.to eq(Treblle::Configuration::DEFAULT_SENSITIVE_ATTRS) }

    context 'when sensitive_attrs are set' do
      let(:sensitive_attrs) { %w[custom_attr1 custom_attr2] }

      before { config.sensitive_attrs = sensitive_attrs }

      it { is_expected.to eq(Treblle::Configuration::DEFAULT_SENSITIVE_ATTRS + sensitive_attrs) }
    end
  end

  context '#restricted_endpoints' do
    subject { config.restricted_endpoints }

    it { is_expected.to eq([]) }

    context 'when restricted_endpoints are set' do
      let(:restricted_endpoints) { ['/restricted/endpoint'] }

      before { config.restricted_endpoints = restricted_endpoints }

      it { is_expected.to eq(restricted_endpoints) }
    end
  end

  context '#restricted_endpoint?' do
    subject { config.send(:restricted_endpoint?, request_url) }
    let(:restricted_endpoints) { ['/restricted/endpoint'] }

    before { config.restricted_endpoints = restricted_endpoints }

    context 'when request_url is restricted' do
      let(:request_url) { '/restricted/endpoint' }

      it { is_expected.to be true }
    end

    context 'when request_url is not restricted' do
      let(:request_url) { '/non_restricted/endpoint' }

      it { is_expected.to be false }
    end

    context 'when restricted_endpoints are empty' do
      let(:restricted_endpoints) { [] }
      let(:request_url) { '/restricted/endpoint' }

      it { is_expected.to be false }
    end
  end

  describe 'overriding @whitelisted_endpoints' do
    before do
      config.whitelisted_endpoints = '/custom_endpoint/'
    end

    it 'uses the new value for @whitelisted_endpoints' do
      expect(config.whitelisted_endpoints).to eq('/custom_endpoint/')
    end

    describe 'when whitelisted_endpoints is an array' do
      before do
        config.whitelisted_endpoints = ['/api/', '/custom_endpoint/']
      end

      it 'uses the array for @whitelisted_endpoints' do
        expect(config.whitelisted_endpoints).to eq(['/api/', '/custom_endpoint/'])
      end
    end
  end

  context '#enabled_environment?' do
    subject { config.send(:enabled_environment?) }

    before do
      allow(Rails).to receive(:env).and_return('production')
    end

    context 'when enabled_environments is not set' do
      context 'when Rails.env is production by default' do
        it { is_expected.to be true }
      end
    end

    context 'when enabled_environments is set' do
      before do
        config.enabled_environments = enabled_environments
      end

      context 'when Rails.env is included in enabled_environments' do
        let(:enabled_environments) { %w[production development] }

        it { is_expected.to be true }
      end

      context 'when Rails.env is not included in enabled_environments' do
        let(:enabled_environments) { %w[staging development] }

        it { is_expected.to be false }
      end

      context 'when enabled_environments is empty' do
        let(:enabled_environments) { [] }

        it { is_expected.to be false }
      end

      context 'when enabled_environments includes Rails.env in a case-insensitive manner' do
        let(:enabled_environments) { %w[Production Staging] }

        it { is_expected.to be true }
      end
    end
  end
end
