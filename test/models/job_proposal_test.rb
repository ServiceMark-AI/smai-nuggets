require "test_helper"

class JobProposalTest < ActiveSupport::TestCase
  setup do
    @jp = job_proposals(:in_users_org)
  end

  test "short_address joins house number and street" do
    @jp.update!(customer_house_number: "1247", customer_street: "Oak Ridge Drive")
    assert_equal "1247 Oak Ridge Drive", @jp.short_address
  end

  test "short_address returns the street alone when house number is blank" do
    @jp.update!(customer_house_number: nil, customer_street: "Oak Ridge Drive")
    assert_equal "Oak Ridge Drive", @jp.short_address
  end

  test "short_address returns the house number alone when street is blank" do
    @jp.update!(customer_house_number: "1247", customer_street: nil)
    assert_equal "1247", @jp.short_address
  end

  test "short_address returns nil when both fields are blank" do
    @jp.update!(customer_house_number: nil, customer_street: nil)
    assert_nil @jp.short_address
  end

  test "short_address returns nil when both fields are whitespace" do
    @jp.update!(customer_house_number: "  ", customer_street: "  ")
    assert_nil @jp.short_address
  end

  test "short_address strips whitespace around each component" do
    @jp.update!(customer_house_number: "  1247  ", customer_street: "  Oak Ridge Drive  ")
    assert_equal "1247 Oak Ridge Drive", @jp.short_address
  end

  # --- pipeline_stage enum ---

  test "pipeline_stage enum maps to its string column values" do
    @jp.update!(pipeline_stage: :in_campaign)
    assert_equal "in_campaign", @jp.reload.pipeline_stage
    assert @jp.pipeline_stage_in_campaign?

    @jp.update!(pipeline_stage: :won)
    assert_equal "won", @jp.reload.pipeline_stage

    @jp.update!(pipeline_stage: :lost)
    assert_equal "lost", @jp.reload.pipeline_stage

    @jp.update!(pipeline_stage: nil)
    assert_nil @jp.reload.pipeline_stage
  end

  test "pipeline_stage rejects unknown values" do
    assert_raises(ArgumentError) { @jp.pipeline_stage = "in_progress" }
  end

  # --- cta_for ---

  test "cta_for returns view_job for in_campaign with no overlay" do
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: "in_campaign", status_overlay: nil)
  end

  test "cta_for returns open_in_gmail for in_campaign + customer_waiting" do
    assert_equal :open_in_gmail, JobProposal.cta_for(pipeline_stage: "in_campaign", status_overlay: "customer_waiting")
  end

  test "cta_for returns fix_delivery_issue for in_campaign + delivery_issue" do
    assert_equal :fix_delivery_issue, JobProposal.cta_for(pipeline_stage: "in_campaign", status_overlay: "delivery_issue")
  end

  test "cta_for returns resume_campaign for in_campaign + paused" do
    assert_equal :resume_campaign, JobProposal.cta_for(pipeline_stage: "in_campaign", status_overlay: "paused")
  end

  test "cta_for returns view_job for won proposals regardless of overlay" do
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: "won", status_overlay: nil)
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: "won", status_overlay: "anything")
  end

  test "cta_for returns view_job for lost proposals regardless of overlay" do
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: "lost", status_overlay: nil)
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: "lost", status_overlay: "anything")
  end

  test "cta_for falls back to view_job for nil pipeline_stage" do
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: nil, status_overlay: nil)
  end

  test "cta_for falls back to view_job for unknown overlays under in_campaign" do
    assert_equal :view_job, JobProposal.cta_for(pipeline_stage: "in_campaign", status_overlay: "wat")
  end

  test "cta delegates to cta_for using the proposal's own values once past drafting" do
    @jp.update!(status: :approved, pipeline_stage: :in_campaign, status_overlay: "delivery_issue")
    assert_equal :fix_delivery_issue, @jp.cta
  end

  test "cta returns review_proposal for proposals still in drafting" do
    @jp.update!(status: :drafting)
    assert_equal :review_proposal, @jp.cta
  end

  test "cta returns review_campaign for proposals in approving" do
    @jp.update!(status: :approving)
    assert_equal :review_campaign, @jp.cta
  end

  # --- needs_attention scope ---

  test "needs_attention includes drafting proposals" do
    @jp.update!(status: :drafting)
    assert_includes JobProposal.needs_attention, @jp
  end

  test "needs_attention includes approving proposals" do
    @jp.update!(status: :approving)
    assert_includes JobProposal.needs_attention, @jp
  end

  test "needs_attention includes approved proposals with customer_waiting overlay" do
    @jp.update!(status: :approved, pipeline_stage: :in_campaign, status_overlay: "customer_waiting")
    assert_includes JobProposal.needs_attention, @jp
  end

  test "needs_attention includes approved proposals with delivery_issue overlay" do
    @jp.update!(status: :approved, pipeline_stage: :in_campaign, status_overlay: "delivery_issue")
    assert_includes JobProposal.needs_attention, @jp
  end

  test "needs_attention excludes approved in-campaign proposals with no overlay" do
    @jp.update!(status: :approved, pipeline_stage: :in_campaign, status_overlay: nil)
    assert_not_includes JobProposal.needs_attention, @jp
  end

  test "needs_attention excludes approved proposals with paused overlay" do
    @jp.update!(status: :approved, pipeline_stage: :in_campaign, status_overlay: "paused")
    assert_not_includes JobProposal.needs_attention, @jp
  end

  test "needs_attention excludes won/lost proposals regardless of overlay" do
    @jp.update!(status: :approved, pipeline_stage: :won, status_overlay: "customer_waiting")
    assert_not_includes JobProposal.needs_attention, @jp
    @jp.update!(pipeline_stage: :lost)
    assert_not_includes JobProposal.needs_attention, @jp
  end

  # --- gmail_thread_id ---

  test "gmail_thread_id is nil when no step instances exist" do
    assert_nil @jp.gmail_thread_id
  end

  # --- campaign_readiness_blockers ---

  test "campaign_ready? is true when every required field has a value" do
    @jp.update!(
      scenario: scenarios(:sewage_backup),
      customer_email: "x@example.com",
      customer_first_name: "Alice",
      customer_house_number: "1",
      customer_street: "Oak"
    )
    assert @jp.campaign_ready?
    assert_empty @jp.campaign_readiness_blockers
  end

  test "campaign_readiness_blockers reports each blank field with an operator-facing reason" do
    @jp.update!(
      scenario: nil,
      customer_email: nil,
      customer_first_name: nil,
      customer_house_number: nil,
      customer_street: nil
    )
    refute @jp.campaign_ready?
    blockers = @jp.campaign_readiness_blockers
    assert_equal 5, blockers.size
    blockers.each do |b|
      assert_kind_of Symbol, b[:field]
      assert b[:reason].present?
    end
    fields = blockers.map { |b| b[:field] }
    assert_includes fields, :scenario_id
    assert_includes fields, :customer_email
  end

  test "campaign_readiness_blockers omits fields that have any non-blank value" do
    @jp.update!(
      scenario: scenarios(:sewage_backup),
      customer_email: "x@example.com",
      customer_first_name: "Alice",
      customer_house_number: nil,
      customer_street: nil
    )
    fields = @jp.campaign_readiness_blockers.map { |b| b[:field] }
    refute_includes fields, :scenario_id
    refute_includes fields, :customer_email
    assert_includes fields, :customer_house_number
    assert_includes fields, :customer_street
  end

  test "gmail_thread_id returns the most recently updated step instance's thread id" do
    instance = CampaignInstance.create!(host: @jp, campaign: campaigns(:approved_campaign), status: :active)
    older = CampaignStepInstance.create!(
      campaign_instance: instance, campaign_step: campaign_steps(:approved_step_one),
      gmail_thread_id: "OLD-thread", email_delivery_status: :sent
    )
    newer = CampaignStepInstance.create!(
      campaign_instance: instance, campaign_step: campaign_steps(:approved_step_two),
      gmail_thread_id: "NEW-thread", email_delivery_status: :sent
    )
    older.update!(updated_at: 2.hours.ago)
    newer.update!(updated_at: 1.hour.ago)

    assert_equal "NEW-thread", @jp.gmail_thread_id
  end
end
