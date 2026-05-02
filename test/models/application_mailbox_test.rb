require "test_helper"

class ApplicationMailboxTest < ActiveSupport::TestCase
  def valid_attrs(overrides = {})
    {
      provider: "google_oauth2",
      email: "noreply@app.example.com",
      access_token: "tok"
    }.merge(overrides)
  end

  test "valid with required fields" do
    assert ApplicationMailbox.new(valid_attrs).valid?
  end

  test "requires email" do
    refute ApplicationMailbox.new(valid_attrs(email: nil)).valid?
  end

  test "requires access_token" do
    refute ApplicationMailbox.new(valid_attrs(access_token: nil)).valid?
  end

  test "only one mailbox can exist at a time" do
    ApplicationMailbox.create!(valid_attrs)
    second = ApplicationMailbox.new(valid_attrs(email: "another@app.example.com"))
    refute second.valid?
    assert_match(/already configured/i, second.errors[:base].join)
  end

  test "expired? is false when expires_at is in the future" do
    mb = ApplicationMailbox.new(valid_attrs(expires_at: 1.hour.from_now))
    refute mb.expired?
  end

  test "expired? is true when expires_at has passed" do
    mb = ApplicationMailbox.new(valid_attrs(expires_at: 1.hour.ago))
    assert mb.expired?
  end

  test "expired? is false when expires_at is nil" do
    mb = ApplicationMailbox.new(valid_attrs)
    refute mb.expired?
  end

  test "current returns the configured mailbox or nil" do
    assert_nil ApplicationMailbox.current
    mb = ApplicationMailbox.create!(valid_attrs)
    assert_equal mb, ApplicationMailbox.current
  end
end
