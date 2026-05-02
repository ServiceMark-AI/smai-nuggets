class Admin::ScenarioActivationsController < Admin::BaseController
  before_action :load_tenant

  # POST /admin/tenants/:tenant_id/scenario_activations  (body: scenario_id=…)
  # Activates a scenario for this tenant. Requires the parent job type to
  # already be activated for this tenant; otherwise rejected with a flash
  # alert (no orphan scenarios under inactive job types).
  def create
    scenario = Scenario.find(params[:scenario_id])
    parent = @tenant.tenant_job_types.find_by(job_type_id: scenario.job_type_id)
    unless parent&.is_active
      redirect_to admin_tenant_activations_path(@tenant),
        alert: "Activate #{scenario.job_type.name} before activating its scenarios." and return
    end

    record = TenantScenario.find_or_initialize_by(tenant: @tenant, scenario: scenario)
    record.is_active = true
    record.save!
    redirect_to admin_tenant_activations_path(@tenant), notice: "#{scenario.short_name} activated."
  end

  # DELETE /admin/tenants/:tenant_id/scenario_activations/:id
  def destroy
    record = @tenant.tenant_scenarios.find(params[:id])
    record.update!(is_active: false)
    redirect_to admin_tenant_activations_path(@tenant), notice: "#{record.scenario.short_name} deactivated."
  end

  private

  def load_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end
end
