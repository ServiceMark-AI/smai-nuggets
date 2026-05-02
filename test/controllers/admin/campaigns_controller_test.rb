require "test_helper"

class Admin::CampaignsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @campaign = campaigns(:approved_campaign)
  end

  test "redirects to sign-in when not signed in" do
    get admin_campaigns_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin user is redirected away with an alert" do
    sign_in @non_admin
    get admin_campaigns_url
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/not authorized/i, response.body)
  end

  test "admin index lists campaigns" do
    sign_in @admin
    get admin_campaigns_url
    assert_response :success
    assert_match "Spring Outreach", response.body
    assert_match "Summer Push", response.body
    assert_match "Winter Hold", response.body
  end

  test "admin show renders the campaign with its steps" do
    sign_in @admin
    get admin_campaign_url(@campaign)
    assert_response :success
    assert_match @campaign.name, response.body
    assert_match "Welcome", response.body  # subject of approved_step_one fixture
    assert_match "Add step", response.body
  end

  test "non-admin show is denied" do
    sign_in @non_admin
    get admin_campaign_url(@campaign)
    assert_redirected_to root_path
  end

  test "admin sees the new form" do
    sign_in @admin
    get new_admin_campaign_url
    assert_response :success
    assert_select "form input[name='campaign[name]']"
    assert_select "form select[name='campaign[status]']"
  end

  test "admin create with valid params persists and redirects" do
    sign_in @admin
    assert_difference "Campaign.count", 1 do
      post admin_campaigns_url, params: { campaign: { name: "Fall Drive", status: "new" } }
    end
    assert_redirected_to admin_campaigns_path
    follow_redirect!
    assert_match "Campaign created.", response.body
    assert_match "Fall Drive", response.body
  end

  test "admin create with attributed_scenario_id sets the polymorphic attribution" do
    sign_in @admin
    scenario = scenarios(:sewage_backup)
    assert_difference "Campaign.count", 1 do
      post admin_campaigns_url, params: {
        campaign: { name: "Sewage Outreach", status: "new", attributed_scenario_id: scenario.id }
      }
    end
    created = Campaign.find_by(name: "Sewage Outreach")
    assert_equal scenario, created.attributed_to
    assert_equal "Scenario", created.attributed_to_type
    assert_equal scenario.id, created.attributed_to_id
  end

  test "admin update can clear the attribution" do
    sign_in @admin
    scenario = scenarios(:sewage_backup)
    @campaign.update!(attributed_to: scenario)

    patch admin_campaign_url(@campaign), params: { campaign: { attributed_scenario_id: "" } }
    assert_nil @campaign.reload.attributed_to
  end

  test "admin create with invalid params re-renders the form" do
    sign_in @admin
    assert_no_difference "Campaign.count" do
      post admin_campaigns_url, params: { campaign: { name: "", status: "new" } }
    end
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
  end

  test "admin sees the edit form" do
    sign_in @admin
    get edit_admin_campaign_url(@campaign)
    assert_response :success
    assert_select "form input[name='campaign[name]'][value=?]", @campaign.name
  end

  test "admin edit page lists steps and links to add step" do
    sign_in @admin
    get edit_admin_campaign_url(@campaign)
    assert_response :success
    assert_match "Welcome", response.body  # subject of approved_step_one fixture
    assert_match "Following up", response.body  # subject of approved_step_two
    assert_select "a[href=?]", new_admin_campaign_step_path(@campaign), text: "Add step"
  end

  test "admin update with valid params changes the record and redirects" do
    sign_in @admin
    patch admin_campaign_url(@campaign), params: { campaign: { name: "Renamed", status: "paused" } }
    assert_redirected_to admin_campaigns_path
    @campaign.reload
    assert_equal "Renamed", @campaign.name
    assert_equal "paused", @campaign.status
  end

  test "admin update with invalid params re-renders the form" do
    sign_in @admin
    patch admin_campaign_url(@campaign), params: { campaign: { name: "" } }
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
    assert_equal "Summer Push", @campaign.reload.name
  end

  test "admin destroy removes the campaign" do
    sign_in @admin
    assert_difference "Campaign.count", -1 do
      delete admin_campaign_url(@campaign)
    end
    assert_redirected_to admin_campaigns_path
  end

  test "show offers Approve button only when status is new" do
    sign_in @admin
    new_campaign = campaigns(:new_campaign)
    get admin_campaign_url(new_campaign)
    assert_select "form[action=?]", approve_admin_campaign_path(new_campaign)
    assert_select "form[action=?]", pause_admin_campaign_path(new_campaign), false

    get admin_campaign_url(@campaign)  # @campaign is approved
    assert_select "form[action=?]", pause_admin_campaign_path(@campaign)
    assert_select "form[action=?]", approve_admin_campaign_path(@campaign), false

    paused = campaigns(:paused_campaign)
    get admin_campaign_url(paused)
    assert_select "form[action=?]", approve_admin_campaign_path(paused), false
    assert_select "form[action=?]", pause_admin_campaign_path(paused), false
  end

  test "approve sets status, approved_by_user, and approved_at" do
    sign_in @admin
    new_campaign = campaigns(:new_campaign)
    freeze_time = Time.zone.parse("2026-05-02 12:00:00")

    travel_to freeze_time do
      patch approve_admin_campaign_url(new_campaign)
    end
    assert_redirected_to admin_campaign_path(new_campaign)
    new_campaign.reload
    assert_equal "approved", new_campaign.status
    assert_equal @admin, new_campaign.approved_by_user
    assert_equal freeze_time, new_campaign.approved_at
  end

  test "pause sets status, paused_by_user, and paused_at" do
    sign_in @admin
    freeze_time = Time.zone.parse("2026-05-02 13:00:00")

    travel_to freeze_time do
      patch pause_admin_campaign_url(@campaign)
    end
    assert_redirected_to admin_campaign_path(@campaign)
    @campaign.reload
    assert_equal "paused", @campaign.status
    assert_equal @admin, @campaign.paused_by_user
    assert_equal freeze_time, @campaign.paused_at
  end

  test "non-admin cannot approve or pause" do
    sign_in @non_admin
    new_campaign = campaigns(:new_campaign)

    patch approve_admin_campaign_url(new_campaign)
    assert_redirected_to root_path
    assert_equal "new", new_campaign.reload.status

    patch pause_admin_campaign_url(@campaign)
    assert_redirected_to root_path
    assert_equal "approved", @campaign.reload.status
  end

  test "non-admin cannot create a campaign" do
    sign_in @non_admin
    assert_no_difference "Campaign.count" do
      post admin_campaigns_url, params: { campaign: { name: "Sneaky", status: "new" } }
    end
    assert_redirected_to root_path
  end
end
