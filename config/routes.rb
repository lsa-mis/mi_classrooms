require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks", sessions: "users/sessions"} do
    delete 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
  end
  resources :rooms do
    resources :notes, module: :rooms
  end
  resources :notes
  
  match "toggle_visibile/:id" => "rooms#toggle_visibile", :via => [:get, :post], :as => :toggle_visibile
  
  get '/about', to: 'pages#about'
  get '/room_filters_glossary', to: 'pages#room_filters_glossary'
  root to: 'pages#index'
  get 'pages/index'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :buildings

  resources :announcements
  post 'announcements/:id/cancel', to: "announcements#cancel", as: 'announcements_cancel'

  get "legacy_crdb" => redirect("https://rooms.lsa.umich.edu")

  authenticate :user, lambda { |u| u.email == "dschmura@umich.edu" } do
    mount Sidekiq::Web => "/sidekiq"
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  
end
