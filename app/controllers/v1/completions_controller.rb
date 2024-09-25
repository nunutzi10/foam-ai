# frozen_string_literal: true

module V1
  # Completion API Endpoints
  class CompletionsController < BaseController
    before_action :authenticate_admin_or_api_key_or_user!,
                  only: %i[index show create]
    before_action :find_completion!, only: %i[show]

    # retuns a list of completions
    # @return [JSON] completions
    # @example success
    #   {
    #     "completions"=>
    #       [
    #         {
    #           "id"=>1,
    #           "updated_at"=>"2024-07-06T16:44:14.888-06:00",
    #           "created_at"=>"2024-07-06T16:44:14.888-06:00",
    #           "bot_id"=>1,
    #           "status"=>"valid_response",
    #           "prompt"=>"Possimus nesciunt ut aspernatur.",
    #           "full_prompt"=>nil,
    #           "context"=>nil,
    #           "response"=>"Aliquid magnam nobis accusantium.",
    #           "metadata"=>nil,
    #         }
    #       ]
    #   }
    def index
      authorize Completion
      collection = policy_scope(Completion)
      render_json_api_list_resource(
        collection:,
        search_fields: %i[prompt],
        paginate: params[:paginate] != 'false'
      )
    end

    # returns the information of an specific completion
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] Completion on JSON fromat
    # @example success
    #   {
    #     "completions"=> {
    #       "id"=>1,
    #       "updated_at"=>"2024-09-23T22:43:30.023-06:00",
    #       "created_at"=>"2024-09-23T22:43:30.023-06:00",
    #       "bot_id"=>1,
    #       "status"=>"valid_response",
    #       "prompt"=>"Possimus nesciunt ut aspernatur.",
    #       "full_prompt"=>nil,
    #       "context"=>nil,
    #       "response"=>"Aliquid magnam nobis accusantium.",
    #       "metadata"=>nil,
    #     }
    #   }
    def show
      authorize @completion
      json_response @completion
    end

    def create
      authorize Completion
      completion = CreateCompletionService.call!(
        params:
      )
      json_response completion, :created
    end

    private

    # this method selects an specific completion resource based on the id param
    # @raise ActiveRecord::RecordNotFound
    # @return [Completion] an Completion by the id
    def find_completion!
      @completion = Completion.find params[:id]
    end
  end
end
