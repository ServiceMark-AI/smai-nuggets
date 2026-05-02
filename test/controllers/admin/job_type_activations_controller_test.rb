require "test_helper"

class Admin::JobTypeActivationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user = users(:one)
    @tenant = tenants(:two)         # nothing activated
    @job_type = job_types(:two)
  end

  test "non-admin users cannot toggle activations" do
    sign_in @user
    post admin_tenant_job_type_activations_url(@tenant), params: { job_type_id: @job_type.id }
    assert_redirected_to root_path
  end

  test "create activates a job type for the tenant" do
    sign_in @admin
    assert_difference -> { TenantJobType.where(is_active: true).count }, 1 do
      post admin_tenant_job_type_activations_url(@tenant), params: { job_type_id: @job_type.id }
    end
    assert_redirected_to admin_tenant_activations_path(@tenant)
    record = TenantJobType.find_by!(tenant: @tenant, job_type: @job_type)
    assert record.is_active
  end

  test "create is idempotent — re-activating an existing row keeps it active" do
    record = TenantJobType.create!(tenant: @tenant, job_type: @job_type, is_active: false)
    sign_in @admin
    assert_no_difference -> { TenantJobType.count } do
      post admin_tenant_job_type_activations_url(@tenant), params: { job_type_id: @job_type.id }
    end
    assert record.reload.is_active
  end

  test "destroy deactivates the job type and cascades to its scenarios" do
    record = tenant_job_types(:one_active)
    cascading_scenario = tenant_scenarios(:sewage_active_for_one)
    assert cascading_scenario.is_active

    sign_in @admin
    delete admin_tenant_job_type_activation_url(record.tenant, record)

    assert_redirected_to admin_tenant_activations_path(record.tenant)
    refute record.reload.is_active
    refute cascading_scenario.reload.is_active
  end

  test "activate_all_scenarios upserts active TenantScenario rows under the job type" do
    record = tenant_job_types(:one_active)
    sign_in @admin
    expected_count = record.job_type.scenarios.count
    post activate_all_scenarios_admin_tenant_job_type_activation_url(record.tenant, record)
    assert_redirected_to admin_tenant_activations_path(record.tenant)

    record.job_type.scenarios.each do |scenario|
      ts = TenantScenario.find_by!(tenant: record.tenant, scenario: scenario)
      assert ts.is_active, "expected scenario #{scenario.code} to be active"
    end
    assert_equal expected_count,
                 record.tenant.tenant_scenarios.where(scenario_id: record.job_type.scenarios).count
  end
end
