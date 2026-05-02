require "test_helper"

class Admin::ModelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
  end

  test "redirects to sign-in when not signed in" do
    get admin_models_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin is redirected away" do
    sign_in @non_admin
    get admin_models_url
    assert_redirected_to root_path
  end

  test "admin index renders even with no models" do
    sign_in @admin
    get admin_models_url
    assert_response :success
    assert_match(/No models loaded/i, response.body)
  end
end
