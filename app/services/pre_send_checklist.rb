# Single source of truth for the conditions that must hold before a customer
# email leaves the system. Both the runtime sender (CampaignSweepJob) and the
# operator UI (JobProposal show page) call into this same class so what the
# operator sees on the page is exactly what the sweep will evaluate when the
# step's planned_delivery_at arrives.
#
# Authority: PRD-09 v1.3 §9.2 defines the canonical seven checks. We add an
# eighth defensive guard for rendered step content because in our codebase
# content is locked at approve time (not at send time) and a step instance
# without final_subject indicates an upstream issue that would otherwise
# silently fail.
#
# Failure classes (per PRD-09 §9.2):
# - :block_silent          — drop the task, log, do nothing else. The state
#                            will resolve when the underlying condition does
#                            (operator resumes campaign, status overlay
#                            clears, etc.).
# - :block_delivery_issue  — block the send AND surface a delivery_issue
#                            overlay on the proposal so the operator can
#                            fix the input (mailbox, recipient, suppression).
class PreSendChecklist
  Check = Struct.new(:key, :label, :status, :detail, :remedy, keyword_init: true) do
    def pass? = status == :pass
    def fail? = !pass?
    def block_delivery_issue? = status == :block_delivery_issue
    def block_silent? = status == :block_silent
  end

  PASS = :pass
  BLOCK_SILENT = :block_silent
  BLOCK_DELIVERY_ISSUE = :block_delivery_issue

  def self.run(step_instance)
    new(step_instance).run
  end

  def initialize(step_instance)
    @step_instance = step_instance
    @campaign_instance = step_instance.campaign_instance
    @job_proposal = @campaign_instance&.host
  end

  def run
    [
      check_mailbox_connected,
      check_pipeline_stage,
      check_status_overlay,
      check_campaign_active,
      check_idempotency,
      check_contact_email,
      check_suppression,
      check_step_content
    ]
  end

  def pass?
    run.all?(&:pass?)
  end

  # First failing check, or nil when everything passes. This is what callers
  # branch on — the failure class lives on the Check itself.
  def first_blocker
    run.find(&:fail?)
  end

  private

  attr_reader :step_instance, :campaign_instance, :job_proposal

  def check_mailbox_connected
    mailbox = ApplicationMailbox.current
    if mailbox.nil?
      fail_check(:mailbox_connected, "Mailbox connected", BLOCK_DELIVERY_ISSUE,
                 "No Gmail mailbox is connected for this tenant.",
                 "Connect a mailbox in Settings → Integrations.")
    elsif mailbox.expired? && mailbox.refresh_token.blank?
      fail_check(:mailbox_connected, "Mailbox connected", BLOCK_DELIVERY_ISSUE,
                 "The connected Gmail mailbox's authorization has expired and there is no refresh token.",
                 "Reconnect the mailbox in Settings → Integrations.")
    else
      pass_check(:mailbox_connected, "Mailbox connected")
    end
  end

  def check_pipeline_stage
    return missing_proposal(:pipeline_stage, "Job is in campaign") if job_proposal.nil?

    if job_proposal.status_approved? && job_proposal.pipeline_stage_in_campaign?
      pass_check(:pipeline_stage, "Job is in campaign")
    else
      fail_check(:pipeline_stage, "Job is in campaign", BLOCK_SILENT,
                 "This job's pipeline stage is #{describe(job_proposal.pipeline_stage)} (status: #{describe(job_proposal.status)}).",
                 "A campaign only sends while the job sits in the in-campaign stage.")
    end
  end

  def check_status_overlay
    return missing_proposal(:status_overlay, "No blocking status overlay") if job_proposal.nil?

    if job_proposal.status_overlay.blank?
      pass_check(:status_overlay, "No blocking status overlay")
    else
      fail_check(:status_overlay, "No blocking status overlay", BLOCK_SILENT,
                 "This job has a #{job_proposal.status_overlay.humanize.downcase} overlay.",
                 overlay_remedy(job_proposal.status_overlay))
    end
  end

  def check_campaign_active
    return missing_instance(:campaign_active, "Campaign run is active") if campaign_instance.nil?

    unless campaign_instance.status_active?
      return fail_check(:campaign_active, "Campaign run is active", BLOCK_SILENT,
                        "The campaign run is currently #{campaign_instance.status.humanize.downcase}.",
                        "Resume or restart the campaign before any further steps can ship.")
    end

    # The underlying campaign template can be paused by a SMAI admin to halt
    # every active run across all tenants. Operators can't unpause a template
    # — surfacing this as a distinct failure helps support diagnose quickly.
    template = campaign_instance.campaign
    unless template&.status_approved?
      return fail_check(:campaign_active, "Campaign run is active", BLOCK_SILENT,
                        "The campaign behind this run is currently #{template&.status.to_s.humanize.downcase.presence || 'unavailable'}.",
                        "A SMAI admin must re-approve the campaign template before any of its runs can ship steps.")
    end

    pass_check(:campaign_active, "Campaign run is active")
  end

  # Idempotency in our model: a step instance moves pending → sending → sent.
  # The send is safe to attempt while it is still pending or sending. Once it
  # has reached sent / failed / bounced, the step is terminal and a duplicate
  # send must not happen. This matches PRD-09 §9.2 check 5 ("no existing
  # messages row for this campaign_run + step_order with status = sent").
  def check_idempotency
    case step_instance.email_delivery_status
    when "pending", "sending"
      pass_check(:idempotency, "Not already sent")
    when "sent"
      fail_check(:idempotency, "Not already sent", BLOCK_SILENT,
                 "This campaign step has already been sent.",
                 "No action needed — this is a duplicate-send guard.")
    else
      fail_check(:idempotency, "Not already sent", BLOCK_SILENT,
                 "This campaign step is in a terminal state (#{step_instance.email_delivery_status}).",
                 "The next campaign step (or a recovery flow) handles the next send.")
    end
  end

  def check_contact_email
    return missing_proposal(:contact_email, "Recipient email present and valid") if job_proposal.nil?

    email = job_proposal.customer_email.to_s.strip
    if email.blank?
      fail_check(:contact_email, "Recipient email present and valid", BLOCK_DELIVERY_ISSUE,
                 "The customer email field is blank.",
                 "Add the customer's email on the proposal Edit page.")
    elsif !valid_email_format?(email)
      fail_check(:contact_email, "Recipient email present and valid", BLOCK_DELIVERY_ISSUE,
                 "The customer email \"#{email}\" is not a valid email address.",
                 "Correct the customer email on the proposal Edit page.")
    else
      pass_check(:contact_email, "Recipient email present and valid")
    end
  end

  def check_suppression
    return missing_proposal(:suppression, "Recipient is not on the suppression list") if job_proposal.nil?

    email = job_proposal.customer_email.to_s.strip
    location = job_proposal.location
    if email.blank? || location.nil?
      pass_check(:suppression, "Recipient is not on the suppression list")
    elsif EmailSuppression.suppressed?(location: location, email: email)
      fail_check(:suppression, "Recipient is not on the suppression list", BLOCK_DELIVERY_ISSUE,
                 "The address #{email} is on the suppression list for this location.",
                 "A SMAI admin must clear the suppression entry before the campaign can resume.")
    else
      pass_check(:suppression, "Recipient is not on the suppression list")
    end
  end

  def check_step_content
    if step_instance.final_subject.present?
      pass_check(:step_content, "Step content rendered")
    else
      # Treated as a delivery_issue so the step is marked failed and the run
      # is stopped — a step with no rendered subject is a terminal upstream
      # defect and we don't want it to retry forever.
      fail_check(:step_content, "Step content rendered", BLOCK_DELIVERY_ISSUE,
                 "The step has no rendered subject. The campaign was likely approved before this step's content was generated.",
                 "Re-approve the campaign, or contact support if the issue persists.")
    end
  end

  def overlay_remedy(overlay)
    case overlay
    when "paused"            then "Resume the campaign from the proposal page."
    when "delivery_issue"    then "Use Fix Issue on the proposal to correct the recipient and resume."
    when "customer_waiting"  then "The customer has replied — handle the reply, then resume if appropriate."
    else                          "Clear the overlay before this step can ship."
    end
  end

  def missing_proposal(key, label)
    fail_check(key, label, BLOCK_SILENT,
               "The campaign step is not attached to a job proposal.",
               "This is a system error; contact support.")
  end

  def missing_instance(key, label)
    fail_check(key, label, BLOCK_SILENT,
               "The campaign step is not attached to a campaign run.",
               "This is a system error; contact support.")
  end

  def pass_check(key, label)
    Check.new(key: key, label: label, status: PASS)
  end

  def fail_check(key, label, status, detail, remedy)
    Check.new(key: key, label: label, status: status, detail: detail, remedy: remedy)
  end

  def valid_email_format?(email)
    email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def describe(value)
    value.presence&.to_s&.humanize&.downcase || "blank"
  end
end
