# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/interfaces/configuration'

describe Treblle::Interfaces::Configuration do
  let(:config) { Treblle::Interfaces::Configuration.new }

  describe '#valid?' do
    it 'returns true when both api_key and project_id are present' do
      config.api_key = 'your_api_key'
      config.project_id = 'your_project_id'

      assert config.valid?
    end

    it 'returns false when api_key is missing' do
      config.project_id = 'your_project_id'

      refute config.valid?
    end

    it 'returns false when project_id is missing' do
      config.api_key = 'your_api_key'

      refute config.valid?
    end
  end

  describe '#monitoring_enabled?' do
    before do
      config.api_key = 'your_api_key'
      config.project_id = 'your_project_id'
    end

    it 'returns true for a valid request_url' do
      request_url = '/api/some_endpoint'

      assert config.monitoring_enabled?(request_url)
    end

    it 'returns false for an invalid request_url' do
      request_url = '/non_api/some_endpoint'

      refute config.monitoring_enabled?(request_url)
    end

    it 'returns false when api_key is missing' do
      config.api_key = nil
      request_url = '/api/some_endpoint'

      refute config.monitoring_enabled?(request_url)
    end

    it 'returns false when project_id is missing' do
      config.project_id = nil
      request_url = '/api/some_endpoint'

      refute config.monitoring_enabled?(request_url)
    end
  end

  describe '#sensitive_attrs=' do
    it 'appends additional sensitive attributes to the default list' do
      default_sensitive_attrs = Treblle::Interfaces::Configuration::DEFAULT_SENSITIVE_ATTRS
      additional_attrs = %w[custom_attr1 custom_attr2]
      config.sensitive_attrs = additional_attrs

      assert_equal default_sensitive_attrs + additional_attrs, config.sensitive_attrs
    end
  end

  describe '#restricted_endpoint?' do
    it 'returns true for a restricted endpoint' do
      config.restricted_endpoints = ['/restricted/endpoint']

      assert config.send(:restricted_endpoint?, '/restricted/endpoint')
    end

    it 'returns false for a non-restricted endpoint' do
      config.restricted_endpoints = ['/restricted/endpoint']

      refute config.send(:restricted_endpoint?, '/non_restricted/endpoint')
    end

    it 'returns true for a restricted group of endpoints' do
      config.restricted_endpoints = ['/restricted/*']

      assert config.send(:restricted_endpoint?, '/restricted/endpoint')
    end

    it 'returns false if restricted endpoints are empty' do
      refute config.send(:restricted_endpoint?, '/restricted/endpoint')
    end
  end
end
