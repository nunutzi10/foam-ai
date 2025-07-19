# frozen_string_literal: true

# [ConversationSerializer]
class ConversationSerializer < ApplicationSerializer
  attributes :title,
             :bot_id

  # Optionally include the number of completions in the conversation
  attribute :completions_count do
    object.completions.count
  end
end
