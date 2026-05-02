require "test_helper"

class JobProposalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)               # tenant: one, member of org one
    @other_tenant_user = users(:two)  # tenant: two, member of org three
    @admin = users(:admin)            # is_admin
  end

  test "redirects to sign-in when not signed in" do
    get job_proposals_url
    assert_redirected_to new_user_session_path
  end

  test "user sees proposals in their tenant and orgs they are a member of" do
    sign_in @user
    get job_proposals_url
    assert_response :success
    assert_match "Alice", response.body  # in_users_org: tenant=one, org=one ✓
  end

  test "user does not see proposals from orgs they are not in, even in same tenant" do
    sign_in @user
    get job_proposals_url
    assert_response :success
    assert_no_match "Bob", response.body  # same_tenant_other_org: tenant=one, org=two ✗ (user not in org two)
  end

  test "user does not see proposals from other tenants" do
    sign_in @user
    get job_proposals_url
    assert_response :success
    assert_no_match "Carol", response.body  # other_tenant: tenant=two ✗
  end

  test "user from another tenant only sees their own tenant's proposals" do
    sign_in @other_tenant_user
    get job_proposals_url
    assert_response :success
    assert_match "Carol", response.body
    assert_no_match "Alice", response.body
    assert_no_match "Bob", response.body
  end

  test "user with no organization memberships sees empty state" do
    lonely = User.create!(email: "lonely@example.com", password: "Password1", tenant: tenants(:one))
    sign_in lonely
    get job_proposals_url
    assert_response :success
    assert_no_match "Alice", response.body
    assert_no_match "Bob", response.body
    assert_no_match "Carol", response.body
    assert_match "No job proposals yet.", response.body
  end

  test "admin sees all proposals across tenants" do
    sign_in @admin
    get job_proposals_url
    assert_response :success
    assert_match "Alice", response.body
    assert_match "Bob", response.body
    assert_match "Carol", response.body
  end
end
