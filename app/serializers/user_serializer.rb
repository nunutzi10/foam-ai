# frozen_string_literal: true

# [UserSerializer]
class UserSerializer < ApplicationSerializer
  attributes :name,
             :last_name,
             :email,
             :tenant_id
end
