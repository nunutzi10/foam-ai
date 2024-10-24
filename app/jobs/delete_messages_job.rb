# frozen_string_literal: true

# [DeleteMessagesJob] ActiveJob
class DeleteMessagesJob < ApplicationJob
  queue_as :default

  # Background job to delete all messages from the database.
  #   This method removes all records from the Message table,
  #   effectively clearing any stored messages.
  # @return [nil]
  def perform
    Message.delete_all
  end
end
