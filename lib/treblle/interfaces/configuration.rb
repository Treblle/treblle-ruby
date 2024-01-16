# frozen_string_literal: true

module Treblle
  module Interfaces
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

      attr_accessor :restricted_endpoints, :api_key, :project_id, :app_version
      attr_reader :sensitive_attrs

      def initialize
        @restricted_endpoints = []
        @sensitive_attrs = DEFAULT_SENSITIVE_ATTRS
        @app_version = nil
      end

      def valid?
        api_key.present? && project_id.present?
      end

      def monitoring_enabled?(request_url)
        valid? && !restricted_endpoint?(request_url) && request_url.start_with?('/api/')
      end

      def sensitive_attrs=(value)
        self.sensitive_attrs = DEFAULT_SENSITIVE_ATTRS + value
      end

      private

      def restricted_endpoint?(request_url)
        @restricted_endpoints.any? do |endpoint|
          pattern = Regexp.escape(endpoint).gsub('\*', '.*')
          Regexp.new("^#{pattern}$") =~ request_url
        end
      end
    end
  end
end
