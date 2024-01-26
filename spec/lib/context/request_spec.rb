# frozen_string_literal: true

require 'rspec'
require 'treblle/context/request'

RSpec.describe Treblle::Context::Request do
  context 'GET request' do
    subject { described_class.new(env) }

    let(:path) { '/api/some_endpoint' }
    let(:query_params) { { 'thing' => '123' } }
    let(:env) do
      Rack::MockRequest.env_for(path, {
        method: 'GET',
        params: query_params,
        'QUERY_STRING' => Rack::Utils.build_query(query_params)
      })
    end

    it 'stores request query' do
      expect(subject.headers["QUERY-STRING"]).to eq("thing=123")
    end
  end

  context 'POST request' do
    subject { described_class }

    let(:method) { 'POST' }

    context 'with form body' do
      it 'includes body' do
        env = Rack::MockRequest.env_for(
          '/',
          method: method,
          params: { thing: 123 }
        )

        result = subject.new(env)

        expect(result.body).to eq('thing' => '123')
      end
    end

    context 'with binary body' do
      it 'includes form data' do
        Tempfile.open('test', encoding: 'binary') do |f|
          f.write('0123456789' * 1024 * 1024)
          f.rewind

          env = Rack::MockRequest.env_for(
            '/',
            method: method,
            params: {
              file: Rack::Multipart::UploadedFile.new(f.path, 'binary')
            }
          )

          result = subject.new(env)

          expect(result.body['file'].headers).to match(/content-disposition: form-data/)
          expect(result.body['file'].headers).to match(/content-type: binary/)
          expect(result.body['file'].headers).to match(/content-length: 10485760/)
        end
      end

      context 'with JSON body' do
        it 'includes body in utf-8' do
          env = Rack::MockRequest.env_for(
            '/',
            'CONTENT_TYPE' => 'application/json',
            input: { something: 'everything' }.to_json
          )

          result = subject.new(env)

          expect(result.body).to eq '{"something":"everything"}'
          expect(result.body.encoding).to eq Encoding::UTF_8
          expect(result.body.valid_encoding?).to be true
        end
      end
    end
  end

  context 'stores request headers' do
    subject { described_class.new(env) }

    let(:path) { '/api/some_endpoint' }
    let(:env) { Rack::MockRequest.env_for(path, {}) }

    it 'stores path info' do
      expect(subject.headers['PATH-INFO']).to eq(path)
    end

    it 'stores Authorization header' do
      env.merge!('HTTP_AUTHORIZATION' => 'Bearer token')

      expect(subject.headers['AUTHORIZATION']).to eq('Bearer token')
    end

    it 'stores Authorization header' do
      env.merge!('X_REQUEST_ID' => '12345678')

      expect(subject.headers['X-REQUEST-ID']).to eq('12345678')
    end

    it "doesn't remove ip address headers" do
      ip = '1.1.1.1'

      env.merge!(
        'REMOTE_ADDR' => ip,
        'HTTP_CLIENT_IP' => ip,
        'HTTP_X_REAL_IP' => ip,
        'HTTP_X_FORWARDED_FOR' => ip
      )
      expect(subject.headers.keys).to include('REMOTE-ADDR', 'CLIENT-IP', 'X-REAL-IP', 'X-FORWARDED-FOR')
    end
  end

  context 'header manipulation' do
    subject { described_class.new(env) }

    let(:path) { '/api/some_endpoint' }
    let(:env) { Rack::MockRequest.env_for(path, {}) }

    context '#normalize_header' do
      it 'replaces _ with - and removes HTTP_ prefix' do
        expect(subject.send(:normalize_header, 'HTTP_ACCEPT_LANGUAGE')).to include('ACCEPT-LANGUAGE')
      end
    end

    context '#request_headers' do
      it 'returns a hash of headers' do
        env.merge!('HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.9')

        expect(subject.send(:request_headers)).to include({ 'ACCEPT-LANGUAGE' => 'en-US,en;q=0.9' })
      end
    end

    context '#header_to_include?' do
      it 'returns true for headers with valid prefixes' do
        valid_headers = %w[HTTP_ACCEPT HTTP_AUTHORIZATION QUERY_STRING CONTENT_TYPE REQUEST_METHOD SERVER_NAME
                           SERVER_SOFTWARE HTTP_USER_AGENT]

        valid_headers.each do |header|
          expect(subject.send(:header_to_include?, header)).to be true
        end
      end

      it 'returns false for headers with invalid prefixes' do
        invalid_headers = %w[rack.header puma.test INVLADI_HEADER]

        invalid_headers.each do |header|
          expect(subject.send(:header_to_include?, header)).to be false
        end
      end
    end
  end
end
