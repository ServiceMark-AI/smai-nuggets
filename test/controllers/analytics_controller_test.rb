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

  test "by-location breakdown renders a per-location bar chart sorted by rate descending" do
    tenant   = tenants(:one)
    high_loc = locations(:ne_dallas)
    low_loc  = tenant.locations.create!(
      display_name: "Low Performer", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75003", phone_number: "(214) 555-0303", is_active: true
    )

    # high_loc: 1 won out of 1 activated → 100%
    high = job_proposals(:in_users_org)
    high.update!(location: high_loc, pipeline_stage: :won)
    CampaignInstance.create!(host: high, campaign: campaigns(:approved_campaign), status: :active)

    # low_loc: 0 won out of 1 activated → 0%
    low = job_proposals(:same_tenant_other_org)
    low.update!(location: low_loc, pipeline_stage: :in_campaign)
    CampaignInstance.create!(host: low, campaign: campaigns(:approved_campaign), status: :active)

    sign_in @user_one
    get analytics_url
    assert_response :success
    # Both locations render with a progress bar inside the breakdown.
    assert_select "#cr-by-location .progress .progress-bar", minimum: 1
    # High-performer's row appears before the low-performer's (descending by
    # rate). Scope the index lookup to #cr-by-location — the page now also
    # has a "Conversion rate by location" card grid sorted alphabetically,
    # and a body-wide index() would pick those names up first.
    breakdown_html = css_select("#cr-by-location").first.to_s
    high_pos = breakdown_html.index(high_loc.display_name)
    low_pos  = breakdown_html.index(low_loc.display_name)
    assert high_pos < low_pos, "expected #{high_loc.display_name} (100%) above #{low_loc.display_name} (0%) in the breakdown"
  end

  test "Conversion rate by location section renders one card per location with MTD/YTD" do
    tenant = tenants(:one)
    loc_a = locations(:ne_dallas)
    loc_b = tenant.locations.create!(
      display_name: "South Dallas", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75002", phone_number: "(214) 555-0202", is_active: true
    )
    job_proposals(:in_users_org).update!(location: loc_a)
    job_proposals(:same_tenant_other_org).update!(location: loc_b)

    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_match "Conversion rate by location", response.body
    assert_match loc_a.display_name, response.body
    assert_match loc_b.display_name, response.body
    # MTD/YTD labels live in spans inside each card. The Conversion Rate
    # hero tile and the Closed Revenue tile each have one MTD/YTD pair too,
    # so >= 4 total (2 hero tiles + ≥2 location cards).
    assert_select "span", text: "MTD", minimum: 4
    assert_select "span", text: "YTD", minimum: 4
  end

  test "Conversion rate by location section is hidden for single-location tenants" do
    job_proposals(:other_tenant).update!(location: locations(:globex_main))
    sign_in @user_two
    get analytics_url
    assert_response :success
    assert_no_match "Conversion rate by location", response.body
  end

  test "Conversion rate by location section is hidden for users scoped to a location" do
    @user_one.update!(location: locations(:ne_dallas))
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_no_match "Conversion rate by location", response.body
  end

  test "by-location breakdown renders an em-dash for zero-denominator locations" do
    tenant = tenants(:one)
    other_loc = tenant.locations.create!(
      display_name: "Quiet Branch", address_line_1: "9 Side", city: "Dallas",
      state: "TX", postal_code: "75004", phone_number: "(214) 555-0404", is_active: true
    )

    # ne_dallas has activations; Quiet Branch is referenced via a proposal
    # but has no campaign instance — its activated count is 0, so the rate
    # row should render "—" instead of "0%".
    job_proposals(:in_users_org).update!(location: locations(:ne_dallas))
    CampaignInstance.create!(host: job_proposals(:in_users_org), campaign: campaigns(:approved_campaign), status: :active)
    job_proposals(:same_tenant_other_org).update!(location: other_loc)

    sign_in @user_one
    get analytics_url
    assert_response :success
    # The em-dash row for Quiet Branch shows up inside the breakdown without a bar.
    assert_select "#cr-by-location" do
      assert_match "Quiet Branch", response.body
      assert_match "—", response.body
    end
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

  # --- Location slicer ----------------------------------------------------

  test "tenant admin with multiple locations sees a Location slicer defaulting to All locations" do
    tenant = tenants(:one)
    tenant.locations.create!(
      display_name: "South Dallas", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75002", phone_number: "(214) 555-0202", is_active: true
    )
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_select "form[action=?][method=get] select[name=location_id]", analytics_path
    assert_select "select[name=location_id] option[value='']", text: "All locations"
  end

  test "selecting a location narrows the proposals scope across every section" do
    tenant   = tenants(:one)
    dallas   = locations(:ne_dallas)
    south    = tenant.locations.create!(
      display_name: "South Dallas", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75002", phone_number: "(214) 555-0202", is_active: true
    )

    # Dallas: $5K won (counts toward Closed revenue when scoped here).
    dallas_jp = job_proposals(:in_users_org)
    dallas_jp.update!(location: dallas, pipeline_stage: :won, proposal_value: 5_000)
    CampaignInstance.create!(host: dallas_jp, campaign: campaigns(:approved_campaign), status: :completed)

    # South Dallas: $9K won — should be excluded when filtering to Dallas only.
    south_jp = job_proposals(:same_tenant_other_org)
    south_jp.update!(location: south, pipeline_stage: :won, proposal_value: 9_000)
    CampaignInstance.create!(host: south_jp, campaign: campaigns(:approved_campaign), status: :completed)

    sign_in @user_one
    get analytics_url, params: { location_id: dallas.id }
    assert_response :success
    assert_match "$5,000", response.body
    assert_no_match "$9,000", response.body
    # Scope label reflects the active location.
    assert_match dallas.display_name, response.body
  end

  test "location slicer is hidden for users scoped to a single location" do
    @user_one.update!(location: locations(:ne_dallas))
    sign_in @user_one
    get analytics_url
    assert_response :success
    assert_select "select[name=location_id]", count: 0
  end

  test "an originator's tampered location_id param is ignored — scope stays at their own location" do
    other_loc = tenants(:one).locations.create!(
      display_name: "Other Branch", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75003", phone_number: "(214) 555-0303", is_active: true
    )
    @user_one.update!(location: locations(:ne_dallas)) # originator at NE Dallas
    # Plant a $9K won at the Other Branch — must not leak even with a
    # tampered ?location_id param.
    other_jp = job_proposals(:same_tenant_other_org)
    other_jp.update!(location: other_loc, pipeline_stage: :won, proposal_value: 9_000)

    sign_in @user_one
    get analytics_url, params: { location_id: other_loc.id }
    assert_response :success
    assert_no_match "$9,000", response.body
  end

  test "a cross-tenant location_id param is ignored" do
    foreign = locations(:globex_main) # belongs to tenant: two
    sign_in @user_one
    get analytics_url, params: { location_id: foreign.id }
    assert_response :success
    # Slicer should fall back to All locations — selected_location_id stays nil.
    assert_select "select[name=location_id] option[selected]", count: 0
  end

  test "slicer is hidden for tenants with only one location" do
    job_proposals(:other_tenant).update!(location: locations(:globex_main))
    sign_in @user_two # tenant: two has one location
    get analytics_url
    assert_response :success
    assert_select "select[name=location_id]", count: 0
  end

  # --- Date range slicer ------------------------------------------------

  test "date range narrows the proposals scope by created_at" do
    inside  = job_proposals(:in_users_org)
    outside = job_proposals(:same_tenant_other_org)
    inside.update!(pipeline_stage: :won, proposal_value: 5_000, created_at: Date.new(2026, 3, 15))
    outside.update!(pipeline_stage: :won, proposal_value: 9_000, created_at: Date.new(2026, 1, 5))

    sign_in @user_one
    get analytics_url, params: { date_from: "2026-03-01", date_to: "2026-03-31" }
    assert_response :success
    assert_match "$5,000", response.body
    assert_no_match "$9,000", response.body
  end

  test "date_from alone bounds only the lower edge" do
    inside  = job_proposals(:in_users_org)
    outside = job_proposals(:same_tenant_other_org)
    inside.update!(pipeline_stage: :won, proposal_value: 5_000, created_at: Date.new(2026, 4, 1))
    outside.update!(pipeline_stage: :won, proposal_value: 9_000, created_at: Date.new(2026, 1, 5))

    sign_in @user_one
    get analytics_url, params: { date_from: "2026-03-01" }
    assert_response :success
    assert_match "$5,000", response.body
    assert_no_match "$9,000", response.body
  end

  test "malformed date params don't 500 — slicer falls back to all-time" do
    sign_in @user_one
    get analytics_url, params: { date_from: "not-a-date", date_to: "also-bad" }
    assert_response :success
  end
end
