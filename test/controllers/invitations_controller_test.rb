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
end
