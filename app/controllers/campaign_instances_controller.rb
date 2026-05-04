# Detail page for a single CampaignInstance under a job proposal.
# Shows every step's email fully populated through the template engine
# (final_subject/final_body when sent, MailGenerator render with a
# render_safely fallback when not).
#
# Scoping mirrors CampaignStepInstancesController: the parent JobProposal
# is loaded through accessible_by(current_ability), then the instance is
# asserted to belong to that proposal so cross-tenant ID guessing 404s.
class CampaignInstancesController < ApplicationController
  RenderedStep = Struct.new(:step_instance, :campaign_step, :sent, :rendered, :rendering_error, :preview_send_at, keyword_init: true)

  before_action :load_proposal_and_instance

  def show
    @from_address = ApplicationMailbox.current&.email
    @to_address   = @job_proposal.customer_email.presence

    step_instances = @campaign_instance.step_instances
                       .includes(:campaign_step)
                       .joins(:campaign_step)
                       .order("campaign_steps.sequence_number")

    # Until the operator approves the proposal, any planned_delivery_at on
    # the row is either nil (fresh launch) or stale (pre-approve data from
    # an older code path) — neither is meaningful as a real schedule. Compute
    # a preview using `now` as the hypothetical start time so the page shows
    # when each step would land if they approved right now. Once approved,
    # the row's planned_delivery_at is the source of truth.
    show_preview = !@job_proposal.status_approved?
    preview_anchor = Time.current
    cumulative_minutes = 0
    @rendered_steps = step_instances.map do |si|
      cumulative_minutes += si.campaign_step.offset_min.to_i
      preview_send_at = if show_preview && !si.email_delivery_status_sent?
                          preview_anchor + cumulative_minutes.minutes
                        end
      build_rendered_step(si, preview_send_at: preview_send_at)
    end
  end

  private

  def load_proposal_and_instance
    @job_proposal      = JobProposal.accessible_by(current_ability).find(params[:job_proposal_id])
    @campaign_instance = CampaignInstance.find(params[:id])
    unless @campaign_instance.host_type == "JobProposal" && @campaign_instance.host_id == @job_proposal.id
      raise ActiveRecord::RecordNotFound, "campaign instance does not belong to this proposal"
    end
  end

  def build_rendered_step(si, preview_send_at:)
    sent = si.email_delivery_status_sent?
    # Once approved, final_subject/final_body are locked in (set by
    # JobProposalsController#approve) and the sweep ships them verbatim.
    # The page should reflect that frozen copy, not re-render against
    # current proposal data which may have drifted. Pre-approve the
    # persisted columns are nil, so we render live as a preview.
    if si.final_subject.present?
      rendered = MailGenerator::Output.new(subject: si.final_subject, body: si.final_body.to_s)
      rendering_error = nil
    else
      begin
        rendered = MailGenerator.render(campaign_step: si.campaign_step, job_proposal: @job_proposal)
        rendering_error = nil
      rescue MailGenerator::UnresolvedMergeFieldError => e
        rendered = MailGenerator.render_safely(campaign_step: si.campaign_step, job_proposal: @job_proposal)
        rendering_error = e.message
      end
    end

    RenderedStep.new(
      step_instance:   si,
      campaign_step:   si.campaign_step,
      sent:            sent,
      rendered:        rendered,
      rendering_error: rendering_error,
      preview_send_at: preview_send_at
    )
  end
end
