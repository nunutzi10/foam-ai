# frozen_string_literal: true

module Overrides
  # Devise [SessionsController] overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    protected

    # overrides '/resource/sign_in' so a JSON serialization of the
    # authenticated resource conforms to +active_model_serializers+
    # @return JSON representation of authenticated resource
    def render_create_success
      # 04/09: Devise issue with multi model authentication.
      # A new token is recreated upon successful signin
      # https://github.com/lynndylanhurley/devise_token_auth/issues/602
      update_auth_header
      json_response(
        @resource,
        :ok,
        show_ai_context_ids: true,
        show_payment_card: true,
        show_current_billing_cycle: true,
        show_tenant: true
      )
    end

    # overrides [create_and_assign_token] to set the token lifespan based on
    #   the [remember_me] param
    # @return [nil]
    def create_and_assign_token
      lifespan = DeviseTokenAuth.token_lifespan
      lifespan = 1.day if params[:remember_me] == 'true' ||
                          params[:remember_me] == true
      token_extras = { lifespan_seconds: lifespan.to_i }

      if @resource.respond_to?(:with_lock)
        @resource.with_lock do
          @token = @resource.create_token(lifespan:, **token_extras)
          @resource.save!
        end
      else
        @token = @resource.create_token(lifespan:, **token_extras)
        @resource.save!
      end
    end
  end
end
