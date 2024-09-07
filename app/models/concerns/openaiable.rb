# frozen_string_literal: true

# [Openaiable] module.
module Openaiable
  extend ActiveSupport::Concern

  included do
    # returns an instace of [OpenAI::Client] initialized with the
    #  OPENAI_API_KEY environment variable
    # @return [OpenAI::Client]
    def openai_client
      @openai_client ||= OpenAI::Client.new(
        access_token: tenant.settings['openai_api_key']
      )
    end
  end
end
