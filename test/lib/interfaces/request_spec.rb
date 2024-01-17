require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/interfaces/request'

describe Treblle::Interfaces::Request do
  describe '#initialize' do
    it 'initializes with valid environment data' do
      env = {
        'PATH_INFO' => '/api/some_endpoint',
        'SERVER_PROTOCOL' => 'HTTP/1.1',
        'HTTP_AUTHORIZATION' => 'Bearer token',
        'rack.input' => StringIO.new
      }
      request = Treblle::Interfaces::Request.new(env)

      assert_equal({ 'PATH-INFO' => '/api/some_endpoint',
                     'SERVER-PROTOCOL' => 'HTTP/1.1',
                     'AUTHORIZATION' => 'Bearer token' }, request.headers)
      assert_equal({}, request.body)
    end
  end

  describe '#header_to_include?' do
    let(:env) do
      {
        'PATH_INFO' => '/api/some_endpoint',
        'SERVER_PROTOCOL' => 'HTTP/1.1',
        'HTTP_AUTHORIZATION' => 'Bearer token',
        'rack.input' => StringIO.new
      }
    end
    let(:request) { Treblle::Interfaces::Request.new(env) }

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
end
