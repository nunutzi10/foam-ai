# frozen_string_literal: true

FactoryBot.define do
  sequence(:contact_unique_email) { |n| "#{n}#{Faker::Internet.email}" }

  factory :contact do
    name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    email { generate :contact_unique_email }
    phone { Faker::PhoneNumber.cell_phone_in_e164 }
    tenant
  end
end
