require "net/http"

# Runs every 5 minutes (see config/sidekiq_cron.yml) to find campaign step
# instances whose planned_delivery_at has passed, render and send their email
# via the application's connected Gmail mailbox, and update both the step
# instance and its parent campaign instance to reflect the outcome.
#
# Eligibility: only step instances whose parent CampaignInstance is `active`,
# whose Campaign is `approved`, and whose host JobProposal has status
# `approved` are considered. The JobProposal status gate is the operator's
# explicit "go" signal — until they click Approve on the campaign instance
# page, the proposal sits in `approving` and the sweep skips it.
#
# Concurrency: each due step instance is claimed by atomically transitioning
# its email_delivery_status from `pending` to `sending` with a conditional
# UPDATE. If two sweeps overlap, only one gets the row.
#
# Failure handling: a delivery failure (Gmail rejection, missing recipient,
# unsupported host, unresolved merge field) marks the step `failed` and
# stops the parent campaign instance with `stopped_on_delivery_issue`. A
# successful final step transitions the instance to `completed`.
class CampaignSweepJob < ApplicationJob
  queue_as :default

  # Outbound mail flow goes through several gates:
  #
  #   1. production AND no TEST_TO_EMAIL              -> real send to host.customer_email
  #   2. TEST_TO_EMAIL set (any env, mailbox present) -> mail redirected to TEST_TO_EMAIL
  #   3. development AND no mailbox                   -> FAKE-SEND mode: render the email,
  #                                                      log it, mark the step :sent.
  #                                                      Lets dev exercise the campaign
  #                                                      lifecycle without real Gmail.
  #   4. non-dev AND no mailbox                       -> skip; log warning
  #   5. non-prod AND mailbox AND no TEST_TO_EMAIL    -> skip; we won't email customers
  #                                                      from staging/dev by accident
  #
  # Devise mailers (password reset, registration) are unaffected — they go
  # through Action Mailer, not this job.

  def self.production_environment?
    Rails.env.production?
  end

  def self.test_to_email_override
    ENV["TEST_TO_EMAIL"].presence
  end

  def perform
    has_any_mailbox = ApplicationMailbox.connected?

    if has_any_mailbox
      # Real-send path: still gate non-prod behind TEST_TO_EMAIL so we
      # don't accidentally email customers from a dev/staging box.
      unless self.class.production_environment? || self.class.test_to_email_override
        Rails.logger.warn "[CampaignSweepJob] sending disabled in #{Rails.env}; set TEST_TO_EMAIL to redirect mail, or run in production"
        return
      end
    elsif !self.class.production_environment?
      # No mailbox + non-prod env (dev/test/staging) — fake-send so the
      # campaign lifecycle logic is still exercised end to end.
      Rails.logger.info "[CampaignSweepJob] no application mailbox connected; running in FAKE-SEND mode (no real email leaves the host)"
    else
      Rails.logger.warn "[CampaignSweepJob] no application mailbox connected; skipping sweep"
      return
    end

    # Per PRD-09 §5, the per-location mailbox sends for that location's
    # proposals; the legacy no-location mailbox is the fallback. Resolve
    # per step instance so a tenant with mixed location coverage can
    # still send from the right address.
    due_step_instance_ids(Time.current).each { |id| process(id) }
  end

  private

  def recipient_for(host)
    self.class.test_to_email_override || host.customer_email
  end

  def due_step_instance_ids(now)
    CampaignStepInstance
      .joins(campaign_instance: :campaign)
      .joins("INNER JOIN job_proposals ON job_proposals.id = campaign_instances.host_id AND campaign_instances.host_type = 'JobProposal'")
      .where(email_delivery_status: :pending)
      .where("campaign_step_instances.planned_delivery_at <= ?", now)
      .where(campaign_instances: { status: CampaignInstance.statuses[:active] })
      .where(campaigns: { status: Campaign.statuses[:approved] })
      .where(job_proposals: { status: JobProposal.statuses[:approved] })
      .pluck("campaign_step_instances.id")
  end

  def process(step_instance_id)
    return unless claim(step_instance_id)

    step_instance = CampaignStepInstance.find(step_instance_id)
    host = step_instance.campaign_instance.host
    mailbox = host.is_a?(JobProposal) ? ApplicationMailbox.for_proposal(host) : ApplicationMailbox.current
    deliver(step_instance, mailbox)
  end

  # Atomically transitions pending -> sending. Returns true if this worker
  # won the claim, false if the row was already taken or no longer pending.
  def claim(step_instance_id)
    rows = CampaignStepInstance
      .where(id: step_instance_id, email_delivery_status: :pending)
      .update_all(
        email_delivery_status: CampaignStepInstance.email_delivery_statuses[:sending],
        updated_at: Time.current
      )
    rows.positive?
  end

  def deliver(step_instance, mailbox)
    instance = step_instance.campaign_instance
    host = instance.host

    unless host.is_a?(JobProposal)
      Rails.logger.warn "[CampaignSweepJob] unsupported host #{host.class.name} for step instance #{step_instance.id}"
      mark_failed(step_instance, instance)
      return
    end

    recipient = recipient_for(host)
    if recipient.blank?
      Rails.logger.warn "[CampaignSweepJob] no recipient resolvable for JobProposal #{host.id} (customer_email blank, no TEST_TO_EMAIL override) on step instance #{step_instance.id}"
      mark_failed(step_instance, instance)
      return
    end

    # Content is locked in at approve time (see JobProposalsController#approve).
    # The sweep just ships the persisted final_subject / final_body — no late
    # re-render means a post-approve edit to the proposal can't silently change
    # a queued email.
    subject = step_instance.final_subject
    body    = step_instance.final_body
    if subject.blank?
      Rails.logger.warn "[CampaignSweepJob] step instance #{step_instance.id} has no final_subject — was it approved?"
      mark_failed(step_instance, instance)
      return
    end

    # Display name on the From header is the proposal owner's full
    # name (Mike Frizzell), so the recipient sees
    #   "Mike Frizzell" <mike@servicemark.ai>
    # instead of just the bare connected-mailbox address. Falls back
    # to nil (no display name, just the email) if the owner has no
    # name set on their profile.
    from_name = host.owner&.full_name

    # The first email of the sequence carries the proposal's PDF
    # attachments; subsequent steps go out as plain text. "First" is
    # the lowest sequence_number among this campaign's steps — robust
    # to admins deleting and re-adding step 1.
    attachments = first_step?(step_instance) ? pdf_attachments_for(host) : []

    sender = mailbox ? GmailSender.new(mailbox) : nil
    send_response = if sender
                      sender.send_email(to: recipient, subject: subject, body: body.to_s, from_name: from_name, attachments: attachments)
                    else
                      Rails.logger.info "[CampaignSweepJob][FAKE-SEND] step #{step_instance.id} -> #{recipient} (from #{from_name.inspect}, #{attachments.size} attachment(s)): #{subject.inspect}"
                      nil # fake-send path: no Gmail response to record
                    end

    if mailbox && send_response.nil?
      mark_failed(step_instance, instance)
      return
    end

    persist_send_metadata(step_instance, sender, send_response)
    step_instance.update!(email_delivery_status: :sent)
    complete_instance_if_done(instance)
  rescue StandardError => e
    Rails.logger.error "[CampaignSweepJob] unexpected error sending step instance #{step_instance.id}: #{e.class}: #{e.message}"
    mark_failed(step_instance, instance)
  end

  # Stores the Gmail send response and (best-effort) the thread snapshot
  # captured immediately after send. The snapshot is the baseline the
  # GmailReplyPollJob compares against to detect customer replies. A
  # snapshot fetch failure (auth blip, missing scope) is non-fatal: we
  # log and leave gmail_thread_snapshot nil so the poller can fill it in
  # on its first pass.
  def persist_send_metadata(step_instance, sender, send_response)
    return if send_response.nil? # fake-send path

    thread_id = send_response["threadId"]
    thread_snapshot = nil
    if sender && thread_id.present?
      begin
        thread_snapshot = sender.fetch_thread(thread_id)
        if thread_snapshot.nil?
          Rails.logger.warn "[CampaignSweepJob] thread snapshot fetch returned nil for step #{step_instance.id} thread #{thread_id} — poller will populate later"
        end
      rescue StandardError => e
        Rails.logger.warn "[CampaignSweepJob] thread snapshot fetch raised for step #{step_instance.id} thread #{thread_id}: #{e.class}: #{e.message}"
      end
    end

    step_instance.update!(
      gmail_send_response: send_response,
      gmail_thread_id: thread_id,
      gmail_thread_snapshot: thread_snapshot
    )
  end

  # True iff this step is the first one in its campaign by
  # sequence_number. Computed by comparing against the campaign's
  # minimum sequence_number, so it remains correct if step 1 is
  # later renumbered or removed.
  def first_step?(step_instance)
    campaign_id = step_instance.campaign_step.campaign_id
    first_seq = CampaignStep.where(campaign_id: campaign_id).minimum(:sequence_number)
    step_instance.campaign_step.sequence_number == first_seq
  end

  # Returns an array of { filename:, content:, mime_type: } hashes for
  # every PDF attachment on the proposal. Skips non-PDF attachments
  # (we only want the original proposal document on the first email,
  # not photos or other supporting files).
  def pdf_attachments_for(proposal)
    proposal.attachments.includes(file_attachment: :blob).filter_map do |att|
      next unless att.file.attached?
      next unless att.file.content_type == "application/pdf" || att.file.filename.to_s.downcase.end_with?(".pdf")
      {
        filename:  att.file.filename.to_s,
        content:   att.file.download,
        mime_type: att.file.content_type || "application/pdf"
      }
    end
  end

  def mark_failed(step_instance, instance)
    step_instance.update!(email_delivery_status: :failed)
    instance.reload
    instance.update!(status: :stopped_on_delivery_issue, ended_at: Time.current) if instance.status_active?
  end

  def complete_instance_if_done(instance)
    has_open = instance.step_instances
      .where(email_delivery_status: [
        CampaignStepInstance.email_delivery_statuses[:pending],
        CampaignStepInstance.email_delivery_statuses[:sending]
      ])
      .exists?
    return if has_open
    instance.reload
    instance.update!(status: :completed, ended_at: Time.current) if instance.status_active?
  end
end
