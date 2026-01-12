class GenerateVoiceJob < ApplicationJob
  queue_as :voice_generation
  
  def perform(voice_gen_id)
    voice_gen = VoiceGeneration.find(voice_gen_id)
    voice_gen.update!(status: "processing")
    
    result = ElevenLabs::TextToSpeech.call(
    text: voice_gen.text,
    voice_id: voice_gen.elevenlabs_voice_id
    )
    
    if result[:error].present?
      voice_gen.update!(status: "failed", error_message: result[:error])
      return
    end

    audio_data = result[:audio]

    voice_gen.audio_file.attach(
    io: StringIO.new(audio_data),
    filename: "voice_#{voice_gen.id}.mp3",
    content_type: "audio/mpeg"
    )
    
    voice_gen.update!(status: "completed")
  rescue ActiveRecord::RecordNotFound
    
  rescue => e
    voice_gen&.update!(status: "failed", error_message: e.message)
  end
end
