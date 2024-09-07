# frozen_string_literal: true

# [UpdateVonageMessageService] definition
# @description Updates an existing [Message] for the given HTTP params
class UpdateVonageMessageService < ApplicationService
  # Updates a [Message] record status with the given params
  # @return [Message] - updated message
  def call!
    Message.transaction do
      find_message!
      update_message!
    end
  end

  private

  # returns a [Message] record identified by params[:message_uuid]
  # @return nil
  def find_message!
    self.message = Message.find_by!(vonage_id: params.dig(:message_uuid))
  end

  # updates Message's status attribute with the given HTTP Param
  # @return nil
  def update_message!
    status = params.dig(:status)&.to_sym

    return unless Message::Status::LIST.keys.include? status

    message.update!(status:)
  end

  attr_accessor :params, :message

  # Updates a [Message] record status with the given params
  # Broadcasts update to Websocket
  # @return [Message] - updated message
  def initialize(args)
    args.each { |key, val| send "#{key}=", val }
  end
end
