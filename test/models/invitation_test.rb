require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @tenant = Tenant.create!(name: "InvCo")
    @inviter = users(:admin)
    @invitation = Invitation.create!(
      tenant: @tenant,
      invited_by_user: @inviter,
      email: "joiner@example.com"
    )
  end

  test "accept! attaches the user to the tenant when they have none" do
    user = User.create!(email: "joiner@example.com", password: "Password1")
    @invitation.accept!(user)
    assert_equal @tenant, user.reload.tenant
  end

  test "accept! attaches the user to the tenant (no location when invite has none)" do
    user = User.create!(email: "joiner@example.com", password: "Password1")
    @invitation.accept!(user)
    assert_equal @tenant, user.reload.tenant
    assert_nil user.location_id
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

  # --- location handling ---

  test "accept! sets user.location when the invitation has a location" do
    location = Location.create!(
      tenant: @tenant, display_name: "Dallas", address_line_1: "1 Main",
      city: "Dallas", state: "TX", postal_code: "75001", phone_number: "(214) 555-0101", is_active: true
    )
    invitation = Invitation.create!(
      tenant: @tenant, location: location,
      invited_by_user: @inviter, email: "loc-joiner@example.com"
    )
    user = User.create!(email: "loc-joiner@example.com", password: "Password1")

    invitation.accept!(user)
    assert_equal location, user.reload.location
  end

  test "accept! leaves user.location nil when the invitation has no location" do
    user = User.create!(email: "joiner@example.com", password: "Password1")
    @invitation.accept!(user)
    assert_nil user.reload.location_id
  end

  test "accept! copies invitee profile fields onto the joining user" do
    @invitation.update!(first_name: "Inga", last_name: "Vega", phone_number: "(214) 555-1010")
    user = User.create!(email: "joiner@example.com", password: "Password1")
    @invitation.accept!(user)
    user.reload
    assert_equal "Inga", user.first_name
    assert_equal "Vega", user.last_name
    assert_equal "(214) 555-1010", user.phone_number
  end

  test "accept! does not overwrite name or phone the user already set" do
    @invitation.update!(first_name: "Inga", last_name: "Vega", phone_number: "(214) 555-1010")
    user = User.create!(email: "joiner@example.com", password: "Password1",
                       first_name: "Already", last_name: "Set", phone_number: "(555) 000-0000")
    @invitation.accept!(user)
    user.reload
    assert_equal "Already", user.first_name
    assert_equal "Set", user.last_name
    assert_equal "(555) 000-0000", user.phone_number
  end

  test "invitation is invalid when location belongs to a different tenant" do
    other_tenant = Tenant.create!(name: "OtherInvCo")
    foreign_location = Location.create!(
      tenant: other_tenant, display_name: "Reno", address_line_1: "9 Foreign",
      city: "Reno", state: "NV", postal_code: "89501", phone_number: "(775) 555-0101", is_active: true
    )

    invitation = Invitation.new(
      tenant: @tenant, location: foreign_location,
      invited_by_user: @inviter, email: "leak@example.com"
    )
    refute invitation.valid?
    assert_match(/same tenant/i, invitation.errors[:location].join(" "))
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
