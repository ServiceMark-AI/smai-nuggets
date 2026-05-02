class Admin::ActivationsController < Admin::BaseController
  def show
    @tenant = Tenant.find(params[:tenant_id])
    @job_types = JobType.includes(:scenarios).order(:name)
    @tenant_job_types = @tenant.tenant_job_types.includes(:job_type).index_by(&:job_type_id)
    @tenant_scenarios = @tenant.tenant_scenarios.index_by(&:scenario_id)
  end
end
