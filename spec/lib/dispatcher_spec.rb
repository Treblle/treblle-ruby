# frozen_string_literal: true

require 'rspec'
require 'webmock/rspec'
require 'securerandom'
require 'treblle/dispatcher'

RSpec.describe Treblle::Dispatcher do
  subject { described_class.new(payload: payload, configuration: configuration) }

  let(:configuration) { instance_double('Treblle::Configuration', api_key: api_key) }
  let(:api_key) { 'test-api-key' }
  let(:payload) { { message: 'OK' }.to_json }
  let(:fake_uuid) { 'fake-uuid' }
  let(:treblle_url) { 'https://rocknrolla.treblle.com' }

  context '#call' do
    before do
      allow(SecureRandom).to receive(:uuid).and_return(fake_uuid)
      allow_any_instance_of(Treblle::Dispatcher).to receive(:get_uri)
        .and_return(URI(treblle_url))
    end

    context 'when request is valid' do
      it 'makes a successful HTTP request to Treblle and logs the response' do
        stub_request(:post, treblle_url)
          .with(
            body: payload,
            headers: {
              'Content-Type' => 'application/json',
              'x-api-key' => api_key,
              'x-treblle-trace-id' => fake_uuid
            }
          ).to_return(status: 200, body: payload)

        expect(subject.logger).to receive(:info).with(/Successfully sent to Treblle/)

        subject.call.join
      end
    end

    context 'when the Treblle request returns a response with status >= 400' do
      it 'logs failed monitoring' do
        stub_request(:post, treblle_url)
          .to_return(status: 400, body: 'Internal Server Error')

        expect(subject.logger).to receive(:error).with(/Treblle monitoring failed/)

        subject.call.join
      end
    end

    context 'when the Treblle request times out' do
      it 'logs an error' do
        stub_request(:post, 'https://rocknrolla.treblle.com/').to_timeout

        expect(subject.logger).to receive(:error).with(/Treblle monitoring failed/)

        subject.call.join
      end
    end

    context 'when the Treblle request fails' do
      it 'logs an error' do
        stub_request(:post, 'https://rocknrolla.treblle.com/').to_raise(StandardError)

        expect(subject.logger).to receive(:error).with(/Treblle monitoring failed/)

        subject.call.join
      end
    end
  end
end
