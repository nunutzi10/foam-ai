# frozen_string_literal: true

# +Tenantable+ module.
module Tenantable
  extend ActiveSupport::Concern
  included do
    # filters all records that belong to a the given tenant
    # @param [Tenant] - tenant
    # @return ActiveRecord::Relation
    def self.filter_by_tenant(tenant)
      where tenant:
    end
  end
end
