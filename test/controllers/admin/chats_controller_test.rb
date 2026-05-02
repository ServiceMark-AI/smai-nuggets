require "test_helper"

class Admin::ChatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
  end

  test "redirects to sign-in when not signed in" do
    get admin_chats_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin is redirected away" do
    sign_in @non_admin
    get admin_chats_url
    assert_redirected_to root_path
  end

  test "admin index renders even with no chats" do
    sign_in @admin
    get admin_chats_url
    assert_response :success
    assert_match "No chats yet.", response.body
  end

  test "admin index lists chats and admin show renders messages" do
    chat = Chat.create!
    chat.messages.create!(role: "user", content: "Hello!")
    chat.messages.create!(role: "assistant", content: "Hi there.")

    sign_in @admin

    get admin_chats_url
    assert_response :success
    assert_match chat.id.to_s, response.body

    get admin_chat_url(chat)
    assert_response :success
    assert_match "Hello!", response.body
    assert_match "Hi there.", response.body
  end
end
