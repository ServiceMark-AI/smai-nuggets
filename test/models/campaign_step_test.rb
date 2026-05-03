require "test_helper"

class CampaignStepTest < ActiveSupport::TestCase
  setup do
    @campaign = campaigns(:approved_campaign)
  end

  test "offset_days/hours/minutes setters compose into offset_min on save" do
    step = @campaign.steps.build(
      sequence_number: 99, template_subject: "S", template_body: "B",
      offset_days: 1, offset_hours: 2, offset_minutes: 30
    )
    assert step.save
    assert_equal (1 * 1440) + (2 * 60) + 30, step.reload.offset_min
  end

  test "offset_days/hours/minutes readers split a stored offset_min when no override is set" do
    step = @campaign.steps.create!(
      sequence_number: 98, template_subject: "S", template_body: "B",
      offset_min: (3 * 1440) + (4 * 60) + 15
    )
    step = @campaign.steps.find(step.id)
    assert_equal 3,  step.offset_days
    assert_equal 4,  step.offset_hours
    assert_equal 15, step.offset_minutes
  end

  test "all three offset parts at zero composes to offset_min = 0" do
    step = @campaign.steps.build(
      sequence_number: 97, template_subject: "S", template_body: "B",
      offset_days: 0, offset_hours: 0, offset_minutes: 0
    )
    assert step.save
    assert_equal 0, step.reload.offset_min
  end

  test "string inputs from a form coerce to integers" do
    step = @campaign.steps.build(
      sequence_number: 96, template_subject: "S", template_body: "B",
      offset_days: "2", offset_hours: "0", offset_minutes: ""
    )
    assert step.save
    assert_equal 2 * 1440, step.reload.offset_min
  end

  test "negative offset_min is rejected" do
    step = @campaign.steps.build(
      sequence_number: 95, template_subject: "S", template_body: "B", offset_min: -5
    )
    refute step.valid?
    assert step.errors[:offset_min].any?
  end
end
