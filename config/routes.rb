Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }

  resource :user_profiles, only: [:show, :edit, :update], path: '/profile', as: :current_user_profile
  get '/profile/:id', to: 'user_profiles#show', as: :user_profile


  resources :bookmarks

  root to: "home#index"
end
