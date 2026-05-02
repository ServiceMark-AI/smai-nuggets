require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user  = users(:one)
    @org   = organizations(:one)
  end

  test "redirects unauthenticated visitors to sign-in" do
    get admin_organization_url(@org)
    assert_redirected_to new_user_session_path
  end

  test "non-admin users are turned away" do
    sign_in @user
    get admin_organization_url(@org)
    assert_redirected_to root_path
  end

  test "admin can view an organization" do
    sign_in @admin
    get admin_organization_url(@org)
    assert_response :success
    assert_match @org.name, response.body
    assert_match @org.tenant.name, response.body
  end

  test "show links the parent (when present) to the parent's admin page" do
    sign_in @admin
    child = organizations(:two) # parent: one
    get admin_organization_url(child)
    assert_response :success
    assert_select "a[href=?]", admin_organization_path(child.parent), text: child.parent.name
  end

  test "show 404s for missing organizations" do
    sign_in @admin
    get admin_organization_url(id: 0)
    assert_response :not_found
  end
end
