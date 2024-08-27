# frozen_string_literal: true

module V1
  # Admin API Endpoints
  class AdminsController < BaseController
    before_action :authenticate_admin_or_api_key!,
                  only: %i[index create show update destroy]
    before_action :find_admin!, only: %i[show update destroy]

    # retuns a list of admins
    # @return [JSON] admins
    # @example success
    #   {
    #     "admins"=>
    #       [
    #         {
    #           "id"=>1,
    #           "updated_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "created_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "name"=>"Ricardo Hurtado Lucio",
    #           "last_name"=>"Tafoya",
    #           "password"=>nil,
    #           "password_confirmation"=>nil,
    #           "email"=>"bernhard@example.org",
    #           "role"=>"admin",
    #           "tenant_id"=>"nil"
    #         },
    #         {
    #           "id"=>2,
    #           "updated_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "created_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "name"=>"Ricardo Hurtado Lucio",
    #           "last_name"=>"Tafoya",
    #           "password"=>nil,
    #           "password_confirmation"=>nil,
    #           "email"=>"bernhard@example.org",
    #           "role"=>"admin",
    #           "tenant_id"=>"nil"
    #         },
    #         {
    #           "id"=>3,
    #           "updated_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "created_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "name"=>"Ricardo Hurtado Lucio",
    #           "last_name"=>"Tafoya",
    #           "password"=>nil,
    #           "password_confirmation"=>nil,
    #           "email"=>"bernhard@example.org",
    #           "role"=>"admin",
    #           "tenant_id"=>"nil"
    #         },
    #         {
    #           "id"=>4,
    #           "updated_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "created_at"=>"2018-12-10T12:12:42.411-06:00",
    #           "name"=>"Ricardo Hurtado Lucio",
    #           "last_name"=>"Tafoya",
    #           "password"=>nil,
    #           "password_confirmation"=>nil,
    #           "email"=>"bernhard@example.org",
    #           "role"=>"admin",
    #           "tenant_id"=>"nil"
    #         },
    #       ]
    #   }
    def index
      authorize Admin
      collection = policy_scope(Admin)
      render_json_api_list_resource(
        collection:,
        filtering_params: params.slice(
          :role
        ),
        search_fields: %i[name last_name email],
        paginate: params[:paginate] != 'false'
      )
    end

    # returns the information of a new  admin resource created
    # @return [JSON] new Admin on JSON fromat
    # @example success
    #   {
    #     "admin"=> {
    #       "id"=>2,
    #       "updated_at"=>"2020-07-29T20:05:41.780Z",
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "password"=>nil,
    #       "password_confirmation"=>nil,
    #       "email"=>"kristoffer",
    #       "role"=>"admin",
    #       "tenant_id"=>"nil"
    #     }
    #   }
    def create
      authorize Admin
      admin = policy_scope(Admin).create! create_admin_params
      json_response admin, :created
    end

    # returns the information of an specific updated admin
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] Admin on JSON fromat
    # @example success
    #   {
    #     "admin"=> {
    #       "id"=>2,
    #       "updated_at"=>"2020-07-29T20:05:41.780Z",
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "password"=>nil,
    #       "password_confirmation"=>nil,
    #       "email"=>"kristoffer",
    #       "role"=>"admin",
    #       "tenant_id"=>"nil"
    #     }
    #   }
    def update
      authorize @admin
      @admin.update! admin_params
      json_response @admin
    end

    # returns the information of an specific admin
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] Admin on JSON fromat
    # @example success
    #   {
    #     "admin"=> {
    #       "id"=>2,
    #       "updated_at"=>"2020-07-29T20:05:41.780Z",
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "password"=>nil,
    #       "password_confirmation"=>nil,
    #       "email"=>"kristoffer",
    #       "role"=>"admin",
    #       "tenant_id"=>"nil"
    #     }
    #   }
    def show
      authorize @admin
      json_response @admin
    end

    # returns the information of an specific admin
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] Admin on JSON fromat
    # @example success
    #   {
    #     "admin"=> {
    #       "id"=>2,
    #       "updated_at"=>"2020-07-29T20:05:41.780Z",
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "password"=>nil,
    #       "password_confirmation"=>nil,
    #       "email"=>"kristoffer",
    #       "role"=>"admin",
    #       "tenant_id"=>"nil"
    #     }
    #   }
    def destroy
      authorize @admin
      json_response @admin.destroy!
    end

    private

    # returns an array of permitted http params in order to create admin
    # resources
    # @return [Array] the require params to create
    def admin_params
      result = params.require(:admin).permit(
        :name,
        :last_name,
        :email,
        :role,
        admin_ai_contexts_attributes: %i[ai_context_id]
      )
      result[:tenant_id] = current_admin_or_api_key.tenant_id
      result
    end

    # returns an array of permitted http params in order to create admin
    # resources
    # @return [Array] the require params to create
    def create_admin_params
      create_params = params.require(:admin).permit(
        :password,
        :password_confirmation
      )
      admin_params.merge(create_params)
    end

    # this method selects an specific admin resource based on the id param
    # @raise ActiveRecord::RecordNotFound
    # @return [Admin] an Admin by the id
    def find_admin!
      @admin = policy_scope(Admin).find params[:id]
    end
  end
end
