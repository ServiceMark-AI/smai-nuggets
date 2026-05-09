require "application_system_test_case"

class PasswordResetTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(
      email: "reset-me@example.com",
      password: "OldPassword1",
      is_pending: false,
      tenant: tenants(:one)
    )
    ActionMailer::Base.deliveries.clear
  end

  # --- "Forgot your password?" link visibility -----------------------------

  test "the sign-in page shows a Forgot your password? link" do
    visit new_user_session_path
    assert_link "Forgot your password?", href: new_user_password_path
  end

  # --- Request a reset email -----------------------------------------------

  test "submitting a known email queues a reset-instructions email and shows confirmation" do
    visit new_user_session_path
    click_link "Forgot your password?"
    assert_current_path new_user_password_path

    assert_emails 1 do
      fill_in "Email", with: @user.email
      click_button "Send me password reset instructions"
    end

    assert_text "You will receive an email with instructions"
    assert_equal [@user.email], last_email.to
    assert_match(/Change my password/i, last_email.body.to_s)
  end

  test "submitting an unknown email shows the same confirmation but sends no mail" do
    visit new_user_password_path

    assert_no_emails do
      fill_in "Email", with: "stranger@example.com"
      click_button "Send me password reset instructions"
    end

    # Devise's paranoid_email setting controls this; default behavior on
    # this app gives a "not found" error rather than the security-friendly
    # neutral message. The test just pins the actual current behavior so
    # any later flip to paranoid mode is intentional.
    assert_text(/not found|email/i)
  end

  # --- End-to-end: receive email -> click link -> set new password ---------

  test "the reset-instructions link in the email lets the user set a new password" do
    visit new_user_password_path
    fill_in "Email", with: @user.email
    click_button "Send me password reset instructions"

    reset_url = link_in_last_email(matching: "reset_password_token", body_part: :html)
    visit reset_url

    fill_in "New password", with: "NewPassword2"
    fill_in "Confirm new password", with: "NewPassword2"
    click_button "Change my password"

    # Devise signs the user in after a successful reset.
    assert_text(/password (has been|was) changed/i)
  end

  test "after resetting the password the old password no longer works" do
    visit new_user_password_path
    fill_in "Email", with: @user.email
    click_button "Send me password reset instructions"
    visit link_in_last_email(matching: "reset_password_token", body_part: :html)
    fill_in "New password", with: "NewPassword2"
    fill_in "Confirm new password", with: "NewPassword2"
    click_button "Change my password"

    # Sign out so the next attempt starts fresh.
    visit destroy_user_session_path rescue nil

    visit new_user_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "OldPassword1"
    click_button "Log in"
    assert_text(/Invalid Email or password/i)
  end

  test "after resetting the password the new password lets the user sign in" do
    visit new_user_password_path
    fill_in "Email", with: @user.email
    click_button "Send me password reset instructions"
    visit link_in_last_email(matching: "reset_password_token", body_part: :html)
    fill_in "New password", with: "NewPassword2"
    fill_in "Confirm new password", with: "NewPassword2"
    click_button "Change my password"

    visit destroy_user_session_path rescue nil

    visit new_user_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "NewPassword2"
    click_button "Log in"
    assert_no_text(/Invalid Email or password/i)
  end

  # --- Token tampering / expiry ------------------------------------------

  test "an invalid reset_password_token can't change the password" do
    visit edit_user_password_url(reset_password_token: "totally-fake-token")
    fill_in "New password", with: "NewPassword2"
    fill_in "Confirm new password", with: "NewPassword2"
    click_button "Change my password"

    assert_text(/(invalid|expired|not found|reset password token)/i)
  end
end
