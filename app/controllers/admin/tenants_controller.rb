class Admin::TenantsController < Admin::BaseController
  before_action :set_tenant, only: [:show]

  def index
    @tenants = Tenant.order(:name)
  end

  def show
    @invitation = Invitation.new
    @pending_invitations = @tenant.invitations.where(accepted_at: nil).order(created_at: :desc)
    @users = @tenant.users.order(:email)
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(name: params.dig(:tenant, :name))
    Tenant.transaction do
      @tenant.save!
      @tenant.organizations.create!(name: @tenant.name)
    end
    redirect_to admin_tenant_path(@tenant), notice: "Tenant '#{@tenant.name}' created with a top-level organization."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end
end
