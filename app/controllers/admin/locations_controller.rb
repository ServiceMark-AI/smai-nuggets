class Admin::LocationsController < Admin::BaseController
  before_action :load_organization

  def new
    if @organization.location
      redirect_to admin_organization_path(@organization),
        alert: "#{@organization.name} already has a location." and return
    end
    @location = @organization.build_location
  end

  def create
    if @organization.location
      redirect_to admin_organization_path(@organization),
        alert: "#{@organization.name} already has a location." and return
    end
    @location = @organization.build_location(location_params.merge(created_by_user: current_user))
    if @location.save
      redirect_to admin_organization_path(@organization), notice: "Location added."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def load_organization
    @organization = Organization.find(params[:organization_id])
  end

  def location_params
    params.require(:location).permit(
      :display_name, :address_line_1, :address_line_2,
      :city, :state, :postal_code, :phone_number, :is_active
    )
  end
end
