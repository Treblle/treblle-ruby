require 'minitest/autorun'
require 'minitest/spec'
require 'treblle/interfaces/request'

describe Treblle::Interfaces::Request do
  let(:path) { '/api/some_endpoint' }
  let(:env) { Rack::MockRequest.env_for(path, { 'RAW_POST_DATA' => 'true' }) }
  let(:request) { Treblle::Interfaces::Request.new(env) }

  describe '#initialize' do
    it 'stores form data' do
      skip
      env.merge!('REQUEST_METHOD' => 'POST', ::Rack::RACK_INPUT => StringIO.new('data=catch me'))

      assert_equal Hash['data', 'catch me'], request.body
    end

    it 'stores request body' do
      skip
      env.merge!(::Rack::RACK_INPUT => StringIO.new('catch me'))

      assert_equal 'catch me', request.body
    end

    it 'stores path info' do
      assert_equal path, request.headers['PATH-INFO']
    end

    it 'stores Authorization header' do
      env.merge!('HTTP_AUTHORIZATION' => 'Bearer token')

      assert_equal 'Bearer token', request.headers['AUTHORIZATION']
    end

    it 'stores Authorization header' do
      env.merge!('X_REQUEST_ID' => '12345678')

      assert_equal '12345678', request.headers['X-REQUEST-ID']
    end

    it "doesn't remove ip address headers" do
      ip = '1.1.1.1'

      env.merge!(
        'REMOTE_ADDR' => ip,
        'HTTP_CLIENT_IP' => ip,
        'HTTP_X_REAL_IP' => ip,
        'HTTP_X_FORWARDED_FOR' => ip
      )
      assert_includes request.headers.keys, 'REMOTE-ADDR'
      assert_includes request.headers.keys, 'CLIENT-IP'
      assert_includes request.headers.keys, 'X-REAL-IP'
      assert_includes request.headers.keys, 'X-FORWARDED-FOR'
    end
  end

  describe '#header_to_include?' do
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
