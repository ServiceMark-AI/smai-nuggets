require "test_helper"

class TenantScenarioTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:two)
    @scenario = scenarios(:clean_water)
  end

  test "valid with required fields" do
    assert TenantScenario.new(tenant: @tenant, scenario: @scenario).valid?
  end

  test "is_active defaults to false" do
    record = TenantScenario.create!(tenant: @tenant, scenario: @scenario)
    refute record.is_active
  end

  test "tenant + scenario combination must be unique" do
    TenantScenario.create!(tenant: @tenant, scenario: @scenario)
    duplicate = TenantScenario.new(tenant: @tenant, scenario: @scenario)
    refute duplicate.valid?
  end

  test "active scope returns only is_active = true rows" do
    inactive = TenantScenario.create!(tenant: @tenant, scenario: @scenario)
    active = tenant_scenarios(:sewage_active_for_one)
    assert_includes TenantScenario.active, active
    refute_includes TenantScenario.active, inactive
  end
end
