# frozen_string_literal: true

require 'rspec'
require 'treblle/version'

RSpec.describe Treblle do
  describe 'version' do
    it 'is a version string' do
      expect(Treblle::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end

  describe 'API version' do
    it 'is a version string' do
      expect(Treblle::API_VERSION).to match(/\d+\.\d+/)
    end
  end
end
