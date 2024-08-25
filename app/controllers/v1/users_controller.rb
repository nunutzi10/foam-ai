# frozen_string_literal: true

module V1
  # User API Endpoints
  class UsersController < BaseController
    before_action :authenticate_v1_user!, only: %i[index show update destroy]
    before_action :find_user!, only: %i[show update destroy]

    # retuns a list of users
    # @return [JSON] users
    # @example success
    #   {
    #     "users"=>
    #       [
    #         {
    #           "id"=>1,
    #           "updated_at"=>"2024-07-06T16:44:14.888-06:00",
    #           "created_at"=>"2024-07-06T16:44:14.888-06:00",
    #           "name"=>"Ricardo Hurtado Lucio",
    #           "last_name"=>"Tafoya",
    #           "email"=>"bernhard@example.org",
    #           "tenant_id"=>1
    #         }
    #       ]
    #   }
    def index
      authorize User
      collection = policy_scope(User)
      render_json_api_list_resource(
        collection:,
        search_fields: %i[name last_name email],
        paginate: params[:paginate] != 'false'
      )
    end

    # returns the information of a new user resource created
    # @return [JSON] new User on JSON fromat
    # @example success
    #   {
    #     "user"=> {
    #       "id"=>2,
    #       "updated_at"=>"2024-07-06T16:46:16.178-06:00",
    #       "created_at"=>"2024-07-06T16:46:16.178-06:00",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "email"=>"spec1_isaias@example.org",
    #       "tenant_id"=>1
    #     }
    #   }
    def create
      tenant = Tenant.find params[:tenant_id]
      user = tenant.users.create! create_user_params
      json_response user, :created
    end

    # returns the information of an specific updated user
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] User on JSON fromat
    # @example success
    #   {
    #     "user"=> {
    #       "id"=>2,
    #       "updated_at"=>"2024-07-06T16:47:37.520-06:00",
    #       "created_at"=>"2024-07-06T16:47:37.520-06:00",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "email"=>"spec3_irwin@example.net",
    #       "tenant_id"=>1
    #     }
    #   }
    def update
      authorize @user
      @user.update! user_params
      json_response @user
    end

    # returns the information of an specific user
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] User on JSON fromat
    # @example success
    #   {
    #     "user"=> {
    #       "id"=>2,
    #       "updated_at"=>"2024-07-06T16:49:17.645-06:00",
    #       "created_at"=>"2024-07-06T16:49:17.645-06:00",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "email"=>"spec2_yesenia_bernhard@example.com",
    #       "tenant_id"=>1
    #     }
    #   }
    def show
      authorize @user
      json_response @user
    end

    # returns the information of an specific user
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] User on JSON fromat
    # @example success
    #   {
    #     "user"=> {
    #       "id"=>2,
    #       "updated_at"=>"2024-07-06T16:50:19.431-06:00",
    #       "created_at"=>"2024-07-06T16:50:19.431-06:00",
    #       "name"=>"Gregorio Villanueva Espinal",
    #       "last_name"=>"Ureña",
    #       "email"=>"spec1_johnson@example.com",
    #       "tenant_id"=>1
    #     }
    #   }
    def destroy
      authorize @user
      json_response @user.destroy!
    end

    private

    # returns an array of permitted http params in order to create user
    # resources
    # @return [Array] the require params to create
    def user_params
      params.require(:user).permit(
        :name,
        :last_name,
        :email
      )
    end

    # returns an array of permitted http params in order to create user
    # resources
    # @return [Array] the require params to create
    def create_user_params
      create_params = params.require(:user).permit(
        :password,
        :password_confirmation
      )
      user_params.merge(create_params)
    end

    # this method selects an specific user resource based on the id param
    # @raise ActiveRecord::RecordNotFound
    # @return [User] an User by the id
    def find_user!
      @user = User.find params[:id]
    end
  end
end
