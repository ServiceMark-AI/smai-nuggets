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
end
