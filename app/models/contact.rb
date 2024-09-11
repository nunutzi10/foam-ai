# frozen_string_literal: true

# Definition of [Contact]
class Contact < ApplicationRecord
  # concerns
  include Tenantable
  include DateFilterable

  # associations
  belongs_to :tenant
  has_many :messages, dependent: :destroy

  # validations
  validates :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
                    allow_blank: true
  validates :email, uniqueness: { scope: :tenant }, allow_blank: true
  validates :phone, uniqueness: { scope: :tenant }

  # updates [name] and [last_name] attributes based on [profile_name]
  # parses result from People::NameParser gem
  # @return nil
  def update_profile_name_if_needed(profile_name)
    return if profile_name.blank?

    name_parser = People::NameParser.new
    result = name_parser.parse(profile_name)
    self.name = result[:first]
    self.last_name = result[:last]
  end
end
