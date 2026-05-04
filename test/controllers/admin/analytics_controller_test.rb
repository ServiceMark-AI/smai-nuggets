require "test_helper"

class Admin::AnalyticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user  = users(:one)
  end

  test "redirects to sign-in when unauthenticated" do
    get admin_analytics_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin is turned away" do
    sign_in @user
    get admin_analytics_url
    assert_redirected_to root_path
  end

  test "admin sees the analytics page with hero tiles, funnel, originator table, and pending-data callout" do
    sign_in @admin
    get admin_analytics_url
    assert_response :success
    assert_match "Conversion rate", response.body
    assert_match "Closed revenue", response.body
    assert_match "Active pipeline", response.body
    assert_match "Follow-ups sent", response.body
    assert_match "Where jobs are won and lost", response.body
    assert_match "Originator performance", response.body
    assert_match "Follow-up activity", response.body
    assert_match "Pending data", response.body
  end

  test "page surfaces the right counts when a proposal has campaign + sent step" do
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: :won, proposal_value: 5_000)
    instance = CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :completed)
    CampaignStepInstance.create!(
      campaign_instance: instance, campaign_step: campaign_steps(:approved_step_one),
      planned_delivery_at: 1.hour.ago, email_delivery_status: :sent,
      final_subject: "x", final_body: "y"
    )

    sign_in @admin
    get admin_analytics_url
    assert_response :success
    # Conversion rate: 1 won / 1 activated = 100%
    assert_match "100%", response.body
    # Closed revenue: $5,000
    assert_match "$5,000", response.body
  end
end
