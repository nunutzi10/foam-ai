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
  has_many :contacts, dependent: :destroy
  has_many :bots, dependent: :destroy
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

  # Creates a Vonage PEM file if it does not exist with the current
  #   channel's Vonage private key
  # This is needed for the Vonage gem client to work
  # @return nil
  def create_vonage_pem_if_needed!
    return if File.exist? vonage_pem_path

    vonage_private_key = settings['vonage_private_key']
    raise 'Vonage private key is missing' if vonage_private_key.blank?

    File.write(vonage_pem_path, vonage_private_key.gsub('\n', "\n"))
  end

  # Returns the path to the Vonage PEM file for the current [Channel]
  # @return string
  def vonage_pem_path
    @vonage_pem_path ||= lambda do
      "tmp/#{id}-vonage-pem.key"
    end.call
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
