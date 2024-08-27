# frozen_string_literal: true

# [TenantSetting] model for storing [setting] json fields
class TenantSetting
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  # ai settings
  attr_accessor :openai_api_key

  # validations
  validates :openai_api_key, presence: true

  # initializes the model with the given params and sets default values
  # @param [Hash] arguments - the params to initialize the model with
  # @return [TenantSetting] the initialized model
  def initialize(arguments)
    super arguments
    self
  end
end
