require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @tenant = Tenant.create!(name: "TenantCo")
    @user = User.create!(
      email: "leader@example.com",
      password: "Password1",
      is_pending: false,
      tenant: @tenant,
      first_name: "Tina",
      last_name: "Lee"
    )
  end

  test "redirects to sign-in when unauthenticated" do
    get users_url
    assert_redirected_to new_user_session_path
  end

  test "lists members of the current user's tenant and shows the invite button" do
    other = User.create!(email: "second@example.com", password: "Password1", is_pending: false, tenant: @tenant)
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
    outsider = User.create!(email: "outsider@example.com", password: "Password1", is_pending: false, tenant: other_tenant)

    sign_in @user
    get users_url
    assert_response :success
    assert_no_match outsider.email, response.body
  end

  test "shows pending invitations for the tenant" do
    Invitation.create!(
      tenant: @tenant,
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

  test "team table renders Role column with Admin for tenant admins and Originator for users with a location" do
    location = @tenant.locations.create!(
      display_name: "Main", address_line_1: "1 Main", city: "Dallas",
      state: "TX", postal_code: "75001", phone_number: "(214) 555-0101", is_active: true
    )
    User.create!(email: "originator@example.com", password: "Password1", is_pending: false, tenant: @tenant, location: location)

    sign_in @user # @user has tenant: one, no location → tenant admin
    get users_url
    assert_response :success
    assert_select "th", text: "Role"
    # The team table contains both badge labels
    assert_match "Admin", response.body
    assert_match "Originator", response.body
  end

  test "regular tenant user (with a location) does not see the Invite button or modal" do
    location = @tenant.locations.create!(
      display_name: "Main", address_line_1: "1 Main", city: "Dallas",
      state: "TX", postal_code: "75001", phone_number: "(214) 555-0101", is_active: true
    )
    regular = User.create!(email: "regular@example.com", password: "Password1", is_pending: false, tenant: @tenant, location: location)
    sign_in regular

    get users_url
    assert_response :success
    assert_no_match(/Invite user/i, response.body)
    assert_select "#inviteUserModal", false
  end
end
