require 'treblle/errors/configuration_errors'
RSpec.describe Treblle::Errors::ConfigurationError do
  describe '#initialize' do
    it 'creates a new instance of ConfigurationError with correct message' do
      error = Treblle::Errors::ConfigurationError.new("Configuration Error Message")
      expect(error).to be_an_instance_of(Treblle::Errors::ConfigurationError)
      expect(error.message).to eq("Configuration Error Message")
    end
  end
end

RSpec.describe Treblle::Errors::MissingApiKeyError do
  describe '#initialize' do
    it 'creates a new instance of MissingApiKeyError with correct message' do
      error = Treblle::Errors::MissingApiKeyError.new("Missing API Key Error Message")
      expect(error).to be_an_instance_of(Treblle::Errors::MissingApiKeyError)
      expect(error.message).to eq("Missing API Key Error Message")
    end
  end
end

RSpec.describe Treblle::Errors::InvalidEndpointError do
  describe '#initialize' do
    it 'creates a new instance of InvalidEndpointError with correct message' do
      error = Treblle::Errors::InvalidEndpointError.new("Invalid Endpoint Error Message")
      expect(error).to be_an_instance_of(Treblle::Errors::InvalidEndpointError)
      expect(error.message).to eq("Invalid Endpoint Error Message")
    end
  end
end
