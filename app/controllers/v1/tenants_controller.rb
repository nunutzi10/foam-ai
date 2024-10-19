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

    def create_tenant_and_apikey
      tenant = Tenant.create!(
        name: "Let's Talk",
        vonage_production: false,
        vonage_private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDmeRYCAheTrH+v\nn3wSuag0IvD2rMdVRVVAfZVVsz3kqoOZQEHpp0yjG6b1ktKb5juzTlM7Lf+MJsJN\nQe2bndoEVFWvaUdAtw5Dh+mlGgLd4kATmKhJte923KL/iYIFkAJrbkTIAaKA5BW9\nVXW0LqNk0Mp1ndguHrBhExwUfcBIJ8ptNZIUZuRJt7wKrWFXbTxIkJTpVT+TYVPr\nvJRLINktNnxocZD6o0nhgJohlVJHQp84RexSxe50M+sPOAIrQaxdxuFVIZTaN6ss\npt+K99CW2BgaAzhtEMtGCw1I46Tak8qxl4AXGEmgFVNbKZ3ARoUeecQUbNDfvcTi\n2QsveP1RAgMBAAECggEAHVhQiYvrpZVioqFrYlT6Sj0isj3YmY5c5vu2fnV2jX16\niRJJ8i6njuMP9JevskLz2gZAibn3Hki3F7AryVMldcSpLk740BAexFFzWd7Ae7D5\nmKUo1E3Sgi9gn6nKANxPuo8NOewfXUrtS7Csbnc7vbPp+2TQKDsnGQ0eV6uVRnpw\nova2AgxjZGTj239ICfC3M7O1OubSXVxVFgabT23k5S5wnk7wXrAN0ZKgAmoGccW/\nsJ9BsZSLJWhVw8za4B9in0eml06liwokKx0uN1GvF/EetOnn3OI0lJLilAnsGZOt\nKeU+URgHKsy1kF0W/xSCrpawRxbcFJWQR+Ctgw55eQKBgQD7WNp22SG3HEdJYvbe\nA3pTe13Xz/LSr+SLy8qUZDLCZE8C05d+ML9ZJ4BP389S/E6WANBpFmVR3O2GBd+/\n7oNSXPpkRp07/PERXoEWQUGh6qqp7IJ7GINCp1BDkFwycIN7MstO41lvIagiBIS3\nqbHBhCiKx/jF6hXlAibDSxQRlQKBgQDqvU8oZnBIOkULfEhf6u1eEvrnuV+QZNLW\ncNrfbWeZHym3f8n9//LtQYbgNtHrmmfZl3R1ug/AIkgXkXKu5xCULjnREneetuf7\nEJpLaZcPrtr2AeuKJiYhrw1HYkZ+1tugo4XqamOu45v7cuEcQwzJhVJRKIYrOFzS\noFFqZhMFzQKBgCcedSH6OV0ecZniZTm4oNlNYhWsr8ZKye9YEHd4AM5wfjuaYwGo\n5J8jnrzPwJzR2AlQpx8z9SEAmZc6YtCkdpvjDLV+qAomG/7wDndAQM7KjzVTMhum\nfQdqsvtRBIh1KoGKLkpg6BJ70oc43M8ZAil0QDsZVIa5IB88bnwGu2DhAoGAGCB9\nEln1EHdswVF03ub2nsS0pTyYZe72/LN8y5ojG8noL8Qirsiv31Ls2f7IdL7aDbNT\ndQY6uDTN1B5O+0skmRZnOuX7BYUnMtbyBO5FaIdAWii4XOqu4KdtZfjj5gWPbWNh\nUEa/GCqszZtxJ8Z8efoKC+1uXOLeJ4fy1kzHh8ECgYAPINT1VmLfqxxEctRXuCmP\nr11ySVC9Jat/ghZKYF226iY12J5B3XBStVtg+o6JsbQDx791pvVBC/7V0dZ2dCH4\nsu3PQSRyHGdMqgFGuj0OUniX3PqbVkMMBW4tM6HA5WkLZPn7BhOZ93bjxByltdNa\nKYDfO/tcvbxLVIdUML7kxQ==\n-----END PRIVATE KEY-----\n",
        vonage_application_id: ENV.fetch('VONAGE_APPLICATION_ID'),
        openai_api_key: ENV.fetch('OPENAI_API_KEY'),
        message_template: "¡Bienvenido a Let's Talk! 🎶\n\n¡Hola! Soy tu amigable compañero de aprendizaje de idiomas, y estoy aquí para hacer que aprender inglés sea divertido y emocionante a través del poder de la música. Ya seas principiante o estés buscando perfeccionar tus habilidades, tenemos las canciones perfectas para ayudarte en tu camino.\n\nEsto es lo que puedes hacer con Let's Talk:\nDescubrir nuevas canciones: Explora una variedad de canciones en inglés adaptadas a tu nivel de aprendizaje.\nAprender letras: Entiende el significado detrás de las letras y mejora tu vocabulario.\nPracticar pronunciación: Canta junto a las canciones y recibe consejos sobre cómo pronunciar las palabras correctamente.\nCuestionarios interactivos: Pon a prueba tus conocimientos con divertidos cuestionarios basados en las canciones que te gustan.\n\n¿Listo para comenzar tu aventura musical?"
      )
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
