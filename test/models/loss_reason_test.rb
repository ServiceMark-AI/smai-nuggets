require "test_helper"

class LossReasonTest < ActiveSupport::TestCase
  def valid_attrs(overrides = {})
    {
      code: "fresh_code",
      display_name: "Fresh Reason",
      sort_order: 100
    }.merge(overrides)
  end

  test "valid with required fields" do
    assert LossReason.new(valid_attrs).valid?
  end

  test "requires code" do
    refute LossReason.new(valid_attrs(code: nil)).valid?
  end

  test "requires display_name" do
    refute LossReason.new(valid_attrs(display_name: nil)).valid?
  end

  test "code is unique" do
    LossReason.create!(valid_attrs(code: "dup"))
    refute LossReason.new(valid_attrs(code: "dup")).valid?
  end

  test "ordered scope sorts by sort_order then display_name" do
    codes = LossReason.ordered.pluck(:code)
    expected = %w[
      price_too_high
      went_with_competitor
      insurance_issue
      no_response_from_customer
      timing_scheduling_conflict
      other
    ]
    assert_equal expected, codes
  end
end
