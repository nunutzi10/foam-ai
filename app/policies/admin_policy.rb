# frozen_string_literal: true

# AdminPolicy
class AdminPolicy < ApplicationPolicy
  API_KEY_FEATURE = ApiKey::Role::ADMINS

  def index?
    admin? || user.authorized?(API_KEY_FEATURE)
  end

  def create?
    (admin? && user.admin?) || user.authorized?(API_KEY_FEATURE)
  end

  def update?
    (admin? && user.admin?) || user.authorized?(API_KEY_FEATURE)
  end

  def show?
    admin? || user.authorized?(API_KEY_FEATURE)
  end

  def destroy?
    (admin? && user.admin?) || user.authorized?(API_KEY_FEATURE)
  end

  # Conversation scope
  class Scope < Scope
    # Base scope for admin resource
    # Overrides on policies if necessary
    # Remove current user from scope unless explicit include_me http_param is
    #   true
    # @return [ActiveRecord::Relation]
    def admin_scope
      include_me = http_params[:include_me] == 'true'
      result = super
      return result if include_me

      super.where.not(id: user.id)
    end
  end
end
