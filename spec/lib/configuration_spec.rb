# frozen_string_literal: true

require 'rspec'
require 'treblle/configuration'

RSpec.describe Treblle::Configuration do
  subject(:config) { described_class.new(api_key: api_key, project_id: project_id) }
  let(:api_key) { nil }
  let(:project_id) { nil }

  context '#valid?' do
    subject { config.valid? }

    context 'when api_key and project_id are present' do
      let(:api_key) { 'your_api_key' }
      let(:project_id) { 'your_project_id' }

      it { is_expected.to be true }
    end

    context 'when api_key is missing' do
      let(:project_id) { 'your_project_id' }

      it { is_expected.to be false }
    end

    context 'when project_id is missing' do
      let(:api_key) { 'your_api_key' }

      it { is_expected.to be false }
    end
  end

  context '#monitoring_enabled?' do
    subject { config.monitoring_enabled?(request_url) }
    let(:api_key) { 'your_api_key' }
    let(:project_id) { 'your_project_id' }

    context 'when request_url is valid' do
      let(:request_url) { '/api/some_endpoint' }

      it { is_expected.to be true }
    end

    context 'when request_url is invalid' do
      let(:request_url) { '/non_api/some_endpoint' }

      it { is_expected.to be false }
    end

    context 'when api_key is missing' do
      let(:request_url) { '/api/some_endpoint' }
      let(:api_key) { '' }

      it { is_expected.to be false }
    end

    context 'when project_id is missing' do
      let(:request_url) { '/api/some_endpoint' }
      let(:project_id) { '' }

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
end
