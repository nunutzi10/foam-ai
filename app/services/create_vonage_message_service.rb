# frozen_string_literal: true

# [CreateVonageMessageService] definition
# @description Creates a new [Message] for the given HTTP params
class CreateVonageMessageService < ApplicationService
  # Creates a new [Message] for the given HTTP params
  # @return [Message] - created message
  def call!
    Message.transaction do
      # 1. find or create contact
      find_or_create_contact!
      # 2. create [User] message
      create_user_message!
      # 3. Send a response message
      send_response_message!
    end
  end

  # Creates a new [Contact] if it's the first contact for an existing [Campaign]
  #   otherwise, the existing contact is returned
  # @return Contact
  def find_or_create_contact!
    self.contact = tenant.contacts.find_or_create_by!(
      phone: from_number
    ) do |contact|
      contact.update_profile_name_if_needed params.dig(:profile, :name)
    end
  end

  # Creates a new [Message] for the given HTTP params
  # Optionally assigns it to a [SurveyInteraction] record
  # @return [Message] - created message
  def create_user_message!
    self.user_message = contact.messages.create!(
      status: Message::Status::SENT,
      sender: Message::Sender::USER,
      content_type: message_content_type,
      body: setup_prompt,
      media_url: message_media_url,
      metadata: message_metadata,
      vonage_id: params.dig('message_uuid')
    )
  end

  # Sets up a prompt by calling the SetupPromptService
  # with the necessary parameters
  # This method delegates the setup process to the SetupPromptService
  def setup_prompt
    SetupPromptService.call!(
      message_content_type:,
      message_body:,
      media_url: message_media_url,
      tenant:
    )
  end

  # return the Message body attribute based on [ContentType]
  # @return String or nil
  def message_body
    case message_content_type
    when Message::ContentType::TEXT
      params.dig(:text)
    when Message::ContentType::IMAGE
      params.dig(:image, :caption)
    when Message::ContentType::VIDEO
      params.dig(:video, :caption)
    when Message::ContentType::AUDIO
      params.dig(:audio, :caption)
    when Message::ContentType::FILE
      params.dig(:file, :caption)
    when Message::ContentType::STICKER
      params.dig(:sticker, :caption)
    when Message::ContentType::REPLY
      params.dig(:reply, :title)
    when Message::ContentType::BUTTON
      params.dig(:button, :text)
    end
  end

  # return the Message's media_url attribute based on [ContentType]
  # @return String or nil
  def message_media_url
    case message_content_type
    when Message::ContentType::IMAGE
      params.dig(:image, :url)
    when Message::ContentType::VIDEO
      params.dig(:video, :url)
    when Message::ContentType::AUDIO
      params.dig(:audio, :url)
    when Message::ContentType::FILE
      params.dig(:file, :url)
    when Message::ContentType::STICKER
      params.dig(:sticker, :url)
    end
  end

  # return the Message metadata attribute based on [ContentType]
  # @return Json or nil
  def message_metadata
    case message_content_type
    when Message::ContentType::LOCATION
      params.dig(:location)
    when Message::ContentType::REPLY
      params.dig(:reply)
    end
  end

  # returns the [ContentType] representation of the Message in HTTP Params
  # @return [ContentType] or nil
  def message_content_type
    @message_content_type ||= params.dig('message_type')&.to_sym
  end

  # Sends a response [Message] to the [User]
  # @return nil
  def send_response_message!
    messages = contact.messages
    if messages.size == 1
      send_first_message!
    else
      send_bot_response!
    end
  end

  # Sends the first message to the user based
  # on the tenant's settings or a default template.
  # @return [Message] The message that was sent.
  def send_first_message!
    message_template = tenant.settings['message_template'] ||
                       I18n.t('models.first_interaction.unknown_interaction')
    message = contact.messages.create!(
      status: Message::Status::SENT,
      sender: Message::Sender::SYSTEM,
      content_type: Message::ContentType::TEXT,
      custom_destination: from_number,
      body: message_template
    )
    message.send_to_vonage!(bot.whatsapp_phone)
  end

  # Creates a [Completion] record
  # Generates an OpenAI completion for the user prompt
  #   and sends a completion message to the [User]
  # @return nil
  def send_bot_response!
    recent_messages = contact.messages
                             .where.not(id: user_message.id)
                             .order(created_at: :desc)
                             .limit(2)
                             .reverse

    completion = bot.completions.create!(
      prompt: user_message.body
    )
    completion.create_openai_completion!(recent_messages)
    completion.send_completion_message(contact)
  end

  private

  # returns the [Tenant] record based on the to_number HTTP param
  # @raise [ActiveRecord::RecordNotFound] if the tenant is not found
  # @return [Tenant]
  def tenant
    @tenant ||= bot.tenant
  end

  # Retrieves the bot associated with the given WhatsApp phone number.
  # If the bot is not already cached, it finds the
  # bot by the WhatsApp phone number and caches it.
  def bot
    @bot ||= Bot.find_by!(whatsapp_phone: to_number)
  end

  # returns the origin whatsapp number from HTTP params
  # @return string
  def to_number
    @to_number ||= params.dig('to')
  end

  # returns the origin number from HTTP params
  # @return string
  def from_number
    @from_number ||= params.dig('from')
  end

  attr_accessor :params, :user_message, :contact

  # Creates a new [Message] for the given HTTP params
  # @return [Message] - created message
  def initialize(args)
    args.each { |key, val| send "#{key}=", val }
  end
end
