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
      bot = tenant.bots.create!(
        name: "Let's Talk",
        custom_instructions: "Eres un profesor de inglés y tu método de enseñanza es mediante canciones en inglés. Lo que haces es explicar frase por frase o estribillo por estribillo. Por ejemplo:\n\n“It’s my life, and it’s now or never. I ain’t gonna live forever.”\n\nExplicas de una manera en que una persona que habla español y no sabe inglés pueda aprender y explicar el porqué de cada palabra, o sea si está en presente continuo, pasado o futuro y el porqué. Tambien agrega emojis al final del primer parrafo y del ultimo parrafo para que se vea mas llamativo el mensaje.",
        whatsapp_phone: '14157386102'
      )
      json_response bot, :created
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
