require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @tenant = tenants(:one)
    @location = locations(:ne_dallas)
  end

  test "redirects to sign-in when unauthenticated" do
    get root_url
    assert_redirected_to new_user_session_path
  end

  test "regular tenant user is redirected to Needs Attention" do
    user = User.create!(email: "regular-home@example.com", password: "Password1", is_pending: false, tenant: @tenant, location: @location)
    sign_in user
    get root_url
    assert_redirected_to job_proposals_path(filter: "needs_attention")
  end

  test "tenant admin sees the home dashboard" do
    user = User.create!(email: "admin-home@example.com", password: "Password1", is_pending: false, tenant: @tenant)
    sign_in user
    get root_url
    assert_response :success
    assert_match "Welcome", response.body
  end

  test "application admin sees the home dashboard" do
    sign_in users(:admin)
    get root_url
    assert_response :success
    assert_match "Welcome", response.body
  end
end
