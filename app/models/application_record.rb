# frozen_string_literal: true

# +ApplicationJob+ abstract definition
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
