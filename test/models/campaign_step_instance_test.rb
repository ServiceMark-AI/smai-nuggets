require "test_helper"

class CampaignStepInstanceTest < ActiveSupport::TestCase
  setup do
    @campaign = campaigns(:approved_campaign)
    @step = campaign_steps(:approved_step_one)
    @proposal = job_proposals(:in_users_org)
    @instance = CampaignInstance.create!(campaign: @campaign, host: @proposal)
  end

  test "creates a step instance with rendered subject and body and pending delivery status" do
    si = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step,
      final_subject: "Hi Alice — drying day 1",
      final_body: "Here's what to expect tonight…",
      planned_delivery_at: 1.hour.from_now
    )
    assert_equal "pending", si.email_delivery_status
    assert si.email_delivery_status_pending?
    assert_equal "Hi Alice — drying day 1", si.final_subject
    assert_equal @step, si.campaign_step
    assert_equal @instance, si.campaign_instance
  end

  test "exposes all email delivery status transitions" do
    si = CampaignStepInstance.create!(campaign_instance: @instance, campaign_step: @step)
    %w[pending sending sent failed bounced].each do |s|
      si.update!(email_delivery_status: s)
      assert_equal s, si.email_delivery_status
    end
  end

  test "rejects an unknown email delivery status" do
    assert_raises ArgumentError do
      CampaignStepInstance.new(campaign_instance: @instance, campaign_step: @step, email_delivery_status: "exploded")
    end
  end

  test "stores gmail_thread_id and planned_delivery_at" do
    when_at = Time.zone.parse("2026-05-10 09:00:00")
    si = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step,
      gmail_thread_id: "thread-abc-123",
      planned_delivery_at: when_at
    )
    assert_equal "thread-abc-123", si.gmail_thread_id
    assert_equal when_at, si.planned_delivery_at
  end

  test "requires a campaign instance and a step" do
    bare = CampaignStepInstance.new
    assert_not bare.valid?
    assert bare.errors[:campaign_instance].any?
    assert bare.errors[:campaign_step].any?
  end

  test "campaign instance and campaign step expose their step instances" do
    si = CampaignStepInstance.create!(campaign_instance: @instance, campaign_step: @step)
    assert_includes @instance.reload.step_instances, si
    assert_includes @step.reload.step_instances, si
  end

  test "destroying the campaign instance destroys its step instances" do
    CampaignStepInstance.create!(campaign_instance: @instance, campaign_step: @step)
    assert_difference "CampaignStepInstance.count", -1 do
      @instance.destroy
    end
  end

  test "destroying the campaign step destroys its step instances" do
    step = @campaign.steps.create!(sequence_number: 99, offset_min: 60, template_subject: "Tmp", template_body: "Tmp")
    CampaignStepInstance.create!(campaign_instance: @instance, campaign_step: step)
    assert_difference "CampaignStepInstance.count", -1 do
      step.destroy
    end
  end
end
