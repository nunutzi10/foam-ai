# frozen_string_literal: true

require 'open-uri'
# Definition of +ApplicationMailer+
class ApplicationMailer < ActionMailer::Base
  # Mailer default settings
  default from: ENV.fetch('EMAIL_FROM')
  layout 'mailer'
  # set URLS
  before_action :set_external_urls

  # Delivers a new HTML email template for the given parameters.
  # @param resource - Devise resource (Admin)
  # @param token - Devise password recovery token
  # @param options - Hash with additional devise options
  # @return nil
  def reset_password_instructions(resource, token, _options)
    @resource = resource
    set_theme_ui
    @token = token
    @resource_reset_password_token = @resource.reset_password_token
    @resource_dashboard_url = (@dashboard_url if resource.is_a? Admin)
    @subject = "#{@public_name} | Restablece tu contraseña"
    mail(
      to: resource.email,
      subject: @subject
    )
  end

  protected

  # sets the appropriate external urls for +dashboard_url+ and inline
  # attachments to be rendered as part of the given HTML template.
  # This method should be called as part of a +before_action+ filter call.
  # @return nil
  def set_external_urls
    @dashboard_url = ENV.fetch('DASHBOARD_URL', nil)
  end

  # updates instance variables to match [Tenant] resource files
  #   or returns default values
  # @return nil
  def set_theme_ui
    @tenant = @resource.tenant
    @public_name = 'FoamAi'
    @brand_primary_color = '#060228'
    @brand_secondary_color = '#309DF9'
  end
end
