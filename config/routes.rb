Rails.application.routes.draw do
  resources :categories do
    resources :recipes, except: %i[show]
  end
  resources :recipes, only: %i[show] do
    resources :reviews, only: %i[create]
  end
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
