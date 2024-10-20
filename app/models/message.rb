# frozen_string_literal: true

# [Message] model
class Message < ApplicationRecord
  include DateFilterable
  # associations
  belongs_to :contact
  # delegations
  delegate :tenant, to: :contact
  # validations
  validates :status, :sender, :content_type, presence: true
  validates :vonage_id, uniqueness: true, allow_nil: true

  # modules
  module Status
    SENT = :sent
    READ = :read
    FAILED = :failed
    LIST = {
      SENT => 0, READ => 1, FAILED => 2
    }.freeze
  end

  module Sender
    USER = :user
    BOT = :bot
    SYSTEM = :system
    LIST = {
      USER => 0, BOT => 1, SYSTEM => 2
    }.freeze
  end

  module ContentType
    TEXT = :text
    IMAGE = :image
    VIDEO = :video
    AUDIO = :audio
    FILE = :file
    LOCATION = :location
    STICKER = :sticker
    UNSUPPORTTED = :unsupported
    TEMPLATE = :template
    SURVEY_RESPONSE = :survey_response
    REPLY = :reply
    BUTTON = :button
    LIST = {
      TEXT => 0, IMAGE => 1, VIDEO => 2, AUDIO => 3, FILE => 4, LOCATION => 5,
      STICKER => 6, UNSUPPORTTED => 7, TEMPLATE => 8, SURVEY_RESPONSE => 9,
      REPLY => 10, BUTTON => 11
    }.freeze
  end

  enum status: Status::LIST
  enum sender: Sender::LIST
  enum content_type: ContentType::LIST

  # methods
  # delivers a [Message] via [Vonage] SDK
  # @return nil
  def send_to_vonage!(whatsapp_phone)
    message = Vonage::Messaging::Message.send(
      :whatsapp,
      format_message_content
    )
    result = vonage_client.messaging.send(
      from: whatsapp_phone,
      to: contact.phone,
      **message
    )
    update! vonage_id: result.message_uuid
  end

  # returns a message payload based on [ContentType] enum to be used in Vonage
  #   REST API
  # @return Hash
  def format_message_content
    result = {}
    case content_type&.to_sym
    when ContentType::TEXT
      result.merge!(type: 'text', message: body)
    when ContentType::IMAGE
      message_data = { url: media_url }
      message_data[:caption] = body if body.present?
      result.merge!(type: 'image', message: message_data)
    when ContentType::AUDIO
      result.merge!(type: 'audio', message: { url: media_url })
    end
    result
  end

  # returns an instance of a [Vonage::Client] class initialized with the
  # account api_key and api_secret from tenant settings
  # @return Vonage::Client
  def vonage_client
    @vonage_client ||= lambda do
      tenant.create_vonage_pem_if_needed!
      options = {
        application_id: tenant.settings['vonage_application_id'],
        private_key: tenant.vonage_pem_path
      }
      if tenant.settings['vonage_production'] == 'false'
        options[:api_host] = 'messages-sandbox.nexmo.com'
      end
      Vonage::Client.new options
    end.call
  end
end
