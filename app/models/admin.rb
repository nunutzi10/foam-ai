# frozen_string_literal: true

# Definition of +Admin+
class Admin < ApplicationRecord
  extend Devise::Models
  include ApiKeyable
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :recoverable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  include DateFilterable
  include Tenantable

  # associations
  belongs_to :tenant

  # validations
  validates :name, :last_name, :email, presence: true
  validates :uid, uniqueness: { scope: :provider }, allow_blank: true
  validates :email, uniqueness: { scope: :provider }
  validates :email, email: true
  validates :password, :password_confirmation, presence: true, on: :create

  # modules
  module Role
    ADMIN = :admin
    SUPERVISOR = :supervisor
    AGENT = :agent
    LIST = { ADMIN => 0, SUPERVISOR => 1, AGENT => 2 }.freeze
  end

  # Enums
  enum role: Role::LIST

  # Scope
  scope :filter_role, ->(role) { where(role:) }

  # methods
  # returns true if [Admin] has a supervisor or admin role
  # @return Boolean
  def admin_or_supervisor?
    admin? || supervisor?
  end

  # name and last_name
  # @return String
  def full_name
    "#{name} #{last_name}"
  end
end
