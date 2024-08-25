# frozen_string_literal: true

describe ApiKey, type: :model do
  describe 'validations' do
    subject { create :api_key }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:api_id) }
    it { is_expected.to validate_presence_of(:api_key) }
  end
end
