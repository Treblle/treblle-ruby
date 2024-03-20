# frozen_string_literal: true

module Treblle
  module Utils
    class HashSanitizer
      class << self
        def sanitize(hash, sensitive_attrs)
          return {} if hash.nil? || hash.empty?
          return hash unless hash.is_a?(Hash) || hash.is_a?(Array)

          hash.each_with_object({}) do |(key, value), result|
            result[key] = if value.is_a?(Hash) || value.is_a?(Array)
                            sanitize_hash(value, sensitive_attrs)
                          else
                            sensitive_attrs.include?(key.to_s) ? '*' * value.to_s.length : value
                          end
          end
        end
      end
    end
  end
end
