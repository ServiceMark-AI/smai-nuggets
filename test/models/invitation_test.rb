require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @tenant = Tenant.create!(name: "InvCo")
    @org = @tenant.organizations.create!(name: "HQ")
    @inviter = users(:admin)
    @invitation = Invitation.create!(
      tenant: @tenant,
      organization: @org,
      invited_by_user: @inviter,
      email: "joiner@example.com"
    )
  end

  test "accept! attaches the user to the tenant when they have none" do
    user = User.create!(email: "joiner@example.com", password: "Password1")
    @invitation.accept!(user)
    assert_equal @tenant, user.reload.tenant
  end

  test "accept! creates the OrganizationalMember row" do
    user = User.create!(email: "joiner@example.com", password: "Password1")
    assert_difference "OrganizationalMember.count", 1 do
      @invitation.accept!(user)
    end
    assert_includes user.organizations, @org
  end

  test "accept! flips is_pending to false on the joining user" do
    user = User.create!(email: "joiner@example.com", password: "Password1") # default is_pending=true
    assert user.is_pending, "fixture sanity: is_pending defaults to true"
    @invitation.accept!(user)
    refute user.reload.is_pending,
      "is_pending should clear so the joiner shows Active in the Users table"
  end

  test "accept! stamps accepted_at" do
    user = User.create!(email: "joiner@example.com", password: "Password1")
    assert_nil @invitation.accepted_at
    @invitation.accept!(user)
    assert_not_nil @invitation.reload.accepted_at
  end

  test "accept! does not flip is_pending on a user who is already active" do
    user = User.create!(email: "joiner@example.com", password: "Password1", is_pending: false)
    @invitation.accept!(user)
    refute user.reload.is_pending
  end

  # --- send_blockers ---

  test "send_blockers is empty when APP_HOST is set and a mailbox is connected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    assert_empty Invitation.send_blockers
    assert Invitation.can_send?
  end

  test "send_blockers reports the mailbox gap when no ApplicationMailbox exists" do
    refute Invitation.can_send?
    assert_match(/no Gmail account is connected/i, Invitation.send_blockers.join(" "))
  end

  test "send_blockers reports the APP_HOST gap when the env var is unset" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    prior = ENV.delete("APP_HOST")
    begin
      assert_match(/APP_HOST is not set/i, Invitation.send_blockers.join(" "))
    ensure
      ENV["APP_HOST"] = prior
    end
  end

  test "send_blockers lists both gaps when both are missing" do
    prior = ENV.delete("APP_HOST")
    begin
      blockers = Invitation.send_blockers
      assert_match(/APP_HOST/i, blockers.join(" "))
      assert_match(/Gmail account/i, blockers.join(" "))
      assert_equal 2, blockers.size
    ensure
      ENV["APP_HOST"] = prior
    end
  end
end
