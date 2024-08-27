# frozen_string_literal: true

module ApplicationCable
  # [ApplicationCable::Channel] base class for all channels
  class Channel < ActionCable::Channel::Base
    include Pundit::Authorization
  end
end
