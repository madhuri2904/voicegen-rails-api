require "rails_helper"

RSpec.describe GenerateVoiceJob, type: :job do
  let!(:voice_gen) { create(:voice_generation, status: "pending") }
  
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
