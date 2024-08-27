# frozen_string_literal: true

# Definition of [User]
class User < ApplicationRecord
  extend Devise::Models
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  include DateFilterable
  include Tenantable

  # associations
  belongs_to :tenant

  # validations
  validates :name, :last_name, :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create

  # methods
  # name and last_name
  # @return String
  def full_name
    "#{name} #{last_name}"
  end
end
