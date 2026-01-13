# app/services/eleven_labs/text_to_speech.rb
module ElevenLabs
  class TextToSpeech
    MODEL_ID = "eleven_multilingual_v2"

    def self.call(text:, voice_id:)
      new(text:, voice_id:).call
    end

    def initialize(text:, voice_id:)
      @text = text
      @voice_id = voice_id
      @api_key = Rails.application.credentials.dig(:elevenlabs, :api_key)
    end

    def call
      Rails.logger.info("🔥 ElevenLabs runtime base URL: #{ElevenLabs::Client.connection.url_prefix}")

      response = ElevenLabs::Client.connection.post("/text-to-speech/#{@voice_id}") do |req|
        req.headers["Accept"] = "audio/mpeg"
        req.headers["Content-Type"] = "application/json"
        req.headers["xi-api-key"] = @api_key

        req.body = {
          text: @text,
          model_id: MODEL_ID,
          voice_settings: {
            stability: 0.5,
            similarity_boost: 0.5
          }
        }.to_json
      end

      response.body
    rescue Faraday::ResourceNotFound
      raise "Invalid ElevenLabs voice_id or endpoint"
    rescue Faraday::UnauthorizedError
      raise "Invalid ElevenLabs API key"
    rescue Faraday::Error => e
      raise "Text-to-Speech Service error: #{e.message}"
    end
  end
end
