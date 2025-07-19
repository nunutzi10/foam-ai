# frozen_string_literal: true

# ConversationPolicy
class ConversationPolicy < ApplicationPolicy
  API_KEY_FEATURE = ApiKey::Role::COMPLETIONS

  def index?
    admin? || user.authorized?(API_KEY_FEATURE)
  end

  def create?
    (admin? && user.admin?) || user.authorized?(API_KEY_FEATURE)
  end

  def show?
    admin? || user.authorized?(API_KEY_FEATURE)
  end

  def update?
    (admin? && user.admin?) || user.authorized?(API_KEY_FEATURE)
  end

  def destroy?
    (admin? && user.admin?) || user.authorized?(API_KEY_FEATURE)
  end
end
