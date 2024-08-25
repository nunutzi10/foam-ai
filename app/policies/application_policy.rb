# frozen_string_literal: true

# Base Pundit policy
class ApplicationPolicy
  attr_reader :context, :user, :scope, :http_params

  def initialize(context, scope)
    @context = context
    @api_key = context.dig(:api_key)
    @user = context.dig(:user) || @api_key
    @scope = scope
    @http_params = context.dig(:http_params)
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # user is [Admin]
  # @return [Boolean]
  def admin?
    user.is_a? Admin
  end

  # user is [ApiKey]
  # @return [Boolean]
  def api_key?
    user.is_a? ApiKey
  end

  # Base pundit scope
  class Scope
    attr_reader :context, :user, :scope, :http_params

    def initialize(context, scope)
      @context = context
      @user = context.dig(:user)
      @scope = scope
      @http_params = context.dig(:http_params)
    end

    def resolve
      if user.is_a?(Admin)
        admin_scope
      elsif user.is_a?(ApiKey)
        api_key_scope
      else
        scope
      end
    end

    # Base scope for api_key resource
    # Overrides on policies if necessary
    # Filters all records for the associated tenant
    # If a model has a direct relation to tenant a where clause is added
    #   Otherwise a filter_by_tenant scope must be implemented on the model
    # It also applies a global filter_by_date scope if the model respond_to it
    # @return [ActiveRecord::Relation]
    def api_key_scope
      tenant = user.tenant
      tenant_scope tenant, scope
    end

    # Base scope for admin resource
    # Overrides on policies if necessary
    # Filters all records for the associated tenant
    # If a model has a direct relation to tenant a where clause is added
    #   Otherwise a filter_by_tenant scope must be implemented on the model
    # It also applies a global filter_by_date scope if the model respond_to it
    # @return [ActiveRecord::Relation]
    def admin_scope
      tenant = user.tenant
      result = scope
      if result.respond_to?(:filter_by_date)
        result = result.filter_by_date(http_params[:start_date],
                                       http_params[:end_date])
      end

      tenant_scope tenant, result
    end

    # Filters all records for the associated tenant
    # If a model has a direct relation to tenant a where clause is added
    #  Otherwise a filter_by_tenant scope must be implemented on the model
    # @param [Tenant] tenant
    # @param [ActiveRecord::Relation] scope
    # @return [ActiveRecord::Relation]
    def tenant_scope(tenant, scope)
      result = scope
      if result.respond_to?(:filter_by_tenant)
        result.filter_by_tenant(tenant)
      else
        result.where(tenant:)
      end
    end
  end
end
