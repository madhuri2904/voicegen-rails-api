require "rails_helper"

RSpec.describe "Api::VoiceGenerations", type: :request do
  let(:api_key) { "test_api_key" }

  let(:params) do
    {
      voice_generation: {
        text: "Hello from RSpec",
        voice_id: "12345678-1234-1234-1234-123456789012"
      }
    }
  end

  before do
    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:elevenlabs, :api_key)
      .and_return(api_key)

    allow(GenerateVoiceJob).to receive(:perform_later)
  end

  it "creates a voice generation and enqueues job" do
    post "/api/voice_generations",
         params: params,
         headers: { "X-API-Key" => api_key }

    expect(response).to have_http_status(:ok)

    expect(GenerateVoiceJob)
      .to have_received(:perform_later)
      .once
  end
end
