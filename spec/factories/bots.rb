# frozen_string_literal: true

FactoryBot.define do
  factory :bot do
    name { Faker::Name.name }
    custom_instructions { Faker::Name.last_name }
    whatsapp_phone { '14157386102' }
    tenant
  end
end
