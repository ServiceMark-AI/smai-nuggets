class JobProposal < ApplicationRecord
  belongs_to :tenant
  belongs_to :location, optional: true
  belongs_to :owner, class_name: "User"
  belongs_to :created_by_user, class_name: "User"
  belongs_to :closed_by_user, class_name: "User", optional: true
  belongs_to :job_type, optional: true
  belongs_to :scenario, optional: true

  has_many :attachments, class_name: "JobProposalAttachment", dependent: :destroy
  has_many :campaign_instances, as: :host, dependent: :destroy

  enum :status, { drafting: 0, approving: 1, approved: 2 }, prefix: true
  enum :pipeline_stage,
       { in_campaign: "in_campaign", won: "won", lost: "lost" },
       prefix: true

  # Operator hasn't done their part yet on this proposal — it sits in
  # one of: drafting (not finished), approving (campaign drafted but
  # awaiting operator approval), or approved+in-campaign with an
  # attention-grabbing overlay (customer replied, delivery failed).
  # Powers the sidebar's "Needs Attention" badge and filter.
  scope :needs_attention, -> {
    drafting_or_approving = where(status: [:drafting, :approving])
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
end
