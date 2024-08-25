# frozen_string_literal: true

# +ApiKeySerializer+
class ApiKeySerializer < ApplicationSerializer
  attributes :name,
             :role
  attribute :api_key, if: lambda {
                            instance_options[:show_api_key]
                          }
end
