# frozen_string_literal: true

describe User do
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
    let!(:user) { create :user }

    it 'does not find the field "deleted at" in users' do
      expect(user.deleted_at).to be_nil
      expect(user.deleted?).to be false
    end

    it 'finds "deleted_at" after deletion' do
      user.destroy
      expect(user.deleted_at).to be_present
      expect(user.deleted?).to be true
    end

    it 'does not find "deleted_at" in user after it has been restored' do
      user.destroy
      expect(user.deleted_at).to be_present
      expect(user.deleted?).to be true

      user.restore
      expect(user.deleted_at).to be_nil
      expect(user.deleted?).to be false
    end
  end

  describe '#full_name' do
    let(:user) { create :user, name: 'Sara', last_name: 'Lopez' }

    it 'returns full name of user' do
      expect(user.full_name).to be_present
      expect(user.full_name).to eq('Sara Lopez')
    end
  end
end
