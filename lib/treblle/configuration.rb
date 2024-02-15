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

    attr_accessor :restricted_endpoints, :whitelisted_endpoints, :enabled_environments,
      :api_key, :project_id, :app_version
    attr_reader :sensitive_attrs

    def initialize(api_key: nil, project_id: nil)
      @restricted_endpoints = []
      @whitelisted_endpoints = '/api/'
      @enabled_environments = ['production']
      @app_version = nil
      @api_key = api_key
      @project_id = project_id
      @sensitive_attrs = DEFAULT_SENSITIVE_ATTRS

      return unless enabled_environment?

      raise Errors::MissingApiKeyError if api_key.to_s.empty?
      raise Errors::MissingProjectIdError if project_id.to_s.empty?
    end

    def monitoring_enabled?(request_url)
      whitelisted_endpoint?(request_url) && !restricted_endpoint?(request_url)
    end

    def sensitive_attrs=(attributes)
      @sensitive_attrs = attributes ? DEFAULT_SENSITIVE_ATTRS + attributes : DEFAULT_SENSITIVE_ATTRS
    end

    private

    def whitelisted_endpoint?(request_url)
      Array(whitelisted_endpoints).any? do |endpoint|
        request_url.start_with?(endpoint)
      end
    end

    def enabled_environment?
      enabled_environments.map(&:downcase).include?(Rails.env)
    end

    def restricted_endpoint?(request_url)
      restricted_endpoints.any? do |endpoint|
        pattern = Regexp.escape(endpoint).gsub('\*', '.*')
        Regexp.new("^#{pattern}$") =~ request_url
      end
    end
  end
end
