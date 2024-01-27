# frozen_string_literal: true

require 'webmock/rspec'
require 'securerandom'
require 'treblle/dispatcher'

RSpec.describe Treblle::Dispatcher do
  let(:payload) { '{"key": "value"}' }
  let(:api_key) { 'test_api_key' }
  let(:configuration) { instance_double('Treblle::Configuration', api_key: api_key) }

  subject { described_class.new(payload: payload, configuration: configuration) }

  describe '#send_payload_to_treblle' do
    let(:mock_response_body) { 'Mock response body' }

    before do
      allow(Net::HTTP).to receive(:start).and_return(double(body: mock_response_body))
      allow(Rails.logger).to receive(:info)
    end

    it 'makes a successful HTTP request to Treblle and logs the response' do
      expect(Net::HTTP).to receive(:start).with(any_args).and_return(double(body: mock_response_body))
      expect(Rails.logger).to receive(:info).with("Successfully sent to Treblle: #{mock_response_body}")
      subject.send(:send_payload_to_treblle)
    end
  end

  describe '#build_request' do
    let(:fake_uuid) { 'fake-uuid' }

    before do
      allow(SecureRandom).to receive(:uuid).and_return(fake_uuid)
    end

    it 'builds a Net::HTTP::Post request with the correct headers and payload' do
      request = subject.send(:build_request)

      expect(request).to be_a(Net::HTTP::Post)
      expect(request['Content-Type']).to eq('application/json')
      expect(request['x-api-key']).to eq(api_key)
      expect(request['x-treblle-trace-id']).to eq(fake_uuid)
      expect(request.body).to eq(payload)
    end
  end

  describe 'HTTP request integration test' do
    it 'successfully sends the payload to a mock Treblle endpoint' do
      stub_request(:post, /treblle\.com/)
        .to_return(status: 200, body: 'Mock Treblle response')

      subject.call

      expect(WebMock).to have_requested(:post, /treblle\.com/).with(
        headers: {
          'Content-Type' => 'application/json',
          'x-api-key' => api_key,
          'x-treblle-trace-id' => /.+/
        },
        body: payload
      ).once
    end
  end
end
