# frozen_string_literal: true

# [CompletionSerializer]
class CompletionSerializer < ApplicationSerializer
  attributes :bot_id,
             :status,
             :prompt,
             :full_prompt,
             :context,
             :response,
             :metadata
end
