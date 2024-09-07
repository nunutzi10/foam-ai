# frozen_string_literal: true

module V1
  # Vonage API Endpoints
  class VonageController < BaseController
    # Creates a new [Message] for the given HTTP params
    # Creates a new [Contact] if it doesn't exist for the given [Tenant]
    # Creates a new [Conversation] if it doesn't exist
    # @raise ActiveRecord::RecordNotFound on invalid models
    # @return [Hash] - empty response
    # @example
    # {}
    def messages
      CreateVonageMessageJob.perform_now(params.to_unsafe_h)
      json_response({})
    end

    # Updates a [Message] record status with the given params
    # Broadcasts update to Websocket
    # @return [Hash] - empty response
    # @example
    # {}
    def status
      UpdateVonageMessageService.call!(params:)
      json_response({})
    end
  end
end
