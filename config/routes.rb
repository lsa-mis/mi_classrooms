require 'sidekiq/web'

Rails.application.routes.draw do
  resources :rooms
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  get '/linkedin' => redirect('https://www.linkedin.com/in/mi_classrooms/')
  get '/github' => redirect('https://github.com/mi_classrooms')
  get '/twitter' => redirect('https://twitter.com/mi_classrooms')
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



  mount Sidekiq::Web => '/sidekiq'


end
