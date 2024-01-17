require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/interfaces/response'

describe Treblle::Interfaces::Response do
  describe '#initialize' do
    it 'initializes with valid response data' do
      response_data = [200, { 'Content-Type' => 'application/json' }, {}]
      response = Treblle::Interfaces::Response.new(response_data)

      assert_equal 200, response.status
      assert_equal({ 'Content-Type' => 'application/json' }, response.headers)
      assert_equal({}, response.body)
      assert_equal 2, response.size
    end

    it 'handles invalid JSON in response body' do
      response_data = [500, { 'Content-Type' => 'application/json' }, 'invalid_json']
      response = Treblle::Interfaces::Response.new(response_data)

      assert_equal 500, response.status
      assert_equal({ 'Content-Type' => 'application/json' }, response.headers)
      assert_equal({}, response.body)
      assert_equal 2, response.size
    end
  end
end
