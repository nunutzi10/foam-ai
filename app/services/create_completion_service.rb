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
  # @return [Completion]
  def create_completion!
    self.completion = bot.completions.create!(
      completion_params.merge(
        status: Completion::Status::VALID_RESPONSE
      )
    )
    completion.create_openai_completion!
  end

  private

  # returns an [Bot] record for the given [bot_id] param
  # @return [Bot]
  def bot
    @bot ||= Bot.find(completion_params[:bot_id])
  end

  # returns a list of permitted params for [Completion]
  # @return [Hash]
  def completion_params
    @completion_params ||= params.require(:completion).permit(
      :prompt, :bot_id, :status
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
