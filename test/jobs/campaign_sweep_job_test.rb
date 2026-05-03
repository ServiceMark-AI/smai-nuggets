require "test_helper"

class CampaignSweepJobTest < ActiveSupport::TestCase
  setup do
    @mailbox = ApplicationMailbox.create!(
      provider: "google",
      email: "ops@example.com",
      access_token: "atk",
      refresh_token: "rtk",
      expires_at: 1.hour.from_now
    )
    @campaign = campaigns(:approved_campaign)
    @step_one = campaign_steps(:approved_step_one)
    @step_two = campaign_steps(:approved_step_two)
    @proposal = job_proposals(:in_users_org)
    @proposal.update!(
      customer_email: "alice@example.com",
      customer_house_number: "100",
      customer_street: "Oak Ridge"
    )
    @instance = CampaignInstance.create!(campaign: @campaign, host: @proposal, status: :active)

    # Existing tests assume mail goes out. The send gates require either
    # production OR TEST_TO_EMAIL set, so default tests to redirect-mode
    # and let gate-specific tests below opt out explicitly.
    @prior_test_to_email = ENV["TEST_TO_EMAIL"]
    ENV["TEST_TO_EMAIL"] = "redirect@test.example.com"
  end

  teardown do
    if @prior_test_to_email.nil?
      ENV.delete("TEST_TO_EMAIL")
    else
      ENV["TEST_TO_EMAIL"] = @prior_test_to_email
    end
  end

  test "sends a due pending step and marks it sent (redirected to TEST_TO_EMAIL)" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    step_instance.reload
    assert_equal "sent", step_instance.email_delivery_status
    assert_equal @step_one.template_subject, step_instance.final_subject
    assert_equal @step_one.template_body, step_instance.final_body

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal "redirect@test.example.com", delivery[:to]
    assert_equal "ops@example.com", delivery[:from]
    assert_equal @step_one.template_subject, delivery[:subject]
  end

  test "in production with no TEST_TO_EMAIL, mail goes to the customer's address" do
    ENV.delete("TEST_TO_EMAIL")
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_production_environment(true) { CampaignSweepJob.new.perform }

    assert_equal "sent", step_instance.reload.email_delivery_status
    assert_equal 1, GmailSender.deliveries.size
    assert_equal "alice@example.com", GmailSender.deliveries.first[:to]
  end

  test "in development with no TEST_TO_EMAIL, the sweep is a no-op" do
    ENV.delete("TEST_TO_EMAIL")
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_production_environment(false) { CampaignSweepJob.new.perform }

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "TEST_TO_EMAIL overrides the customer address in production too" do
    ENV["TEST_TO_EMAIL"] = "qa@test.example.com"
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_production_environment(true) { CampaignSweepJob.new.perform }

    assert_equal "sent", step_instance.reload.email_delivery_status
    assert_equal 1, GmailSender.deliveries.size
    assert_equal "qa@test.example.com", GmailSender.deliveries.first[:to]
  end

  test "skips steps whose planned_delivery_at is in the future" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 10.minutes.from_now)

    CampaignSweepJob.new.perform

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "skips steps whose campaign is not approved" do
    @campaign.update!(status: :paused, paused_by_user: users(:one), paused_at: Time.current)
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "skips steps whose campaign instance is not active" do
    @instance.update!(status: :paused)
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "marks campaign instance completed when its final step is sent" do
    sent_step = build_step_instance(@step_one, status: :sent, due: 2.hours.ago)
    sent_step.update!(final_subject: "x", final_body: "y")
    final_step = build_step_instance(@step_two, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "sent", final_step.reload.email_delivery_status
    assert_equal "completed", @instance.reload.status
  end

  test "leaves campaign instance active while later steps remain pending" do
    build_step_instance(@step_one, status: :pending, due: 1.minute.ago)
    build_step_instance(@step_two, status: :pending, due: 1.day.from_now)

    CampaignSweepJob.new.perform

    assert_equal "active", @instance.reload.status
  end

  test "marks step failed and stops instance when customer_email is missing in production" do
    ENV.delete("TEST_TO_EMAIL")
    @proposal.update!(customer_email: nil)
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_production_environment(true) { CampaignSweepJob.new.perform }

    assert_equal "failed", step_instance.reload.email_delivery_status
    assert_equal "stopped_on_delivery_issue", @instance.reload.status
    assert_empty GmailSender.deliveries
  end

  test "marks step failed and stops instance when render has unresolved merge fields" do
    @step_one.update!(template_body: "Hi {{totally_unknown_field}}")
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "failed", step_instance.reload.email_delivery_status
    assert_equal "stopped_on_delivery_issue", @instance.reload.status
    assert_empty GmailSender.deliveries
  end

  test "marks step failed and stops instance when GmailSender returns false" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_gmail_sender_returning(false) do
      CampaignSweepJob.new.perform
    end

    assert_equal "failed", step_instance.reload.email_delivery_status
    assert_equal "stopped_on_delivery_issue", @instance.reload.status
  end

  test "skips the sweep entirely when no application mailbox is connected" do
    @mailbox.destroy!
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "claim is idempotent across overlapping sweeps" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform
    CampaignSweepJob.new.perform

    assert_equal "sent", step_instance.reload.email_delivery_status
    assert_equal 1, GmailSender.deliveries.size
  end

  private

  def build_step_instance(step, status:, due:)
    CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: step,
      planned_delivery_at: due,
      email_delivery_status: status
    )
  end

  def with_gmail_sender_returning(value)
    original = GmailSender.instance_method(:send_email)
    GmailSender.define_method(:send_email) { |to:, subject:, body:| value }
    yield
  ensure
    GmailSender.define_method(:send_email, original)
  end

  def with_production_environment(value)
    original = CampaignSweepJob.singleton_method(:production_environment?)
    CampaignSweepJob.define_singleton_method(:production_environment?) { value }
    yield
  ensure
    CampaignSweepJob.define_singleton_method(:production_environment?, original)
  end
end
