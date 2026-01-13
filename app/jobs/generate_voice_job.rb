# app/jobs/generate_voice_job.rb

class GenerateVoiceJob < ApplicationJob
  queue_as :voice_generation

  def perform(voice_gen_id)
    voice_gen = VoiceGeneration.find(voice_gen_id)
    voice_gen.generating!

    # 🔊 Generate audio
    audio_data = ElevenLabs::TextToSpeech.call(
      text: voice_gen.text,
      voice_id: voice_gen.elevenlabs_voice_id
    )

    # ☁️ Upload to Cloudinary
    upload = Cloudinary::Uploader.upload(
      StringIO.new(audio_data),
      resource_type: :video,
      format: "mp3"
    )

    # ✅ Save result
    voice_gen.update!(
      status: :completed,
      audio_url: upload["secure_url"]
    )

    Rails.logger.info("✅ VoiceGeneration #{voice_gen.id} completed")

  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("VoiceGeneration #{voice_gen_id} not found")

  rescue StandardError => e
    voice_gen&.update!(
      status: :failed,
      error_message: e.message
    )

    Rails.logger.error("❌ GenerateVoiceJob failed: #{e.message}")
    raise e # allow Sidekiq retry
  end
end
