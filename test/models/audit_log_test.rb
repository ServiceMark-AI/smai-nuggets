require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @actor = users(:admin)
  end

  test "valid with required fields" do
    log = AuditLog.new(
      tenant: @tenant, actor_user: @actor,
      action: "tenant.update", target_type: "Tenant", target_id: @tenant.id,
      payload: { before: { name: "old" }, after: { name: "new" } }
    )
    assert log.valid?
  end

  test "rejects updates after creation" do
    log = AuditLog.create!(
      tenant: @tenant, action: "x", target_type: "Tenant", target_id: @tenant.id
    )
    assert_raises(ActiveRecord::ReadOnlyRecord) { log.update!(action: "y") }
  end

  test "rejects destroy" do
    log = AuditLog.create!(
      tenant: @tenant, action: "x", target_type: "Tenant", target_id: @tenant.id
    )
    assert_raises(ActiveRecord::ReadOnlyRecord) { log.destroy }
  end
end

class AuditLoggerTest < ActiveSupport::TestCase
  test "writes an audit log row with before/after" do
    tenant = tenants(:one)
    actor = users(:admin)
    assert_difference "AuditLog.count", 1 do
      AuditLogger.write(
        tenant: tenant, actor: actor,
        action: "tenant.update", target: tenant,
        before: { name: "Old Name" }, after: { name: "New Name" }
      )
    end
    log = AuditLog.last
    assert_equal "tenant.update", log.action
    assert_equal "Tenant", log.target_type
    assert_equal tenant.id, log.target_id
    assert_equal "Old Name", log.payload["before"]["name"]
    assert_equal "New Name", log.payload["after"]["name"]
  end
end
