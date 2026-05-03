require "net/http"

# Runs every 5 minutes (see config/sidekiq_cron.yml) to find campaign step
# instances whose planned_delivery_at has passed, render and send their email
# via the application's connected Gmail mailbox, and update both the step
# instance and its parent campaign instance to reflect the outcome.
#
# Eligibility: only step instances whose parent CampaignInstance is `active`
# and whose Campaign is `approved` are considered.
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

  # Outbound campaign mail goes through two gates:
  #
  #   1. production AND no TEST_TO_EMAIL  -> mail goes to host.customer_email (real send)
  #   2. TEST_TO_EMAIL set (any env)      -> all mail is redirected to TEST_TO_EMAIL
  #   3. otherwise (e.g. dev with no override) -> sweep is a no-op; nothing sends
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
    mailbox = ApplicationMailbox.current
    unless mailbox
      Rails.logger.warn "[CampaignSweepJob] no application mailbox connected; skipping sweep"
      return
    end

    unless self.class.production_environment? || self.class.test_to_email_override
      Rails.logger.warn "[CampaignSweepJob] sending disabled in #{Rails.env}; set TEST_TO_EMAIL to redirect mail, or run in production"
      return
    end

    due_step_instance_ids(Time.current).each { |id| process(id, mailbox) }
  end

  private

  def recipient_for(host)
    self.class.test_to_email_override || host.customer_email
  end

  def due_step_instance_ids(now)
    CampaignStepInstance
      .joins(campaign_instance: :campaign)
      .where(email_delivery_status: :pending)
      .where("campaign_step_instances.planned_delivery_at <= ?", now)
      .where(campaign_instances: { status: CampaignInstance.statuses[:active] })
      .where(campaigns: { status: Campaign.statuses[:approved] })
      .pluck(:id)
  end

  def process(step_instance_id, mailbox)
    return unless claim(step_instance_id)

    step_instance = CampaignStepInstance.find(step_instance_id)
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

    rendered = MailGenerator.render(campaign_step: step_instance.campaign_step, job_proposal: host)
    sent = GmailSender.new(mailbox).send_email(to: recipient, subject: rendered.subject, body: rendered.body)

    if sent
      step_instance.update!(
        email_delivery_status: :sent,
        final_subject: rendered.subject,
        final_body: rendered.body
      )
      complete_instance_if_done(instance)
    else
      mark_failed(step_instance, instance)
    end
  rescue MailGenerator::UnresolvedMergeFieldError => e
    Rails.logger.warn "[CampaignSweepJob] render failed for step instance #{step_instance.id}: #{e.message}"
    mark_failed(step_instance, instance)
  rescue StandardError => e
    Rails.logger.error "[CampaignSweepJob] unexpected error sending step instance #{step_instance.id}: #{e.class}: #{e.message}"
    mark_failed(step_instance, instance)
  end

  def mark_failed(step_instance, instance)
    step_instance.update!(email_delivery_status: :failed)
    instance.update!(status: :stopped_on_delivery_issue) if instance.reload.status_active?
  end

  def complete_instance_if_done(instance)
    has_open = instance.step_instances
      .where(email_delivery_status: [
        CampaignStepInstance.email_delivery_statuses[:pending],
        CampaignStepInstance.email_delivery_statuses[:sending]
      ])
      .exists?
    instance.update!(status: :completed) if !has_open && instance.reload.status_active?
  end
end
