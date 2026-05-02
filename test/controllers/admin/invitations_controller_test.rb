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

  test "admin without a connected Gmail still creates the invitation but no email is sent" do
    sign_in @admin
    assert_difference "Invitation.count", 1 do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "lead@example.com" } }
    end
    assert_empty GmailSender.deliveries
    follow_redirect!
    assert_match(/no Gmail account is connected/i, response.body)
  end

  test "admin with a connected Gmail sends the invitation email via that delegation" do
    @admin.update!(tenant: @tenant)
    @admin.email_delegations.create!(provider: "google_oauth2", email: "admin-gmail@example.com", access_token: "tok", expires_at: 1.hour.from_now)
    sign_in @admin

    assert_difference "Invitation.count", 1 do
      post admin_tenant_invitations_url(@tenant), params: { invitation: { email: "lead@example.com" } }
    end

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal "lead@example.com", delivery[:to]
    assert_equal "admin-gmail@example.com", delivery[:from]
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
end
