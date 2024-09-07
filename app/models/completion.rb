# frozen_string_literal: true

# Definition of [Completion]
class Completion < ApplicationRecord
  # includes
  include DateFilterable
  include Openaiable
  # associations
  belongs_to :bot
  # delegations
  delegate :tenant, to: :bot
  # validations
  validates :prompt, presence: true
  # modules
  module Status
    VALID_RESPONSE = :valid_response
    INVALID_RESPONSE = :invalid_response
    LIST = {
      VALID_RESPONSE => 0,
      INVALID_RESPONSE => 1
    }.freeze
  end

  # creates the full prompt for the completion composed of base instructions,
  #   the [TextChunk] records grouped by embedding and the final instructions
  # updates the [full_prompt] attribute with the result
  # @return nil
  def create_full_prompt!
    lang_key = 'models.completion.system_prompt'
    full_prompt = bot.custom_instructions.presence ||
                  I18n.t("#{lang_key}.instructions").join("\n")
    update! full_prompt:
  end

  # returns the [user_instructions] embedded in a [I18n.t] call if present
  #   otherwise it returns the [prompt] attribute
  # Updates the [input_tokens] attribute with the number of tokens in the
  #   [user_instructions] attribute
  # @return [String]
  def user_prompt!
    return prompt if bot.user_instructions.blank?

    I18n.t('models.completion.user_prompt',
           user_instructions:,
           prompt:)
  end

  # creates the completion via OpenAI API.
  # Builds a message array with the [full_prompt] and the [context] if present
  # Calls OpenAI API to create the completion
  # Updates the [response] and [metadata] attributes with the result
  # Updates the [status] attribute to [Status::INVALID_RESPONSE] if the
  #  [response] attribute matches any of the [NO_RESPONSE_REGEXPS]
  # @return nil
  def create_openai_completion!(messages)
    create_full_prompt!
    http_response = openai_client.chat(
      parameters: openai_parameters(messages)
    )
    response = http_response.dig('choices', 0, 'message', 'content')
    update!(
      response:,
      metadata: http_response.slice('id', 'model', 'usage'),
      status: Status::VALID_RESPONSE
    )
  rescue Faraday::Error
    update! status: Status::INVALID_RESPONSE, response: invalid_response_message
  end

  # returns the parameters to be used for the OpenAI API call
  # Builds a message array with the [full_prompt] and the [context] if present
  # @return [Hash]
  def openai_parameters(recent_messages)
    messages = []
    user_prompt = user_prompt!
    messages << { role: 'system', content: full_prompt } if
      full_prompt.present?

    if recent_messages.present?
      recent_messages.map do |message|
        messages << if message.user?
                      { role: 'user', content: message.body }
                    else
                      { role: 'system', content: message.body }
                    end
      end.join("\n")
    end

    messages << { role: 'user', content: user_prompt } if user_prompt.present?

    {
      model: 'gpt-3.5-turbo-16k',
      messages:,
      temperature: 0,
      max_tokens: 2000,
      top_p: 0,
      frequency_penalty: 0,
      presence_penalty: 0
    }
  end

  # creates a new [Message] record and sends
  #   it via Vonage
  # @return nil
  def send_completion_message(contact)
    completion_message = contact.messages.create!(
      status: Message::Status::SENT,
      sender: Message::Sender::SYSTEM,
      content_type: Message::ContentType::TEXT,
      body: response
    )
    save!
    completion_message.send_to_vonage!(bot.whatsapp_phone)
  end

  # returns a default message to be used when the model could not resolve the
  #   User's query
  # @return [String]
  def invalid_response_message
    @invalid_response_message ||= I18n.t('models.invalid_response')
  end
end
