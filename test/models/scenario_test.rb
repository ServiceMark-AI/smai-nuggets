require "test_helper"

class ScenarioTest < ActiveSupport::TestCase
  setup do
    @job_type = job_types(:one)
  end

  def valid_attrs(overrides = {})
    {
      job_type: @job_type,
      code: "test_#{SecureRandom.hex(4)}",
      short_name: "Test scenario"
    }.merge(overrides)
  end

  test "valid with required fields" do
    assert Scenario.new(valid_attrs).valid?
  end

  test "requires job_type" do
    refute Scenario.new(valid_attrs(job_type: nil)).valid?
  end

  test "requires code" do
    refute Scenario.new(valid_attrs(code: nil)).valid?
  end

  test "requires short_name" do
    refute Scenario.new(valid_attrs(short_name: nil)).valid?
  end

  test "code may not exceed 64 characters" do
    refute Scenario.new(valid_attrs(code: "x" * 65)).valid?
  end

  test "code is unique within a job type (case-insensitive)" do
    Scenario.create!(valid_attrs(code: "uniq_a"))
    refute Scenario.new(valid_attrs(code: "uniq_a")).valid?
    refute Scenario.new(valid_attrs(code: "UNIQ_A")).valid?
  end

  test "the same code may exist under a different job type" do
    Scenario.create!(valid_attrs)
    other = Scenario.new(valid_attrs(job_type: job_types(:two)))
    assert other.valid?
  end

  test "campaign association is optional" do
    s = Scenario.new(valid_attrs(campaign: nil))
    assert s.valid?
  end

  test "campaign association can be set" do
    s = Scenario.create!(valid_attrs(campaign: campaigns(:approved_campaign)))
    assert_equal campaigns(:approved_campaign), s.campaign
  end
end
