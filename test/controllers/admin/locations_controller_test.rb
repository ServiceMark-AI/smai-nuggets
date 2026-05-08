require "test_helper"

class Admin::LocationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user = users(:one)
    @tenant = tenants(:one)
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
    get new_admin_tenant_location_url(@tenant)
    assert_redirected_to root_path
  end

  test "new renders for a tenant" do
    sign_in @admin
    get new_admin_tenant_location_url(@tenant)
    assert_response :success
    assert_match "New Location for #{@tenant.name}", response.body
    assert_select "form"
  end

  test "create persists a location under the tenant and stamps created_by" do
    sign_in @admin
    assert_difference -> { Location.count }, 1 do
      post admin_tenant_locations_url(@tenant), params: valid_params
    end
    assert_redirected_to admin_tenant_path(@tenant)
    location = @tenant.locations.find_by(display_name: "Boise")
    refute_nil location
    assert_equal "ID", location.state
    assert_equal @admin, location.created_by_user
  end

  test "create rejects invalid input without saving" do
    sign_in @admin
    assert_no_difference -> { Location.count } do
      post admin_tenant_locations_url(@tenant), params: valid_params(display_name: "")
    end
    assert_response :unprocessable_content
  end
end
