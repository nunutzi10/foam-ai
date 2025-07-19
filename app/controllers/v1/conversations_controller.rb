# frozen_string_literal: true

module V1
  # Conversation API Endpoints
  class ConversationsController < BaseController
    before_action :authenticate_admin_or_api_key_or_user!,
                  only: %i[index show create update destroy]
    before_action :find_conversation!, only: %i[show update destroy]

    # retuns a list of conversations
    # @return [JSON] conversations
    # @example success
    #   {
    #     "conversations"=>
    #       [
    #         {
    #           "id"=>1,
    #           "title"=>"Chat about AI",
    #           "bot_id"=>1,
    #           "created_at"=>"2024-07-06T16:44:14.888-06:00",
    #           "updated_at"=>"2024-07-06T16:44:14.888-06:00"
    #         }
    #       ]
    #   }
    def index
      authorize Conversation
      collection = policy_scope(Conversation)
      render_json_api_list_resource(
        collection:,
        search_fields: %i[title],
        paginate: params[:paginate] != 'false'
      )
    end

    # returns the information of an specific conversation
    # @raise ActiveRecord::RecordNotFound
    # @return [JSON] Conversation on JSON format
    # @example success
    #   {
    #     "conversation"=> {
    #       "id"=>1,
    #       "title"=>"Chat about AI",
    #       "bot_id"=>1,
    #       "created_at"=>"2024-07-06T16:44:14.888-06:00",
    #       "updated_at"=>"2024-07-06T16:44:14.888-06:00"
    #     }
    #   }
    def show
      authorize @conversation
      json_response @conversation
    end

    # returns the information of a new conversation resource created
    # @return [JSON] new Conversation on JSON format
    # @example success
    #   {
    #     "conversation"=> {
    #       "id"=>1,
    #       "title"=>"New conversation",
    #       "bot_id"=>1,
    #       "created_at"=>"2020-07-29T20:05:41.780Z",
    #       "updated_at"=>"2020-07-29T20:05:41.780Z"
    #     }
    #   }
    def create
      authorize Conversation
      conversation = bot.conversations.create!(conversation_params)
      json_response conversation, :created
    end

    # updates an existing conversation
    # @return [JSON] updated Conversation on JSON format
    def update
      authorize @conversation
      @conversation.update!(conversation_params)
      json_response @conversation
    end

    # destroys an existing conversation
    # @return [JSON] empty response with 204 status
    def destroy
      authorize @conversation
      @conversation.destroy!
      head :no_content
    end

    private

    # this method selects an specific conversation resource
    # based on the id param
    # @raise ActiveRecord::RecordNotFound
    # @return [Conversation] a Conversation by the id
    def find_conversation!
      @conversation = Conversation.find params[:id]
    end

    # returns an [Bot] record for the given [bot_id] param
    # @return [Bot]
    def bot
      @bot ||= Bot.find(conversation_params[:bot_id])
    end

    # returns a list of permitted params for [Conversation]
    # @return [Hash]
    def conversation_params
      @conversation_params ||= params.require(:conversation).permit(
        :title, :bot_id
      )
    end
  end
end
