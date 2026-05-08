require "test_helper"

class Admin::InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @tenant = Tenant.create!(name: "InviteCo")
  end

  test "non-admin cannot create invitations" do
    sign_in @non_admin
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "x@example.com" } }
    end
    assert_redirected_to root_path
  end

  test "without an application mailbox the invitation is refused with a clear blocker message" do
    sign_in @admin
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "lead@example.com" } }
    end
    assert_empty GmailSender.deliveries
    assert_redirected_to admin_tenant_path(@tenant)
    assert_match(/can't send invitations/i, flash[:alert].to_s)
    assert_match(/no Gmail account is connected/i, flash[:alert].to_s)
  end

  test "without APP_HOST the invitation is refused with a clear blocker message" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok", expires_at: 1.hour.from_now)
    sign_in @admin

    prior = ENV.delete("APP_HOST")
    begin
      assert_no_difference "Invitation.count" do
        post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "lead@example.com" } }
      end
      assert_match(/APP_HOST is not set/i, flash[:alert].to_s)
    ensure
      ENV["APP_HOST"] = prior
    end
  end

  test "invites send via the application mailbox when one is connected" do
    @admin.update!(tenant: @tenant)
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok", expires_at: 1.hour.from_now)
    sign_in @admin

    assert_difference "Invitation.count", 1 do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "lead@example.com" } }
    end

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal ["lead@example.com"], delivery[:to]
    assert_equal %("SMAI Admin" <noreply@app.example.com>), delivery[:from]
    assert_match @tenant.name, delivery[:subject]
    invitation = Invitation.last
    assert_match invitation.token, delivery[:body]
  end

  test "creating an invitation with a blank email is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    sign_in @admin
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "" } }
    end
    assert_redirected_to admin_tenant_path(@tenant)
    assert_match(/email can/i, flash[:alert].to_s)
  end

  # --- existing-user disposition ------------------------------------------

  test "admin: inviting an existing tenant-less user adopts them into the tenant" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    existing = User.create!(email: "tenantless2@example.com", password: "Password1", is_pending: false)
    sign_in @admin

    GmailSender.reset_deliveries!
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "tenantless2@example.com" } }
    end
    assert_empty GmailSender.deliveries
    assert_equal @tenant, existing.reload.tenant
    assert_match(/Added tenantless2@example.com/i, flash[:notice].to_s)
  end

  test "admin: existing user already in same tenant is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    User.create!(email: "alreadyhere2@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    sign_in @admin

    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "alreadyhere2@example.com" } }
    end
    assert_match(/already in #{Regexp.escape(@tenant.name)}/i, flash[:alert].to_s)
  end

  test "admin: existing user in a different tenant is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    other_tenant = Tenant.create!(name: "OtherTenant2")
    User.create!(email: "elsewhere2@example.com", password: "Password1", is_pending: false, tenant: other_tenant)
    sign_in @admin

    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "elsewhere2@example.com" } }
    end
    assert_match(/another tenant/i, flash[:alert].to_s)
  end

  test "admin: invite to admin email rejects" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    sign_in @admin
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: @admin.email } }
    end
    assert_match(/system admin/i, flash[:alert].to_s)
  end

  # --- destroy (revoke) ----------------------------------------------------

  test "non-admin cannot revoke invitations" do
    invitation = @tenant.invitations.create!(invited_by_user: @admin, email: "x@example.com")
    sign_in @non_admin

    assert_no_difference "Invitation.count" do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_redirected_to root_path
  end

  test "admin revokes a pending invitation in any tenant" do
    invitation = @tenant.invitations.create!(invited_by_user: @admin, email: "revoke-me@example.com")
    sign_in @admin

    assert_difference "Invitation.count", -1 do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_redirected_to admin_tenant_path(@tenant)
    assert_match(/Revoked invitation/i, flash[:notice].to_s)
  end

  test "destroy with a foreign tenant id 404-ish redirects with not-found" do
    other_tenant = Tenant.create!(name: "Other")
    invitation = other_tenant.invitations.create!(invited_by_user: @admin, email: "lone@example.com")
    sign_in @admin

    assert_no_difference "Invitation.count" do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_match(/not found/i, flash[:alert].to_s)
  end

  test "admin destroy refuses to revoke an already-accepted invitation" do
    invitation = @tenant.invitations.create!(invited_by_user: @admin, email: "claimed@example.com")
    invitation.update!(accepted_at: Time.current)
    sign_in @admin

    assert_no_difference "Invitation.count" do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_match(/already been accepted/i, flash[:alert].to_s)
  end
end
