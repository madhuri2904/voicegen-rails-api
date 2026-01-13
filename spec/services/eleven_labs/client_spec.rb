require "rails_helper"

RSpec.describe ElevenLabs::Client do
  describe ".connection" do
    it "returns a Faraday connection" do
      connection = described_class.connection

      expect(connection).to be_a(Faraday::Connection)
      expect(connection.url_prefix.to_s).to eq("https://api.elevenlabs.io/v1")
    end

    it "memoizes the connection" do
      first = described_class.connection
      second = described_class.connection

      expect(first).to equal(second)
    end

    it "configures Faraday middleware" do
      connection = described_class.connection

      handlers = connection.builder.handlers

      expect(handlers).to include(Faraday::Request::Json)
      expect(handlers).to include(Faraday::Response::RaiseError)
    end
  end
end
