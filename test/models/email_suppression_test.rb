require "test_helper"

class EmailSuppressionTest < ActiveSupport::TestCase
  setup do
    @location = locations(:ne_dallas)
  end

  test "is valid with an email, location, and recognised reason" do
    suppression = EmailSuppression.new(location: @location, email: "spam@example.com", reason: "hard_bounce")
    assert suppression.valid?
  end

  test "rejects an unknown reason" do
    suppression = EmailSuppression.new(location: @location, email: "spam@example.com", reason: "nope")
    refute suppression.valid?
    assert_includes suppression.errors[:reason].to_s, "not included"
  end

  test "rejects a malformed email" do
    suppression = EmailSuppression.new(location: @location, email: "not-an-email", reason: "manual")
    refute suppression.valid?
  end

  test "is unique per (location, email)" do
    EmailSuppression.create!(location: @location, email: "dupe@example.com", reason: "manual")
    dup = EmailSuppression.new(location: @location, email: "dupe@example.com", reason: "manual")
    refute dup.valid?
  end

  test "uniqueness is case-insensitive" do
    EmailSuppression.create!(location: @location, email: "case@example.com", reason: "manual")
    dup = EmailSuppression.new(location: @location, email: "CASE@example.com", reason: "manual")
    refute dup.valid?
  end

  test "the same email can be suppressed independently in two locations" do
    other = Location.create!(
      tenant: @location.tenant,
      display_name: "Other",
      address_line_1: "1 Other Way",
      city: "Dallas",
      state: "TX",
      postal_code: "75001",
      phone_number: "(555) 555-0001"
    )
    EmailSuppression.create!(location: @location, email: "shared@example.com", reason: "manual")
    second = EmailSuppression.new(location: other, email: "shared@example.com", reason: "manual")
    assert second.valid?
  end

  test ".suppressed? returns true for a matching entry, ignoring case and whitespace" do
    EmailSuppression.create!(location: @location, email: "Match@Example.com", reason: "manual")
    assert EmailSuppression.suppressed?(location: @location, email: "  match@example.com ")
  end

  test ".suppressed? returns false when nothing matches" do
    refute EmailSuppression.suppressed?(location: @location, email: "ghost@example.com")
  end

  test ".suppressed? short-circuits on blank inputs" do
    refute EmailSuppression.suppressed?(location: @location, email: nil)
    refute EmailSuppression.suppressed?(location: nil, email: "x@example.com")
  end
end
