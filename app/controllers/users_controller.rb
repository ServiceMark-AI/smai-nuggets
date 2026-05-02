class UsersController < ApplicationController
  def index
    @tenant = current_user.tenant
    if @tenant
      @users = @tenant.users.order(:email)
      @pending_invitations = @tenant.invitations.where(accepted_at: nil).order(created_at: :desc)
    else
      @users = User.none
      @pending_invitations = Invitation.none
    end
    @invitation = Invitation.new
  end
end
