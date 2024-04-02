Rails.application.routes.draw do
  root 'search#index'
  post '/search' => 'search#search'
  get '/search' => 'search#search'
  get '/about' => 'static_pages#about'
  get '/images' => 'images#show'

  resources :authors, only: [:show]
  # using singular-named routes to match FiMFetch/FiMFiction.
  resources :stories, only: [:show], path: :story do
    resources :chapters, only: [:show], path: :chapter
  end
end
