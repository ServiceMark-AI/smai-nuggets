require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)  # encrypted_password = "password123"
  end

  test "edit redirects to sign-in when not signed in" do
    get change_password_url
    assert_redirected_to new_user_session_path
  end

  test "edit renders the change-password form" do
    sign_in @user
    get change_password_url
    assert_response :success
    assert_select "input[name='user[current_password]']"
    assert_select "input[name='user[password]']"
    assert_select "input[name='user[password_confirmation]']"
  end

  test "update with correct current password changes the password and stays signed in" do
    sign_in @user
    patch change_password_url, params: {
      user: { current_password: "password123", password: "NewPass1word", password_confirmation: "NewPass1word" }
    }
    assert_redirected_to profile_path
    follow_redirect!
    assert_match "Password updated.", response.body
    assert @user.reload.valid_password?("NewPass1word")
  end

  test "update fails when current password is wrong" do
    sign_in @user
    patch change_password_url, params: {
      user: { current_password: "WRONG", password: "NewPass1word", password_confirmation: "NewPass1word" }
    }
    assert_response :unprocessable_content
    assert_match(/current password is invalid/i, response.body)
    assert @user.reload.valid_password?("password123")
  end

  test "update fails when confirmation doesn't match" do
    sign_in @user
    patch change_password_url, params: {
      user: { current_password: "password123", password: "NewPass1word", password_confirmation: "Mismatch1" }
    }
    assert_response :unprocessable_content
    assert_match(/doesn&#39;t match Password/i, response.body)
    assert @user.reload.valid_password?("password123")
  end
end
