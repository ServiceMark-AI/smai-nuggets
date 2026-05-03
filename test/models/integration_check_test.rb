require "test_helper"

class IntegrationCheckTest < ActiveSupport::TestCase
  setup { IntegrationCheck.delete_all }

  test "record creates a row when none exists for the key" do
    assert_difference "IntegrationCheck.count", 1 do
      IntegrationCheck.record(key: "redis", state: :ok, details: "PING -> PONG")
    end
    row = IntegrationCheck.find_by!(key: "redis")
    assert_equal "ok", row.state
    assert_equal "PING -> PONG", row.details
    assert_not_nil row.last_checked_at
  end

  test "record updates the existing row for the same key" do
    IntegrationCheck.record(key: "redis", state: :ok, details: "first")

    assert_no_difference "IntegrationCheck.count" do
      IntegrationCheck.record(key: "redis", state: :missing, details: "second", error_message: "boom")
    end
    row = IntegrationCheck.find_by!(key: "redis")
    assert_equal "missing", row.state
    assert_equal "second", row.details
    assert_equal "boom", row.error_message
  end

  test "key uniqueness is enforced" do
    IntegrationCheck.create!(key: "redis", state: :ok, details: "first")
    dup = IntegrationCheck.new(key: "redis", state: :ok, details: "second")
    assert_not dup.valid?
  end

  test "state enum exposes predicates and rejects unknown values" do
    row = IntegrationCheck.create!(key: "redis", state: :ok, details: "x")
    assert row.state_ok?
    assert_raises ArgumentError do
      IntegrationCheck.new(key: "redis", state: "exploded")
    end
  end
end
