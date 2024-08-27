# frozen_string_literal: true

# +ApiKeyAuthenticable+ module
module ApiKeyAuthenticable
  extend ActiveSupport::Concern
  # includes
  include Knock::Authenticable

  private

  # Overrides pundit user allowing api_key resource finded by pundit
  # @return nil
  def pundit_user
    current_v1_admin || current_api_key
  end

  # authenticates the signed api key if exists, else raises and auth error
  # @raises ActionController::Unauthorized
  def authenticate_api_key!
    authenticate_for ApiKey

    render(nothing: true, status: :unauthorized) if current_api_key.blank?
  end
end
