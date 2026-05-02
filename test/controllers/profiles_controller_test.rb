require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "show redirects to sign-in when not signed in" do
    get profile_url
    assert_redirected_to new_user_session_path
  end

  test "show renders the user's profile" do
    sign_in @user
    get profile_url
    assert_response :success
    assert_match @user.email, response.body
    assert_select "a[href=?]", edit_profile_path, text: "Edit"
  end

  test "edit renders the form with current profile values" do
    @user.update!(first_name: "Jane", last_name: "Doe", phone_number: "555-1234")
    sign_in @user
    get edit_profile_url
    assert_response :success
    assert_select "input[name='user[first_name]'][value='Jane']"
    assert_select "input[name='user[last_name]'][value='Doe']"
    assert_select "input[name='user[phone_number]'][value='555-1234']"
    assert_select "input[name='user[email]']", false  # email is intentionally not in this form
  end

  test "update with valid params saves and redirects to show" do
    sign_in @user
    patch profile_url, params: { user: { first_name: "Jane", last_name: "Doe", phone_number: "555-7777" } }
    assert_redirected_to profile_path
    @user.reload
    assert_equal "Jane", @user.first_name
    assert_equal "Doe", @user.last_name
    assert_equal "555-7777", @user.phone_number
  end

  test "update ignores email even if submitted" do
    sign_in @user
    original_email = @user.email
    patch profile_url, params: { user: { first_name: "Jane", email: "hacker@example.com" } }
    assert_redirected_to profile_path
    @user.reload
    assert_equal "Jane", @user.first_name
    assert_equal original_email, @user.email
  end
end
