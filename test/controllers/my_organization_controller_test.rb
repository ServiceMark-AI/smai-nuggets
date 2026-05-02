require "test_helper"

class MyOrganizationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "redirects to sign-in when not signed in" do
    get my_organization_url
    assert_redirected_to new_user_session_path
  end

  test "shows tenant, parent placeholder, and other members for a top-level org" do
    user = users(:one)  # member of organizations(:one) (Acme HQ, tenant: one, no parent)
    other = User.create!(email: "coworker@example.com", password: "Password1", tenant: user.tenant, is_pending: false)
    OrganizationalMember.create!(organization: organizations(:one), user: other, role: :member)

    sign_in user
    get my_organization_url
    assert_response :success
    assert_match "Acme HQ", response.body
    assert_match "Acme", response.body                    # tenant name
    assert_match "(top-level)", response.body             # no parent
    assert_match "coworker@example.com", response.body    # other member listed
    assert_no_match user.email, response.body             # current user excluded
  end

  test "shows the parent organization name when one is set" do
    user = User.create!(email: "child-org-user@example.com", password: "Password1", tenant: tenants(:one), is_pending: false)
    OrganizationalMember.create!(organization: organizations(:two), user: user, role: :member)

    sign_in user
    get my_organization_url
    assert_response :success
    assert_match "Acme West", response.body   # the user's org
    assert_match "Acme HQ", response.body     # listed as parent
  end

  test "shows the empty-other-members state when the user is the only member" do
    user = User.create!(email: "solo@example.com", password: "Password1", tenant: tenants(:one), is_pending: false)
    OrganizationalMember.create!(organization: organizations(:one), user: user, role: :admin)
    # user :one is also in organizations(:one), but we want ONLY this user — remove the fixture link
    OrganizationalMember.where(organization: organizations(:one)).where.not(user: user).destroy_all

    sign_in user
    get my_organization_url
    assert_response :success
    assert_match "No other members", response.body
  end

  test "shows the no-organization message when the user has no memberships" do
    user = User.create!(email: "lonely-org@example.com", password: "Password1", tenant: tenants(:one), is_pending: false)
    sign_in user
    get my_organization_url
    assert_response :success
    assert_match(/not a member of any organization/i, response.body)
  end
end
