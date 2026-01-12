class VoiceGenerationsController < ApplicationController
  def index
    @voice_generations = VoiceGeneration.recent
  end
  
  def create
    @voice_generation = VoiceGeneration.new(voice_generation_params)
    respond_to do |format|
      if @voice_generation.save
        GenerateVoiceJob.perform_later(@voice_generation.id)
        format.turbo_stream
        format.html { redirect_to root_path, notice: "Voice generation started!" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def voice_generation_params
    params.require(:voice_generation).permit(:text, :voice_id)
  end
end
