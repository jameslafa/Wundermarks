Rails.application.routes.draw do
  resources :bookmarks
  get 'home/index'

  devise_for :users

  root to: "home#index"
end
