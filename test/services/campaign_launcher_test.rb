require "test_helper"

class CampaignLauncherTest < ActiveSupport::TestCase
  setup do
    @proposal = job_proposals(:in_users_org)
    @scenario = scenarios(:sewage_backup)  # campaign: approved_campaign (2 steps)
  end

  test "launches an active CampaignInstance with one step instance per step" do
    @proposal.update!(scenario: @scenario)

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

  test "step instances are pending with no rendered copy and offset planned_delivery_at" do
    @proposal.update!(scenario: @scenario)
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
    @proposal.update!(scenario: @scenario)
    CampaignInstance.create!(host: @proposal, campaign: campaigns(:approved_campaign), status: :active)

    assert_no_difference "CampaignInstance.count" do
      result = CampaignLauncher.launch(@proposal)
      assert_equal :already_running, result.reason
      assert_nil result.instance
    end
  end

  test "no-ops when the proposal has no scenario" do
    @proposal.update!(scenario: nil)
    assert_no_difference "CampaignInstance.count" do
      result = CampaignLauncher.launch(@proposal)
      assert_equal :no_scenario, result.reason
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
