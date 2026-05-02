class Admin::ToolCallsController < Admin::BaseController
  def index
    @tool_calls = ToolCall.includes(:message).order(created_at: :desc).limit(200)
  end
end
