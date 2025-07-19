# frozen_string_literal: true

# [ConversationSerializer]
class ConversationSerializer < ApplicationSerializer
  attributes :bot_id,
             :title,
             :created_at,
             :updated_at

  # Add custom attributes
  attribute :message_count do
    object.completions.count
  end
end
