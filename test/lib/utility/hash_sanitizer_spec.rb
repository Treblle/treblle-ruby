# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/utility/hash_sanitizer'

describe Treblle::Utility::HashSanitizer do
  describe '.sanitize' do
    let(:sensitive_attributes) { %w[password credit_card] }

    it 'returns an empty hash when given an empty hash' do
      result = Treblle::Utility::HashSanitizer.sanitize({}, sensitive_attributes)
      assert_equal({}, result)
    end

    it 'does not modify a hash without sensitive attributes' do
      input_hash = { name: 'John', age: 30 }
      result = Treblle::Utility::HashSanitizer.sanitize(input_hash, sensitive_attributes)
      assert_equal input_hash, result
    end

    it 'replaces sensitive attribute values with asterisks' do
      input_hash = { name: 'John', password: 'secretpassword', credit_card: '1234567890123456' }
      expected_result = { name: 'John', password: '**************', credit_card: '****************' }
      result = Treblle::Utility::HashSanitizer.sanitize(input_hash, sensitive_attributes)
      assert_equal expected_result, result
    end

    it 'handles nested hashes' do
      input_hash = { user: { name: 'John', password: 'secretpassword' } }
      expected_result = { user: { name: 'John', password: '**************' } }
      result = Treblle::Utility::HashSanitizer.sanitize(input_hash, sensitive_attributes)
      assert_equal expected_result, result
    end

    it 'handles arrays of hashes' do
      input_hash = [{ name: 'John', password: 'secretpassword' }, { name: 'Jane', password: 'anotherpassword' }]
      expected_result = [{ name: 'John', password: '**************' }, { name: 'Jane', password: '***************' }]
      result = Treblle::Utility::HashSanitizer.sanitize(input_hash, sensitive_attributes)
      assert_equal expected_result, result
    end
  end
end