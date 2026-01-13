require "rails_helper"

RSpec.describe ElevenLabs::TextToSpeech do
  let(:voice_id) { "voice_123" }
  let(:text) { "Hello world" }
  let(:api_key) { "test-api-key" }

  let(:connection) { instance_double(Faraday::Connection) }
  let(:response)   { instance_double(Faraday::Response, body: "audio_binary_data") }

  let(:headers) { {} }

  let(:request) do
    Class.new do
      attr_accessor :headers, :body
      def initialize(headers)
        @headers = headers
      end
    end.new(headers)
  end

  before do
    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:elevenlabs, :api_key)
      .and_return(api_key)

    allow(ElevenLabs::Client)
      .to receive(:connection)
      .and_return(connection)
  end

  describe ".call" do
    context "when request succeeds" do
      before do
        allow(connection).to receive(:post) do |_, &block|
          block.call(request) if block
          response
        end
      end

      it "returns audio data and sets request headers/body" do
        result = described_class.call(text: text, voice_id: voice_id)

        expect(result).to eq("audio_binary_data")
        expect(headers["Accept"]).to eq("audio/mpeg")
        expect(headers["Content-Type"]).to eq("application/json")
        expect(headers["xi-api-key"]).to eq(api_key)
        expect(request.body).to be_present
      end
    end

    context "when voice_id is invalid" do
      before do
        allow(connection)
          .to receive(:post)
          .and_raise(Faraday::ResourceNotFound.new("404"))
      end

      it "raises a friendly error" do
        expect {
          described_class.call(text: text, voice_id: voice_id)
        }.to raise_error("Invalid ElevenLabs voice_id or endpoint")
      end
    end

    context "when API key is invalid" do
      before do
        allow(connection)
          .to receive(:post)
          .and_raise(Faraday::UnauthorizedError.new("401"))
      end

      it "raises a friendly auth error" do
        expect {
          described_class.call(text: text, voice_id: voice_id)
        }.to raise_error("Invalid ElevenLabs API key")
      end
    end

    context "when other Faraday error occurs" do
      before do
        allow(connection)
          .to receive(:post)
          .and_raise(Faraday::Error.new("timeout"))
      end

      it "raises a generic service error" do
        expect {
          described_class.call(text: text, voice_id: voice_id)
        }.to raise_error("Text-to-Speech Service error: timeout")
      end
    end
  end
end
