require 'rspec'
require 'treblle/response_builder'

RSpec.describe Treblle::ResponseBuilder do
  subject { described_class.new(rack_response).build }

  before { skip }
  let(:rack_response) do
    Rack::MockResponse.new(
      200,
      {
        'x-frame-options' => 'SAMEORIGIN',
        'x-xss-protection' => '0',
        'x-content-type-options' => 'nosniff',
        'x-permitted-cross-domain-policies' => 'none',
        'referrer-policy' => 'strict-origin-when-cross-origin',
        'content-type' => 'application/json; charset=utf-8',
        'vary' => 'Accept'
      },
      '{[{"id":102,"email":"email1@test.com"}]}'
    )
  end
  let(:asd) do
    [
      200,
      {
        'x-frame-options' => 'SAMEORIGIN',
        'x-xss-protection' => '0',
        'x-content-type-options' => 'nosniff',
        'x-permitted-cross-domain-policies' => 'none',
        'referrer-policy' => 'strict-origin-when-cross-origin',
        'content-type' => 'application/json; charset=utf-8',
        'vary' => 'Accept'
      },
      ActionDispatch::Response::RackBody.new(
        ActionDispatch::Response.new(
          200,
          {
            'x-frame-options' => 'SAMEORIGIN',
            'x-xss-protection' => '0',
            'x-content-type-options' => 'nosniff',
            'x-permitted-cross-domain-policies' => 'none',
            'referrer-policy' => 'strict-origin-when-cross-origin',
            'content-type' => 'application/json; charset=utf-8',
            'vary' => 'Accept'
          },
          '[{"id":102,"email":"email1@test.com"}]'
        )
      )
    ]
  end

  it 'builds a Models::Response object with the correct attributes' do
    expect(subject).to be_an_instance_of(Treblle::Models::Response)
    expect(subject.status).to eq(200)
    expect(subject.headers).to eq(
      'x-frame-options' => 'SAMEORIGIN',
      'x-xss-protection' => '0',
      'x-content-type-options' => 'nosniff',
      'x-permitted-cross-domain-policies' => 'none',
      'referrer-policy' => 'strict-origin-when-cross-origin',
      'content-type' => 'application/json; charset=utf-8',
      'vary' => 'Accept'
    )
    expect(subject.body).to eq(
      [
        { 'id' => 102, 'email' => 'email1@test.com' }
      ]
    )
  end

  context 'when @app.call fails and rack_response is not present' do
    let(:rack_response) { nil }

    it 'builds a Models::Response object with default values' do
      expect(subject).to be_an_instance_of(Treblle::Models::Response)
      expect(subject.status).to eq(500)
      expect(subject.headers).to eq([])
      expect(subject.body).to be_nil
    end
  end
end
