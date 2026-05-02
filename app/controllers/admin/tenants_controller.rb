class Admin::TenantsController < Admin::BaseController
  before_action :set_tenant, only: [:show]

  def index
    @tenants = Tenant.order(:name)
  end

  def show
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end
end
