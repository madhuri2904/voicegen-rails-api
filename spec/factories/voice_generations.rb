FactoryBot.define do
  factory :voice_generation do
    text { "Hello from ElevenLabs" }
    voice_id { "12345678-1234-1234-1234-123456789012" }
    status { "pending" }
  end
end