require "test_helper"

class TenantJobTypeTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:two)
    @job_type = job_types(:two)
  end

  test "valid with required fields" do
    assert TenantJobType.new(tenant: @tenant, job_type: @job_type).valid?
  end

  test "is_active defaults to false" do
    record = TenantJobType.create!(tenant: @tenant, job_type: @job_type)
    refute record.is_active
  end

  test "tenant + job_type combination must be unique" do
    TenantJobType.create!(tenant: @tenant, job_type: @job_type)
    duplicate = TenantJobType.new(tenant: @tenant, job_type: @job_type)
    refute duplicate.valid?
  end

  test "active scope returns only is_active = true rows" do
    inactive = TenantJobType.create!(tenant: @tenant, job_type: @job_type)
    active = tenant_job_types(:one_active)
    assert_includes TenantJobType.active, active
    refute_includes TenantJobType.active, inactive
  end
end
