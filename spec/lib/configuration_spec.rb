# frozen_string_literal: true

require 'rspec'
require 'treblle/configuration'
require 'rails'

RSpec.describe Treblle::Configuration do
  let(:config) { described_class.new }

  before do
    config.api_key = 'your-api-key'
    config.project_id = 'your-project-id'
    config.enabled_environments = 'development'

    allow(Rails).to receive(:env).and_return('development')
  end

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

  describe '#validate_credentials!' do
    let(:request_url) { 'http://example.com/api/' }

    context 'when api_key is not provided' do
      before { config.api_key = nil }

      it 'raises an error' do
        expect { config.validate_credentials! }.to raise_error(Treblle::Errors::MissingApiKeyError)
      end
    end

    context 'when project_id is not provided' do
      before { config.project_id = nil }

      it 'raises an error' do
        expect { config.validate_credentials! }.to raise_error(Treblle::Errors::MissingProjectIdError)
      end
    end

    context 'when both api_key and project_id are provided' do
      it 'does not raise an error' do
        expect { config.validate_credentials! }.not_to raise_error
      end
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

    context 'when whitelisted_endpoints is an array' do
      before do
        config.whitelisted_endpoints = ['/api/', '/custom_endpoint/']
      end

      it 'uses the array for @whitelisted_endpoints' do
        expect(config.whitelisted_endpoints).to eq(['/api/', '/custom_endpoint/'])
      end
    end
  end

  describe '#enabled_environments=' do
    it 'converts the value to an array' do
      subject.enabled_environments = 'production'
      expect(subject.enabled_environments).to eq(['production'])

      subject.enabled_environments = %w[staging production]
      expect(subject.enabled_environments).to eq(%w[staging production])

      subject.enabled_environments = nil
      expect(subject.enabled_environments).to eq([])
    end
  end

  describe '#enabled_environment?' do
    before do
      allow(subject).to receive(:environment).and_return('production')
    end

    context 'when enabled_environments is empty' do
      it 'returns false' do
        subject.enabled_environments = []
        expect(subject.enabled_environment?).to be_falsey
      end
    end

    context 'when environment is included in enabled_environments' do
      it 'returns true' do
        subject.enabled_environments = ['production']
        expect(subject.enabled_environment?).to be_truthy
      end
    end

    context 'when environment is not included in enabled_environments' do
      it 'returns false' do
        subject.enabled_environments = ['staging']
        expect(subject.enabled_environment?).to be_falsey
      end
    end
  end
end
