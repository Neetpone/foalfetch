Rails.application.routes.draw do
  root 'search#index'
  post '/search' => 'search#search'
  get '/search' => 'search#search'
  get '/about' => 'static_pages#about'
  get '/images' => 'images#show'

  resources :authors, only: [:show]
  resources :stories, only: [:show] do
    resources :chapters, only: [:show]
  end
end
