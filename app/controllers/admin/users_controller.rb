class Admin::UsersController < Admin::BaseController
  EDITABLE_PARAMS = %i[first_name last_name title phone_number location_id].freeze

  before_action :load_tenant
  before_action :load_user

  def edit
    @location_options = @tenant.locations.active.order(:display_name)
  end

  def update
    before = audit_snapshot(@user)
    if @user.update(user_params)
      AuditLogger.write(
        tenant: @tenant, actor: current_user,
        action: "user.update", target: @user,
        before: before, after: audit_snapshot(@user)
      )
      redirect_to admin_tenant_path(@tenant), notice: "Updated #{@user.display_name}."
    else
      @location_options = @tenant.locations.active.order(:display_name)
      render :edit, status: :unprocessable_content
    end
  end

  private

  def load_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end

  def load_user
    @user = @tenant.users.find_by(id: params[:id])
    return if @user
    redirect_to admin_tenant_path(@tenant), alert: "User not found in this tenant."
  end

  def user_params
    attrs = params.require(:user).permit(*EDITABLE_PARAMS)
    # Defense in depth: drop a tampered location_id that doesn't belong
    # to the tenant being edited.
    if attrs[:location_id].present? &&
       !@tenant.locations.exists?(id: attrs[:location_id])
      attrs = attrs.except(:location_id)
    end
    attrs
  end

  def audit_snapshot(user)
    user.slice(:first_name, :last_name, :title, :phone_number, :location_id)
  end
end
