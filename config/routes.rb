Rails.application.routes.draw do
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
