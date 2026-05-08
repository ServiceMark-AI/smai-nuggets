class Admin::TenantsController < Admin::BaseController
  before_action :set_tenant, only: [:show]

  def index
    @tenants = Tenant.order(:name)
  end

  def show
    @invitation = Invitation.new
    @pending_invitations = @tenant.invitations.where(accepted_at: nil).order(created_at: :desc)
    @users = @tenant.users.includes(:location).order(:email)
    @locations = @tenant.locations.order(:display_name)
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(name: params.dig(:tenant, :name))
    if @tenant.save
      redirect_to admin_tenant_path(@tenant), notice: "Tenant '#{@tenant.name}' created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end
end
