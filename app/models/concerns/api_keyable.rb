# frozen_string_literal: true

# +ApiKeyable+ module.
module ApiKeyable
  extend ActiveSupport::Concern

  included do
    # updates an instance +api_key+ and +api_secret+ attributes with a random
    # generated secure unique value and an AuthToken generated via knock gem.
    # @return nil
    def generate_api_id_and_api_key!
      return if api_id.present? && api_key.present?

      api_id = SecureRandom.uuid
      api_key = Knock::AuthToken.new(payload: { api_id: }).token
      update!(api_id:, api_key:)
    end
  end
end
