require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @org_with_location = organizations(:one)         # has fixture location :ne_dallas
    @org_without_location = organizations(:two)      # no location
    @existing_location = locations(:ne_dallas)

    @org_admin = User.create!(
      email: "orgadmin@example.com",
      password: "Password1",
      tenant: @org_with_location.tenant,
      is_pending: false
    )
    OrganizationalMember.create!(
      organization: @org_with_location,
      user: @org_admin,
      role: :admin
    )

    @org_member = User.create!(
      email: "orgmember@example.com",
      password: "Password1",
      tenant: @org_with_location.tenant,
      is_pending: false
    )
    OrganizationalMember.create!(
      organization: @org_with_location,
      user: @org_member,
      role: :member
    )

    @app_admin = users(:admin)
  end

  def valid_params(overrides = {})
    {
      location: {
        display_name: "Boise",
        address_line_1: "100 Main St",
        city: "Boise",
        state: "id",
        postal_code: "83701",
        phone_number: "(208) 555-0100"
      }.merge(overrides)
    }
  end

  # --- new action ---

  test "new redirects to sign-in when not signed in" do
    get new_location_url
    assert_redirected_to new_user_session_path
  end

  test "new redirects to root when user has no organization" do
    lonely = User.create!(email: "lonely@example.com", password: "Password1", tenant: tenants(:one))
    sign_in lonely
    get new_location_url
    assert_redirected_to root_path
  end

  test "new is forbidden for org members who are not admin" do
    sign_in @org_member
    get new_location_url
    assert_redirected_to my_organization_path
  end

  test "new redirects to edit when the org already has a location" do
    sign_in @org_admin
    get new_location_url
    assert_redirected_to edit_location_path
  end

  test "new renders for an org admin when no location exists" do
    @existing_location.destroy
    sign_in @org_admin
    get new_location_url
    assert_response :success
    assert_select "form"
    assert_match "Add Location", response.body
  end

  test "new renders for the app admin even without org admin role" do
    @existing_location.destroy
    sign_in @app_admin
    # app admin has no org; need at least one membership to have a current org
    OrganizationalMember.create!(organization: @org_with_location, user: @app_admin, role: :member)
    get new_location_url
    assert_response :success
  end

  # --- create action ---

  test "create rejects org members who are not admin" do
    @existing_location.destroy
    sign_in @org_member
    post location_url, params: valid_params
    assert_redirected_to my_organization_path
    assert_nil @org_with_location.reload.location
  end

  test "create succeeds for an org admin and saves the location to the org" do
    @existing_location.destroy
    sign_in @org_admin
    assert_difference -> { Location.count }, 1 do
      post location_url, params: valid_params
    end
    assert_redirected_to my_organization_path
    location = @org_with_location.reload.location
    assert_equal "Boise", location.display_name
    assert_equal "ID", location.state
    assert_equal @org_admin, location.created_by_user
  end

  test "create re-renders the form on validation error without saving" do
    @existing_location.destroy
    sign_in @org_admin
    assert_no_difference -> { Location.count } do
      post location_url, params: valid_params(display_name: "")
    end
    assert_response :unprocessable_content
    assert_match "Display name", response.body
  end

  test "create redirects to edit when the org already has a location" do
    sign_in @org_admin
    assert_no_difference -> { Location.count } do
      post location_url, params: valid_params
    end
    assert_redirected_to edit_location_path
  end

  # --- edit + update ---

  test "edit redirects to new when no location exists" do
    @existing_location.destroy
    sign_in @org_admin
    get edit_location_url
    assert_redirected_to new_location_path
  end

  test "edit renders the form pre-populated for an org admin" do
    sign_in @org_admin
    get edit_location_url
    assert_response :success
    assert_match @existing_location.display_name, response.body
  end

  test "update saves changes and stamps updated_by_user" do
    sign_in @org_admin
    patch location_url, params: { location: { display_name: "Northeast Dallas" } }
    assert_redirected_to my_organization_path
    assert_equal "Northeast Dallas", @existing_location.reload.display_name
    assert_equal @org_admin, @existing_location.updated_by_user
  end

  test "update re-renders edit on validation error" do
    sign_in @org_admin
    patch location_url, params: { location: { state: "Texas" } }
    assert_response :unprocessable_content
    assert_match "state", response.body
  end

  test "update is forbidden for non-admin org members" do
    sign_in @org_member
    patch location_url, params: { location: { display_name: "Hacked" } }
    assert_redirected_to my_organization_path
    refute_equal "Hacked", @existing_location.reload.display_name
  end
end
