# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-limit_fetch'

return if Rails.env.test?

# setup sidekiq
sidekiq_redis = ENV.fetch('SIDEKIQ_REDIS', nil)
return if sidekiq_redis.blank?

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_redis }
  config.logger.level = Logger::ERROR
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_redis }
  config.logger.level = Logger::ERROR
end

# setup sidekiq-cron
return unless Rails.env.production? || Rails.env.stage?

file_path = 'config/schedule.yml'
return unless File.exist?(file_path)

# Manejo seguro de YAML
begin
  schedule = YAML.safe_load(File.read(file_path), permitted_classes: [Symbol])
  Sidekiq::Cron::Job.load_from_hash(schedule) if schedule.present?
rescue Psych::SyntaxError => e
  Rails.logger.error "Error loading Sidekiq schedule: #{e.message}"
end
