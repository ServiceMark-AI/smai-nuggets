require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @tenant = Tenant.create!(name: "InviteCo")
    @inviter = users(:admin)
    @invitation = Invitation.create!(
      tenant: @tenant,
      invited_by_user: @inviter,
      email: "newperson@example.com"
    )
  end

  def signed_in_inviter(email:, **overrides)
    inviter = User.create!(email: email, password: "Password1", is_pending: false, tenant: @tenant, **overrides)
    sign_in inviter
    inviter
  end

  test "expired or unknown tokens redirect to root with an alert" do
    get invitation_url("nope")
    assert_redirected_to root_path
    assert_match(/not found or expired/i, flash[:alert].to_s)
  end

  test "signed-in user accepting an invitation joins the tenant" do
    accepter = User.create!(email: "joiner@example.com", password: "Password1", is_pending: false)
    sign_in accepter

    get invitation_url(@invitation.token)
    assert_redirected_to root_path

    accepter.reload
    assert_equal @tenant, accepter.tenant
    assert_not_nil @invitation.reload.accepted_at
  end

  test "anonymous visit stores the token in session and redirects to sign-up" do
    get invitation_url(@invitation.token)
    assert_redirected_to new_user_registration_path(email: @invitation.email)
    follow_redirect!
    assert_select "input[name='user[email]'][value=?]", @invitation.email
  end

  test "signing up after visiting the invite link claims the invitation" do
    get invitation_url(@invitation.token)
    follow_redirect!  # at /users/sign_up

    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: { email: @invitation.email, password: "Password1", password_confirmation: "Password1" }
      }
    end
    user = User.find_by!(email: @invitation.email)
    assert_equal @tenant, user.tenant
    assert_not_nil @invitation.reload.accepted_at
  end

  # --- create (tenant-scoped invite from /users index) ----------------------

  test "create requires authentication" do
    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "x@example.com", is_account_admin: "1" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "tenant-less user cannot create an invitation" do
    orphan = User.create!(email: "orphan@example.com", password: "Password1", is_pending: false)
    sign_in orphan

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "x@example.com", is_account_admin: "1" } }
    end
    assert_redirected_to users_path
    assert_match(/not assigned to a tenant/i, flash[:alert].to_s)
  end

  test "without an application mailbox the invitation is refused with a clear blocker message" do
    signed_in_inviter(email: "inviter@example.com")

    GmailSender.reset_deliveries!
    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "lead@example.com", is_account_admin: "1" } }
    end
    assert_empty GmailSender.deliveries
    assert_redirected_to users_path
    assert_match(/can't send invitations/i, flash[:alert].to_s)
    assert_match(/no Gmail account is connected/i, flash[:alert].to_s)
  end

  test "without APP_HOST the invitation is refused with a clear blocker message" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "inviter-noapphost@example.com")

    prior = ENV.delete("APP_HOST")
    begin
      assert_no_difference "Invitation.count" do
        post invitations_path, params: { invitation: { email: "lead@example.com", is_account_admin: "1" } }
      end
      assert_match(/APP_HOST is not set/i, flash[:alert].to_s)
    ensure
      ENV["APP_HOST"] = prior
    end
  end

  test "invites send via the application mailbox when one is connected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok", expires_at: 1.hour.from_now)
    signed_in_inviter(email: "inviter2@example.com", first_name: "Inga", last_name: "Vega")

    GmailSender.reset_deliveries!
    assert_difference "Invitation.count", 1 do
      post invitations_path, params: { invitation: { email: "newhire@example.com", is_account_admin: "1" } }
    end

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal ["newhire@example.com"], delivery[:to]
    assert_equal %("Inga Vega" <noreply@app.example.com>), delivery[:from]
    assert_match @tenant.name, delivery[:subject]
    invitation = Invitation.where(email: "newhire@example.com").last
    assert_equal @tenant, invitation.tenant
    assert_match invitation.token, delivery[:body]
    assert_match(/Inga Vega/, delivery[:body])
  end

  test "create with blank email is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "inviter3@example.com")

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "", is_account_admin: "1" } }
    end
    assert_redirected_to users_path
    assert_match(/email can/i, flash[:alert].to_s)
  end

  # --- existing-user disposition ------------------------------------------

  test "inviting an existing tenant-less user adopts them into the tenant without sending mail" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "adopter@example.com")

    existing_user = User.create!(email: "tenantless@example.com", password: "Password1", is_pending: false)

    GmailSender.reset_deliveries!
    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "tenantless@example.com", is_account_admin: "1" } }
    end
    assert_empty GmailSender.deliveries
    assert_equal @tenant, existing_user.reload.tenant
    assert_match(/Added tenantless@example.com/i, flash[:notice].to_s)
  end

  test "inviting an email already in the same tenant is rejected with a friendly message" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "inviter-already@example.com")

    User.create!(email: "alreadyhere@example.com", password: "Password1", is_pending: false, tenant: @tenant)

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "alreadyhere@example.com", is_account_admin: "1" } }
    end
    assert_match(/already in #{Regexp.escape(@tenant.name)}/i, flash[:alert].to_s)
  end

  test "inviting an email belonging to a different tenant is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "inviter-cross@example.com")

    other_tenant = Tenant.create!(name: "OtherTenant")
    User.create!(email: "elsewhere@example.com", password: "Password1", is_pending: false, tenant: other_tenant)

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "elsewhere@example.com", is_account_admin: "1" } }
    end
    assert_match(/another tenant/i, flash[:alert].to_s)
  end

  test "inviting an email belonging to a system admin is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "inviter-adminemail@example.com")

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: users(:admin).email, is_account_admin: "1" } }
    end
    assert_match(/system admin/i, flash[:alert].to_s)
  end

  # --- destroy (revoke) ----------------------------------------------------

  test "destroy redirects to sign-in when not signed in" do
    delete invitation_path(@invitation)
    assert_redirected_to new_user_session_path
  end

  test "tenant user can revoke a pending invitation in their tenant" do
    signed_in_inviter(email: "revoker@example.com")

    assert_difference "Invitation.count", -1 do
      delete invitation_path(@invitation)
    end
    assert_redirected_to users_path
    assert_match(/Revoked invitation/i, flash[:notice].to_s)
  end

  test "user from another tenant cannot revoke a foreign invitation" do
    other_tenant = Tenant.create!(name: "OtherCo")
    outsider = User.create!(email: "outsider@example.com", password: "Password1", is_pending: false, tenant: other_tenant)
    sign_in outsider

    assert_no_difference "Invitation.count" do
      delete invitation_path(@invitation)
    end
    assert_redirected_to users_path
    assert_match(/not found/i, flash[:alert].to_s)
  end

  test "tenant-less user cannot revoke any invitation" do
    orphan = User.create!(email: "orphan2@example.com", password: "Password1", is_pending: false)
    sign_in orphan

    assert_no_difference "Invitation.count" do
      delete invitation_path(@invitation)
    end
    assert_match(/not found/i, flash[:alert].to_s)
  end

  test "destroy refuses to revoke an already-accepted invitation" do
    @invitation.update!(accepted_at: Time.current)
    signed_in_inviter(email: "revoker2@example.com")

    assert_no_difference "Invitation.count" do
      delete invitation_path(@invitation)
    end
    assert_match(/already been accepted/i, flash[:alert].to_s)
  end

  # --- location handling --------------------------------------------------

  test "create rejects when neither admin nor location is provided" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "needs-loc@example.com")

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "newhire1@example.com" } }
    end
    assert_redirected_to users_path
    assert_match(/Pick a location, or check Is Account Admin/i, flash[:alert].to_s)
  end

  test "create persists location_id on the invitation when one is chosen" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "with-loc@example.com")
    location = @tenant.locations.create!(
      display_name: "Dallas", address_line_1: "1 Main",
      city: "Dallas", state: "TX", postal_code: "75001", phone_number: "(214) 555-0101", is_active: true
    )

    assert_difference "Invitation.count", 1 do
      post invitations_path, params: { invitation: { email: "loc-person@example.com", location_id: location.id } }
    end
    invitation = Invitation.where(email: "loc-person@example.com").last
    assert_equal location, invitation.location
  end

  test "create rejects a location that belongs to a different tenant" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    signed_in_inviter(email: "cross-loc@example.com")
    other_tenant = Tenant.create!(name: "OtherCo2")
    foreign_location = other_tenant.locations.create!(
      display_name: "Reno", address_line_1: "9 Foreign",
      city: "Reno", state: "NV", postal_code: "89501", phone_number: "(775) 555-0101", is_active: true
    )

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "leak@example.com", location_id: foreign_location.id } }
    end
    assert_match(/isn't part of your tenant/i, flash[:alert].to_s)
  end

  test "is_account_admin checked allows the invite to go through with no location" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok", expires_at: 1.hour.from_now)
    signed_in_inviter(email: "admin-invite@example.com")

    assert_difference "Invitation.count", 1 do
      post invitations_path, params: { invitation: { email: "another-admin@example.com", is_account_admin: "1" } }
    end
    invitation = Invitation.where(email: "another-admin@example.com").last
    assert_nil invitation.location_id
  end
end
