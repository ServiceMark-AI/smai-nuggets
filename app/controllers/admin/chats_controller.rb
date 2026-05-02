class Admin::ChatsController < Admin::BaseController
  def index
    @chats = Chat.includes(:messages, :model).order(created_at: :desc)
  end

  def show
    @chat = Chat.find(params[:id])
    @messages = @chat.messages.order(:created_at)
  end
end
