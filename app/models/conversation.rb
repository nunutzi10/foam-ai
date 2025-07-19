# frozen_string_literal: true

# Definition of [Conversation]
class Conversation < ApplicationRecord
  # Simple message class for compatibility with openai_parameters method
  class ContextMessage
    attr_reader :body, :is_user

    def initialize(body:, is_user:)
      @body = body
      @is_user = is_user
    end

    def user?
      @is_user
    end
  end

  # includes
  include DateFilterable
  include Tenantable

  # associations
  belongs_to :bot
  has_many :completions, dependent: :destroy

  # delegations
  delegate :tenant, to: :bot

  # validations
  validates :title, presence: true
  validates :title, uniqueness: { scope: :bot_id }

  # scopes
  # returns all the records that belong to a tenant through a [Bot] association
  # @param [Tenant] - tenant
  # @return ActiveRecord::Relation
  def self.filter_by_tenant(tenant)
    where(
      'EXISTS(?)',
      Bot.select(1)
        .where('bots.id = conversations.bot_id')
        .where(tenant:)
        .limit(1)
    )
  end

  # returns the recent completions for context (minimum 5, ordered by creation)
  # @param [Integer] limit - number of recent completions to fetch (default: 5)
  # @return [ActiveRecord::Relation]
  def recent_completions(limit = 5)
    completions
      .order(created_at: :desc)
      .limit([limit, 5].max) # Ensure minimum 5 messages
  end

  # returns the context messages compatible with openai_parameters method
  # Creates message objects that respond to user? and body methods
  # Filters out messages with blank content to avoid OpenAI errors
  # @return [Array] message objects compatible with existing openai_parameters
  def context_messages
    messages = []
    recent_completions.reverse.each do |completion|
      # Only add messages with valid content
      if completion.prompt.present?
        messages << ContextMessage.new(
          body: completion.prompt,
          is_user: true
        )
      end

      next if completion.response.blank?

      messages << ContextMessage.new(
        body: completion.response,
        is_user: false
      )
    end
    messages
  end
end
