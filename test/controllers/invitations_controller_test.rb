require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @tenant = Tenant.create!(name: "InviteCo")
    @org = @tenant.organizations.create!(name: "InviteCo")
    @inviter = users(:admin)
    @invitation = Invitation.create!(
      tenant: @tenant,
      organization: @org,
      invited_by_user: @inviter,
      email: "newperson@example.com"
    )
  end

  test "expired or unknown tokens redirect to root with an alert" do
    get invitation_url("nope")
    assert_redirected_to root_path
    assert_match(/not found or expired/i, flash[:alert].to_s)
  end

  test "signed-in user accepting an invitation joins the tenant and org" do
    accepter = User.create!(email: "joiner@example.com", password: "Password1", is_pending: false)
    sign_in accepter

    get invitation_url(@invitation.token)
    assert_redirected_to root_path

    accepter.reload
    assert_equal @tenant, accepter.tenant
    assert accepter.organizations.include?(@org)
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
    assert_includes user.organizations, @org
    assert_not_nil @invitation.reload.accepted_at
  end

  # --- create (tenant-scoped invite from /users index) ----------------------

  test "create requires authentication" do
    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "x@example.com" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "tenant-less user cannot create an invitation" do
    orphan = User.create!(email: "orphan@example.com", password: "Password1", is_pending: false)
    sign_in orphan

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "x@example.com" } }
    end
    assert_redirected_to users_path
    assert_match(/not assigned to a tenant/i, flash[:alert].to_s)
  end

  test "tenant member without a connected Gmail still creates the invitation but no email is sent" do
    inviter = User.create!(email: "inviter@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    GmailSender.reset_deliveries!
    assert_difference "Invitation.count", 1 do
      post invitations_path, params: { invitation: { email: "lead@example.com" } }
    end
    assert_empty GmailSender.deliveries
    assert_redirected_to users_path
    follow_redirect!
    assert_match(/no Gmail account is connected/i, response.body)
  end

  test "tenant member with a connected Gmail sends the invite via that delegation" do
    inviter = User.create!(email: "inviter2@example.com", password: "Password1", is_pending: false, tenant: @tenant, first_name: "Inga", last_name: "Vega")
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    inviter.email_delegations.create!(provider: "google_oauth2", email: "inviter-gmail@example.com", access_token: "tok", expires_at: 1.hour.from_now)
    sign_in inviter

    GmailSender.reset_deliveries!
    assert_difference "Invitation.count", 1 do
      post invitations_path, params: { invitation: { email: "newhire@example.com" } }
    end

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal "newhire@example.com", delivery[:to]
    assert_equal "inviter-gmail@example.com", delivery[:from]
    assert_match @tenant.name, delivery[:subject]
    invitation = Invitation.where(email: "newhire@example.com").last
    assert_equal @tenant, invitation.tenant
    assert_equal @org, invitation.organization
    assert_equal inviter, invitation.invited_by_user
    assert_match invitation.token, delivery[:body]
    assert_match(/Inga Vega/, delivery[:body])
  end

  test "create with blank email is rejected" do
    inviter = User.create!(email: "inviter3@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "" } }
    end
    assert_redirected_to users_path
    assert_match(/email can/i, flash[:alert].to_s)
  end

  test "create attaches the invite to the tenant's root org when both root and child orgs exist" do
    child = @tenant.organizations.create!(name: "InviteCo Branch", parent: @org)
    inviter = User.create!(email: "inviter4@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: child, user: inviter, role: :admin)
    sign_in inviter

    post invitations_path, params: { invitation: { email: "rootinvite@example.com" } }
    invitation = Invitation.where(email: "rootinvite@example.com").last
    assert_equal @org, invitation.organization
  end
end
