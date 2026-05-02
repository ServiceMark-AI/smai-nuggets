Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  resources :invitations, only: [:show]
  get "profile" => "profiles#show", as: :profile
  get "profile/edit" => "profiles#edit", as: :edit_profile
  patch "profile" => "profiles#update"
  get "change_password" => "passwords#edit", as: :change_password
  patch "change_password" => "passwords#update"
  get "my_organization" => "my_organization#show", as: :my_organization
  resource :location, only: [:new, :create, :edit, :update]

  get "/auth/:provider/callback", to: "email_delegations#create", as: :email_delegation_callback
  get "/auth/failure", to: "email_delegations#failure", as: :email_delegation_failure
  resources :email_delegations, only: [:destroy]
  resources :job_proposals, only: [:index, :show, :new, :create]

  namespace :admin do
    resources :chats, only: [:index, :show]
    resources :messages, only: [:index]
    resources :tool_calls, only: [:index]
    resources :models, only: [:index]
    resources :pdf_processing_revisions, only: [:index, :new, :create]
    resources :tenants, only: [:index, :show, :new, :create] do
      resources :invitations, only: [:create]
      resource :activations, only: [:show], controller: "activations"
      resources :job_type_activations, only: [:create, :destroy] do
        member { post :activate_all_scenarios }
      end
      resources :scenario_activations, only: [:create, :destroy]
    end
    resources :organizations, only: [:show] do
      resources :locations, only: [:new, :create]
    end
    resources :job_types do
      resources :scenarios, only: [:new, :create]
    end
    resources :scenarios, only: [:show, :edit, :update, :destroy]
    resources :campaigns do
      member do
        patch :approve
        patch :pause
      end
      resources :steps, only: [:new, :create, :edit, :update, :destroy], controller: "campaign_steps" do
        collection do
          patch :reorder
        end
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
