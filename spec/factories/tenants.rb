# frozen_string_literal: true

FactoryBot.define do
  factory :tenant do
    name { Faker::Commerce.product_name }

    settings do
      {
        vonage_production: ENV.fetch('VONAGE_PRODUCTION'),
        vonage_private_key: ENV.fetch('VONAGE_PRIVATE_KEY_PATH'),
        vonage_application_id: ENV.fetch('VONAGE_APPLICATION_ID'),
        openai_api_key: ENV.fetch('OPENAI_API_KEY'),
        message_template: 'Soy un bot de ingles!'
      }
    end
  end
end
