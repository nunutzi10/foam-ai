# frozen_string_literal: true

# Generic +Error+ serializer
class ErrorSerializer < ActiveModel::Serializer
  attribute :errors

  def errors
    return [] if object.errors.nil?

    object.errors.to_hash(true).map do |k, v|
      v.map do |msg|
        {
          status: '422',
          title: k,
          detail: msg,
          source: {
            pointer: "data/attributes/#{k}"
          }
        }
      end
    end.flatten
  end
end
