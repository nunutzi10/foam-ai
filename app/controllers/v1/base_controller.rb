# frozen_string_literal: true

module V1
  # API BaseController Class
  # Shared method definitions
  class BaseController < ApplicationController
    # ActiveModel::Serializer vs Versionist
    before_action do
      self.namespace_for_serializer = nil
    end
    EXPORT_PAGE_LIMIT = 1000000
    EXPORT_DEFAULT_PAGE_LIMIT = 1000
    EXPORT_LIMIT_MINUTES = 10
    # concerns
    include ApiListable
    include Pundit::Authorization
    include Errorable
    include Knock::Authenticable
    before_action :set_airbrake_context
    before_action :set_paper_trail_whodunnit

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    # Used by Pundit in policies to provide the user context.
    #
    # @return [Hash, nil] A hash containing user-related information
    # or nil if no user is authenticated.
    def pundit_user
      {
        user: current_admin_or_api_key || current_v1_user,
        http_params: params
      }
    end

    # returns the current admin or api_key authenticated via knock or devise
    # @return [Admin, ApiKey]
    def current_admin_or_api_key
      current_v1_admin || current_api_key
    end

    # Add additional export fields to the given args in order to be used for
    # export request
    # @params [Hash] args
    # @returns Hash
    def api_list_export_params(args = {})
      {
        sort: params[:sort],
        sort_direction: params[:sort_direction],
        format: params[:file_format]
      }.merge(args)
    end

    # Authenticates the current request for a logged admin or a signed api_key
    # via knock implementation
    # @return nil.
    def authenticate_admin_or_api_key!
      return if current_v1_admin.present?

      authenticate_for ApiKey
      render(nothing: true, status: :unauthorized) if current_api_key.blank?
    end

    # Authenticates the current request for a logged admin or a signed api_key
    # or user
    # via knock implementation
    # @return nil.
    def authenticate_admin_or_api_key_or_user!
      return if current_v1_admin.present? || current_v1_user.present?

      authenticate_for ApiKey
      render(nothing: true, status: :unauthorized) if current_api_key.blank?
    end

    # Validates the request collection and check if page Limit is valid
    # @raise ActiveRecord::BadRequest
    # @return nil
    def validate_collection!
      page = (params[:page] || 1).to_i
      page_size = (params[:page_size] || EXPORT_PAGE_LIMIT).to_i

      return if page.positive? && page_size <= EXPORT_PAGE_LIMIT

      raise ActionController::BadRequest.new(
        I18n.t(
          'activerecord.errors.messages.invalid_pagination',
          page_size: EXPORT_PAGE_LIMIT
        )
      )
    end

    private

    # Response with forbidden http code
    # @return nil
    def user_not_authorized
      json_response({ message: 'Not authorized' }, :forbidden)
    end

    # saves the whodunnit, that it is the current user that is creating
    # the papertrail version when creating or updated
    # Overrides paper_trail gem method
    # @return nil
    def user_for_paper_trail
      return if pundit_user.blank?

      pundit_user.full_name if pundit_user.respond_to? :full_name
    end
  end
end
