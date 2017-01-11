Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }

  # User profiles
  resource :user_profiles, only: [:show, :edit, :update], path: '/profile', as: :current_user_profile
  get '/profiles', to: 'user_profiles#index', as: :user_profiles
  get '/profile/:id', to: 'user_profiles#show', as: :user_profile

  # Bookmarks
  resources :bookmarks do
    get 'copy', on: :member, to: 'bookmarks#new', as: 'copy'
  end
  get '/bookmarks/:id/:title', to: 'bookmarks#show', as: 'bookmark_permalink'
  get '/b/:id', to: 'bookmarks#show', as: 'bookmark_shortlink'

  # User relationships
  post '/user_relationships/:user_id', to: 'user_relationships#create', as: 'follow_user'
  delete '/user_relationships/:user_id', to: 'user_relationships#destroy', as: 'unfollow_user'

  # Bookmark likes
  post '/bookmark_likes/:bookmark_id', to: 'bookmark_likes#create', as: 'like_bookmark'
  delete '/bookmark_likes/:bookmark_id', to: 'bookmark_likes#destroy', as: 'unlike_bookmark'


  # JSON only
  scope :format => true, :constraints => { :format => 'json' } do
    get '/autocomplete_search/tags',                to: "autocomplete_search#tags"
    get '/autocomplete_search/username_available',  to: "autocomplete_search#username_available"
  end

  scope '/tools' do
    get   '/',            to: "tools#index",        as: 'tools'
    get   '/bookmarklet', to: "tools#bookmarklet",  as: 'bookmarklet_tool'
    get   '/import',      to: "tools#import",       as: 'import_tool'
    post  '/import',      to: "tools#import_file",  as: 'import_file_tool'
    get   '/imported',    to: "tools#imported",     as: 'imported_tool'
  end

  resource :preferences, only: [:edit, :update]
  get "/preferences", to: "preferences#edit"

  get "/logos",   to: "home#logos"
  get "/feed",    to: "feed#index"

  root to: "home#index"
end
