# frozen_string_literal: true

module RequestSpecHelper
  # CallCounter is a class that counts the number of times a method is called
  #   and stores the count in the call_count attribute
  # @return [CallCounter]
  class CallCounter
    attr_accessor :call_count

    # initializes a CallCounter with a call_count of 0
    # @return [CallCounter]
    def initialize
      self.call_count = 0
    end
  end

  # Parse JSON response to ruby hash
  def json
    body = response.body
    body = page.body if body.empty?

    JSON.parse(body)
  end
end
