require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user_one = users(:one)        # tenant: one
    @user_two = users(:two)        # tenant: two
    @no_tenant = users(:no_tenant) if User.where(email: "no-tenant@example.com").any?
  end

  test "redirects to sign-in when unauthenticated" do
    get analytics_url
    assert_redirected_to new_user_session_path
  end

  test "any signed-in user with a tenant can see the page" do
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_match "Conversion rate", response.body
    assert_match "Originator performance", response.body
  end

  test "page surfaces only the current user's tenant's proposals" do
    # tenant one's fixture proposal — winning, $5000.
    jp_one = job_proposals(:in_users_org)
    jp_one.update!(pipeline_stage: :won, proposal_value: 5_000)
    inst = CampaignInstance.create!(host: jp_one, campaign: campaigns(:approved_campaign), status: :completed)
    CampaignStepInstance.create!(
      campaign_instance: inst, campaign_step: campaign_steps(:approved_step_one),
      planned_delivery_at: 1.hour.ago, email_delivery_status: :sent,
      final_subject: "x", final_body: "y"
    )
    # tenant two's fixture proposal — winning, $9000. Should NOT show up
    # in tenant one's analytics.
    jp_two = job_proposals(:other_tenant)
    jp_two.update!(pipeline_stage: :won, proposal_value: 9_000)

    sign_in @user_one
    get analytics_url
    assert_response :success
    # Tenant one sees their $5,000 closed revenue.
    assert_match "$5,000", response.body
    # Must NOT show tenant two's $9,000.
    assert_no_match "$9,000", response.body
  end

  test "scope label names the user's tenant" do
    sign_in @user_one
    get analytics_url
    assert_match @user_one.tenant.name, response.body
  end
end
