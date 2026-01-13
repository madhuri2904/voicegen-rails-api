# app/services/eleven_labs/client.rb
module ElevenLabs
  class Client
    def self.connection
      @connection ||= Faraday.new(url: "https://api.elevenlabs.io/v1") do |f|
        f.request :json
        f.request :retry, max: 2, interval: 0.5
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end
  end
end
