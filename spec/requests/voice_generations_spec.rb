require "rails_helper"

RSpec.describe "VoiceGenerations", type: :request do
  include ActiveJob::TestHelper

  describe "POST /voice_generations" do
    let(:params) do
      {
        voice_generation: {
          text: "Hello world",
          voice_id: "voice_123"
        }
      }
    end

    context "when save succeeds" do
      it "creates voice generation, enqueues job, and redirects" do
        expect {
          post "/voice_generations.html", params: params
        }.to have_enqueued_job(GenerateVoiceJob)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(VoiceGeneration)
          .to receive(:save)
          .and_return(false)
      end

      it "renders dashboard/index with 422 status" do
        post "/voice_generations.html", params: params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
