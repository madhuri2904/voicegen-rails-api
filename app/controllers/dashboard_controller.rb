class DashboardController < ApplicationController
  def index
    @voice_generation = VoiceGeneration.new
  end
  
  def history
    @voice_generations = VoiceGeneration.all.order(created_at: :desc)
  end
end
