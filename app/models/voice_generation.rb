class VoiceGeneration < ApplicationRecord
  validates :text, presence: true, length: { maximum: 10_000 }
  validates :voice_id, presence: true, length: { is: 36 }
  
  has_one_attached :audio_file
  
  before_validation :set_words_count
  before_create :set_initial_status
  
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
  
  def set_initial_status
    self.status ||= :pending
  end
  
  def elevenlabs_voice_id
    voice_id
  end
end
