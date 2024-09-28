# frozen_string_literal: true

# ApiKey definition
class ApiKey < ApplicationRecord
  # includes
  include DateFilterable
  # include Tenantable
  include ApiKeyable
  # associations
  belongs_to :tenant
  # validations
  validates :name, :api_id, :api_key, presence: true
  # callbacks
  before_validation :generate_api_id_and_api_key!, on: :create

  # modules
  module Role
    ADMINS = (1 << 0)
    COMPLETIONS = (1 << 1)
    LIST = [
      ADMINS,
      COMPLETIONS
    ].freeze

    def self.all
      result = 0
      LIST.each { |el| result |= el }
      result
    end
  end

  # finds an [ApiKey] instance for the given +payload+ Hash attribute.
  # returns the first found record or raises and error if not found.
  # generated secure unique value and an AuthToken generated via knock gem.
  # @raise ActiveRecord::RecordNotFound
  # @return [ApiKey]
  def self.from_token_payload(payload)
    find_by api_id: payload['api_id']
  end

  # check if api key has allowed access to a given feature
  # @return [Boolean]
  def authorized?(role)
    self.role & role == role
  end
end
