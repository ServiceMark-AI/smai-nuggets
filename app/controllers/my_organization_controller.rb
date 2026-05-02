class MyOrganizationController < ApplicationController
  def show
    @organization = current_user.organizations.first
    if @organization
      @other_members = @organization.users.where.not(id: current_user.id).order(:email)
      @location = @organization.location
    end
  end
end
