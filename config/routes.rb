Rails.application.routes.draw do
  resources :categories do
    resources :recipes, except: %i[show]
    resources :cakemodels, except: %i[show]
    collection do
      get :recipes
    end
  end
  resources :recipes, only: %i[show] do
    resources :reviews, only: %i[create edit update destroy]
  end
  resources :cakemodels, only: %i[show] do
    resources :reviews, only: %i[create edit update destroy]
  end

  resources :items

  resource :cart, only: %i[show]

  devise_for :users
  root to: 'pages#home'
  get 'how_to_order', to: 'pages#how_to_order'
  get 'about', to: 'pages#about'
  get 'dashboard',  to: 'pages#admin_dashboard'
  get '*any', via: :all, to: 'errors#not_found'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
