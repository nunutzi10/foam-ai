# frozen_string_literal: true

describe Tenant, type: :model do
  # validations
  describe 'validations' do
    subject { create :tenant }

    it { is_expected.to validate_presence_of(:name) }
  end

  # associations
  # describe 'associations' do
  # end

  describe 'paranoid' do
    let!(:tenant) { create :tenant }

    it 'does not find the field "deleted at" in tenants' do
      expect(tenant.deleted_at).to be_nil
      expect(tenant).not_to be_deleted
    end

    it 'finds "deleted_at" after deletion' do
      tenant.destroy
      expect(tenant.deleted_at).to be_present
      expect(tenant).to be_deleted
    end

    it 'does not find "deleted_at" in tenant after it has been restored' do
      tenant.destroy
      expect(tenant.deleted_at).to be_present
      expect(tenant).to be_deleted

      tenant.restore
      expect(tenant.deleted_at).to be_nil
      expect(tenant).not_to be_deleted
    end
  end
end
