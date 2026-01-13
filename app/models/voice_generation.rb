class VoiceGeneration < ApplicationRecord
  validates :text, presence: true, length: { maximum: 10_000 }
  validates :voice_id, presence: true
  
  has_one_attached :audio_file
  
  before_save :set_words_count
  
  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
    
  }

  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :completed, -> { where(status: :completed) }
  
  def words_count
    text&.split(/\s+/).to_a.size || 0
  end
  
  def set_words_count
    self[:words_count] ||= words_count
  end
  
  def elevenlabs_voice_id
    voice_id
  end

  def human_status
    case status
    when "pending" then "⏳ Pending"
    when "processing" then "🎙️ Processing"
    when "completed" then "✅ Completed"
    when "failed" then "❌ Failed"
    end
  end
end
