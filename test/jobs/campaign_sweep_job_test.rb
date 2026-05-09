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
    # status:approved is the operator-explicit "go" gate the sweep checks
    # before sending. Existing tests pre-date this gate; default to approved
    # and let any gate-specific tests below override.
    @proposal.update!(
      status: :approved,
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

  test "skips a step when host JobProposal status is not approved" do
    @proposal.update!(status: :approving)
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "sends a due pending step and marks it sent (redirected to TEST_TO_EMAIL)" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    step_instance.reload
    assert_equal "sent", step_instance.email_delivery_status
    assert_equal @step_one.template_subject, step_instance.final_subject
    # final_body is template_body rendered through MailGenerator, which
    # also prepends a salutation and appends a signature block. Assert
    # the substituted body content appears between the wrappers; the
    # salutation/signature are verified by MailGenerator's own tests.
    assert_includes step_instance.final_body, @step_one.template_body,
      "final_body should contain the rendered template; got: #{step_instance.final_body.inspect}"

    assert_equal 1, GmailSender.deliveries.size
    delivery = GmailSender.deliveries.first
    assert_equal "redirect@test.example.com", delivery[:to]
    # From header carries the proposal owner's display name when set,
    # otherwise just the bare connected-mailbox email.
    expected_from = @proposal.owner.full_name.present? ? %("#{@proposal.owner.full_name}" <ops@example.com>) : "ops@example.com"
    assert_equal expected_from, delivery[:from]
    assert_equal @step_one.template_subject, delivery[:subject]
  end

  test "From header carries the proposal owner's display name when set" do
    @proposal.owner.update!(first_name: "Mike", last_name: "Frizzell")
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "sent", step_instance.reload.email_delivery_status
    assert_equal 1, GmailSender.deliveries.size
    assert_equal %("Mike Frizzell" <ops@example.com>), GmailSender.deliveries.first[:from]
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

  test "marks step failed and stops instance when final_subject is missing (legacy/un-approved row)" do
    step_instance = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step_one,
      planned_delivery_at: 1.minute.ago,
      email_delivery_status: :pending,
      final_subject: nil,
      final_body: nil
    )

    CampaignSweepJob.new.perform

    assert_equal "failed", step_instance.reload.email_delivery_status
    assert_equal "stopped_on_delivery_issue", @instance.reload.status
    assert_empty GmailSender.deliveries
  end

  test "marks step failed and stops instance when GmailSender returns nil" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_gmail_sender_returning(nil) do
      CampaignSweepJob.new.perform
    end

    assert_equal "failed", step_instance.reload.email_delivery_status
    assert_equal "stopped_on_delivery_issue", @instance.reload.status
    assert_not_nil @instance.reload.ended_at, "ended_at should be stamped when the instance is stopped"
  end

  test "persists gmail send response and thread snapshot on a successful send" do
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform
    step_instance.reload

    assert_equal "sent", step_instance.email_delivery_status
    assert step_instance.gmail_send_response.present?, "send response should be stored"
    assert step_instance.gmail_send_response["threadId"].present?, "send response should include threadId"
    assert_equal step_instance.gmail_send_response["threadId"], step_instance.gmail_thread_id
    assert step_instance.gmail_thread_snapshot.present?, "thread snapshot should be captured"
    assert_equal step_instance.gmail_thread_id, step_instance.gmail_thread_snapshot["id"]
  end

  test "stamps ended_at when the final step completes the campaign instance" do
    sent_step = build_step_instance(@step_one, status: :sent, due: 2.hours.ago)
    sent_step.update!(final_subject: "x", final_body: "y")
    final_step = build_step_instance(@step_two, status: :pending, due: 1.minute.ago)

    freeze_time = Time.current
    travel_to(freeze_time) { CampaignSweepJob.new.perform }

    @instance.reload
    assert_equal "sent", final_step.reload.email_delivery_status
    assert_equal "completed", @instance.status
    assert_in_delta freeze_time, @instance.ended_at, 1.second
  end

  test "first step attaches PDF attachments from the proposal" do
    attach_pdf!(@proposal, filename: "proposal.pdf")
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "sent", step_instance.reload.email_delivery_status
    delivery = GmailSender.deliveries.first
    assert_equal 1, delivery[:attachments].size
    assert_equal "proposal.pdf", delivery[:attachments].first[:filename]
    assert_equal "application/pdf", delivery[:attachments].first[:mime_type]
  end

  test "later steps do not attach the proposal PDF" do
    attach_pdf!(@proposal, filename: "proposal.pdf")
    sent_step_one = build_step_instance(@step_one, status: :sent, due: 2.hours.ago)
    sent_step_one.update!(final_subject: "x", final_body: "y")
    final_step = build_step_instance(@step_two, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "sent", final_step.reload.email_delivery_status
    delivery = GmailSender.deliveries.first
    assert_equal [], delivery[:attachments], "step two should not carry the proposal PDF"
  end

  test "non-PDF attachments are not sent on the first email" do
    image = @proposal.attachments.build(uploaded_by_user: users(:one))
    image.file.attach(io: StringIO.new("\x89PNG fake"), filename: "ceiling.png", content_type: "image/png")
    image.save!
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    CampaignSweepJob.new.perform

    assert_equal "sent", step_instance.reload.email_delivery_status
    assert_equal [], GmailSender.deliveries.first[:attachments]
  end

  test "FAKE-SEND mode does not populate gmail_send_response or thread snapshot" do
    @mailbox.destroy!
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)
    ENV.delete("TEST_TO_EMAIL")

    with_production_environment(false) { CampaignSweepJob.new.perform }

    step_instance.reload
    assert_equal "sent", step_instance.email_delivery_status
    assert_nil step_instance.gmail_send_response
    assert_nil step_instance.gmail_thread_id
    assert_nil step_instance.gmail_thread_snapshot
  end

  test "skips the sweep entirely outside development when no mailbox is connected" do
    @mailbox.destroy!
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)

    with_production_environment(true) { CampaignSweepJob.new.perform }

    assert_equal "pending", step_instance.reload.email_delivery_status
    assert_empty GmailSender.deliveries
  end

  test "in development with no mailbox, runs in FAKE-SEND mode and progresses the step" do
    @mailbox.destroy!
    step_instance = build_step_instance(@step_one, status: :pending, due: 1.minute.ago)
    # No TEST_TO_EMAIL set in this test path so we use the real customer
    # email as the fake recipient — exercises the resolution logic.
    ENV.delete("TEST_TO_EMAIL")

    with_production_environment(false) { CampaignSweepJob.new.perform }

    assert_equal "sent", step_instance.reload.email_delivery_status
    assert_equal @step_one.template_subject, step_instance.final_subject
    # final_body is template_body rendered through MailGenerator, which
    # also prepends a salutation and appends a signature block. Assert
    # the substituted body content appears between the wrappers; the
    # salutation/signature are verified by MailGenerator's own tests.
    assert_includes step_instance.final_body, @step_one.template_body,
      "final_body should contain the rendered template; got: #{step_instance.final_body.inspect}"
    # Crucially: no real GmailSender call happened. The dev fake-send
    # path bypasses the sender entirely.
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
    # Post-approve, every step instance carries its final_subject /
    # final_body — content is locked in at approve time and the sweep
    # ships that frozen copy. Render here via MailGenerator so each
    # test starts with a realistic post-approve row.
    rendered = MailGenerator.render(campaign_step: step, job_proposal: @proposal)
    CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: step,
      planned_delivery_at: due,
      email_delivery_status: status,
      final_subject: rendered.subject,
      final_body: rendered.body
    )
  end

  def attach_pdf!(proposal, filename:)
    att = proposal.attachments.build(uploaded_by_user: users(:one))
    att.file.attach(
      io: StringIO.new("%PDF-1.4 fake content"),
      filename: filename,
      content_type: "application/pdf"
    )
    att.save!
    att
  end

  def with_gmail_sender_returning(value)
    original = GmailSender.instance_method(:send_email)
    GmailSender.define_method(:send_email) { |to:, subject:, body:, from_name: nil, attachments: []| value }
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
