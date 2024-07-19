Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "application#index"

  devise_for :users
  get '/users(/:id)(/:resource)', to: 'users#show', constraints: { id: /\d+/ }, as: :users
  post '/follow', to: 'users#follow', as: 'follow'
  post '/like', to: 'users#like', as: 'like'

  resources :posts, except: [:index, :show]
  post 'fetch', to: 'posts#fetch', as: 'fetch'
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
