require "faraday"

class ElevenLabs::TextToSpeech
  VOICE_ENDPOINT = "https://api.elevenlabs.io/v1/text-to-speech"
  API_KEY = Rails.application.credentials.dig(:elevenlabs, :api_key)
  VOICE_ID = Rails.application.credentials.dig(:elevenlabs, :voice_id)
  HEADERS = {
    "Accept": "audio/mpeg",
    "Content-Type": "application/json",
    "xi-api-key": -> { api_key }
  }.freeze
  
  def self.call(text:, voice_id: VOICE_ID)
    new(text: text, voice_id: voice_id).call
  end
  
  def initialize(text)
    @text = text
    @api_key = API_KEY
    @voice_id = VOICE_ID
  end
  
  def call
    connection.post(url, body, headers)
  rescue Faraday::Error => e
    Rails.logger.error("ElevenLabs API error: #{e.message}")
    { error: "TextToSpeech service unavailable", status: :failed }
  end
  
  private
  
  def url
    "#{VOICE_ENDPOINT}/#{@voice_id}"
  end
  
  def body
    { text: @text, model_id: "eleven_multilingual_v2", voice_settings: { stability: 0.5, similarity_boost: 0.5 } }.to_json
  end
  
  def headers
    HEADERS.merge("xi-api-key" => HEADERS["xi-api-key"].call)
  end
  
  def connection
    @connection ||= Faraday.new(headers: headers) do |f|
      f.request(:retry, max: 3, interval: 0.5, interval_randomness: 0.5)
    end
  end
end
