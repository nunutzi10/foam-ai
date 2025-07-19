# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'validations' do
    subject { build(:conversation) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:bot_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:bot) }
    it { is_expected.to have_many(:completions).dependent(:destroy) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:tenant).to(:bot) }
  end

  describe '#recent_completions' do
    let(:conversation) { create(:conversation) }

    before do
      # Create 7 completions for the conversation
      7.times do |i|
        create(:completion, conversation:, created_at: i.hours.ago)
      end
    end

    it 'returns recent completions ordered by creation date' do
      recent = conversation.recent_completions(5)
      expect(recent.count).to eq(5)
      expect(recent.first.created_at).to be > recent.last.created_at
    end

    it 'ensures minimum 5 messages even if limit is less' do
      recent = conversation.recent_completions(3)
      expect(recent.count).to eq(5) # Should return minimum 5
    end
  end

  describe '#context_messages' do
    let(:conversation) { create(:conversation) }

    before do
      2.times do |i|
        create(:completion,
               conversation:,
               prompt: "Question #{i}",
               response: "Answer #{i}",
               created_at: i.hours.ago)
      end
    end

    it 'returns message objects compatible with openai_parameters' do
      messages = conversation.context_messages
      expect(messages).to be_an(Array)
      expect(messages.length).to eq(4) # 2 completions * 2 messages each

      # Check that objects respond to expected methods
      expect(messages.first).to respond_to(:user?)
      expect(messages.first).to respond_to(:body)

      # Check alternating pattern: user, assistant, user, assistant
      expect(messages[0].user?).to be true
      expect(messages[1].user?).to be false
      expect(messages[2].user?).to be true
      expect(messages[3].user?).to be false

      # Check content is present
      expect(messages.first.body).to be_present
      expect(messages.second.body).to be_present
    end
  end
end
