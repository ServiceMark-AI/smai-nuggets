require "test_helper"

class JobTypeTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
  end

  def valid_attrs(overrides = {})
    {
      tenant: @tenant,
      name: "Water Mitigation",
      type_code: "WTR-MIT"
    }.merge(overrides)
  end

  test "valid with all required fields" do
    assert JobType.new(valid_attrs).valid?
  end

  test "requires name" do
    refute JobType.new(valid_attrs(name: nil)).valid?
  end

  test "requires type_code" do
    refute JobType.new(valid_attrs(type_code: nil)).valid?
  end

  test "type_code may not exceed 64 characters" do
    refute JobType.new(valid_attrs(type_code: "X" * 65)).valid?
    assert JobType.new(valid_attrs(type_code: "X" * 64)).valid?
  end

  test "type_code is unique within a tenant (case-insensitive)" do
    JobType.create!(valid_attrs)
    duplicate = JobType.new(valid_attrs(name: "Other"))
    refute duplicate.valid?
    case_diff = JobType.new(valid_attrs(name: "Lowercased", type_code: "wtr-mit"))
    refute case_diff.valid?
  end

  test "the same type_code may exist in a different tenant" do
    JobType.create!(valid_attrs)
    other = JobType.new(valid_attrs(tenant: tenants(:two)))
    assert other.valid?
  end
end
