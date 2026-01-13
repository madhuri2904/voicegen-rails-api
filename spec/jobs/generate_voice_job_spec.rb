require "rails_helper"

RSpec.describe GenerateVoiceJob, type: :job do
  include ActiveJob::TestHelper

  let!(:voice_gen) { create(:voice_generation, status: "pending") }

  before do
    allow(Rails.application.credentials)
      .to receive(:dig)
      .with(:elevenlabs, :voice_id)
      .and_return("voice_123")
  end

  context "when voice generation succeeds" do
    before do
      stub_const(
        "ElevenLabs::TextToSpeech",
        Class.new do
          def self.call(text:, voice_id:)
            { audio: "fake_audio_data" }
          end
        end
      )
    end

    it "processes voice generation successfully" do
      described_class.perform_now(voice_gen.id)

      voice_gen.reload

      expect(voice_gen.status).to eq("completed")
      expect(voice_gen.audio_file).to be_attached
    end
  end

  context "when ElevenLabs service raises an error" do
    before do
      stub_const(
        "ElevenLabs::TextToSpeech",
        Class.new do
          def self.call(*)
            raise StandardError, "ElevenLabs API error"
          end
        end
      )
    end

    it "marks the voice generation as failed and stores error message" do
      expect {
        described_class.perform_now(voice_gen.id)
      }.to raise_error(StandardError, "ElevenLabs API error")

      voice_gen.reload

      expect(voice_gen.status).to eq("failed")
      expect(voice_gen.error_message).to eq("ElevenLabs API error")
    end
  end
end
