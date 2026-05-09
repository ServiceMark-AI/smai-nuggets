class Admin::LocationsController < Admin::BaseController
  before_action :load_tenant

  def new
    @location = @tenant.locations.build
  end

  def create
    @location = @tenant.locations.build(location_params.merge(created_by_user: current_user))
    if @location.save
      AuditLogger.write(
        tenant: @tenant, actor: current_user,
        action: "location.create", target: @location,
        after: @location.slice(:display_name, :address_line_1, :address_line_2, :city, :state, :postal_code, :phone_number, :is_active)
      )
      redirect_to admin_tenant_path(@tenant), notice: "Location added."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def load_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end

  def location_params
    params.require(:location).permit(
      :display_name, :address_line_1, :address_line_2,
      :city, :state, :postal_code, :phone_number, :is_active
    )
  end
end
