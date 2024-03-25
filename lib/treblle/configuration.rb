# frozen_string_literal: true

require_relative 'errors/configuration_errors'

module Treblle
  class Configuration
    DEFAULT_SENSITIVE_ATTRS = %w[
      card_number
      cardNumber
      cc
      ccv
      credit_score
      creditScore
      password
      password_confirmation
      passwordConfirmation
      pwd
      secretn
      ssn
    ].freeze

    attr_accessor :restricted_endpoints, :whitelisted_endpoints,
      :api_key, :project_id, :app_version
    attr_reader :sensitive_attrs, :enabled_environments

    def initialize
      @restricted_endpoints = []
      @whitelisted_endpoints = '/api/'
      @app_version = nil
      @sensitive_attrs = DEFAULT_SENSITIVE_ATTRS
    end

    def monitoring_enabled?(request_url)
      whitelisted_endpoint?(request_url) && !restricted_endpoint?(request_url)
    end

    def sensitive_attrs=(attributes)
      @sensitive_attrs = attributes ? DEFAULT_SENSITIVE_ATTRS + attributes : DEFAULT_SENSITIVE_ATTRS
    end

    def enabled_environments=(value)
      @enabled_environments = Array(value)
    end

    def enabled_environment?
      return false if enabled_environments.empty?

      enabled_environments.include?(environment)
    end

    def validate_credentials!
      raise Errors::MissingApiKeyError if api_key.to_s.empty?
      raise Errors::MissingProjectIdError if project_id.to_s.empty?
    end

    private

    def environment
      @environment || ::Rails.env
    end

    def whitelisted_endpoint?(request_url)
      Array(whitelisted_endpoints).any? do |endpoint|
        request_url.start_with?(endpoint)
      end
    end

    def restricted_endpoint?(request_url)
      restricted_endpoints.any? do |endpoint|
        pattern = Regexp.escape(endpoint).gsub('\*', '.*')
        Regexp.new("^#{pattern}$") =~ request_url
      end
    end
  end
end
