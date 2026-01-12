# spec/models/voice_generation_spec.rb
require "rails_helper"

RSpec.describe VoiceGeneration, type: :model do
  subject do
    described_class.new(
      text: "Hello from ElevenLabs",
      voice_id: "12345678-1234-1234-1234-123456789012"
    )
  end

  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_length_of(:text).is_at_most(10_000) }

  it { is_expected.to validate_presence_of(:voice_id) }
  it { is_expected.to validate_length_of(:voice_id).is_equal_to(36) }

  it "defines a string-backed status enum" do
    expect(described_class.statuses).to eq(
      "pending" => "pending",
      "processing" => "processing",
      "completed" => "completed",
      "failed" => "failed"
    )
  end


  it "sets default status to pending" do
    subject.save!
    expect(subject.status).to eq("pending")
  end

  it "calculates words_count before validation" do
    subject.text = "one two three"
    subject.valid?
    expect(subject.words_count).to eq(3)
  end

  it { is_expected.to have_db_column(:status).of_type(:string) }

  describe ".completed" do
    it "returns completed records only" do
      completed = create(:voice_generation, status: "completed")
      create(:voice_generation, status: "pending")

      expect(described_class.completed).to contain_exactly(completed)
    end
  end

  it { is_expected.to have_one_attached(:audio_file) }
end
