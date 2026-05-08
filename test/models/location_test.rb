require "test_helper"

class LocationTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:two)
  end

  def valid_attrs(overrides = {})
    {
      tenant: @tenant,
      display_name: "NE Dallas",
      address_line_1: "10280 Miller Rd",
      city: "Dallas",
      state: "TX",
      postal_code: "75238",
      phone_number: "(214) 343-3973"
    }.merge(overrides)
  end

  test "valid with all required fields" do
    assert Location.new(valid_attrs).valid?
  end

  test "requires tenant" do
    refute Location.new(valid_attrs(tenant: nil)).valid?
  end

  test "requires display_name" do
    refute Location.new(valid_attrs(display_name: nil)).valid?
  end

  test "requires address_line_1" do
    refute Location.new(valid_attrs(address_line_1: nil)).valid?
  end

  test "address_line_2 is optional" do
    assert Location.new(valid_attrs(address_line_2: nil)).valid?
  end

  test "requires city" do
    refute Location.new(valid_attrs(city: nil)).valid?
  end

  test "rejects two-word state names" do
    refute Location.new(valid_attrs(state: "Texas")).valid?
  end

  test "rejects single-letter state codes" do
    refute Location.new(valid_attrs(state: "T")).valid?
  end

  test "upcases state automatically" do
    loc = Location.new(valid_attrs(state: "tx"))
    assert loc.valid?
    assert_equal "TX", loc.state
  end

  test "requires postal_code" do
    refute Location.new(valid_attrs(postal_code: nil)).valid?
  end

  test "requires phone_number" do
    refute Location.new(valid_attrs(phone_number: nil)).valid?
  end

  test "is_active defaults to false" do
    loc = Location.create!(valid_attrs)
    assert_equal false, loc.is_active
  end

  test "active scope returns only active locations" do
    inactive = Location.create!(valid_attrs)
    active = Location.create!(valid_attrs(display_name: "Boise", is_active: true))
    assert_includes Location.active, active
    refute_includes Location.active, inactive
  end

  test "a tenant may have multiple locations" do
    first = Location.create!(valid_attrs)
    second = Location.new(valid_attrs(display_name: "South Dallas"))
    assert second.valid?
    assert_equal first.tenant_id, second.tenant_id
  end
end
