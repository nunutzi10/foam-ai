# frozen_string_literal: true

describe DeleteMessagesJob, type: :job do
  it 'delete messages', perform_enqueued: true do
    # setup
    create :message
    described_class.perform_now
    # data expectations
    expect(Message.count).to eq(0)
  end
end
