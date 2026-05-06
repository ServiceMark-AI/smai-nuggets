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
end
