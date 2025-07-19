# frozen_string_literal: true

FactoryBot.define do
  factory :completion do
    status { Completion::Status::VALID_RESPONSE }
    response { Faker::Lorem.sentence }
    prompt { Faker::Lorem.sentence }

    bot

    trait :with_conversation do
      conversation
    end
  end
end
