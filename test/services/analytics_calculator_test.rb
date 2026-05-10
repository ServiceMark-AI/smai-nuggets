require "test_helper"

class AnalyticsCalculatorTest < ActiveSupport::TestCase
  test "scope-narrowed result excludes proposals outside the scope" do
    JobProposal.update_all(pipeline_stage: "in_campaign")
    job_proposals(:in_users_org).update!(pipeline_stage: :won, proposal_value: 5_000)
    job_proposals(:other_tenant).update!(pipeline_stage: :won, proposal_value: 9_000)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    assert_equal 5_000.to_d, result.closed_revenue, "tenant_one's calculator should not see tenant_two's revenue"
  end

  test "campaign + step instance counts respect the proposal scope" do
    # Set up tenant one's proposal with one sent step.
    jp1 = job_proposals(:in_users_org)
    inst1 = CampaignInstance.create!(host: jp1, campaign: campaigns(:approved_campaign), status: :active)
    CampaignStepInstance.create!(
      campaign_instance: inst1, campaign_step: campaign_steps(:approved_step_one),
      planned_delivery_at: 1.hour.ago, email_delivery_status: :sent,
      final_subject: "x", final_body: "y"
    )
    # Tenant two's proposal also has a sent step — should not contribute
    # to tenant one's totals.
    jp2 = job_proposals(:other_tenant)
    inst2 = CampaignInstance.create!(host: jp2, campaign: campaigns(:approved_campaign), status: :active)
    CampaignStepInstance.create!(
      campaign_instance: inst2, campaign_step: campaign_steps(:approved_step_one),
      planned_delivery_at: 1.hour.ago, email_delivery_status: :sent,
      final_subject: "x", final_body: "y"
    )

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    assert_equal 1, result.activated_count
    assert_equal 1, result.first_followup_delivered
    assert_equal 1, result.follow_ups_sent
  end

  test "conversion_rate_pct is nil when no proposals are activated" do
    result = AnalyticsCalculator.new(proposals_scope: JobProposal.none).call
    assert_nil result.conversion_rate_pct
  end

  # --- SPEC-05 v1.0 MTD/YTD --------------------------------------------

  test "conversion_rate_mtd_pct is the won rate among activations created this month" do
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: :won, closed_at: Time.current.beginning_of_month + 1.hour, proposal_value: 5_000)
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active,
                             created_at: Time.current.beginning_of_month + 30.minutes)

    other = job_proposals(:same_tenant_other_org)
    other.update!(pipeline_stage: :in_campaign)
    CampaignInstance.create!(host: other, campaign: campaigns(:approved_campaign), status: :active,
                             created_at: Time.current.beginning_of_month + 1.hour)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    # 1 won out of 2 activated this month → 50%
    assert_equal 50, result.conversion_rate_mtd_pct
  end

  test "conversion_rate_ytd_pct counts only this year's activations and wins" do
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: :won, closed_at: Time.current.beginning_of_year + 1.day, proposal_value: 5_000)
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active,
                             created_at: Time.current.beginning_of_year + 1.hour)

    # An activation from last year — should NOT count toward YTD
    last_year_jp = job_proposals(:same_tenant_other_org)
    last_year_jp.update!(pipeline_stage: :in_campaign)
    CampaignInstance.create!(host: last_year_jp, campaign: campaigns(:approved_campaign), status: :active,
                             created_at: 14.months.ago)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    # 1 won out of 1 activated YTD → 100%
    assert_equal 100, result.conversion_rate_ytd_pct
  end

  test "conversion_rate_mtd_pct and ytd are nil when nothing has been activated" do
    result = AnalyticsCalculator.new(proposals_scope: JobProposal.none).call
    assert_nil result.conversion_rate_mtd_pct
    assert_nil result.conversion_rate_ytd_pct
  end

  # --- Closed revenue MTD/YTD ------------------------------------------

  test "closed_revenue_mtd sums won proposal_value with closed_at this month" do
    job_proposals(:in_users_org).update!(
      pipeline_stage: :won,
      closed_at: Time.current.beginning_of_month + 1.hour,
      proposal_value: 5_000
    )
    # Won earlier in the year — counts toward YTD but not MTD.
    job_proposals(:same_tenant_other_org).update!(
      pipeline_stage: :won,
      closed_at: Time.current.beginning_of_year + 1.day,
      proposal_value: 8_000
    )

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    assert_equal 5_000.to_d,  result.closed_revenue_mtd
    assert_equal 13_000.to_d, result.closed_revenue_ytd
  end

  test "closed_revenue_mtd/ytd ignore wins from prior years" do
    last_year_close = Time.current.beginning_of_year - 1.day
    job_proposals(:in_users_org).update!(
      pipeline_stage: :won, closed_at: last_year_close, proposal_value: 12_345
    )

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    assert_equal 0.to_d, result.closed_revenue_mtd
    assert_equal 0.to_d, result.closed_revenue_ytd
  end

  test "closed_revenue_mtd/ytd are zero when scope has nothing won" do
    result = AnalyticsCalculator.new(proposals_scope: JobProposal.none).call
    assert_equal 0.to_d, result.closed_revenue_mtd
    assert_equal 0.to_d, result.closed_revenue_ytd
  end

  # --- SPEC-06 v1.0 by-location breakdown -------------------------------

  test "conversion_rate_by_location returns one row per location with activated/won/rate" do
    loc_a = locations(:ne_dallas)
    loc_b = tenants(:one).locations.create!(
      display_name: "South Dallas", address_line_1: "5 Side", city: "Dallas",
      state: "TX", postal_code: "75002", phone_number: "(214) 555-0202", is_active: true
    )
    jp_a = job_proposals(:in_users_org)
    jp_a.update!(location: loc_a, pipeline_stage: :won)
    CampaignInstance.create!(host: jp_a, campaign: campaigns(:approved_campaign), status: :active)

    jp_b = job_proposals(:same_tenant_other_org)
    jp_b.update!(location: loc_b, pipeline_stage: :in_campaign)
    CampaignInstance.create!(host: jp_b, campaign: campaigns(:approved_campaign), status: :active)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    rows = result.conversion_rate_by_location
    by_name = rows.index_by { |r| r[:location_display_name] }
    assert_equal 100, by_name["NE Dallas"][:conversion_rate_pct]
    assert_equal 0,   by_name["South Dallas"][:conversion_rate_pct]
  end

  test "conversion_rate_by_location is empty when no proposals have a location" do
    result = AnalyticsCalculator.new(proposals_scope: JobProposal.none).call
    assert_equal [], result.conversion_rate_by_location
  end

  test "conversion_rate_by_location includes per-location MTD and YTD pct" do
    loc = locations(:ne_dallas)
    # MTD win
    jp = job_proposals(:in_users_org)
    jp.update!(location: loc, pipeline_stage: :won, closed_at: Time.current.beginning_of_month + 1.hour)
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active,
                             created_at: Time.current.beginning_of_month + 30.minutes)

    # YTD-but-not-MTD win
    other_jp = job_proposals(:same_tenant_other_org)
    other_jp.update!(location: loc, pipeline_stage: :won, closed_at: Time.current.beginning_of_year + 1.day)
    CampaignInstance.create!(host: other_jp, campaign: campaigns(:approved_campaign), status: :active,
                             created_at: Time.current.beginning_of_year + 1.hour)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    row = result.conversion_rate_by_location.find { |r| r[:location_display_name] == "NE Dallas" }
    assert_equal 100, row[:conversion_rate_mtd_pct], "1 won out of 1 activated MTD = 100%"
    assert_equal 100, row[:conversion_rate_ytd_pct], "2 won out of 2 activated YTD = 100%"
  end

  test "per-location MTD and YTD pct are nil when nothing is activated in that window" do
    loc_b = tenants(:one).locations.create!(
      display_name: "Quiet Branch", address_line_1: "9 Side", city: "Dallas",
      state: "TX", postal_code: "75004", phone_number: "(214) 555-0404", is_active: true
    )
    # Quiet Branch has a proposal but no campaign instance — zero
    # denominator for both MTD and YTD windows.
    jp = job_proposals(:in_users_org)
    jp.update!(location: loc_b)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    row = result.conversion_rate_by_location.find { |r| r[:location_display_name] == "Quiet Branch" }
    assert_nil row[:conversion_rate_mtd_pct]
    assert_nil row[:conversion_rate_ytd_pct]
  end

  # --- Loss reasons breakdown -------------------------------------------

  test "loss_reasons_breakdown groups lost proposals by reason and orders by sort_order" do
    JobProposal.update_all(pipeline_stage: "in_campaign", loss_reason_id: nil)
    job_proposals(:in_users_org).update!(
      pipeline_stage: :lost, loss_reason: loss_reasons(:price_too_high)
    )
    job_proposals(:same_tenant_other_org).update!(
      pipeline_stage: :lost, loss_reason: loss_reasons(:went_with_competitor)
    )
    # Add a second "Price" so it leads.
    extra = JobProposal.create!(
      tenant: tenants(:one), location: locations(:ne_dallas),
      owner: users(:one), created_by_user: users(:one),
      customer_first_name: "X", customer_last_name: "Y", proposal_value: 1,
      pipeline_stage: :lost, loss_reason: loss_reasons(:price_too_high)
    )

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    rows = result.loss_reasons_breakdown
    assert_equal 2, rows.size
    assert_equal "Price too high",       rows[0][:display_name]
    assert_equal 2,                      rows[0][:count]
    assert_equal "Went with competitor", rows[1][:display_name]
    assert_equal 1,                      rows[1][:count]

    extra.destroy!
  end

  test "loss_reasons_breakdown buckets lost proposals with a NULL loss_reason as Unspecified" do
    JobProposal.update_all(pipeline_stage: "in_campaign", loss_reason_id: nil)
    job_proposals(:in_users_org).update!(pipeline_stage: :lost, loss_reason: nil)

    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    rows = result.loss_reasons_breakdown
    assert_equal 1, rows.size
    assert_equal "Unspecified", rows[0][:display_name]
    assert_equal 1, rows[0][:count]
  end

  test "loss_reasons_breakdown is empty when nothing is lost" do
    JobProposal.update_all(pipeline_stage: "in_campaign", loss_reason_id: nil)
    result = AnalyticsCalculator.new(proposals_scope: tenants(:one).job_proposals).call
    assert_equal [], result.loss_reasons_breakdown
  end
end
