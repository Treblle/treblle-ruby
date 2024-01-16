require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/interfaces/request'

describe Treblle::Interfaces::Request do
  describe '#initialize' do
    it 'initializes with valid environment data' do
      env = {
        'HTTP_ACCEPT' => 'application/json',
        'REQUEST_METHOD' => 'GET',
        'rack.input' => '{"key": "value"}'
      }
      request = Treblle::Interfaces::Request.new(env)

      assert_equal({ 'Accept' => 'application/json' }, request.headers)
      assert_equal({ 'key' => 'value' }, request.body)
    end

    it 'handles invalid JSON in request body' do
      env = {
        'HTTP_ACCEPT' => 'application/json',
        'REQUEST_METHOD' => 'GET',
        'rack.input' => '{"key": "value"}'
      }
      request = Treblle::Interfaces::Request.new(env)

      assert_equal({ 'Accept' => 'application/json' }, request.headers)
      assert_equal({}, request.body)
    end
  end

  describe '#header_to_include?' do
    let(:request) { Treblle::Interfaces::Request.new({}) }

    it 'returns true for headers with valid prefixes' do
      valid_headers = %w[HTTP_ACCEPT HTTP_AUTHORIZATION QUERY_STRING CONTENT_TYPE REQUEST_METHOD SERVER_NAME
                         SERVER_SOFTWARE HTTP_USER_AGENT]

      valid_headers.each do |header|
        assert request.send(:header_to_include?, header)
      end
    end

    it 'returns false for headers with invalid prefixes' do
      invalid_headers = %w[rack.header puma.test INVLADI_HEADER]

      invalid_headers.each do |header|
        refute request.send(:header_to_include?, header)
      end
    end
  end

  describe '#normalize_header' do
    it 'correctly normalizes headers' do
      request = Treblle::Interfaces::Request.new({})
      test_cases = {
        'HTTP_ACCEPT_LANGUAGE' => 'Accept-Language',
        'AUTHORIZATION' => 'Authorization',
        'X_CUSTOM_HEADER' => 'X-Custom-Header'
      }

      test_cases.each do |input, expected_output|
        assert_equal expected_output, request.send(:normalize_header, input)
      end
    end
  end

  describe '#request_headers' do
    it 'correctly extracts and normalizes request headers' do
      env = {
        'HTTP_ACCEPT_LANGUAGE' => 'en-US',
        'AUTHORIZATION' => 'Bearer token',
        'QUERY_STRING' => 'param=value',
        'rack.input' => StringIO.new('{"key": "value"}')
      }
      request = Treblle::Interfaces::Request.new(env)

      assert_equal({
                     'Accept-Language' => 'en-US',
                     'Authorization' => 'Bearer token',
                     'Query-String' => 'param=value'
                   }, request.send(:request_headers))
    end
  end
end
