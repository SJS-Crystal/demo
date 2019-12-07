Rails.application.routes.draw do
  root "static_pages#home"

  namespace :admin do
    root "pages#home"
    resources :subpitch_types
    get "/revenue", to: "pitches/revenues#index"
    resources :pitches do
      resources :subpitches, controller: "pitches/subpitches" do
        resources :ratings, only: :show, controller: "subpitches/ratings"
      end
      get "/revenue", to: "pitches/revenues#show", on: :member
    end
    resources :transfers, except: %i(show update edit)
    resources :ratings, only: %i(index destroy), controller: "subpitches/ratings"
    resources :bookings
    resources :users do
      resources :roles, only: :create, controller: "users/roles"
    end
  end

  post "/login", to: "sessions#create"
  get "/signup", to: "users#new"
  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/auth/failure", to: "sessions#failure", via: [:get, :post]
  get "/blog", to: "static_pages#blog"
  get "/about", to: "static_pages#about"
  get "/contact", to: "static_pages#contact"
  resources :password_resets, except: :index
  resources :account_activations, only: :edit
  resources :pitches, only: :index do
    resources :subpitches, only: %i(index show) do
      resources :likes, only: %i(create destroy), controller: "subpitches/likes"
    end
  end
  resources :subpitches do
    resources :bookings, only: :new
  end
  resources :bookings do
    resources :pays, only: :new
    resources :ratings, except: :show, controller: "bookings/ratings"
  end
  resources :ratings, only: :index
  patch "pays/update"
  resources :users
end
