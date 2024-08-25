# frozen_string_literal: true

module Overrides
  # Devise +TokenValidationsController+ overrides
  class TokensController < DeviseTokenAuth::TokenValidationsController
    # overrides '/resource/validate_token' to check for altan api available
    #   for users
    # @return nil
    def validate_token
      # @resource will have been set by set_user_by_token concern
      if @resource
        render_validate_token_success
        yield @resource if block_given?
      else
        msg = I18n.t('devise_token_auth.token_validations.invalid')
        render_validate_token_error(401, msg)
      end
    end

    protected

    # overrides '/resource/render_validate_token_success' so a JSON
    #   serialization of the authenticated resource conforms to
    #   +active_model_serializers+
    # @return JSON representation of authenticated resource
    def render_validate_token_success
      json_response(
        @resource,
        :ok,
        show_ai_context_ids: true,
        show_payment_card: true,
        show_current_billing_cycle: true,
        show_tenant: true
      )
    end

    # overrides '/resource/render_validate_token_error' so can receive status
    #   and msg for render error
    # @return JSON representation of authenticated resource
    def render_validate_token_error(status, msg)
      render_error(status, msg)
    end
  end
end
