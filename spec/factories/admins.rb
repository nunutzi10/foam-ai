# frozen_string_literal: true

FactoryBot.define do
  sequence :admin_unique_email do |n|
    "spec#{n}_#{Faker::Internet.safe_email}"
  end

  factory :admin do
    name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { generate :admin_unique_email }
    uid { email }
    password { '12345678' }
    password_confirmation { '12345678' }
    provider { 'email' }
    tenant

    trait :admin do
      role { Admin::Role::ADMIN }
    end

    trait :accountant do
      role { Admin::Role::ACCOUNTANT }
    end

    trait :support do
      role { Admin::Role::SUPPORT }
    end
  end
end
