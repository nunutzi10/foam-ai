# frozen_string_literal: true

# +ApplicationSerializer+ Serializer
class ApplicationSerializer < ActiveModel::Serializer
  attributes :id,
             :updated_at,
             :created_at
end
