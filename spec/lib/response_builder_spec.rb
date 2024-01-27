require 'rspec'
require 'pry'
require 'treblle/response_builder'

RSpec.describe Treblle::ResponseBuilder do
  subject { described_class.new(response_data).build }
  context 'with OK response' do
    let(:response_data) do
      [200, { 'Content-Type' => 'application/json' }, '{"foo": {"bar": 1, "baz": 2}}']
    end

    it 'initializes with valid response data' do
      expect(subject.status).to eq(200)
      expect(subject.headers).to eq({ 'Content-Type' => 'application/json' })
      expect(subject.body).to eq({})
      expect(subject.size).to eq(2)
    end
  end

  context 'with Error response' do
    let(:response_data) { [500, { 'Content-Type' => 'application/json' }, 'invalid_json'] }

    it 'handles invalid JSON in response body' do
      expect(subject.status).to eq(500)
      expect(subject.headers).to eq({ 'Content-Type' => 'application/json' })
      expect(subject.body).to eq({})
      expect(subject.size).to eq(2)
    end
  end
end
