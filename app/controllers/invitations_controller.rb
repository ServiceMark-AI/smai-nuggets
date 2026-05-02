class InvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @invitation = Invitation.find_active_by_token(params[:id])
    if @invitation.nil?
      redirect_to root_path, alert: "Invitation not found or expired."
      return
    end

    if user_signed_in?
      @invitation.accept!(current_user)
      redirect_to root_path, notice: "Welcome to #{@invitation.tenant.name}!"
    else
      session[:invitation_token] = @invitation.token
      redirect_to new_user_registration_path(email: @invitation.email),
        notice: "You've been invited to #{@invitation.tenant.name}. Sign up to accept."
    end
  end
end
