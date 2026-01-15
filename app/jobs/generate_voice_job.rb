# app/jobs/generate_voice_job.rb
class GenerateVoiceJob < ApplicationJob
  queue_as :voice_generation

  def perform(voice_gen_id)
    voice_gen = VoiceGeneration.find(voice_gen_id)
    voice_gen.processing!

    result = ElevenLabs::TextToSpeech.call(
      text: voice_gen.text,
      voice_id: Rails.application.credentials.dig(:elevenlabs, :voice_id)
    )

    voice_gen.audio_file.attach(
      io: StringIO.new(result),
      filename: "voice_#{voice_gen.id}.mp3",
      content_type: "audio/mpeg"
    )
   
    voice_gen.completed!
    Rails.logger.info("✅ VoiceGeneration #{voice_gen.id} completed")

  rescue => e
    voice_gen&.failed!
    voice_gen&.update!(error_message: e.message)
    Rails.logger.error("❌ GenerateVoiceJob failed: #{e.message}")
    raise e
  end
end
