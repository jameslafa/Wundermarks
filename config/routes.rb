Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }

  resource :user_profiles, only: [:show, :edit, :update], path: '/profile', as: :current_user_profile
  get '/profile/:id', to: 'user_profiles#show', as: :user_profile

  resources :bookmarks
  get '/bookmarks/:id/:title', to: 'bookmarks#show', as: 'bookmark_permalink'
  get '/b/:id', to: 'bookmarks#show', as: 'bookmark_shortlink'

  resources :emails, only: [:new, :create]
  get '/emails', to: "emails#new"
  get '/contact', to: "emails#new", as: 'contact'

  # JSON only
  scope :format => true, :constraints => { :format => 'json' } do
    get '/autocomplete_search/tags'                => "autocomplete_search#tags"
    get '/autocomplete_search/username_available'  => "autocomplete_search#username_available"
  end

  get "/tools", to: "home#tools"
  root to: "home#index"
end
