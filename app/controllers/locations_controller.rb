class LocationsController < ApplicationController
  before_action :require_organization
  before_action :require_org_admin
  before_action :load_location, only: [:edit, :update]

  def new
    if @organization.location
      redirect_to edit_location_path and return
    end
    @location = @organization.build_location
  end

  def create
    if @organization.location
      redirect_to edit_location_path, alert: "This organization already has a location." and return
    end
    @location = @organization.build_location(location_params.merge(created_by_user: current_user))
    if @location.save
      redirect_to my_organization_path, notice: "Location added."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @location.update(location_params.merge(updated_by_user: current_user))
      redirect_to my_organization_path, notice: "Location updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def location_params
    params.require(:location).permit(
      :display_name, :address_line_1, :address_line_2,
      :city, :state, :postal_code, :phone_number, :is_active
    )
  end

  def require_organization
    @organization = current_user.organizations.first
    unless @organization
      redirect_to root_path, alert: "You're not a member of any organization yet." and return
    end
  end

  def require_org_admin
    return if current_user.is_admin
    member = current_user.organizational_members.find_by(organization: @organization)
    unless member&.admin?
      redirect_to my_organization_path, alert: "Only an organization admin can manage the location." and return
    end
  end

  def load_location
    @location = @organization.location
    redirect_to new_location_path and return unless @location
  end
end
