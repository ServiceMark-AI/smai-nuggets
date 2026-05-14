class JobProposal < ApplicationRecord
  # Soft-delete via the discard gem. The default_scope hides discarded
  # rows from index/show/accessible_by/analytics/sweep so the rest of the
  # app treats a discarded proposal as gone. The admin trash page reads
  # discarded rows explicitly via `.with_discarded`.
  include Discard::Model
  default_scope -> { kept }

  # Append-only audit trail via paper_trail. Every create / update /
  # destroy on a proposal writes a row to the polymorphic `versions`
  # table. We route writes through our locked-down Version subclass
  # (see app/models/version.rb) so rows can't be edited or deleted
  # after the fact. The activity timeline on the proposal show page
  # reads these.
  #
  # Ignore the bookkeeping `updated_at` so a touch (or a save that
  # only differs in updated_at) doesn't produce a noise row in the
  # timeline — paper_trail skips writing a version when the changeset
  # consists only of ignored attributes.
  has_paper_trail versions: { class_name: "Version" }, ignore: [:updated_at]

  belongs_to :tenant
  belongs_to :location
  belongs_to :owner, class_name: "User"
  belongs_to :created_by_user, class_name: "User"
  belongs_to :closed_by_user, class_name: "User", optional: true
  belongs_to :job_type, optional: true
  belongs_to :scenario, optional: true
  belongs_to :loss_reason, optional: true

  has_many :attachments, class_name: "JobProposalAttachment", dependent: :destroy
  has_many :campaign_instances, as: :host, dependent: :destroy

  enum :status, { drafting: 0, approving: 1, approved: 2 }, prefix: true
  enum :pipeline_stage,
       { in_campaign: "in_campaign", won: "won", lost: "lost" },
       prefix: true

  # When the proposal's tenant requires a DASH-style job reference (per
  # PRD-02 v1.5 §5 / PRD-10 v1.3.1 §7.5), require it before approving the
  # proposal — but allow drafting and approving states to persist without
  # one so the operator can fill it in on the edit form.
  validate :dash_job_number_required_when_approved

  # Refuse to discard a proposal with a live campaign on it — the sweep
  # would otherwise keep shipping steps for a job the admin has hidden.
  # Admins must pause the campaign first.
  before_discard :ensure_no_live_campaign!

  # Read-side helper for the trash page (and any future cross-state
  # lookup). default_scope above hides discarded rows everywhere else.
  def self.with_discarded
    unscoped
  end

  # Operator hasn't done their part yet on this proposal — it sits in
  # one of: drafting (not finished), approving (campaign drafted but
  # awaiting operator approval), or approved+in-campaign with an
  # attention-grabbing overlay (customer replied, delivery failed).
  # Won/lost proposals are always excluded — once the job's outcome is
  # decided, there's nothing left for the operator to do here.
  # Powers the sidebar's "Needs Attention" badge and filter.
  scope :needs_attention, -> {
    # Allow NULL pipeline_stage through — proposals haven't necessarily
    # been assigned an in_campaign stage by the time they're drafting,
    # and SQL `NOT IN ('won','lost')` would silently drop NULL rows.
    drafting_or_approving = where(status: [:drafting, :approving])
      .where(pipeline_stage: [nil, :in_campaign])
    flagged_in_flight = where(
      status: :approved,
      pipeline_stage: :in_campaign,
      status_overlay: %w[customer_waiting delivery_issue]
    )
    drafting_or_approving.or(flagged_in_flight)
  }

  # Fields whose presence is required before a campaign can launch. The
  # operator-facing reason is shown both inline on the edit page (so the
  # author knows why the field matters) and on the proposal show page's
  # Campaign card when launch is blocked. Keep this in sync with the merge
  # fields actually consumed by MailGenerator — anything used in a
  # template's body or subject should appear here so a missing value can't
  # silently render as "" at send time.
  CAMPAIGN_READINESS_FIELDS = {
    scenario_id:           "Picks which campaign runs for this proposal.",
    customer_email:        "Recipient address for the campaign emails — without it there's nowhere to send.",
    customer_first_name:   "Used to address the customer in email templates ({{customer_first_name}}).",
    customer_house_number: "Combined with the street to form the property address shown in email subjects and bodies ({{property_address_short}}).",
    customer_street:       "Combined with the house number to form the property address shown in email subjects and bodies ({{property_address_short}})."
  }.freeze

  # Returns an array of { field:, reason: } hashes for every required
  # field currently blank on the proposal. Empty array means the proposal
  # is ready for the campaign to start.
  def campaign_readiness_blockers
    CAMPAIGN_READINESS_FIELDS.filter_map do |field, reason|
      { field: field, reason: reason } if self[field].blank?
    end
  end

  def campaign_ready?
    campaign_readiness_blockers.empty?
  end

  # Single source of truth for the next call-to-action shown on a proposal.
  # See PRD-01:172 for the underlying mapping. Any combination not listed
  # falls back to :view_job so callers always have something useful to render.
  def self.cta_for(pipeline_stage:, status_overlay:)
    return :view_job unless pipeline_stage == "in_campaign"

    case status_overlay
    when nil                then :view_job
    when "customer_waiting" then :open_in_gmail
    when "delivery_issue"   then :fix_delivery_issue
    when "paused"           then :resume_campaign
    else                         :view_job
    end
  end

  def cta
    return :review_proposal if status_drafting?
    return :review_campaign if status_approving?
    self.class.cta_for(pipeline_stage: pipeline_stage, status_overlay: status_overlay)
  end

  # The campaign step instance that would ship next if the sweep ran right
  # now: the lowest-sequence pending step on the most-recent campaign run.
  # Returns nil when no pending step exists (no run yet, or every step has
  # already shipped). Used by the proposal show page to evaluate the
  # PreSendChecklist for what the operator should fix before the next send.
  def next_pending_step_instance
    instance = campaign_instances.order(created_at: :desc).first
    return nil unless instance

    instance.step_instances
      .where(email_delivery_status: :pending)
      .joins(:campaign_step)
      .order("campaign_steps.sequence_number ASC")
      .first
  end

  # Most recent gmail thread id from any of this proposal's campaign step
  # instances. nil when no email has been sent yet. Used to deep-link the
  # operator into the Gmail conversation when the customer replies.
  def gmail_thread_id
    CampaignStepInstance
      .joins(:campaign_instance)
      .where(campaign_instances: { host_type: "JobProposal", host_id: id })
      .where.not(gmail_thread_id: nil)
      .order(updated_at: :desc)
      .limit(1)
      .pick(:gmail_thread_id)
  end

  # Street number + street, with whitespace squeezed and stripped.
  # Returns nil when both fields are blank so callers can fall back to a placeholder.
  def short_address
    parts = [customer_house_number, customer_street].map { |p| p.to_s.strip }
    joined = parts.reject(&:empty?).join(" ")
    joined.presence
  end

  private

  def dash_job_number_required_when_approved
    return unless tenant&.job_reference_required
    return if dash_job_number.present?
    return if status_drafting? || status_approving?
    errors.add(:dash_job_number, "is required before this job can be approved")
  end

  # Only an :active campaign blocks deletion — that one is mid-send and
  # losing it would orphan in-flight messages. A :drafting instance has
  # never shipped anything (it's the "Review Campaign" state where the
  # operator is deciding whether to approve), so deleting it is safe and
  # is in fact the only way out for an operator who decides not to send.
  def ensure_no_live_campaign!
    live = campaign_instances.where(status: :active).exists?
    if live
      errors.add(:base, "Cannot delete a job with an active campaign. Pause the campaign first.")
      throw(:abort)
    end
  end
end
