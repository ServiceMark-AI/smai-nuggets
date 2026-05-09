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

  test "admin index shows the approver and pauser names alongside the timestamps" do
    sign_in @admin
    get admin_campaigns_url
    assert_response :success
    # approved_campaign (Summer Push) has approved_by_user = users(:one).
    # paused_campaign  (Winter Hold) has approved_by_user = users(:one)
    #                                  and paused_by_user = users(:admin).
    assert_match users(:one).display_name, response.body
    assert_match users(:admin).display_name, response.body
  end

  test "admin show renders the active-revision steps and a Create new revision affordance" do
    sign_in @admin
    get admin_campaign_url(@campaign)
    assert_response :success
    assert_match @campaign.name, response.body
    assert_match "Welcome", response.body              # subject of approved_step_one fixture
    assert_match "Active steps", response.body
    assert_match "Revisions", response.body
    assert_select "form[action=?] button", admin_campaign_revisions_path(@campaign), text: "Create new revision"
  end

  test "non-admin show is denied" do
    sign_in @non_admin
    get admin_campaign_url(@campaign)
    assert_redirected_to root_path
  end

  test "admin sees the new form, but the status field is not shown (defaults to draft)" do
    sign_in @admin
    get new_admin_campaign_url
    assert_response :success
    assert_select "form input[name='campaign[name]']"
    assert_select "form select[name='campaign[status]']", count: 0
  end

  test "admin create with valid params persists and redirects" do
    sign_in @admin
    assert_difference "Campaign.count", 1 do
      post admin_campaigns_url, params: { campaign: { name: "Fall Drive" } }
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
        campaign: { name: "Sewage Outreach", attributed_scenario_id: scenario.id }
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
      post admin_campaigns_url, params: { campaign: { name: "" } }
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

  test "admin edit page no longer lists steps — those live on revisions now" do
    sign_in @admin
    get edit_admin_campaign_url(@campaign)
    assert_response :success
    assert_no_match(/Welcome/, response.body)
    assert_match(/create a new draft revision/i, response.body)
  end

  test "admin update with valid params changes the record and redirects to the show page" do
    sign_in @admin
    patch admin_campaign_url(@campaign), params: { campaign: { name: "Renamed" } }
    assert_redirected_to admin_campaign_path(@campaign)
    @campaign.reload
    assert_equal "Renamed", @campaign.name
  end

  test "admin update ignores any status param sent (status is locked behind Approve/Pause)" do
    sign_in @admin
    patch admin_campaign_url(@campaign), params: { campaign: { name: "Renamed", status: "paused" } }
    @campaign.reload
    assert_equal "Renamed", @campaign.name
    assert_equal "approved", @campaign.status, "status must not be writable from the edit form"
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

  test "show offers Approve button only when status is draft" do
    sign_in @admin
    draft_campaign = campaigns(:draft_campaign)
    get admin_campaign_url(draft_campaign)
    assert_select "form[action=?]", approve_admin_campaign_path(draft_campaign)
    assert_select "form[action=?]", pause_admin_campaign_path(draft_campaign), false

    get admin_campaign_url(@campaign)  # @campaign is approved
    assert_select "form[action=?]", pause_admin_campaign_path(@campaign)
    assert_select "form[action=?]", approve_admin_campaign_path(@campaign), false

    paused = campaigns(:paused_campaign)
    get admin_campaign_url(paused)
    assert_select "form[action=?]", approve_admin_campaign_path(paused), false
    assert_select "form[action=?]", pause_admin_campaign_path(paused), false
  end

  test "show page surfaces who approved an approved campaign" do
    sign_in @admin
    # @campaign is :approved with approved_by_user = users(:one) per fixture
    get admin_campaign_url(@campaign)
    assert_response :success
    assert_match "Approved by", response.body
    assert_match users(:one).display_name, response.body
  end

  test "show page surfaces who paused and who originally approved a paused campaign" do
    sign_in @admin
    paused = campaigns(:paused_campaign)
    # paused_campaign fixture: approved_by_user = one, paused_by_user = admin
    get admin_campaign_url(paused)
    assert_response :success
    assert_match "Paused by", response.body
    assert_match "Originally approved by", response.body
    assert_match users(:admin).display_name, response.body
    assert_match users(:one).display_name, response.body
  end

  test "show page omits the approver row on a draft campaign" do
    sign_in @admin
    get admin_campaign_url(campaigns(:draft_campaign))
    assert_response :success
    # The Revisions table has its own "Approved by" column header, so
    # assert specifically on the campaign-level audit dt rather than a
    # bare /Approved by/ match against the whole response.
    assert_select "dt", text: "Approved by", count: 0
    assert_select "dt", text: "Paused by",   count: 0
  end

  test "approve sets status, approved_by_user, and approved_at" do
    sign_in @admin
    draft_campaign = campaigns(:draft_campaign)
    freeze_time = Time.zone.parse("2026-05-02 12:00:00")

    travel_to freeze_time do
      patch approve_admin_campaign_url(draft_campaign)
    end
    assert_redirected_to admin_campaign_path(draft_campaign)
    draft_campaign.reload
    assert_equal "approved", draft_campaign.status
    assert_equal @admin, draft_campaign.approved_by_user
    assert_equal freeze_time, draft_campaign.approved_at
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

  test "resume flips paused -> approved, clears pause fields, preserves approval audit" do
    paused = campaigns(:paused_campaign)
    original_approved_by = paused.approved_by_user
    original_approved_at = paused.approved_at

    sign_in @admin
    patch resume_admin_campaign_url(paused)
    assert_redirected_to admin_campaign_path(paused)

    paused.reload
    assert_equal "approved", paused.status
    assert_nil paused.paused_by_user
    assert_nil paused.paused_at
    assert_equal original_approved_by, paused.approved_by_user, "resume must not overwrite the original approver"
    assert_equal original_approved_at, paused.approved_at,    "resume must not overwrite the original approval time"
  end

  test "show page renders an Unpause button only when the campaign is paused" do
    sign_in @admin

    paused = campaigns(:paused_campaign)
    get admin_campaign_url(paused)
    assert_select "form[action=?]", resume_admin_campaign_path(paused)

    get admin_campaign_url(@campaign) # approved
    assert_select "form[action=?]", resume_admin_campaign_path(@campaign), false

    get admin_campaign_url(campaigns(:draft_campaign))
    assert_select "form[action=?]", resume_admin_campaign_path(campaigns(:draft_campaign)), false
  end

  test "non-admin cannot approve, pause, or resume" do
    sign_in @non_admin
    draft_campaign = campaigns(:draft_campaign)
    paused = campaigns(:paused_campaign)

    patch approve_admin_campaign_url(draft_campaign)
    assert_redirected_to root_path
    assert_equal "draft", draft_campaign.reload.status

    patch pause_admin_campaign_url(@campaign)
    assert_redirected_to root_path
    assert_equal "approved", @campaign.reload.status

    patch resume_admin_campaign_url(paused)
    assert_redirected_to root_path
    assert_equal "paused", paused.reload.status
  end

  test "non-admin cannot create a campaign" do
    sign_in @non_admin
    assert_no_difference "Campaign.count" do
      post admin_campaigns_url, params: { campaign: { name: "Sneaky" } }
    end
    assert_redirected_to root_path
  end
end
