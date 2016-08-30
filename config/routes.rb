Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }

  resource :user_profiles, only: [:show, :edit, :update], path: '/profile', as: :current_user_profile
  get '/profile/:id', to: 'user_profiles#show', as: :user_profile

  resources :bookmarks do
    get 'copy', on: :member, to: 'bookmarks#new', as: 'copy'
  end
  get '/bookmarks/:id/:title', to: 'bookmarks#show', as: 'bookmark_permalink'
  get '/b/:id', to: 'bookmarks#show', as: 'bookmark_shortlink'

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


  get "/logos",   to: "home#logos"
  get "/feed",    to: "feed#index"

  authenticate :user, lambda { |user| user.admin? } do
    scope '/admin' do
      mount Blazer::Engine, at: "blazer"
    end
  end

  root to: "home#index"
end
