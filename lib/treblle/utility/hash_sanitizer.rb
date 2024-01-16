# frozen_string_literal: true

module Treblle
  module Utility
    class HashSanitizer
      class << self
        def sanitize(hash, sensitive_attrs)
          return {} unless hash.present?

          hash.each do |k, v|
            value = v || k
            if value.is_a?(Hash) || value.is_a?(Array)
              sanitize(value, sensitive_attrs)
            elsif sensitive_attrs.include?(k.to_s)
              hash[k] = '*' * v.to_s.length
            end
          end
          hash
        end
      end
    end
  end
end
