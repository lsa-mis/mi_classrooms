require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"} do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  resources :rooms do
  end
  match "toggle_visibile/:id" => "rooms#toggle_visibile", :via => [:get, :post], :as => :toggle_visibile
  
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
  get "lsa" => redirect("https://lsa.umich.edu")
  get "lsa_tech_services" => redirect("https://lsa.umich.edu/lsa/faculty-staff/technology-services.html")
  get "legacy_crdb" => redirect("https://rooms.lsa.umich.edu")
  get "about_lsats" => redirect("https://lsa.umich.edu/lsa/faculty-staff/technology-services.html")
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources 'feedbacks', only: [:create]
  resources :buildings

  get "legacy_crdb" => redirect("https://rooms.lsa.umich.edu")



  authenticate :user, lambda { |u| u.email == "dschmura@umich.edu" } do
    mount Sidekiq::Web => "/sidekiq"
  end
end
