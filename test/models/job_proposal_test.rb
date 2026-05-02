require "test_helper"

class JobProposalTest < ActiveSupport::TestCase
  setup do
    @jp = job_proposals(:in_users_org)
  end

  test "short_address joins house number and street" do
    @jp.update!(customer_house_number: "1247", customer_street: "Oak Ridge Drive")
    assert_equal "1247 Oak Ridge Drive", @jp.short_address
  end

  test "short_address returns the street alone when house number is blank" do
    @jp.update!(customer_house_number: nil, customer_street: "Oak Ridge Drive")
    assert_equal "Oak Ridge Drive", @jp.short_address
  end

  test "short_address returns the house number alone when street is blank" do
    @jp.update!(customer_house_number: "1247", customer_street: nil)
    assert_equal "1247", @jp.short_address
  end

  test "short_address returns nil when both fields are blank" do
    @jp.update!(customer_house_number: nil, customer_street: nil)
    assert_nil @jp.short_address
  end

  test "short_address returns nil when both fields are whitespace" do
    @jp.update!(customer_house_number: "  ", customer_street: "  ")
    assert_nil @jp.short_address
  end

  test "short_address strips whitespace around each component" do
    @jp.update!(customer_house_number: "  1247  ", customer_street: "  Oak Ridge Drive  ")
    assert_equal "1247 Oak Ridge Drive", @jp.short_address
  end
end
