# frozen_string_literal: true

module V1
  # AiContexts API Endpoints
  class ApiKeysController < BaseController
    before_action :authenticate_v1_admin!,
                  only: %i[index create show update destroy]
    before_action :find_api_key!, only: %i[show update destroy]

    # retuns a list of api_key
    # @return [JSON]
    # @example
    # {
    #   "api_key"=>
    #   [
    #     {
    #     "id"=>1,
    #     "updated_at"=>"2023-08-10T18:15:43.181-06:00",
    #     "created_at"=>"2023-08-10T18:15:43.181-06:00",
    #     "name"=>"Lourdes Hernandes Viera",
    #     "role"=>0
    #   ],
    #   "meta"=>{"itemsCount"=>1, "pagesCount"=>1}
    # }
    def index
      authorize ApiKey
      collection = policy_scope(ApiKey)
      render_json_api_list_resource(
        collection:,
        search_fields: [
          { table: 'api_key', field: 'name' }
        ]
      )
    end

    # returns the information of a new api_key resource created
    # @return [JSON] AiContext
    # @example
    # {
    #   "api_key"=>
    #   {
    #     "id"=>1,
    #     "updated_at"=>"2023-08-10T18:15:43.181-06:00",
    #     "created_at"=>"2023-08-10T18:15:43.181-06:00",
    #     "name"=>"Lourdes Hernandes Viera",
    #     "role"=>0
    #   }
    # }
    def create
      authorize ApiKey
      api_key = current_admin_or_api_key.tenant.api_keys.create!(
        api_key_params
      )
      json_response api_key, :created
    end

    # returns the information of an specific updated api_key
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] AiContext
    # @example
    # {
    #   "api_keys"=>
    #   [
    #     {
    #       "id"=>1,
    #       "updated_at"=>"2023-08-10T18:15:43.181-06:00",
    #       "created_at"=>"2023-08-10T18:15:43.181-06:00",
    #       "name"=>"Lourdes Hernandes Viera",
    #       "role"=>0
    #     }
    #   ],
    #   "meta"=>{"itemsCount"=>1, "pagesCount"=>1}
    # }
    def update
      authorize @api_key
      @api_key.update! api_key_params
      json_response @api_key
    end

    # returns the information of an specific api_key
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] AiContext
    # @example
    # {
    #   "api_key"=>
    #   {
    #     "id"=>2,
    #     "updated_at"=>"2023-07-28T17:34:29.704-06:00",
    #     "created_at"=>"2023-07-28T17:34:29.704-06:00",
    #     "name"=>"Heavy Duty Iron Bottle",
    #     "role"=>0,
    #     "api_key"=>"eyJhbGciOiJIUzI1NiJ9.e"
    #   }
    # }
    def show
      authorize @api_key
      json_response @api_key, :ok, show_api_key: true
    end

    # Destroy the information of an specific api_key and return the current
    # destroyed object
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] AiContext
    # @example
    # {
    #   "api_key"=>
    #   {
    #     "id"=>1,
    #     "updated_at"=>"2023-08-10T18:15:43.181-06:00",
    #     "created_at"=>"2023-08-10T18:15:43.181-06:00",
    #     "name"=>"Lourdes Hernandes Viera",
    #     "role"=>0
    #   }
    # }
    def destroy
      authorize @api_key
      json_response @api_key.destroy!
    end

    private

    # returns an array of permitted http params in order to create
    # api_keys resources
    # @return[Array]
    def api_key_params
      params.require(:api_key).permit(
        :name,
        :role
      )
    end

    # this method selects an specific api_key resource based on the id param
    # @raise ActiveRecord::RecordNotFound
    # @return[AiContext]
    def find_api_key!
      @api_key = policy_scope(ApiKey).find params[:id]
    end
  end
end
