# frozen_string_literal: true

module Treblle
  module Utils
    class HashSanitizer
      class << self
        def sanitize(body, sensitive_attrs)
          return {} if body.nil? || body.empty?
          return hash unless body.is_a?(Hash) || body.is_a?(Array)

          if body.is_a?(Hash)
            sanitize_hash(body, sensitive_attrs)
          elsif body.is_a?(Array)
            sanitize_array(body, sensitive_attrs)
          end
        end

        private

        def sanitize_hash(hash, sensitive_attrs)
          hash.each_with_object({}) do |(key, value), result|
            result[key] = if value.is_a?(Hash) || value.is_a?(Array)
                            sanitize(value, sensitive_attrs)
                          else
                            sanitize_value(key, value, sensitive_attrs)
                          end
          end
        end

        def sanitize_array(array, sensitive_attrs)
          array.map { |item| sanitize(item, sensitive_attrs) }
        end

        def sanitize_value(key, value, sensitive_attrs)
          sensitive_attrs.include?(key.to_s) ? "*****" : value
        end
      end
    end
  end
end
