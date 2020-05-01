Rails.application.routes.draw do
  resources :categories do
    resources :recipes, except: %i[show]
    resources :cakemodels, except: %i[show]
  end
  resources :recipes, only: %i[show] do
    resources :reviews, only: %i[create]
  end
  resources :cakemodels, only: %i[show] do
    resources :reviews, only: %i[create]
  end


  devise_for :users
  root to: 'pages#home'
  get 'how_to_order', to: 'pages#how_to_order'
  get 'about', to: 'pages#about'
  get 'dashboard',  to: 'pages#admin_dashboard'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
