# frozen_string_literal: true

# Chat Web Interface Controller
# rubocop:disable Rails/ApplicationController
class ChatController < ActionController::Base
  # rubocop:enable Rails/ApplicationController
  # Skip CSRF for API-like endpoints
  skip_before_action :verify_authenticity_token,
                     only: %i[send_message create_conversation
                              conversation_history conversations]
  before_action :authenticate_api_key!, except: [:index]
  before_action :find_bot,
                only: %i[send_message create_conversation conversations
                         conversation_history]

  # Main chat interface
  def index; end

  # Send a message to the bot
  def send_message
    conversation_id = params[:conversation_id]

    # If no conversation_id provided, create a new one if auto_create is enabled
    if conversation_id.blank?
      conversation = find_or_create_conversation
      conversation_id = conversation&.id
    end

    completion = CreateCompletionService.call!(
      params: ActionController::Parameters.new({
                                                 completion: {
                                                   prompt: params[:message],
                                                   bot_id: @bot.id,
                                                   conversation_id:
                                                 }
                                               })
    )

    render json: {
      success: true,
      response: completion.response,
      conversation_id: completion.conversation_id,
      completion_id: completion.id
    }
  rescue StandardError => e
    render json: {
      success: false,
      error: e.message
    }, status: :unprocessable_entity
  end

  # Create a new conversation
  def create_conversation
    conversation = @bot.conversations.create!(
      title: params[:title] ||
             "Conversación #{Time.current.strftime('%d/%m/%Y %H:%M')}"
    )

    render json: {
      success: true,
      conversation: {
        id: conversation.id,
        title: conversation.title,
        created_at: conversation.created_at
      }
    }
  rescue StandardError => e
    render json: {
      success: false,
      error: e.message
    }, status: :unprocessable_entity
  end

  # Get conversation history
  # Get conversation history
  def conversation_history
    Rails.logger.info 'Loading history for conversation_id: ' \
                      "#{params[:conversation_id]}"
    Rails.logger.info "Bot: #{@bot&.id}, Tenant: #{@api_key_record&.tenant&.id}"

    # Find conversation that belongs to the current bot
    conversation = @bot.conversations.find(params[:conversation_id])
    completions = conversation.completions.order(:created_at)

    Rails.logger.info "Found #{completions.count} completions"

    messages = completions.map do |completion|
      [
        { role: 'user', content: completion.prompt,
          timestamp: completion.created_at },
        { role: 'assistant', content: completion.response,
          timestamp: completion.created_at }
      ]
    end.flatten

    render json: {
      success: true,
      messages:,
      conversation: {
        id: conversation.id,
        title: conversation.title
      }
    }
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Conversation not found: #{e.message}"
    render json: {
      success: false,
      error: 'Conversación no encontrada'
    }, status: :not_found
  rescue StandardError => e
    Rails.logger.error "Error loading conversation history: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: {
      success: false,
      error: e.message
    }, status: :unprocessable_entity
  end

  # List user's conversations
  def conversations
    conversations = @bot.conversations.order(updated_at: :desc).limit(20)

    render json: {
      success: true,
      conversations: conversations.map do |conv|
        {
          id: conv.id,
          title: conv.title,
          updated_at: conv.updated_at,
          message_count: conv.completions.count
        }
      end
    }
  rescue StandardError => e
    render json: {
      success: false,
      error: e.message
    }, status: :unprocessable_entity
  end

  private

  def authenticate_api_key!
    api_key = request.headers['Authorization']&.gsub('Bearer ', '') ||
              params[:api_key]

    if api_key.blank?
      render json: { error: 'API Key requerida' }, status: :unauthorized
      return
    end

    @api_key_record = ApiKey.find_by(api_key:)

    return if @api_key_record&.authorized?(ApiKey::Role::COMPLETIONS)

    error_message = 'API Key inválida o sin permisos.
    Configurala en el icono de configuración'

    render json: { error: error_message },
           status: :unauthorized
  end

  def find_bot
    bot_id = params[:bot_id]

    if bot_id.blank?
      render json: { error: 'bot_id es requerido' },
             status: :unprocessable_entity
      return
    end

    @bot = Bot.find_by(id: bot_id, tenant: @api_key_record.tenant)

    return if @bot

    render json: { error: 'Bot no encontrado o sin acceso' },
           status: :not_found
  end

  def find_or_create_conversation
    return nil unless params[:auto_create_conversation] == 'true'

    @bot.conversations.create!(
      title: "Chat #{Time.current.strftime('%d/%m/%Y %H:%M')}"
    )
  end

  # Helper method to render JSON responses
  def json_response(object, status = :ok)
    render json: object, status:
  end
end
