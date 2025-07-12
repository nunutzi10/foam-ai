# frozen_string_literal: true

# [AdminChatController] definition
# Controller for admin chat functionality
class AdminChatController < ApplicationController
  layout 'admin_chat'
  protect_from_forgery with: :exception

  before_action :authenticate_admin!, except: %i[login authenticate logout]
  before_action :set_bot, only: %i[show send_message messages]

  # GET /admin_chat
  def index
    return unless authenticate_admin!

    @bots = current_admin.tenant.bots.includes(:tenant)
  end

  # GET /admin_chat/:bot_id
  def show
    @messages = @bot.completions
                    .where('prompt IS NOT NULL OR response IS NOT NULL')
                    .order(created_at: :asc)
                    .limit(50)
  end

  # GET /admin_chat/:bot_id/messages (AJAX endpoint)
  def messages
    @messages = @bot.completions
                    .where('prompt IS NOT NULL OR response IS NOT NULL')
                    .order(created_at: :asc)
                    .limit(50)

    render partial: 'messages', locals: { messages: @messages, bot: @bot }
  end

  # POST /admin_chat/:bot_id/message
  def send_message
    message_text = params[:message]&.strip

    if message_text.blank?
      redirect_to admin_chat_path(@bot),
                  alert: 'El mensaje no puede estar vacío'
      return
    end

    begin
      # Create completion using our chat service
      service = ChatCompletionService.new(
        bot_id: @bot.id,
        user_message: message_text
      )

      service.call!

      redirect_to admin_chat_path(@bot), notice: 'Mensaje enviado correctamente'
    rescue StandardError => e
      Rails.logger.error "Error creating completion: #{e.message}"
      redirect_to admin_chat_path(@bot), alert: 'Error al enviar el mensaje'
    end
  end

  # GET /admin_chat/login
  def login
    return unless current_admin

    redirect_to admin_chat_index_path
  end

  # POST /admin_chat/authenticate
  def authenticate
    email = params[:email]
    password = params[:password]

    admin = Admin.find_by(email:)

    if admin&.valid_password?(password)
      session[:admin_id] = admin.id
      redirect_to admin_chat_index_path, notice: 'Autenticación exitosa'
    else
      redirect_to admin_chat_login_path, alert: 'Credenciales inválidas'
    end
  end

  # DELETE /admin_chat/logout
  def logout
    session[:admin_id] = nil
    redirect_to admin_chat_login_path, notice: 'Sesión cerrada'
  end

  private

  def current_admin
    return unless session[:admin_id]

    @current_admin ||= Admin.find_by(id: session[:admin_id])
  end

  helper_method :current_admin

  def set_bot
    @bot = current_admin.tenant.bots.find(params[:bot_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_chat_index_path, alert: 'Bot no encontrado'
  end

  def authenticate_admin!
    unless current_admin
      redirect_to admin_chat_login_path, alert: 'Debes autenticarte primero'
      return false
    end
    true
  end
end
