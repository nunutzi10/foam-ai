# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    name { Faker::Name.name }
    role { ApiKey::Role.all }
    tenant

    trait :admins do
      role { ApiKey::Role::ADMINS }
    end

    trait :completions do
      role { ApiKey::Role::COMPLETIONS }
    end
  end
end
