Rails.application.routes.draw do
  get 'categories/new'
  get 'categories/create'
  get 'categories/index'
  get 'categories/show'
  get 'categories/edit'
  get 'categories/update'
  get 'categories/destroy'
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
