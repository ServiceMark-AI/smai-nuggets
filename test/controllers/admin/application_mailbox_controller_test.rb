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

  test "show renders a form posting directly to /auth/google_oauth2 with the target hidden field when env is configured" do
    sign_in @admin
    with_google_env do
      get admin_application_mailbox_url
      assert_select "form[action='/auth/google_oauth2'][method=post]" do
        assert_select "input[type=hidden][name=target][value=application_mailbox]"
      end
    end
  end

  test "show disables the Connect button and names the missing env vars when GOOGLE_* is absent" do
    sign_in @admin
    with_google_env(client_id: nil, client_secret: nil) do
      get admin_application_mailbox_url
      assert_response :success
      assert_no_match %r{form action=['"]/auth/google_oauth2['"]}, response.body
      assert_select "button[disabled]", text: /Connect a Google account/
      assert_match "GOOGLE_CLIENT_ID", response.body
      assert_match "GOOGLE_CLIENT_SECRET", response.body
    end
  end

  test "show disables Reconnect with hint text when env vars are missing and a mailbox is connected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    sign_in @admin
    with_google_env(client_id: nil, client_secret: nil) do
      get admin_application_mailbox_url
      assert_select "button[disabled]", text: /Reconnect/
      assert_match "to enable", response.body
    end
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

  private

  # Yields with the GOOGLE_* env vars set / unset, restoring on exit.
  def with_google_env(client_id: "id", client_secret: "secret")
    prior_id, prior_secret = ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
    ENV["GOOGLE_CLIENT_ID"] = client_id
    ENV["GOOGLE_CLIENT_SECRET"] = client_secret
    yield
  ensure
    ENV["GOOGLE_CLIENT_ID"] = prior_id
    ENV["GOOGLE_CLIENT_SECRET"] = prior_secret
  end
end
