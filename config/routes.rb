Rails.application.routes.draw do
  resources :categories do
    resources :recipes do
      resources :reviews, only: %i[new create]
    end
  end
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
