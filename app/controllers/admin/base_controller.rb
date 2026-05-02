class Admin::BaseController < ApplicationController
  before_action :ensure_admin

  private

  def ensure_admin
    return if current_user&.is_admin
    redirect_to root_path, alert: "You are not authorized to access this page."
  end
end
