# frozen_string_literal: true

require 'rspec'
require 'treblle/utils/hash_sanitizer'

RSpec.describe Treblle::Utils::HashSanitizer do
  subject { described_class.sanitize(input_hash, sensitive_attributes) }
  let(:sensitive_attributes) { %w[password credit_card] }

  context 'when given hash is nil' do
    let(:input_hash) { nil }

    it 'returns an empty hash' do
      expect(subject).to eq({})
    end
  end

  context 'when given an empty hash' do
    let(:input_hash) { {} }

    it 'returns an empty hash' do
      expect(subject).to eq({})
    end
  end

  context 'when given a hash without sensitive attributes' do
    let(:input_hash) { { name: 'John', age: 30 } }

    it 'does not modify the hash' do
      expect(subject).to eq(input_hash)
    end
  end

  context 'when given a hash with sensitive attributes' do
    let(:input_hash) { { name: 'John', password: 'secretpassword', credit_card: '1234567890123456' } }
    let(:expected_subject) { { name: 'John', password: '*****', credit_card: '*****' } }

    it 'replaces sensitive attribute values with asterisks' do
      expect(subject).to eq(expected_subject)
    end
  end

  context 'when given a hash with nested hashes' do
    let(:input_hash) { { user: { name: 'John', password: 'secretpassword' } } }
    let(:expected_subject) { { user: { name: 'John', password: '*****' } } }

    it 'replaces sensitive attribute values with asterisks' do
      expect(subject).to eq(expected_subject)
    end
  end

  context 'when given a hash with nested arrays' do
    let(:input_hash) do
      { users: [{ name: 'John', password: 'secretpassword' }, { name: 'Jane', password: 'anotherpassword' }] }
    end
    let(:expected_subject) do
      { users: [{ name: 'John', password: '*****' }, { name: 'Jane', password: '*****' }] }
    end

    it 'replaces sensitive attribute values with asterisks' do
      expect(subject).to eq(expected_subject)
    end
  end
end
