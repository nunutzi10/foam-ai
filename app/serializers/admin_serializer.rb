# frozen_string_literal: true

# [AdminSerializer]
class AdminSerializer < ApplicationSerializer
  attributes :name,
             :last_name,
             :email,
             :role,
             :tenant_id
end
