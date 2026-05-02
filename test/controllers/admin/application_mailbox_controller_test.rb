require "test_helper"

class Admin::ApplicationMailboxControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user  = users(:one)
  end

  test "non-admin users are turned away" do
    sign_in @user
    get admin_application_mailbox_url
    assert_redirected_to root_path
  end

  test "show renders the empty state when no mailbox is connected" do
    sign_in @admin
    get admin_application_mailbox_url
    assert_response :success
    assert_match "Not connected", response.body
    assert_match "Connect a Google account", response.body
  end

  test "show renders the connected state when a mailbox exists" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok", expires_at: 1.hour.from_now)
    sign_in @admin
    get admin_application_mailbox_url
    assert_response :success
    assert_match "noreply@app.example.com", response.body
    assert_match "Reconnect", response.body
    assert_match "Disconnect", response.body
  end

  test "connect stashes the OAuth target and redirects to /auth/google_oauth2" do
    sign_in @admin
    post connect_admin_application_mailbox_url
    assert_redirected_to "/auth/google_oauth2"
    assert_equal "application_mailbox", session[:oauth_target]
  end

  test "destroy removes the mailbox" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    sign_in @admin
    assert_difference -> { ApplicationMailbox.count }, -1 do
      delete admin_application_mailbox_url
    end
    assert_redirected_to admin_application_mailbox_path
  end

  test "destroy with no mailbox shows a flash alert" do
    sign_in @admin
    delete admin_application_mailbox_url
    assert_redirected_to admin_application_mailbox_path
    follow_redirect!
    assert_match(/no mailbox is connected/i, response.body)
  end
end
