# frozen_string_literal: true

# [CreateVonageMessageJob] ActiveJob
class CreateVonageMessageJob < ApplicationJob
  queue_as :default

  attr_accessor :params

  # Background job to proccess Vonage message interactions.
  #   Calls [CreateVonageMessageService] with the given params
  # @param params [Hash] containing the Vonage message HTTP params
  # @return [nil]
  def perform(params)
    self.params = params
    # calls [CreateVonageMessageService] with the given params
    CreateVonageMessageService.call!(params:)
  end
end
