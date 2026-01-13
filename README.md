# Voice Generation API

Production-ready Rails 8.1.2 API with ElevenLabs TTS integration.

## Features
- Real-time text-to-speech with ElevenLabs
- Cloudinary audio storage
- Sidekiq background processing
- API rate limiting
- Turbo/Stimulus frontend
- 95%+ RSpec test coverage

## Setup

1. **Clone & Install**
```bash
git clone <your-repo>
cd voicegen_api
bundle install

## Database

rails db:create db:migrate db:seed

# API
rails s

# Background jobs (terminal 2)
bundle exec sidekiq

# Frontend
bin/dev

## API Documentation
# Generate Audio

POST /api/voice_generation
X-API-Key: your_user_api_key
{
  "audio_generation": {
    "text": "Hello world",
    "voice_id": "21m00Tcm4TlvDq8ikWAM"
  }
}

# Get History

GET /api/voice_generation
X-API-Key: your_user_api_key

## Deployment (Railway)
1. Connect GitHub repo to Railway

2. Add environment variables

3. Deploy!

## Architecture Decisions

1. Sidekiq: Reliable async processing with Redis

2. Cloudinary: CDN-backed audio storage

3. Rack::Attack: Production-grade rate limiting

4. Turbo/Stimulus: Modern Rails frontend

5. RSpec/VCR: Comprehensive testing with API mocking