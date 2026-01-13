require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET / (index)" do
    it "renders the dashboard page successfully" do
      get "/"

      expect(response).to have_http_status(:ok)
    end

    it "renders the voice generation form" do
      get "/"

      expect(response.body).to include("<form")
      expect(response.body).to include("voice_generation")
    end

    it "shows dashboard heading or CTA" do
      get "/"

      expect(response.body).to match(/voice/i)
    end
  end
  
  describe "GET /history" do
    let!(:older) do
      create(
        :voice_generation,
        created_at: 2.days.ago,
        text: "OLDER VOICE"
      )
    end

    let!(:newer) do
      create(
        :voice_generation,
        created_at: 1.hour.ago,
        text: "NEWER VOICE"
      )
    end

    it "shows voice generations in reverse chronological order" do
      get "/history"

      expect(response).to have_http_status(:ok)

      doc = Nokogiri::HTML(response.body)

      ids = doc
        .css(".glass-card[data-voice-id]")
        .map { |el| el["data-voice-id"].to_i }

      expect(ids).to eq([newer.id, older.id])
    end
  end
end
