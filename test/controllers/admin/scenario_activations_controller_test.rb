require "test_helper"

class Admin::ScenarioActivationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user = users(:one)
    @tenant = tenants(:one) # has tenant_job_types(:one_active) → job_types(:one) active
    @scenario_under_active_jt = scenarios(:clean_water) # scenarios(:clean_water).job_type == job_types(:one)
    @scenario_under_inactive_jt = nil # built per-test below
  end

  test "non-admin users cannot toggle scenario activations" do
    sign_in @user
    post admin_tenant_scenario_activations_url(@tenant), params: { scenario_id: @scenario_under_active_jt.id }
    assert_redirected_to root_path
  end

  test "create activates a scenario when its parent job type is active" do
    sign_in @admin
    assert_difference -> { TenantScenario.where(is_active: true).count }, 1 do
      post admin_tenant_scenario_activations_url(@tenant),
           params: { scenario_id: @scenario_under_active_jt.id }
    end
    assert_redirected_to admin_tenant_activations_path(@tenant)
  end

  test "create rejects activation when the parent job type is not active" do
    other_job_type = job_types(:two) # not activated for @tenant
    orphan_scenario = Scenario.create!(job_type: other_job_type, code: "orphan", short_name: "Orphan")

    sign_in @admin
    assert_no_difference -> { TenantScenario.count } do
      post admin_tenant_scenario_activations_url(@tenant), params: { scenario_id: orphan_scenario.id }
    end
    assert_redirected_to admin_tenant_activations_path(@tenant)
    follow_redirect!
    assert_match(/Activate .* before activating its scenarios/i, response.body)
  end

  test "destroy deactivates an active scenario" do
    record = tenant_scenarios(:sewage_active_for_one)
    sign_in @admin
    delete admin_tenant_scenario_activation_url(record.tenant, record)
    assert_redirected_to admin_tenant_activations_path(record.tenant)
    refute record.reload.is_active
  end
end
