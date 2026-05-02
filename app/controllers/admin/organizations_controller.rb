class Admin::OrganizationsController < Admin::BaseController
  def show
    @organization = Organization.find(params[:id])
    @members = @organization.users.order(:email)
    @children = @organization.children.order(:name)
    @location = @organization.location
  end
end
