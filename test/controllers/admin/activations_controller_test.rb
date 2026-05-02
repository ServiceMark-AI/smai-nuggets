require "test_helper"

class Admin::ActivationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user = users(:one)
    @tenant = tenants(:one)
  end

  test "non-admin users cannot access the activations page" do
    sign_in @user
    get admin_tenant_activations_url(@tenant)
    assert_redirected_to root_path
  end

  test "admin sees all job types listed" do
    sign_in @admin
    get admin_tenant_activations_url(@tenant)
    assert_response :success
    JobType.order(:name).each do |jt|
      assert_match jt.name, response.body
    end
  end

  test "active job types render their scenario subrows" do
    # tenant_job_types(:one_active) activates job_types(:one) for tenants(:one)
    sign_in @admin
    get admin_tenant_activations_url(@tenant)
    assert_response :success
    job_types(:one).scenarios.each do |s|
      assert_match s.short_name, response.body
    end
  end

  test "inactive job types do not render their scenarios" do
    # job_types(:two) is not activated for tenants(:one); scenarios(:clean_water)
    # belongs to job_types(:one) — but we have no fixture scenario under job_types(:two).
    # We add a transient scenario for the test.
    other_job_type = job_types(:two)
    transient_scenario = Scenario.create!(job_type: other_job_type, code: "transient", short_name: "Hidden Scenario")
    sign_in @admin
    get admin_tenant_activations_url(@tenant)
    assert_no_match transient_scenario.short_name, response.body
  end
end
