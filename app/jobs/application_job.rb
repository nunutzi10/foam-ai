# frozen_string_literal: true

# [ApplicationJob]
class ApplicationJob < ActiveJob::Base
  # handle known exceptions
  include Errorable
  sidekiq_options retry: false

  # dummy method definition for +Errorable+ support.
  # logs the resulting error to rails logger.
  # @return nil
  def json_response(*args)
    exception = args&.last
    return if exception.blank? || !exception.is_a?(StandardError)

    Airbrake.notify exception
    raise exception if Rails.env.test?
  end
end
