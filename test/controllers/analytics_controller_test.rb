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

  # --- SPEC-06 v1.0 by-location breakdown -------------------------------

  test "tenant admin sees the By location toggle and per-location rows" do
    tenant = tenants(:one)
    location_a = locations(:ne_dallas)
    location_b = tenant.locations.create!(
      display_name: "South Dallas", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75002", phone_number: "(214) 555-0202", is_active: true
    )
    job_proposals(:in_users_org).update!(location: location_a)
    job_proposals(:same_tenant_other_org).update!(location: location_b)

    # @user_one has tenant: one with no location → tenant admin
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_match "By location", response.body
    assert_match location_a.display_name, response.body
    assert_match location_b.display_name, response.body
  end

  test "regular tenant user (scoped to a location) does not see the By location toggle" do
    @user_one.update!(location: locations(:ne_dallas))
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_no_match "By location", response.body
  end

  test "tenant admin in a single-location tenant does not see the toggle (nothing to compare)" do
    # tenant two has globex_main fixture; ensure their proposal lives there
    job_proposals(:other_tenant).update!(location: locations(:globex_main))

    sign_in @user_two
    get analytics_url
    assert_response :success
    assert_no_match "By location", response.body
  end

  # --- Loss reasons pie ------------------------------------------------

  test "Why we lost section renders a pie + reason rows when lost jobs exist" do
    job_proposals(:in_users_org).update!(
      pipeline_stage: :lost, loss_reason: loss_reasons(:price_too_high)
    )
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_match "Why we lost", response.body
    assert_match "Price too high", response.body
    assert_select "div[role=img][aria-label=?]", "Loss reasons breakdown"
  end

  test "Why we lost shows an empty-state message when nothing is lost" do
    JobProposal.update_all(pipeline_stage: "in_campaign", loss_reason_id: nil)
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_match "Why we lost", response.body
    assert_match "No lost jobs yet", response.body
    assert_select "div[role=img][aria-label=?]", "Loss reasons breakdown", count: 0
  end
end
