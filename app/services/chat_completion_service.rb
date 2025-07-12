# frozen_string_literal: true

# [ChatCompletionService] definition
# Creates a chat completion for admin chat interface
class ChatCompletionService < ApplicationService
  attr_accessor :bot_id, :user_message, :bot, :completion

  # Creates a new chat completion
  # @return [Completion]
  def call!
    find_bot!
    create_completion!
    generate_openai_response!
    completion
  end

  private

  def find_bot!
    self.bot = Bot.find(bot_id)
  rescue ActiveRecord::RecordNotFound
    raise ArgumentError, 'Bot no encontrado'
  end

  def create_completion!
    self.completion = bot.completions.create!(
      prompt: user_message,
      status: Completion::Status::VALID_RESPONSE
    )
  end

  def generate_openai_response!
    completion.create_openai_completion!
  rescue StandardError => e
    Rails.logger.error "Error generating OpenAI response: #{e.message}"
    completion.update!(
      response: 'Lo siento, hubo un error al generar la respuesta.',
      status: Completion::Status::INVALID_RESPONSE
    )
  end

  # Creates a new [ChatCompletionService] instance
  # @param [Hash] args
  # @return [ChatCompletionService]
  def initialize(args)
    args.each { |key, val| send "#{key}=", val }
  end
end
