require "rails_helper"

RSpec.describe "Api::VoiceGenerations", type: :request do
  let(:api_key) { "test-api-key" }

  before do
    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:elevenlabs, :api_key)
      .and_return(api_key)
  end

  describe "POST /api/voice_generations" do
    let(:params) do
      {
        voice_generation: {
          text: "Hello world",
          voice_id: "voice_123"
        }
      }
    end

    it "creates voice generation when authorized" do
      post "/api/voice_generations",
           params: params,
           headers: { "X-API-Key" => api_key }

      expect(response).to have_http_status(:ok)
    end

    it "returns 401 when API key is missing" do
      post "/api/voice_generations", params: params

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/voice_generations/:id" do
    context "when completed and audio is attached" do
      let!(:voice_gen) { create(:voice_generation, status: "completed") }

      before do
        voice_gen.audio_file.attach(
          io: StringIO.new("audio"),
          filename: "test.mp3",
          content_type: "audio/mpeg"
        )
      end

      it "returns audio URL" do
        get "/api/voice_generations/#{voice_gen.id}"

        json = JSON.parse(response.body)
        expect(json["url"]).to be_present
      end
    end

    context "when not completed" do
      let!(:voice_gen) { create(:voice_generation, status: "processing") }

      it "returns status and error" do
        get "/api/voice_generations/#{voice_gen.id}"

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("processing")
      end
    end
  end

  describe "GET /api/voice_generations/:id/status" do
    context "when audio is attached" do
      let!(:voice_gen) { create(:voice_generation, status: "completed") }

      before do
        voice_gen.audio_file.attach(
          io: StringIO.new("audio"),
          filename: "test.mp3",
          content_type: "audio/mpeg"
        )
      end

      it "returns audio_url" do
        get "/api/voice_generations/#{voice_gen.id}/status"

        json = JSON.parse(response.body)
        expect(json["audio_url"]).to be_present
      end
    end

    context "when audio is not attached" do
      let!(:voice_gen) { create(:voice_generation, status: "processing") }

      it "returns nil audio_url" do
        get "/api/voice_generations/#{voice_gen.id}/status"

        json = JSON.parse(response.body)
        expect(json["audio_url"]).to be_nil
      end
    end
  end
end
