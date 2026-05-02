class Admin::MessagesController < Admin::BaseController
  def index
    @messages = Message.includes(:chat, :model).order(created_at: :desc).limit(200)
  end
end
