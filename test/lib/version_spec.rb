# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/version'

describe Treblle do
  describe 'version' do
    it 'is a version string' do
      Treblle::VERSION.must_match(/\d+\.\d+\.\d+/)
    end
  end
end
