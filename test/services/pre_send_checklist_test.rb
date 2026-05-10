require "test_helper"

class PreSendChecklistTest < ActiveSupport::TestCase
  setup do
    @campaign = campaigns(:approved_campaign)
    @step = campaign_steps(:approved_step_one)
    @proposal = job_proposals(:in_users_org)
    @proposal.update!(
      status: :approved,
      pipeline_stage: :in_campaign,
      status_overlay: nil,
      customer_email: "alice@example.com",
      customer_house_number: "100",
      customer_street: "Oak Ridge"
    )
    # Per PRD-09 §1, the campaign sends as the originator's own Gmail.
    @owner_delegation = EmailDelegation.create!(
      user: @proposal.owner,
      provider: "google_oauth2",
      email: "originator@example.com",
      access_token: "atk",
      refresh_token: "rtk",
      expires_at: 1.hour.from_now
    )
    @instance = CampaignInstance.create!(campaign: @campaign, host: @proposal, status: :active)
    @step_instance = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step,
      planned_delivery_at: 1.minute.ago,
      email_delivery_status: :pending,
      final_subject: "ready to ship",
      final_body: "hi there"
    )
  end

  test "passes every check on a fully ready step" do
    checks = PreSendChecklist.run(@step_instance)

    assert_equal 8, checks.size, "expected one Check per canonical condition plus the rendered-content guard"
    assert checks.all?(&:pass?), "expected all checks to pass; failing: #{checks.reject(&:pass?).map(&:key).inspect}"
  end

  test "labels are operator-friendly" do
    checks = PreSendChecklist.run(@step_instance)

    assert_match(/originator/i, checks.find { |c| c.key == :originator_mailbox }.label)
    assert_match(/recipient/i, checks.find { |c| c.key == :contact_email }.label)
    assert_match(/suppression/i, checks.find { |c| c.key == :suppression }.label)
  end

  test "fails originator_mailbox with delivery_issue when the proposal owner has no Gmail delegation" do
    @owner_delegation.destroy!

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :originator_mailbox, blocker.key
    assert blocker.block_delivery_issue?
    assert_match(/has not connected their Gmail/i, blocker.detail)
  end

  test "fails originator_mailbox with delivery_issue when the delegation is expired and has no refresh token" do
    @owner_delegation.update!(refresh_token: nil, expires_at: 1.hour.ago)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :originator_mailbox, blocker.key
    assert blocker.block_delivery_issue?
    assert_match(/expired/i, blocker.detail)
  end

  test "passes originator_mailbox when an expired delegation still has a refresh token" do
    @owner_delegation.update!(refresh_token: "rtk", expires_at: 1.hour.ago)

    checks = PreSendChecklist.run(@step_instance)

    assert checks.find { |c| c.key == :originator_mailbox }.pass?
  end

  test "fails pipeline_stage with block_silent when the proposal status is not approved" do
    @proposal.update!(status: :approving)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :pipeline_stage, blocker.key
    assert blocker.block_silent?
  end

  test "fails pipeline_stage with block_silent when the proposal is won" do
    @proposal.update!(pipeline_stage: :won)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :pipeline_stage, blocker.key
    assert blocker.block_silent?
  end

  test "fails status_overlay with block_silent when an overlay is set" do
    @proposal.update!(status_overlay: "paused")

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :status_overlay, blocker.key
    assert blocker.block_silent?
    assert_match(/paused/i, blocker.detail)
  end

  test "fails campaign_active with block_silent when the campaign run is paused" do
    @instance.update!(status: :paused)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :campaign_active, blocker.key
    assert blocker.block_silent?
  end

  test "fails campaign_active with block_silent when the campaign template is paused" do
    @campaign.update!(status: :paused, paused_by_user: users(:one), paused_at: Time.current)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :campaign_active, blocker.key
    assert blocker.block_silent?
    assert_match(/campaign behind/i, blocker.detail)
  end

  test "fails idempotency with block_silent when the step has already been sent" do
    @step_instance.update!(email_delivery_status: :sent)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :idempotency, blocker.key
    assert blocker.block_silent?
  end

  test "passes idempotency while the step is in flight (sending)" do
    @step_instance.update!(email_delivery_status: :sending)

    checks = PreSendChecklist.run(@step_instance)

    assert checks.find { |c| c.key == :idempotency }.pass?
  end

  test "fails contact_email with delivery_issue when the customer email is blank" do
    @proposal.update!(customer_email: nil)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :contact_email, blocker.key
    assert blocker.block_delivery_issue?
  end

  test "fails contact_email with delivery_issue when the customer email is malformed" do
    @proposal.update!(customer_email: "not-an-email")

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :contact_email, blocker.key
    assert blocker.block_delivery_issue?
  end

  test "fails suppression with delivery_issue when the recipient is on the location suppression list" do
    EmailSuppression.create!(
      location: @proposal.location,
      email: "alice@example.com",
      reason: "manual"
    )

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :suppression, blocker.key
    assert blocker.block_delivery_issue?
  end

  test "suppression check is case-insensitive on the email address" do
    EmailSuppression.create!(
      location: @proposal.location,
      email: "ALICE@example.com",
      reason: "manual"
    )

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :suppression, blocker.key
  end

  test "suppression check is scoped per location" do
    other_location = Location.create!(
      tenant: @proposal.tenant,
      display_name: "Other branch",
      address_line_1: "1 Elsewhere Pl",
      city: "Dallas",
      state: "TX",
      postal_code: "75001",
      phone_number: "(555) 555-5555"
    )
    EmailSuppression.create!(
      location: other_location,
      email: "alice@example.com",
      reason: "manual"
    )

    checks = PreSendChecklist.run(@step_instance)

    assert checks.find { |c| c.key == :suppression }.pass?,
      "a suppression entry on a different location must not block this proposal"
  end

  test "fails step_content with delivery_issue when the rendered subject is blank" do
    @step_instance.update!(final_subject: nil)

    blocker = PreSendChecklist.new(@step_instance).first_blocker

    assert_equal :step_content, blocker.key
    assert blocker.block_delivery_issue?
  end

  test "first_blocker returns nil when nothing is wrong" do
    assert_nil PreSendChecklist.new(@step_instance).first_blocker
  end

  test "pass? is true when every check passes" do
    assert PreSendChecklist.new(@step_instance).pass?
  end

  test "pass? is false when any check fails" do
    @proposal.update!(customer_email: nil)

    refute PreSendChecklist.new(@step_instance).pass?
  end
end
