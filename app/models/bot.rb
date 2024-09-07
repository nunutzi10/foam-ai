# frozen_string_literal: true

# Definition of [Bot]
class Bot < ApplicationRecord
  acts_as_paranoid
  # includes
  include DateFilterable
  include Tenantable
  include ApiKeyable
  include Openaiable
  # associations
  belongs_to :tenant
  has_many :completions, dependent: :destroy
  # validations
  validates :name, :custom_instructions, presence: true
  validates :name, uniqueness: { scope: :tenant_id }
end
