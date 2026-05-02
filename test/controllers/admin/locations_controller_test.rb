require "test_helper"

class Admin::LocationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user = users(:one)
    @org_with_location = organizations(:one)         # has fixture location :ne_dallas
    @org_without_location = organizations(:two)
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

  test "non-admin users are turned away" do
    sign_in @user
    get new_admin_organization_location_url(@org_without_location)
    assert_redirected_to root_path
  end

  test "new renders for an org without a location" do
    sign_in @admin
    get new_admin_organization_location_url(@org_without_location)
    assert_response :success
    assert_match "New Location for #{@org_without_location.name}", response.body
    assert_select "form"
  end

  test "new redirects when the org already has a location" do
    sign_in @admin
    get new_admin_organization_location_url(@org_with_location)
    assert_redirected_to admin_organization_path(@org_with_location)
  end

  test "create persists a location and stamps created_by" do
    sign_in @admin
    assert_difference -> { Location.count }, 1 do
      post admin_organization_locations_url(@org_without_location), params: valid_params
    end
    assert_redirected_to admin_organization_path(@org_without_location)
    location = @org_without_location.reload.location
    assert_equal "Boise", location.display_name
    assert_equal "ID", location.state
    assert_equal @admin, location.created_by_user
  end

  test "create rejects invalid input without saving" do
    sign_in @admin
    assert_no_difference -> { Location.count } do
      post admin_organization_locations_url(@org_without_location), params: valid_params(display_name: "")
    end
    assert_response :unprocessable_content
  end

  test "create refuses when the org already has a location" do
    sign_in @admin
    assert_no_difference -> { Location.count } do
      post admin_organization_locations_url(@org_with_location), params: valid_params
    end
    assert_redirected_to admin_organization_path(@org_with_location)
  end
end
