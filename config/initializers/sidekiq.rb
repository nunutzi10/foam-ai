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

Sidekiq::Cron::Job.load_from_hash YAML.load_file(file_path)
