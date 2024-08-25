# frozen_string_literal: true

# Errbit config

Airbrake.configure do |config|
  config.remote_config = false
  config.host = ENV.fetch('ERRBIT_HOST', nil)
  config.project_id = 1 # required, but any positive integer works
  config.project_key = ENV.fetch('ERRBIT_PROJECT_KEY', nil)
  config.performance_stats = false

  # Uncomment for Rails apps
  config.environment = Rails.env
  config.ignore_environments = %w[development test]
end
