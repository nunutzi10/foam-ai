# frozen_string_literal: true

FactoryBot.define do
  factory :tenant do
    name { Faker::Commerce.product_name }

    settings do
      {
        openai_api_key: ENV.fetch('OPENAI_API_KEY')
      }
    end
  end
end
