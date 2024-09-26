# frozen_string_literal: true

require 'rspec'
require 'treblle/response_builder'

RSpec.describe Treblle::ResponseBuilder do
  subject { described_class.new(rack_response).build }

  let(:app) do
    lambda { |env|
      [200, env, '{"result": "success"}']
    }
  end
  let(:response) { Rack::MockRequest.new(app).get('example/api') }
  let(:env) { Rack::MockRequest.env_for('example/api') }
  let(:rack_response) { [200, response.headers, response] }

  context 'with a 200 response' do
    it 'stores status' do
      expect(subject.status).to eq(200)
    end

    it 'stores headers' do
      expect(subject.headers['path_info']).to eq('/example/api')
    end

    it 'stores body' do
      expect(subject.body).to eq({ 'result' => 'success' })
    end

    it 'stores body' do
      expect(subject.size).to eq(20)
    end
  end
end
