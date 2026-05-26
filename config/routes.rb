Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks", sessions: "users/sessions"} do
    delete "sign_out", to: "users/sessions#destroy", as: :destroy_user_session
  end
  # Non-production only: token URL for SAML bypass (local/staging), e.g. Siteimprove on staging.
  # Not registered in production under any configuration.
  unless Rails.env.production?
    get "test_login", to: "users/test_sessions#show", as: :test_login
  end
  resources :rooms do
    post :toggle_visible, on: :member
    resources :notes, module: :rooms
  end
  get "rooms/:id/floor_plan", to: "rooms#floor_plan"
  resources :notes

  # Legacy URL (typo in path); forwards to RoomsController#toggle_visible
  match "toggle_visibile/:id", to: "rooms#toggle_visible", via: [:get, :post], as: :toggle_visibile

  get "/about", to: "pages#about"
  get "/room_filters_glossary", to: "pages#room_filters_glossary"
  root to: "pages#index"
  get "pages/index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :buildings do
    resources :floors, module: :buildings
    resources :notes, module: :buildings
  end

  resources :announcements
  resources :api_update_logs, only: [:index, :show]

  get "legacy_crdb" => redirect("https://rooms.lsa.umich.edu")

  mission_control_allowed_emails = ENV.fetch("MISSION_CONTROL_ALLOWED_EMAILS", "dschmura@umich.edu")
    .split(",")
    .map(&:strip)
    .reject(&:empty?)
    .freeze
  authenticate :user, ->(u) { mission_control_allowed_emails.include?(u.email) } do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  resources :classrooms, only: [:index, :show]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  delete "application/delete_file_attachment/:id", to: "application#delete_file_attachment", as: :delete_file

  # Mount the feedback gem engine
  mount LsaTdxFeedback::Engine, at: '/lsa_tdx_feedback', as: :lsa_tdx_feedback
end
