require "test_helper"

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @campaign = campaigns(:approved_campaign)
  end

  test "redirects to sign-in when not signed in" do
    get campaigns_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin user is redirected away with an alert" do
    sign_in @non_admin
    get campaigns_url
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/not authorized/i, response.body)
  end

  test "admin index lists campaigns" do
    sign_in @admin
    get campaigns_url
    assert_response :success
    assert_match "Spring Outreach", response.body
    assert_match "Summer Push", response.body
    assert_match "Winter Hold", response.body
  end

  test "admin sees the new form" do
    sign_in @admin
    get new_campaign_url
    assert_response :success
    assert_select "form input[name='campaign[name]']"
    assert_select "form select[name='campaign[status]']"
  end

  test "admin create with valid params persists and redirects" do
    sign_in @admin
    assert_difference "Campaign.count", 1 do
      post campaigns_url, params: { campaign: { name: "Fall Drive", status: "new" } }
    end
    assert_redirected_to campaigns_path
    follow_redirect!
    assert_match "Campaign created.", response.body
    assert_match "Fall Drive", response.body
  end

  test "admin create with invalid params re-renders the form" do
    sign_in @admin
    assert_no_difference "Campaign.count" do
      post campaigns_url, params: { campaign: { name: "", status: "new" } }
    end
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
  end

  test "admin sees the edit form" do
    sign_in @admin
    get edit_campaign_url(@campaign)
    assert_response :success
    assert_select "form input[name='campaign[name]'][value=?]", @campaign.name
  end

  test "admin update with valid params changes the record and redirects" do
    sign_in @admin
    patch campaign_url(@campaign), params: { campaign: { name: "Renamed", status: "paused" } }
    assert_redirected_to campaigns_path
    @campaign.reload
    assert_equal "Renamed", @campaign.name
    assert_equal "paused", @campaign.status
  end

  test "admin update with invalid params re-renders the form" do
    sign_in @admin
    patch campaign_url(@campaign), params: { campaign: { name: "" } }
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
    assert_equal "Summer Push", @campaign.reload.name
  end

  test "admin destroy removes the campaign" do
    sign_in @admin
    assert_difference "Campaign.count", -1 do
      delete campaign_url(@campaign)
    end
    assert_redirected_to campaigns_path
  end

  test "non-admin cannot create a campaign" do
    sign_in @non_admin
    assert_no_difference "Campaign.count" do
      post campaigns_url, params: { campaign: { name: "Sneaky", status: "new" } }
    end
    assert_redirected_to root_path
  end
end
