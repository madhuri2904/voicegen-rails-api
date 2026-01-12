Rails.application.routes.draw do
  namespace :api do
    resources :voice_generations, only: [:create, :show] do
      member do
        get :status
      end
      collection do
        get :voices # Future endpoint
      end
    end
  end
  
  root "dashboard#index"
  get "history", to: "dashboard#history"
  resources :voice_generations, only: [:index, :create]
end
