# frozen_string_literal: true

# ApplicationService Definition
class ApplicationService
  # static service implementation
  # should raise any exception
  def self.call!(...)
    new(...).call!
  end
end
