require "test_helper"

class TenantTest < ActiveSupport::TestCase
  test "activated_job_types returns only those with an active join row" do
    tenant = tenants(:one)
    assert_includes tenant.activated_job_types, job_types(:one)
    assert_not_includes tenant.activated_job_types, job_types(:two)
  end

  test "activated_job_types excludes job_types whose join row is inactive" do
    tenant = tenants(:one)
    tenant_job_types(:one_active).update!(is_active: false)
    assert_not_includes tenant.activated_job_types, job_types(:one)
  end

  test "activated_scenarios returns only those with an active join row" do
    tenant = tenants(:one)
    assert_includes tenant.activated_scenarios, scenarios(:sewage_backup)
    assert_not_includes tenant.activated_scenarios, scenarios(:clean_water)
  end

  test "activated_scenarios excludes scenarios whose join row is inactive" do
    tenant = tenants(:one)
    tenant_scenarios(:sewage_active_for_one).update!(is_active: false)
    assert_not_includes tenant.activated_scenarios, scenarios(:sewage_backup)
  end

  test "tenants with no activations get an empty collection, not nil" do
    tenant = tenants(:two)
    assert_equal [], tenant.activated_job_types.to_a
    assert_equal [], tenant.activated_scenarios.to_a
  end
end
