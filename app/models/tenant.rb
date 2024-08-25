# frozen_string_literal: true

# Definition of [Tenant]
class Tenant < ApplicationRecord
  acts_as_paranoid
  # includes
  include DateFilterable
  # associations
  has_many :admins, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :users, dependent: :destroy
  # validations
  validates :name, presence: true
  # custom validations
  validate :validate_settings

  # scopes
  # returns a list of the current instance's admins' emails
  # @return [Array<String>]
  def admins_emails
    admins.admin.map(&:email)
  end

  protected

  # creates a new [TenantSetting] instance with the current instance's
  #   settings and validates it
  # Adds errors to the current instance if the [TenantSetting] instance
  #   is invalid
  # This method is called before validation
  # @return nil
  def validate_settings
    return if settings.blank?

    tenant_setting = TenantSetting.new settings

    if tenant_setting.valid?
      self.settings = TenantSettingSerializer.new(tenant_setting).as_json
      return
    end

    tenant_setting.errors.each do |error|
      errors.add("settings_#{error.attribute}", error.message)
    end
  end
end
