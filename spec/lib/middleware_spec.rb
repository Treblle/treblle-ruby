# frozen_string_literal: true

require 'rspec'
require 'treblle/middleware'
require 'treblle/configuration'
require 'webmock/rspec'

RSpec.describe Treblle::Middleware do
  subject { described_class.new(app) }

  let(:treblle_url) { 'https://rocknrolla.treblle.com' }
  let(:request_url) { '/api/some_endpoint' }
  let(:exception_response_body) do
    [JSON.generate({
      error: "Internal Server Error",
      exception: "#<StandardError: This is a test error message.>",
      traces: {
        'Application Trace': [
          {
            exception_object_id: 23_480,
            id: 0,
            trace: "app/controllers/api/v3/users_controller.rb:9:in `index'"
          }
        ],
        'Framework Trace': [
          {
            exception_object_id: 23_480,
            id: 1,
            trace: "actionpack (7.1.3.2) lib/action_controller/metal/basic_implicit_render.rb:6:in `send_action'"
          },
          {
            exception_object_id: 23_480,
            id: 2,
            trace: "..."
          }
        ]
      }
    })]
  end

  before do
    allow_any_instance_of(Treblle::Configuration).to receive(:enabled_environment?).and_return(true)
    allow_any_instance_of(Treblle::Configuration).to receive(:api_key).and_return('your_api_key')
    allow_any_instance_of(Treblle::Configuration).to receive(:project_id).and_return('project_id')
    allow_any_instance_of(Treblle::Dispatcher).to receive(:get_uri)
      .and_return(URI(treblle_url))

    allow(Thread).to receive(:new).and_yield
  end

  context 'when app request is valid but request to Treblle fails' do
    let(:app) { ->(env) { [200, env, 'OK'] } }
    let(:query_params) { { 'thing' => '123' } }
    let(:env) do
      Rack::MockRequest.env_for(request_url, {
        method: 'GET',
        params: query_params,
        'QUERY_STRING' => Rack::Utils.build_query(query_params)
      })
    end

    it 'fails to make valid request to Treblle' do
      stub = stub_request(:post, treblle_url).to_return(status: 400, body: 'bad request')
      expect(Logger).to receive_message_chain(:new, :error).with(/Treblle monitoring failed:/)

      subject.call(env)

      expect(stub).to have_been_requested
    end
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
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to eq(200)
      expect(response_body).to eq('OK')
      expect(headers['PATH_INFO']).to eq(request_url)
      expect(headers['QUERY_STRING']).to eq('thing=123')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is POST' do
    let(:app) { ->(env) { [201, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'POST',
        params: { post: { content: "lorem ipsum body", title: "lorem ipsum title" } }
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 201
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('POST')
    end
  end

  context 'when app request is DELETE' do
    let(:app) { ->(env) { [204, env, ''] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'DELETE'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 204
      expect(response_body).to eq('')
      expect(headers['REQUEST_METHOD']).to eq('DELETE')
    end
  end

  context 'when app request is PUT' do
    let(:app) { ->(env) { [201, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'PUT'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 201
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('PUT')
    end
  end

  context 'when app request is redirect' do
    let(:app) { ->(env) { [301, env, 'OK'] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 301
      expect(response_body).to eq('OK')
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is not found' do
    let(:app) { ->(env) { [404, env, exception_response_body] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 404
      expect(response_body).to eq(exception_response_body)
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is unauthorized' do
    let(:app) { ->(env) { [401, env, exception_response_body] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 401
      expect(response_body).to eq(exception_response_body)
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is forbidden' do
    let(:app) { ->(env) { [403, env, exception_response_body] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 403
      expect(response_body).to eq(exception_response_body)
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end

  context 'when app request is server error' do
    let(:app) { ->(env) { [500, env, exception_response_body] } }
    let(:env) do
      Rack::MockRequest.env_for(
        request_url,
        method: 'GET'
      )
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      stub = stub_request(:post, treblle_url).to_return(status: 200, body: 'OK')
      expect(Logger).to receive_message_chain(:new, :info).with(/Successfully sent to Treblle:/)

      status, headers, response_body = subject.call(env)

      expect(stub).to have_been_requested
      expect(status).to be 500
      expect(response_body).to eq(exception_response_body)
      expect(headers['REQUEST_METHOD']).to eq('GET')
    end
  end
end
