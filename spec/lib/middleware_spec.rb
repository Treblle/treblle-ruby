require 'rspec'
require 'treblle/middleware'
require 'treblle/configuration'
require 'webmock/rspec'

RSpec.describe Treblle::Middleware do
  subject { described_class.new(app) }

  let(:treblle_url) { 'https://rocknrolla.treblle.com' }
  let(:request_url) { '/api/some_endpoint' }

  before do
    Treblle.configure do |config|
      config.api_key = 'your_api_key'
      config.project_id = 'project_id'
    end

    allow_any_instance_of(Treblle::Dispatcher).to receive(:get_uri)
      .and_return(URI(treblle_url))
  end

  context 'when app request is GET' do
    let(:app) { ->(env) { [200, env, 'OK'] } }
    let(:query_params) { { 'thing' => '123' } }
    let(:env) do
      Rack::MockRequest.env_for(request_url, {
        method: 'GET',
        params: query_params,
        'QUERY_STRING' => Rack::Utils.build_query(query_params)
      })
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to eq(200)
      expect(response_body).to eq('OK')
      expect(headers['PATH_INFO']).to eq(request_url)
      expect(headers['QUERY_STRING']).to eq('thing=123')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is POST' do
    let(:app) { ->(env) { [200, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'POST',
        params: { post: { content: "lorem ipsum body", title: "lorem ipsum title" } }
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 200
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('POST')
    end
  end

  context 'when app request is DELETE' do
    let(:app) { ->(env) { [200, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'DELETE'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 200
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('DELETE')
    end
  end

  context 'when app request is PUT' do
    let(:app) { ->(env) { [200, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'PUT'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 200
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('PUT')
    end
  end

  context 'when app request is redirect' do
    let(:app) { ->(env) { [301, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 301
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is not found' do
    let(:app) { ->(env) { [404, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 404
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is unauthorized' do
    let(:app) { ->(env) { [401, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 401
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is forbidden' do
    let(:app) { ->(env) { [403, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 403
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is server error' do
    let(:app) { ->(env) { [500, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        treblle_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')

      status, headers, response_body = subject.call(env)

      expect(status).to be 500
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end
end
