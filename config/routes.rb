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
  
  get '/project_status', to: 'pages#project_status'
  get '/privacy', to: 'pages#privacy'
  get '/contact', to: 'pages#contact'
  get '/about', to: 'pages#about'
  root to: 'pages#index'
  get 'pages/index'
  get 'pages/about'
  get 'pages/contact'
  get 'pages/privacy'
  get 'pages/project_status'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources 'feedbacks', only: [:create]
  resources :buildings

  resources :announcements

  get "legacy_crdb" => redirect("https://rooms.lsa.umich.edu")



  authenticate :user, lambda { |u| u.email == "dschmura@umich.edu" } do
    mount Sidekiq::Web => "/sidekiq"
  end
end
