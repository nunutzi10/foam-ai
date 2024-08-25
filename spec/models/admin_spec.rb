# frozen_string_literal: true

describe Admin do
  # Associations
  describe 'associations' do
    it { is_expected.to belong_to(:tenant) }
  end

  # validations
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_presence_of(:password_confirmation) }
  end

  describe 'paranoid' do
    let!(:admin) { create :admin }

    it 'does not find the field "deleted at" in admins' do
      expect(admin.deleted_at).to be_nil
      expect(admin.deleted?).to be false
    end

    it 'finds "deleted_at" after deletion' do
      admin.destroy
      expect(admin.deleted_at).to be_present
      expect(admin.deleted?).to be true
    end

    it 'does not find "deleted_at" in admin after it has been restored' do
      admin.destroy
      expect(admin.deleted_at).to be_present
      expect(admin.deleted?).to be true

      admin.restore
      expect(admin.deleted_at).to be_nil
      expect(admin.deleted?).to be false
    end
  end

  describe '#full_name' do
    let(:admin) { create :admin, name: 'Sara', last_name: 'Lopez' }

    it 'returns full name of admin' do
      expect(admin.full_name).to be_present
      expect(admin.full_name).to eq('Sara Lopez')
    end
  end
end
