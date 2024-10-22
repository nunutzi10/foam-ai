# frozen_string_literal: true

module V1
  # Tenant API Endpoints
  class TenantsController < BaseController
    before_action :authenticate_v1_admin!, only: %i[index show update]
    before_action :find_tenant!, only: %i[show update]

    # retuns a list of tenants
    # @return [JSON] a list of the tenants
    # @example success
    #   {
    #     "tenants"=>
    #       [
    #         {
    #           "id"=>1,
    #           "updated_at"=>"2020-07-29T20:01:25.087Z",
    #           "created_at"=>"2020-07-29T20:01:25.087Z",
    #           "name"=>"Incredible Steel Knife",
    #           "ida"=>"1521"
    #         },
    #         {
    #           "id"=>2,
    #           "updated_at"=>"2020-07-29T20:01:25.087Z",
    #           "created_at"=>"2020-07-29T20:01:25.087Z",
    #           "name"=>"Incredible Steel Knife",
    #           "ida"=>"1521"
    #         },
    #         {
    #           "id"=>3,
    #           "updated_at"=>"2020-07-29T20:01:25.087Z",
    #           "created_at"=>"2020-07-29T20:01:25.087Z",
    #           "name"=>"Incredible Steel Knife",
    #           "ida"=>"1521"
    #         },
    #         {
    #           "id"=>4,
    #           "updated_at"=>"2020-07-29T20:01:25.087Z",
    #           "created_at"=>"2020-07-29T20:01:25.087Z",
    #           "name"=>"Incredible Steel Knife",
    #           "ida"=>"1521"
    #         },
    #       ]
    #   }
    def index
      authorize Tenant
      collection = policy_scope(Tenant)
      render_json_api_list_resource(
        collection:,
        search_fields: %i[name]
      )
    end

    # returns the information of an specific updated tenant
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] update a only Tenant
    # @example success
    #   {
    #     "tenant"=> {
    #       "id"=>1,
    #       "updated_at"=>"2020-07-29T20:05:41.780Z",
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "name"=>"Dino World",
    #       "ida"=>"1521"
    #     }
    #   }
    def update
      authorize @tenant
      @tenant.update! tenant_params
      json_response @tenant
    end

    # returns the information of an specific tenant
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] find a Tenant by id
    # @example success
    #   {
    #     "tenant"=> {
    #       "id"=>1,
    #       "updated_at"=>"2020-07-29T20:05:41.780Z",
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "name"=>"Dino World",
    #       "ida"=>"1521"
    #     }
    #   }
    def show
      authorize @tenant
      json_response @tenant
    end

    def create
      tenant = Tenant.last
      tenant.settings["openai_api_key"] = ENV.fetch('OPENAI_API_KEY')
      tenant.save!
      json_response tenant, :created
    end

    private

    # This method selects an specific tenant resource
    # @return [Tenant]
    def find_tenant!
      @tenant = policy_scope(Tenant).find params[:id]
    end

    # returns an array of permitted http params in order to create or update
    # tenant resources
    # @return [Array]
    def tenant_params
      params.require(:tenant).permit :name
    end
  end
end
