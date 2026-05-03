require "test_helper"

class Admin::IntegrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
  end

  test "redirects to sign-in when unauthenticated" do
    get admin_integrations_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin users are turned away" do
    sign_in @non_admin
    get admin_integrations_url
    assert_redirected_to root_path
  end

  test "admin sees the integrations page with each integration listed" do
    sign_in @admin
    get admin_integrations_url
    assert_response :success
    assert_match "Integrations", response.body
    assert_match "Application Mailbox", response.body
    assert_match "Google OAuth", response.body
    assert_match "Gemini API", response.body
    assert_match "Active Storage", response.body
    assert_match "Redis (Sidekiq)", response.body
    assert_match "Bugsnag", response.body
  end
end
