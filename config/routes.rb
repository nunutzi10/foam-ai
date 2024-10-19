# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # [Healthcheck] gem routes
  Healthcheck.routes(self)
  api_version(
    module: 'V1',
    path: { value: 'v1' },
    defaults: { format: 'json' },
    default: true
  ) do
    # [Admin] devise routes
    mount_devise_token_auth_for 'Admin', at: 'admins', controllers: {
      sessions: 'overrides/sessions',
      passwords: 'overrides/passwords',
      token_validations: 'overrides/tokens'
    }
    # [Admin] routes
    resources :admins, only: %i[index create show update destroy]
    # [User] devise routes
    mount_devise_token_auth_for 'User', at: 'users', controllers: {
      sessions: 'overrides/sessions',
      passwords: 'overrides/passwords',
      token_validations: 'overrides/tokens'
    }, skip: [:omniauth_callbacks]
    # [User] routes
    resources :users, only: %i[index create show update destroy]
    # [Tenant] routes
    resources :tenants, only: %i[index show update] do
      post 'create_tenant_and_apikey', to: 'tasks#create_tenant_and_apikey'
    end
    # [ApiKey] routes
    resources :api_keys, only: %i[index show create update destroy]
    # Vonage Webhook routes
    resources :vonage, only: %i[] do
      post :messages, on: :collection
      post :status, on: :collection
    end
    # [Completion] routes
    resources :completions, only: %i[index show create]
  end
end
