class Admin::JobTypeActivationsController < Admin::BaseController
  before_action :load_tenant

  # POST /admin/tenants/:tenant_id/job_type_activations  (body: job_type_id=…)
  def create
    job_type = JobType.find(params[:job_type_id])
    record = TenantJobType.find_or_initialize_by(tenant: @tenant, job_type: job_type)
    record.is_active = true
    record.save!
    redirect_to admin_tenant_activations_path(@tenant), notice: "#{job_type.name} activated."
  end

  # DELETE /admin/tenants/:tenant_id/job_type_activations/:id
  # Soft-deactivates and cascades scenarios under the job type to inactive.
  def destroy
    record = @tenant.tenant_job_types.find(params[:id])
    record.update!(is_active: false)
    scenario_ids = record.job_type.scenarios.pluck(:id)
    @tenant.tenant_scenarios.where(scenario_id: scenario_ids)
                            .update_all(is_active: false, updated_at: Time.current)
    redirect_to admin_tenant_activations_path(@tenant), notice: "#{record.job_type.name} deactivated."
  end

  # POST /admin/tenants/:tenant_id/job_type_activations/:id/activate_all_scenarios
  def activate_all_scenarios
    record = @tenant.tenant_job_types.find(params[:id])
    record.job_type.scenarios.find_each do |scenario|
      ts = TenantScenario.find_or_initialize_by(tenant: @tenant, scenario: scenario)
      ts.is_active = true
      ts.save!
    end
    redirect_to admin_tenant_activations_path(@tenant),
      notice: "All scenarios under #{record.job_type.name} activated."
  end

  private

  def load_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end
end
