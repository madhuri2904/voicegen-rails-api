class Api::VoiceGenerationsController < ApplicationController
  before_action :authenticate_request, only: [:create]
  before_action :set_voice_generation, only: [:show, :status]
  
  def create
    voice_gen = VoiceGeneration.create!(voice_gen_params)
    GenerateVoiceJob.perform_later(voice_gen.id)
    
    render json: {
      id: voice_gen.id,
      status: voice_gen.status,
      url: api_v1_voice_generation_url(voice_gen)
    }, status: :accepted
  end
  
  def show
    if @voice_gen.completed? && @voice_gen.audio_file.attached?
      render json: {
        url: rails_blob_url(@voice_gen.audio_file, expires_in: 1.hour)
      }
    else
      render json: { status: @voice_gen.status, error: @voice_gen.error_message }, 
             status: :processing
    end
  end
  
  def status
    render json: {
      id: @voice_gen.id,
      status: @voice_gen.status,
      audio_url: @voice_gen.audio_file.attached? ? rails_blob_url(@voice_gen.audio_file, expires_in: 1.hour) : nil,
      error: @voice_gen.error_message
    }
  end
  
  private
  
  def voice_gen_params
    params.require(:voice_generation).permit(:text, :voice_id)
  end
  
  def set_voice_generation
    @voice_gen = VoiceGeneration.find(params[:id])
  end
  
  def authenticate_request
    head :unauthorized unless request.headers["X-API-Key"] == ENV["API_AUTH_KEY"]
  end
end
