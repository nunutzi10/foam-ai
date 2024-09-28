# frozen_string_literal: true

# UserPolicy
class UserPolicy < ApplicationPolicy
  def index?
    admin? && user.admin?
  end

  def show?
    (user.present? && user == @user) || (admin? && user.admin?)
  end

  def create?
    admin? && user.admin?
  end

  def update?
    (user.present? && user == @user) || (admin? && user.admin?)
  end

  def destroy?
    (user.present? && user == @user) || (admin? && user.admin?)
  end

  # Conversation scope
  class Scope < Scope
    # Base scope for user resource
    # Overrides on policies if necessary
    # Remove current user from scope unless explicit include_me http_param is
    #   true
    # @return [ActiveRecord::Relation]
    def user_scope
      include_me = http_params[:include_me] == 'true'
      result = super
      return result if include_me

      super.where.not(id: user.id)
    end
  end
end
