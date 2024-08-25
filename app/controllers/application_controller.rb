# frozen_string_literal: true

# Base controller for all API endpoints
class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Jsonable

  protected

  # overrides DeviseTokenAuth [update_auth_header] to renew the token if needed
  # @return [nil]
  def update_auth_header
    result = super
    renew_token_if_needed!
    result
  end

  # This method renews an existing DeviseTokenAuth token by the configured
  #   lifespan_seconds and saves the resource to the database
  # @return [nil]
  def renew_token_if_needed!
    client_id = @token&.client
    token = @resource&.reload&.tokens&.dig(client_id)
    lifespan_seconds = token&.dig('lifespan_seconds')
    return if token.blank? || lifespan_seconds.blank?

    now = Time.current
    expiry = now.advance(seconds: lifespan_seconds).to_i
    token['expiry'] = expiry
    @resource.reload

    @resource.tokens[client_id] = token
    @resource.save!
  end
end
