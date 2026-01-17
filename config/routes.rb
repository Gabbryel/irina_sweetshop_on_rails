Rails.application.routes.draw do
  resources :designs

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
    resources :model_images, only: %i[new create destroy]
    resources :model_components, only: %i[new create destroy]
    resources :reviews, only: %i[create edit update destroy]
  end

  resources :model_components, only: %i[new create destroy]

  resources :features

  resources :items

  resource :cart, only: %i[show]

  devise_for :users
  root to: 'pages#home'
  get 'preturi', to: 'recipes#update_prices'
  patch 'preturi', to: 'recipes#bulk_update_prices'
  get 'cautare-retete', to: 'recipes#search'
  get 'how_to_order', to: 'pages#how_to_order'
  get 'about', to: 'pages#about'
  get 'valori-nutritionale', to: 'pages#valori_nutritionale'
  get 'gdpr', to: 'pages#gdpr', as: :gdpr
  get 'contul-meu', to: 'accounts#show', as: :account
  get 'dashboard',  to: 'pages#admin_dashboard'
  get 'dashboard/designs', to: 'designs#index'
  get 'dashboard/features', to: 'features#index'

  namespace :dashboard do
    resources :orders, only: %i[index show update destroy] do
      post :resend_emails, on: :member
    end
    resources :recipes, only: :index
    resources :delivery_dates, only: :index do
      collection do
        post :toggle
        post :block_range
      end
    end
    resources :users, only: %i[index edit update] do
      member do
        patch :toggle_admin
      end
    end

    resources :admin_users, controller: 'admin_users' do
      member do
        patch :toggle_admin
      end
    end

    resources :audit_logs, only: %i[index show] do
      collection do
        get :statistics
        get :export
      end
    end

    get 'analytics', to: 'analytics#index', as: 'analytics'
  end

  namespace :shop do
    resource :cart, only: :show
    resources :cart_items, only: %i[create update destroy]
    post 'checkout', to: 'checkout#create'
    get 'checkout/success', to: 'checkout#success'
    get 'checkout/cancel', to: 'checkout#cancel'
    get 'guest_confirmation/:id/:token', to: 'checkout#guest_confirmation', as: :guest_confirmation
  end

  get '*any', via: :all, to: 'errors#not_found'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
