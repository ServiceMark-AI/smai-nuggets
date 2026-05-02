require "test_helper"

class EmailDelegationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "1234567890",
      info: { email: "owner@example.com", name: "Owner" },
      credentials: {
        token: "access-token-abc",
        refresh_token: "refresh-token-xyz",
        expires_at: 1.hour.from_now.to_i,
        scope: "email profile https://www.googleapis.com/auth/gmail.send"
      },
      extra: { raw_info: { scope: "email profile https://www.googleapis.com/auth/gmail.send" } }
    )
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "callback redirects unauthenticated users to sign-in" do
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    get "/auth/google_oauth2/callback"
    assert_redirected_to new_user_session_path
  end

  test "callback creates an EmailDelegation tied to the current user" do
    sign_in @user
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    assert_difference -> { @user.email_delegations.count }, 1 do
      get "/auth/google_oauth2/callback"
    end
    assert_redirected_to profile_path
    follow_redirect!
    assert_match "Connected owner@example.com", response.body

    delegation = @user.email_delegations.last
    assert_equal "google_oauth2", delegation.provider
    assert_equal "owner@example.com", delegation.email
    assert_equal "access-token-abc", delegation.access_token
    assert_equal "refresh-token-xyz", delegation.refresh_token
    assert delegation.expires_at > Time.current
    assert_includes delegation.scopes, "gmail.send"
  end

  test "callback updates an existing delegation rather than duplicating" do
    sign_in @user
    @user.email_delegations.create!(
      provider: "google_oauth2",
      email: "owner@example.com",
      access_token: "old-token",
      refresh_token: "old-refresh"
    )
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    assert_no_difference -> { @user.email_delegations.count } do
      get "/auth/google_oauth2/callback"
    end
    delegation = @user.email_delegations.first
    assert_equal "access-token-abc", delegation.access_token
    assert_equal "refresh-token-xyz", delegation.refresh_token
  end

  test "failure path shows an alert" do
    sign_in @user
    get "/auth/failure", params: { message: "invalid_credentials" }
    assert_redirected_to profile_path
    follow_redirect!
    assert_match(/invalid_credentials/i, response.body)
  end

  test "destroy removes the delegation" do
    sign_in @user
    delegation = @user.email_delegations.create!(
      provider: "google_oauth2",
      email: "owner@example.com",
      access_token: "tok"
    )

    assert_difference -> { @user.email_delegations.count }, -1 do
      delete email_delegation_path(delegation)
    end
    assert_redirected_to profile_path
  end

  test "user can't destroy another user's delegation" do
    other = User.create!(email: "stranger@example.com", password: "Password1", tenant: tenants(:one), is_pending: false)
    delegation = other.email_delegations.create!(
      provider: "google_oauth2",
      email: "stranger-gmail@example.com",
      access_token: "tok"
    )

    sign_in @user
    assert_no_difference -> { EmailDelegation.count } do
      delete email_delegation_path(delegation)
    end
    assert delegation.reload.persisted?
  end
end
