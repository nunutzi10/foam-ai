# frozen_string_literal: true

# [CreateCompletionService] definition
# @description Creates a new [Completion] for the given HTTP params
class CreateCompletionService < ApplicationService
  # Creates a new [Completion] for the given HTTP params
  #   with OpenAI API
  # @return [Completion]
  def call!
    create_completion!
    completion
  end

  # Creates a new [Completion] for the given HTTP params
  # Assigns the [requester] to the [Completion]
  # Validates that conversation belongs to the same bot if provided
  # @return [Completion]
  def create_completion!
    validate_conversation_bot_match! if conversation.present?

    self.completion = bot.completions.create!(
      completion_params.merge(
        status: Completion::Status::VALID_RESPONSE
      )
    )
    completion.create_openai_completion!
  end

  private

  # Validates that the conversation belongs to the same bot
  # @raise [ArgumentError] if bot mismatch
  def validate_conversation_bot_match!
    return if conversation.bot_id == bot.id

    raise ArgumentError.new(
      'Conversation must belong to the same bot as the completion'
    )
  end

  # returns an [Bot] record for the given [bot_id] param
  # @return [Bot]
  def bot
    @bot ||= Bot.find(completion_params[:bot_id])
  end

  # returns a [Conversation] record for the given
  # [conversation_id] param if present
  # @return [Conversation, nil]
  def conversation
    return nil if completion_params[:conversation_id].blank?

    @conversation ||= Conversation.find(completion_params[:conversation_id])
  end

  # returns a list of permitted params for [Completion]
  # @return [Hash]
  def completion_params
    @completion_params ||= params.require(:completion).permit(
      :prompt, :bot_id, :status, :conversation_id
    )
  end

  attr_accessor :params, :completion

  # Creates a new [CreateCompletionService] instance with the given args
  # Sets the instance variables and returns the instance
  # @param [Hash] args
  # @return [CreateCompletionService]
  def initialize(args)
    args.each { |key, val| send "#{key}=", val }
  end
end
