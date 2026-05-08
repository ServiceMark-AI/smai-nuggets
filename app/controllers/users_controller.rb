class UsersController < ApplicationController
  def index
    @tenant = current_user.tenant
    if @tenant
      @users = @tenant.users.includes(:email_delegations, :location).order(:email)
      @pending_invitations = @tenant.invitations.where(accepted_at: nil).order(created_at: :desc)
      @invite_locations = @tenant.locations.active.order(:display_name)
    else
      @users = User.none
      @pending_invitations = Invitation.none
      @invite_locations = Location.none
    end
    @invitation = Invitation.new
  end
end
