class JobProposal < ApplicationRecord
  belongs_to :tenant
  belongs_to :organization
  belongs_to :owner, class_name: "User"
  belongs_to :created_by_user, class_name: "User"
  belongs_to :closed_by_user, class_name: "User", optional: true
  belongs_to :job_type, optional: true
  belongs_to :scenario, optional: true

  has_many :attachments, class_name: "JobProposalAttachment", dependent: :destroy
  has_many :campaign_instances, as: :host, dependent: :destroy

  enum :status, { new: 0, open: 1, closed: 2 }, prefix: true
  enum :pipeline_stage,
       { in_campaign: "in_campaign", won: "won", lost: "lost" },
       prefix: true

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
