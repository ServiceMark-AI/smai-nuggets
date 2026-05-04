require "net/http"

# Polls Gmail for replies on threads we've sent campaign emails on. Runs
# on its own cadence (see config/sidekiq_cron.yml), independent of the
# CampaignSweepJob so reply latency isn't bounded by the send cadence.
#
# Eligibility (per-campaign-instance, latest sent step only):
#   - Step has a stored gmail_thread_id.
#   - Parent CampaignInstance.status IN (:active, :completed).
#   - For :completed, ended_at must be within POLLING_CUTOFF (6 months).
#     Active campaigns are never aged out.
#   - Host JobProposal.pipeline_stage is :in_campaign (not :won, :lost).
#
# Reply detection cross-references two snapshots of the same thread:
#   - gmail_thread_snapshot, captured at send time by CampaignSweepJob,
#     is the baseline of "what was on the thread when we sent."
#   - The current thread is fetched on each poll. If the current message
#     count exceeds the baseline AND any of the new messages have a From
#     header whose address isn't the connected mailbox, we treat that as
#     a customer reply.
#
# On reply: the parent CampaignInstance flips to :stopped_on_reply with
# ended_at stamped, and the host JobProposal's status_overlay is set to
# "customer_waiting" — which trips the existing "Open in Gmail" CTA on
# the proposal list/show pages.
#
# Failure handling: a Gmail fetch failure (transient network/auth blip,
# missing scope after a re-consent gap) is logged and skipped. The next
# tick retries — no backoff state needed because the eligibility query
# stays small.
class GmailReplyPollJob < ApplicationJob
  queue_as :default

  POLLING_CUTOFF = 6.months

  def perform
    mailbox = ApplicationMailbox.current
    if mailbox.nil?
      Rails.logger.warn "[GmailReplyPollJob] no application mailbox connected; skipping poll"
      return
    end

    sender = GmailSender.new(mailbox)
    pollable_step_instance_ids(Time.current).each do |id|
      process(id, mailbox, sender)
    end
  end

  private

  # Returns IDs of the most-recent sent step instance per eligible
  # campaign instance. Postgres DISTINCT ON keeps it to one row per
  # parent — there's no point polling N threads under one proposal when
  # only the latest matters for reply detection.
  def pollable_step_instance_ids(now)
    cutoff = now - POLLING_CUTOFF
    active_status = CampaignInstance.statuses[:active]
    completed_status = CampaignInstance.statuses[:completed]

    CampaignStepInstance
      .joins(:campaign_instance)
      .joins("INNER JOIN job_proposals ON job_proposals.id = campaign_instances.host_id AND campaign_instances.host_type = 'JobProposal'")
      .where.not(gmail_thread_id: nil)
      .where(email_delivery_status: CampaignStepInstance.email_delivery_statuses[:sent])
      .where(campaign_instances: { status: [active_status, completed_status] })
      .where(
        "campaign_instances.status = ? OR campaign_instances.ended_at >= ?",
        active_status, cutoff
      )
      .where(job_proposals: { pipeline_stage: JobProposal.pipeline_stages[:in_campaign] })
      .select("DISTINCT ON (campaign_step_instances.campaign_instance_id) campaign_step_instances.id, campaign_step_instances.campaign_instance_id, campaign_step_instances.created_at")
      .order("campaign_step_instances.campaign_instance_id, campaign_step_instances.created_at DESC")
      .map(&:id)
  end

  def process(step_instance_id, mailbox, sender)
    step_instance = CampaignStepInstance.find_by(id: step_instance_id)
    return unless step_instance

    thread = sender.fetch_thread(step_instance.gmail_thread_id)
    if thread.nil?
      Rails.logger.warn "[GmailReplyPollJob] thread fetch returned nil for step #{step_instance.id} thread #{step_instance.gmail_thread_id} — will retry next tick"
      return
    end

    # First-pass baseline: send-time snapshot was missing (snapshot fetch
    # failed at send, or this row pre-dates the column). Establish the
    # baseline now and bail; next tick does the actual diff.
    if step_instance.gmail_thread_snapshot.blank?
      step_instance.update!(gmail_thread_snapshot: thread)
      return
    end

    reply_message = first_reply_message(thread, step_instance.gmail_thread_snapshot, mailbox.email)
    return unless reply_message

    flag_reply(step_instance, reply_message)
  rescue StandardError => e
    Rails.logger.error "[GmailReplyPollJob] unexpected error polling step #{step_instance_id}: #{e.class}: #{e.message}"
  end

  # Returns the first message in the current thread (after the snapshot
  # baseline) that came from someone other than the connected mailbox,
  # or nil when no such message exists. Returning the message itself —
  # rather than a boolean — lets flag_reply persist the specific Gmail
  # payload that triggered the stop, useful for diagnostics.
  def first_reply_message(current_thread, baseline_thread, mailbox_email)
    baseline_count = Array(baseline_thread["messages"]).length
    current_messages = Array(current_thread["messages"])
    return nil if current_messages.length <= baseline_count

    new_messages = current_messages.last(current_messages.length - baseline_count)
    new_messages.find { |msg| from_other_party?(msg, mailbox_email) }
  end

  def from_other_party?(message, mailbox_email)
    headers = message.dig("payload", "headers") || []
    from_value = headers.find { |h| h["name"].to_s.casecmp("From").zero? }&.dig("value").to_s
    sender_email = extract_email(from_value)
    sender_email.present? && sender_email.casecmp(mailbox_email.to_s) != 0
  end

  # Extracts the bare email from a From header value like
  # "Display Name <addr@host>" or just "addr@host".
  def extract_email(from_value)
    bracketed = from_value.match(/<([^>]+)>/)
    return bracketed[1].strip if bracketed
    bare = from_value.match(/\S+@\S+/)
    bare ? bare[0].strip : ""
  end

  def flag_reply(step_instance, reply_message)
    instance = step_instance.campaign_instance
    host = instance.host

    JobProposal.transaction do
      step_instance.update!(customer_replied: true, gmail_reply_payload: reply_message)
      instance.reload
      if instance.status_active? || instance.status_completed?
        instance.update!(status: :stopped_on_reply, ended_at: Time.current)
      end
      if host.is_a?(JobProposal)
        host.update!(status_overlay: "customer_waiting")
      end
    end
  end
end
