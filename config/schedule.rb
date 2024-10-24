# frozen_string_literal: true

every 1.month do
  runner 'DeleteOldMessagesJob.perform_now'
end
