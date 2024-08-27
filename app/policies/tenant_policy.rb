# frozen_string_literal: true

# TenantPolicy
class TenantPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def update?
    admin?
  end

  def show?
    admin?
  end

  # override pundit scope
  class Scope < Scope
    # Base scope for admin resource
    # Overrides on policies if necessary
    def admin_scope
      scope.where(id: user.tenant_id)
    end
  end
end
