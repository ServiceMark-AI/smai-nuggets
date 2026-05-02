require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  test "unauthenticated visit redirects to the sign-in page" do
    visit "/"
    assert_current_path new_user_session_path
    assert_text "Log in"
  end
end
