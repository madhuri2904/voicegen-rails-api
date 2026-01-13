#app\controllers\voice_generations_controller.rb
class VoiceGenerationsController < ApplicationController
  def index
    @voice_generations = VoiceGeneration.recent
  end
  
  def create
    @voice_generation = VoiceGeneration.new(voice_generation_params)
    
    if @voice_generation.save
      GenerateVoiceJob.perform_later(@voice_generation.id)
      redirect_to root_path
    else
      render "dashboard/index", status: :unprocessable_entity
    end
  end
    
  private
  
  def voice_generation_params
    params.require(:voice_generation).permit(:text, :voice_id)
  end
end
