# frozen_string_literal: true

Mailjet.configure do |config|
  config.api_key = ENV.fetch('MAILJET_API_KEY')
  config.secret_key = ENV.fetch('MAILJET_SECRET_KEY')
end
