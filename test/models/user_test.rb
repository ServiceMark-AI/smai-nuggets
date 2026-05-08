require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @location = locations(:ne_dallas)
  end

  test "is_tenant_admin? is true when the user has a tenant and no location" do
    user = User.new(tenant: @tenant)
    assert user.is_tenant_admin?
  end

  test "is_tenant_admin? is false when the user has a location" do
    user = User.new(tenant: @tenant, location: @location)
    refute user.is_tenant_admin?
  end

  test "is_tenant_admin? is false for a tenantless user" do
    user = User.new
    refute user.is_tenant_admin?
  end

  test "is_tenant_admin? does not consider is_admin (orthogonal)" do
    # An application admin attached to a tenant with no location is also
    # technically a tenant admin by this predicate. is_admin is a separate
    # concern handled at call sites.
    user = User.new(tenant: @tenant, is_admin: true)
    assert user.is_tenant_admin?
  end

  test "can_invite_into_tenant? is false when the user has no tenant" do
    user = User.new
    refute user.can_invite_into_tenant?
  end

  test "can_invite_into_tenant? is true for an account admin (tenant, no location)" do
    user = User.new(tenant: @tenant)
    assert user.can_invite_into_tenant?
  end

  test "can_invite_into_tenant? is false for a regular user (tenant + location)" do
    user = User.new(tenant: @tenant, location: @location)
    refute user.can_invite_into_tenant?
  end

  test "can_invite_into_tenant? is true for an application admin attached to a tenant" do
    user = User.new(tenant: @tenant, location: @location, is_admin: true)
    assert user.can_invite_into_tenant?
  end

  test "can_invite_into_tenant? is false for a system admin with no tenant context" do
    user = User.new(is_admin: true)
    refute user.can_invite_into_tenant?
  end

  test "scoped_to_location? is true for a regular tenant user" do
    user = User.new(tenant: @tenant, location: @location)
    assert user.scoped_to_location?
  end

  test "scoped_to_location? is false for an account admin (no location)" do
    user = User.new(tenant: @tenant)
    refute user.scoped_to_location?
  end

  test "scoped_to_location? is false for an application admin even with a location" do
    user = User.new(tenant: @tenant, location: @location, is_admin: true)
    refute user.scoped_to_location?
  end

  test "scoped_to_location? is false for a tenantless user" do
    user = User.new
    refute user.scoped_to_location?
  end
end
