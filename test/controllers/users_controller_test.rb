require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @tenant = Tenant.create!(name: "TenantCo")
    @org = @tenant.organizations.create!(name: "TenantCo HQ")
    @user = User.create!(
      email: "leader@example.com",
      password: "Password1",
      is_pending: false,
      tenant: @tenant,
      first_name: "Tina",
      last_name: "Lee"
    )
    OrganizationalMember.create!(organization: @org, user: @user, role: :admin)
  end

  test "redirects to sign-in when unauthenticated" do
    get users_url
    assert_redirected_to new_user_session_path
  end

  test "lists members of the current user's tenant and shows the invite button" do
    other = User.create!(email: "second@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    OrganizationalMember.create!(organization: @org, user: other, role: :member)
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")

    sign_in @user
    get users_url
    assert_response :success
    assert_match @user.email, response.body
    assert_match other.email, response.body
    assert_match(/Invite user/i, response.body)
    assert_select "form[action=?]", invitations_path
  end

  test "scopes member list to the current user's tenant" do
    other_tenant = Tenant.create!(name: "OtherCo")
    other_org = other_tenant.organizations.create!(name: "OtherCo HQ")
    outsider = User.create!(email: "outsider@example.com", password: "Password1", is_pending: false, tenant: other_tenant)
    OrganizationalMember.create!(organization: other_org, user: outsider, role: :member)

    sign_in @user
    get users_url
    assert_response :success
    assert_no_match outsider.email, response.body
  end

  test "shows pending invitations for the tenant" do
    Invitation.create!(
      tenant: @tenant,
      organization: @org,
      invited_by_user: @user,
      email: "pending@example.com"
    )

    sign_in @user
    get users_url
    assert_response :success
    assert_match "pending@example.com", response.body
  end

  test "users with a Gmail delegation get a Linked badge with the delegated address" do
    EmailDelegation.create!(
      user: @user,
      provider: "google",
      email: "ops-mike@example.com",
      access_token: "tok"
    )

    sign_in @user
    get users_url
    assert_response :success
    assert_match "Linked", response.body
    assert_match "ops-mike@example.com", response.body
  end

  test "users without a Gmail delegation show 'Not linked'" do
    sign_in @user
    get users_url
    assert_response :success
    assert_match "Not linked", response.body
  end

  test "tenant-less user sees an info message and no invite button" do
    orphan = User.create!(email: "orphan@example.com", password: "Password1", is_pending: false)
    sign_in orphan

    get users_url
    assert_response :success
    assert_match(/not assigned to a tenant/i, response.body)
    assert_no_match(/Invite user/i, response.body)
  end
end
