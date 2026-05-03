require "test_helper"

class Admin::InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @tenant = Tenant.create!(name: "InviteCo")
    @org = @tenant.organizations.create!(name: "InviteCo")
  end

  test "non-admin cannot create invitations" do
    sign_in @non_admin
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "x@example.com" } }
    end
    assert_redirected_to root_path
  end

  test "without an application mailbox the invitation is created but no email is sent" do
    sign_in @admin
    assert_difference "Invitation.count", 1 do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "lead@example.com" } }
    end
    assert_empty GmailSender.deliveries
    follow_redirect!
    assert_match(/no application mailbox is connected/i, response.body)
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
    assert_equal "lead@example.com", delivery[:to]
    assert_equal "noreply@app.example.com", delivery[:from]
    assert_match @tenant.name, delivery[:subject]
    invitation = Invitation.last
    assert_match invitation.token, delivery[:body]
  end

  test "creating an invitation with a blank email is rejected" do
    sign_in @admin
    assert_no_difference "Invitation.count" do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "" } }
    end
    assert_redirected_to admin_tenant_path(@tenant)
    assert_match(/email can/i, flash[:alert].to_s)
  end

  # --- destroy (revoke) ----------------------------------------------------

  test "non-admin cannot revoke invitations" do
    invitation = @tenant.invitations.create!(organization: @org, invited_by_user: @admin, email: "x@example.com")
    sign_in @non_admin

    assert_no_difference "Invitation.count" do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_redirected_to root_path
  end

  test "admin revokes a pending invitation in any tenant" do
    invitation = @tenant.invitations.create!(organization: @org, invited_by_user: @admin, email: "revoke-me@example.com")
    sign_in @admin

    assert_difference "Invitation.count", -1 do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_redirected_to admin_tenant_path(@tenant)
    assert_match(/Revoked invitation/i, flash[:notice].to_s)
  end

  test "destroy with a foreign tenant id 404-ish redirects with not-found" do
    other_tenant = Tenant.create!(name: "Other")
    other_org = other_tenant.organizations.create!(name: "HQ")
    invitation = other_tenant.invitations.create!(organization: other_org, invited_by_user: @admin, email: "lone@example.com")
    sign_in @admin

    assert_no_difference "Invitation.count" do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_match(/not found/i, flash[:alert].to_s)
  end

  test "admin destroy refuses to revoke an already-accepted invitation" do
    invitation = @tenant.invitations.create!(organization: @org, invited_by_user: @admin, email: "claimed@example.com")
    invitation.update!(accepted_at: Time.current)
    sign_in @admin

    assert_no_difference "Invitation.count" do
      delete admin_tenant_invitation_url(@tenant, invitation)
    end
    assert_match(/already been accepted/i, flash[:alert].to_s)
  end
end
