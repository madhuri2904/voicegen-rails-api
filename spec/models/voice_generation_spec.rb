# spec/models/voice_generation_spec.rb
require "rails_helper"

RSpec.describe VoiceGeneration, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      vg = build(:voice_generation)
      expect(vg).to be_valid
    end

    it "is invalid without text" do
      vg = build(:voice_generation, text: nil)
      expect(vg).not_to be_valid
      expect(vg.errors[:text]).to be_present
    end

    it "is invalid when text exceeds 10,000 characters" do
      vg = build(:voice_generation, text: "a" * 10_001)
      expect(vg).not_to be_valid
    end

    it "is invalid without voice_id" do
      vg = build(:voice_generation, voice_id: nil)
      expect(vg).not_to be_valid
      expect(vg.errors[:voice_id]).to be_present
    end
  end

  describe "enums" do
    it "defines expected statuses" do
      expect(described_class.statuses.keys)
        .to contain_exactly("pending", "processing", "completed", "failed")
    end

    it "defaults to pending" do
      vg = create(:voice_generation)
      expect(vg.status).to eq("pending")
    end
  end

  describe "callbacks" do
    it "sets words_count before save" do
      vg = create(:voice_generation, text: "Hello world from RSpec")

      expect(vg.words_count).to eq(4)
    end

    it "does not override existing words_count" do
      vg = create(:voice_generation, text: "Hello world", words_count: 2)
      expect(vg.words_count).to eq(2)
    end
  end

  describe "scopes" do
    let!(:older) { create(:voice_generation, created_at: 2.days.ago) }
    let!(:newer) { create(:voice_generation, created_at: 1.hour.ago) }

    it "returns records ordered by newest first" do
      expect(described_class.recent.first).to eq(newer)
    end

    it "limits results to 50" do
      create_list(:voice_generation, 60)
      expect(described_class.recent.count).to be <= 50
    end

    it "returns only completed records" do
      completed = create(:voice_generation, status: "completed")
      create(:voice_generation, status: "pending")

      expect(described_class.completed).to contain_exactly(completed)
    end
  end

  describe "#words_count" do
    it "counts words correctly" do
      vg = build(:voice_generation, text: "Hello world again")
      expect(vg.words_count).to eq(3)
    end

    it "returns 0 when text is nil" do
      vg = build(:voice_generation, text: nil)
      expect(vg.words_count).to eq(0)
    end
  end

  describe "#elevenlabs_voice_id" do
    it "returns voice_id" do
      vg = build(:voice_generation, voice_id: "voice_123")
      expect(vg.elevenlabs_voice_id).to eq("voice_123")
    end
  end

  describe "#human_status" do
    it "returns human readable status" do
      expect(build(:voice_generation, status: "pending").human_status)
        .to eq("⏳ Pending")

      expect(build(:voice_generation, status: "processing").human_status)
        .to eq("🎙️ Processing")

      expect(build(:voice_generation, status: "completed").human_status)
        .to eq("✅ Completed")

      expect(build(:voice_generation, status: "failed").human_status)
        .to eq("❌ Failed")
    end

    it "returns nil for unknown status" do
      vg = build(:voice_generation)
      vg.status = nil

      expect(vg.human_status).to be_nil
    end
  end

  describe "attachments" do
    it "can attach an audio file" do
      vg = create(:voice_generation)

      vg.audio_file.attach(
        io: StringIO.new("audio"),
        filename: "test.mp3",
        content_type: "audio/mpeg"
      )

      expect(vg.audio_file).to be_attached
    end
  end
end
