# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # [Healthcheck] gem routes
  Healthcheck.routes(self)

  # Root route redirects to admin chat
  root 'admin_chat#index'

  # Admin Chat routes (outside API versioning for simple web interface)
  get '/admin_chat/login', to: 'admin_chat#login'
  post '/admin_chat/authenticate', to: 'admin_chat#authenticate'
  get '/admin_chat/logout', to: 'admin_chat#logout'
  delete '/admin_chat/logout', to: 'admin_chat#logout'
  get '/admin_chat', to: 'admin_chat#index', as: 'admin_chat_index'
  get '/admin_chat/:bot_id', to: 'admin_chat#show', as: 'admin_chat'
  get '/admin_chat/:bot_id/messages', to: 'admin_chat#messages',
                                      as: 'admin_chat_messages'
  post '/admin_chat/:bot_id/message', to: 'admin_chat#send_message',
                                      as: 'admin_chat_send_message'

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
    resources :tenants, only: %i[index show update create]
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
