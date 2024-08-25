# frozen_string_literal: true

# AiContextPolicy
class ApiKeyPolicy < ApplicationPolicy
  def index?
    admin? && user.admin_or_supervisor?
  end

  def create?
    admin? && user.admin?
  end

  def update?
    admin? && user.admin?
  end

  def show?
    admin? && user.admin_or_supervisor?
  end

  def destroy?
    admin? && user.admin?
  end
end
