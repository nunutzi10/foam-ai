# frozen_string_literal: true

Devise.setup do |config|
  # The e-mail address that mail will appear to be sent from
  # If absent, mail is sent from
  #   "please-change-me-at-config-initializers-devise@example.com"
  config.mailer_sender = ENV.fetch('EMAIL_FROM')

  # Configure the class responsible to send e-mails.
  config.mailer = 'ApplicationMailer'

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 1.day

  # If using rails-api, you may want to tell devise to not use
  #   ActionDispatch::Flash
  # middleware b/c rails-api does not include it.
  # See: http://stackoverflow.com/q/19600905/806956
  config.navigational_formats = [:json]
end
