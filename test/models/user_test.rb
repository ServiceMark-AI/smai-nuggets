require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @location = locations(:ne_dallas)
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
end
