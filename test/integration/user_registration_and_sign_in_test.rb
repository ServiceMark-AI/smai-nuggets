require "test_helper"

class UserRegistrationAndSignInTest < ActionDispatch::IntegrationTest
  test "new user registers, is auto-signed-in, and lands on the home page" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newbie@example.com",
          password: "Password1",
          password_confirmation: "Password1"
        }
      }
    end

    follow_redirect!
    assert_response :success
    assert_match "Sign out", response.body

    user = User.find_by(email: "newbie@example.com")
    assert user.valid_password?("Password1")
  end

  test "registration fails when password confirmation does not match" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: "mismatch@example.com",
          password: "Password1",
          password_confirmation: "DifferentPassword1"
        }
      }
    end

    assert_response :unprocessable_content
    assert_match(/doesn&#39;t match Password/i, response.body)
  end

  test "registration fails when email is already taken" do
    assert_no_difference "User.count" do
      post user_registration_path, params: {
        user: {
          email: users(:one).email,
          password: "Password1",
          password_confirmation: "Password1"
        }
      }
    end

    assert_response :unprocessable_content
    assert_match(/has already been taken/i, response.body)
  end

  test "existing user can sign in with correct password" do
    post user_session_path, params: {
      user: { email: users(:one).email, password: "password123" }
    }

    follow_redirect!
    assert_response :success
    assert_match "Sign out", response.body
  end

  test "sign in fails with wrong password" do
    post user_session_path, params: {
      user: { email: users(:one).email, password: "wrong-password" }
    }

    assert_response :unprocessable_content
    assert_match(/Invalid Email or password/i, response.body)
  end

  test "register, sign out, and sign back in" do
    post user_registration_path, params: {
      user: {
        email: "fresh@example.com",
        password: "Password1",
        password_confirmation: "Password1"
      }
    }
    follow_redirect!
    assert_match "Sign out", response.body

    delete destroy_user_session_path
    follow_redirect!

    get root_path
    assert_redirected_to new_user_session_path

    post user_session_path, params: {
      user: { email: "fresh@example.com", password: "Password1" }
    }
    follow_redirect!
    assert_response :success
    assert_match "Sign out", response.body
  end
end
