# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
    title { Faker::Lorem.sentence(word_count: 3) }

    bot
  end
end
