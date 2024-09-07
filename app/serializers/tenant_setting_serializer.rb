# frozen_string_literal: true

# [TenantSettingSerializer]
class TenantSettingSerializer < ActiveModel::Serializer
  attributes :vonage_application_id,
             :vonage_private_key,
             :vonage_production,
             :openai_api_key,
             :message_template
end
