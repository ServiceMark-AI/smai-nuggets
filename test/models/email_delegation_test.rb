require "test_helper"

class EmailDelegationTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "delegation-test@example.com", password: "Password1", is_pending: false)
  end

  def build_delegation(scopes:)
    EmailDelegation.new(
      user: @user, provider: "google_oauth2",
      email: "delegate@gmail.example.com", access_token: "tok", scopes: scopes
    )
  end

  test "granted_scopes splits the space-delimited scope string" do
    delegation = build_delegation(scopes: "email https://www.googleapis.com/auth/gmail.send")
    assert_equal ["email", "https://www.googleapis.com/auth/gmail.send"], delegation.granted_scopes
  end

  test "granted_scopes is empty when no scopes were recorded" do
    assert_equal [], build_delegation(scopes: nil).granted_scopes
  end

  test "can_send? is true when the gmail.send scope was granted" do
    delegation = build_delegation(scopes: "email https://www.googleapis.com/auth/gmail.send")
    assert delegation.can_send?
  end

  test "can_send? is false when the gmail.send scope was not granted" do
    delegation = build_delegation(scopes: "email https://www.googleapis.com/auth/gmail.metadata")
    assert_not delegation.can_send?
  end

  test "all_scopes_granted? is true when every required Gmail scope is present" do
    delegation = build_delegation(
      scopes: "email https://www.googleapis.com/auth/gmail.send https://www.googleapis.com/auth/gmail.metadata"
    )
    assert delegation.all_scopes_granted?
    assert_empty delegation.missing_scopes
  end

  test "missing_scopes lists each required Gmail scope that was not granted" do
    delegation = build_delegation(scopes: "email https://www.googleapis.com/auth/gmail.send")
    assert_not delegation.all_scopes_granted?
    assert_equal [EmailDelegation::GMAIL_METADATA_SCOPE], delegation.missing_scopes
  end

  test "missing_scopes lists everything when no scopes were recorded" do
    delegation = build_delegation(scopes: nil)
    assert_equal EmailDelegation::REQUIRED_GMAIL_SCOPES, delegation.missing_scopes
  end

  # --- refresh_failed? / reconnect_required? -------------------------------
  # Single source of truth for "is this delegation actually usable", shared
  # by PreSendChecklist and the profile/admin-roster views so a dead-but-
  # present refresh token doesn't read as "connected" in three different
  # places with three different conditions.

  test "refresh_failed? is true when the last refresh failed with invalid_grant" do
    delegation = build_delegation(scopes: nil)
    delegation.refresh_error = "invalid_grant"
    assert delegation.refresh_failed?
  end

  test "refresh_failed? is false when there is no recorded refresh error" do
    delegation = build_delegation(scopes: nil)
    assert_not delegation.refresh_failed?
  end

  test "refresh_failed? is false for a refresh error other than invalid_grant" do
    delegation = build_delegation(scopes: nil)
    delegation.refresh_error = "temporarily_unavailable"
    assert_not delegation.refresh_failed?
  end

  test "reconnect_required? is true when refresh_failed?" do
    delegation = build_delegation(scopes: nil)
    delegation.refresh_token = "present-but-dead"
    delegation.refresh_error = "invalid_grant"
    assert delegation.reconnect_required?
  end

  test "reconnect_required? is true when expired with no refresh_token" do
    delegation = build_delegation(scopes: nil)
    delegation.expires_at = 1.hour.ago
    delegation.refresh_token = nil
    assert delegation.reconnect_required?
  end

  test "reconnect_required? is false for a healthy delegation" do
    delegation = build_delegation(scopes: nil)
    delegation.refresh_token = "rtk"
    delegation.expires_at = 1.hour.from_now
    assert_not delegation.reconnect_required?
  end

  test "reconnect_required? is false for an expired delegation that still has a refresh token and no refresh failure" do
    delegation = build_delegation(scopes: nil)
    delegation.refresh_token = "rtk"
    delegation.expires_at = 1.hour.ago
    assert_not delegation.reconnect_required?
  end
end
