# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'search#index'
  post '/search' => 'search#search'
  get '/search' => 'search#search'
  get '/about' => 'static_pages#about'
  get '/images' => 'images#show'

  resource :settings, only: [:show, :update]

  resources :authors, only: [:show]

  # using singular-named routes to match FiMFetch/FiMFiction.
  resources :stories, only: [:show], path: :story do
    resources :chapters, only: [:show], path: :chapter
    scope module: :stories do
      resource :download, only: :show
    end
  end

  # Routes for compat with FiMFetch
  get '/story/:id/:ignored0' => 'stories#show'
  get '/story/:story_id/:ignored0/chapter/:id/:ignored1' => 'chapters#show'

  # Different route name again to match FiMFetch
  resources :blogs, only: [:index], path: :news
end
