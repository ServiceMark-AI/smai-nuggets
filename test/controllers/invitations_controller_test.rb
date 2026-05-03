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

  test "without an application mailbox the invitation is refused with a clear blocker message" do
    inviter = User.create!(email: "inviter@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    GmailSender.reset_deliveries!
    assert_no_difference "Invitation.count" do
      post invitations_path, params: { invitation: { email: "lead@example.com" } }
    end
    assert_empty GmailSender.deliveries
    assert_redirected_to users_path
    assert_match(/can't send invitations/i, flash[:alert].to_s)
    assert_match(/no Gmail account is connected/i, flash[:alert].to_s)
  end

  test "without APP_HOST the invitation is refused with a clear blocker message" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    inviter = User.create!(email: "inviter-noapphost@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    prior = ENV.delete("APP_HOST")
    begin
      assert_no_difference "Invitation.count" do
        post invitations_path, params: { invitation: { email: "lead@example.com" } }
      end
      assert_match(/APP_HOST is not set/i, flash[:alert].to_s)
    ensure
      ENV["APP_HOST"] = prior
    end
  end

  test "invites send via the application mailbox when one is connected" do
    inviter = User.create!(email: "inviter2@example.com", password: "Password1", is_pending: false, tenant: @tenant, first_name: "Inga", last_name: "Vega")
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok", expires_at: 1.hour.from_now)
    sign_in inviter

    GmailSender.reset_deliveries!
    assert_difference "Invitation.count", 1 do
      post invitations_path, params: { invitation: { email: "newhire@example.com" } }
    end

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal "newhire@example.com", delivery[:to]
    assert_equal "noreply@app.example.com", delivery[:from]
    assert_match @tenant.name, delivery[:subject]
    invitation = Invitation.where(email: "newhire@example.com").last
    assert_equal @tenant, invitation.tenant
    assert_equal @org, invitation.organization
    assert_equal inviter, invitation.invited_by_user
    assert_match invitation.token, delivery[:body]
    assert_match(/Inga Vega/, delivery[:body])
  end

  test "create with blank email is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
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
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    child = @tenant.organizations.create!(name: "InviteCo Branch", parent: @org)
    inviter = User.create!(email: "inviter4@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: child, user: inviter, role: :admin)
    sign_in inviter

    post invitations_path, params: { invitation: { email: "rootinvite@example.com" } }
    invitation = Invitation.where(email: "rootinvite@example.com").last
    assert_equal @org, invitation.organization
  end

  # --- existing-user disposition ------------------------------------------

  test "inviting an email that matches a user in the same tenant adds them to the org without sending an invite" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    inviter = User.create!(email: "inviter-existing@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    other_org = @tenant.organizations.create!(name: "Branch")
    existing_user = User.create!(email: "teammate@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: other_org, user: existing_user, role: :member)

    GmailSender.reset_deliveries!
    assert_no_difference "Invitation.count" do
      assert_difference "OrganizationalMember.count", 1 do
        post invitations_path, params: { invitation: { email: "teammate@example.com" } }
      end
    end
    assert_empty GmailSender.deliveries
    assert_includes existing_user.reload.organizations, @org
    assert_match(/Added teammate@example.com/i, flash[:notice].to_s)
  end

  test "inviting an email already in the target org is rejected with a friendly message" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    inviter = User.create!(email: "inviter-already@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    same_org_user = User.create!(email: "alreadyhere@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: same_org_user, role: :member)

    assert_no_difference "Invitation.count" do
      assert_no_difference "OrganizationalMember.count" do
        post invitations_path, params: { invitation: { email: "alreadyhere@example.com" } }
      end
    end
    assert_match(/already a member/i, flash[:alert].to_s)
  end

  test "inviting an email belonging to a different tenant is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    inviter = User.create!(email: "inviter-cross@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    other_tenant = Tenant.create!(name: "OtherTenant")
    other_org = other_tenant.organizations.create!(name: "Other HQ")
    cross_user = User.create!(email: "elsewhere@example.com", password: "Password1", is_pending: false, tenant: other_tenant)
    OrganizationalMember.create!(organization: other_org, user: cross_user, role: :member)

    assert_no_difference ["Invitation.count", "OrganizationalMember.count"] do
      post invitations_path, params: { invitation: { email: "elsewhere@example.com" } }
    end
    assert_match(/another tenant/i, flash[:alert].to_s)
  end

  test "inviting an email belonging to a system admin is rejected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    inviter = User.create!(email: "inviter-adminemail@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    assert_no_difference ["Invitation.count", "OrganizationalMember.count"] do
      post invitations_path, params: { invitation: { email: users(:admin).email } }
    end
    assert_match(/system admin/i, flash[:alert].to_s)
  end

  # --- destroy (revoke) ----------------------------------------------------

  test "destroy redirects to sign-in when not signed in" do
    delete invitation_path(@invitation)
    assert_redirected_to new_user_session_path
  end

  test "tenant user can revoke a pending invitation in their tenant" do
    inviter = User.create!(email: "revoker@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    assert_difference "Invitation.count", -1 do
      delete invitation_path(@invitation)
    end
    assert_redirected_to users_path
    assert_match(/Revoked invitation/i, flash[:notice].to_s)
  end

  test "user from another tenant cannot revoke a foreign invitation" do
    other_tenant = Tenant.create!(name: "OtherCo")
    other_org = other_tenant.organizations.create!(name: "HQ")
    outsider = User.create!(email: "outsider@example.com", password: "Password1", is_pending: false, tenant: other_tenant)
    OrganizationalMember.create!(organization: other_org, user: outsider, role: :admin)
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
    inviter = User.create!(email: "revoker2@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: inviter, role: :admin)
    sign_in inviter

    assert_no_difference "Invitation.count" do
      delete invitation_path(@invitation)
    end
    assert_match(/already been accepted/i, flash[:alert].to_s)
  end
end
