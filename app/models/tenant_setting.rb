# frozen_string_literal: true

# [TenantSetting] model for storing [setting] json fields
class TenantSetting
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  # vonage settings
  attr_accessor :vonage_application_id, :vonage_private_key,
                :vonage_production
  # ai settings
  attr_accessor :openai_api_key
  # other settings
  attr_accessor :message_template

  # validations
  validates :vonage_application_id, :vonage_private_key, :vonage_production,
            :openai_api_key, :message_template, presence: true

  # initializes the model with the given params and sets default values
  # @param [Hash] arguments - the params to initialize the model with
  # @return [TenantSetting] the initialized model
  def initialize(arguments)
    super arguments
    # vonage settings
    self.vonage_production ||= 'false'
    self.vonage_application_id ||= ENV.fetch('VONAGE_APPLICATION_ID')
    # openai settings
    self.openai_api_key ||= ENV.fetch('OPENAI_API_KEY')
    self
  end
end
