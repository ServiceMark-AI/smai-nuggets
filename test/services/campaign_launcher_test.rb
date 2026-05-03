require "test_helper"

class CampaignLauncherTest < ActiveSupport::TestCase
  setup do
    @proposal = job_proposals(:in_users_org)
    @scenario = scenarios(:sewage_backup)  # campaign: approved_campaign (2 steps)
    # Set readiness fields so launch passes by default; tests that
    # exercise readiness blockers blank out specific fields.
    @proposal.update!(
      scenario:              @scenario,
      customer_email:        "alice@example.com",
      customer_first_name:   "Alice",
      customer_house_number: "123",
      customer_street:       "Oak Ridge"
    )
  end

  test "launches an active CampaignInstance with one step instance per step" do
    result = nil
    assert_difference "CampaignInstance.count", 1 do
      assert_difference "CampaignStepInstance.count", 2 do
        result = CampaignLauncher.launch(@proposal)
      end
    end
    assert_equal :launched, result.reason

    instance = result.instance
    assert_equal campaigns(:approved_campaign), instance.campaign
    assert_equal @proposal, instance.host
    assert instance.status_active?
  end

  test "launching marks the proposal as in_campaign" do
    @proposal.update!(pipeline_stage: nil)
    CampaignLauncher.launch(@proposal)
    assert_equal "in_campaign", @proposal.reload.pipeline_stage
  end

  test "no-op launch leaves the existing pipeline_stage alone" do
    @proposal.update!(pipeline_stage: "won")
    CampaignInstance.create!(host: @proposal, campaign: campaigns(:approved_campaign), status: :active)
    CampaignLauncher.launch(@proposal)
    assert_equal "won", @proposal.reload.pipeline_stage
  end

  test "step instances are pending with no rendered copy and offset planned_delivery_at" do
    freeze_time = Time.zone.parse("2026-05-03T12:00:00Z")

    travel_to freeze_time do
      CampaignLauncher.launch(@proposal)
    end

    sis = @proposal.campaign_instances.first.step_instances.includes(:campaign_step).order("campaign_steps.sequence_number")
    assert_equal 2, sis.size

    sis.each do |si|
      assert si.email_delivery_status_pending?
      assert_nil si.final_subject
      assert_nil si.final_body
      expected = freeze_time + si.campaign_step.offset_min.minutes
      assert_in_delta expected.to_f, si.planned_delivery_at.to_f, 1.0
    end
  end

  test "no-ops when an instance already exists" do
    CampaignInstance.create!(host: @proposal, campaign: campaigns(:approved_campaign), status: :active)

    assert_no_difference "CampaignInstance.count" do
      result = CampaignLauncher.launch(@proposal)
      assert_equal :already_running, result.reason
      assert_nil result.instance
    end
  end

  test "returns :not_ready with a blockers list when readiness fields are blank" do
    @proposal.update!(scenario: nil, customer_email: nil)
    assert_no_difference "CampaignInstance.count" do
      result = CampaignLauncher.launch(@proposal)
      assert_equal :not_ready, result.reason
      blocker_fields = result.blockers.map { |b| b[:field] }
      assert_includes blocker_fields, :scenario_id
      assert_includes blocker_fields, :customer_email
      result.blockers.each do |b|
        assert b[:reason].present?, "every blocker should carry an operator-facing reason"
      end
    end
  end

  test "no-ops when the scenario has no campaign attached" do
    @proposal.update!(scenario: scenarios(:clean_water))  # fixture: campaign: nil
    assert_no_difference "CampaignInstance.count" do
      result = CampaignLauncher.launch(@proposal)
      assert_equal :no_campaign, result.reason
    end
  end
end
