require "sidekiq/web"

Sidekiq::Web.use Rack::Auth::Basic do |user, password|
  sidekiq_user = ENV["SIDEKIQ_USER"]
  sidekiq_pass = ENV["SIDEKIQ_PASSWORD"]
end


Rails.application.routes.draw do

  mount Sidekiq::Web => "/sidekiq"

  # Frontend routes
  root "dashboard#index"
  get "history", to: "dashboard#history", as: :history
  
  # Frontend voice generations (HTML)
  resources :voice_generations, only: [:create, :index]
  
  # API routes (JSON only)
  namespace :api do
    resources :voice_generations, only: [:create, :show] do
      member do
        get :status
      end
      collection do
        get :voices
      end
    end
  end
end
