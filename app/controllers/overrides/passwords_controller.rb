# frozen_string_literal: true

module Overrides
  # Devise +PasswordsController+ overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :assert_reset_password_not_already_sent!, only: %i[create]
    before_action :assert_reset_password_resource!, only: %i[update]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    protected

    # Devise override for password recovery creation missing email serializer.
    # Calls +render_password_response+
    # @return nil
    def render_create_error_missing_email
      render_password_response
    end

    # Devise override for password recovery creation missing redirect url
    # serializer.
    # Calls +render_password_response+
    # @return nil
    def render_create_error_missing_redirect_url
      render_password_response
    end

    # Devise override for password recovery creation not allowed redirect URL
    # serializer.
    # Calls +render_password_response+
    # @return nil
    def render_create_error_not_allowed_redirect_url
      render_password_response
    end

    # Devise override for password recovery creation success serializer.
    # Calls +render_password_response+
    # @return nil
    def render_create_success
      if @resource.present?
        @resource.update!(
          sign_in_count: @resource.sign_in_count + 1
        )
      end
      render_password_response
    end

    # Devise override for password recovery creation error serializer.
    # Calls +render_password_response+
    # @return nil
    def render_create_error
      render_password_response
    end

    # Renders an empty HTTP response.
    # This method prevents OWASP's Top 10 vulnerabilities (Inconsistent
    # Feedback vulnerability) preventing a pottential attacker to discover
    # user's within the database.
    # Per compliance, all password requests should render the same response
    # @return nil
    def render_password_response
      render nothing: true
    end

    # overrides update password success
    # Devise override for password recovery update success.
    # returns a  JSON serialization of the update resource conforming to
    # +active_model_serializers+
    # @return JSON representation of authenticated resource
    def render_update_success
      authenticate_resource! if @resource.sign_in_count.zero?
      json_response(@resource)
    end

    # this method validates that the given Device Resource has not already
    # started a password recovery process in the configured
    # +Devise.reset_password_within+ setting.
    # If a current proccess is in progress the request will be terminated
    # so an email is not delivered to the same user.
    # This method prevents OWASP's Top 10 vulnerabilities (Missing
    # Authorization Check vulnerability)
    # @return nil
    def assert_reset_password_not_already_sent!
      resource = resource_class.where(email: resource_params[:email]).first
      return if resource.blank? || resource.reset_password_sent_at.blank?

      reset_limit = resource.reset_password_sent_at +
                    Devise.reset_password_within
      render_create_error if reset_limit >= Time.zone.now
    end

    # this method validates that the given Device Resource has an active
    # password recovery process and has not expired within the configured
    # +Devise.reset_password_within+ setting.
    # If validation fails, +@resource+ instance variable will be set to nil
    # so an unauthorized status is rendered via +devise_token_auth+
    # @return nil
    def assert_reset_password_resource!
      resource = resource_class.where(
        reset_password_token: resource_params[:reset_password_token]
      ).first
      return unless valid_reset_password_resource?(resource)

      @resource = resource
    end

    # returns true if Devise resource has a +sign_in+ count attribute for zero
    #   or reset password limit has not been reached.
    # @return bool - eval result
    def valid_reset_password_resource?(resource)
      return false if resource.blank? || resource.reset_password_sent_at.blank?

      reset_limit = resource.reset_password_sent_at +
                    Devise.reset_password_within
      resource.sign_in_count.zero? || Time.zone.now < reset_limit
    end

    # Authenticates the current Devise resource.
    # Generates a new Auth Token with +devise_token_auth+ implementation.
    # The new authentication token is returned in the response headers of the
    # given request context.
    # @return nil
    # @private
    def authenticate_resource!
      return if @resource.blank?

      # devise_token_auth token implementation
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token = SecureRandom.urlsafe_base64(nil, false)
      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.current + DeviseTokenAuth.token_lifespan).to_i
      }
      @resource.save!
      update_auth_header
    end
  end
end
