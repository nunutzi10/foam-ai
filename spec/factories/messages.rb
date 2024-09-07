# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    status { Message::Status::SENT }
    sender { Message::Sender::USER }
    content_type { Message::ContentType::TEXT }
    body { Faker::Name.name }
    contact
  end
end
