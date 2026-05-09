# Detail page for a single CampaignStepInstance under a job proposal.
# Shows the rendered email exactly as it would (or did) ship: From, To,
# Subject, Body, plus planned-delivery / actual-send timing and status.
#
# Scoping: every action loads the parent JobProposal through
# accessible_by(current_ability) and then asserts the step instance
# belongs to that proposal — protects against guessing IDs across
# tenants.
class CampaignStepInstancesController < ApplicationController
  before_action :load_proposal_and_step_instance

  def show
    @campaign_step  = @step_instance.campaign_step
    @sent           = @step_instance.email_delivery_status_sent?

    # For a step that already shipped, final_subject/final_body capture
    # exactly what the customer received — show that. Otherwise (pending,
    # sending, failed before ever queueing copy) render the live template
    # through the same MailGenerator.render the live send uses, so what
    # the preview shows is byte-for-byte what would ship if the step
    # fired right now.
    #
    # render raises UnresolvedMergeFieldError when the template references
    # a merge field this proposal can't provide — a real campaign-config
    # bug (e.g. typo'd token, KNOWN_KEYS missing a binding). We surface
    # the message in a banner and fall back to render_safely so the rest
    # of the page still renders.
    if @sent && @step_instance.final_subject.present?
      @rendered = MailGenerator::Output.new(
        subject: @step_instance.final_subject,
        body:    @step_instance.final_body.to_s
      )
      @rendering_error = nil
    else
      begin
        @rendered = MailGenerator.render(
          campaign_step: @campaign_step,
          job_proposal:  @job_proposal
        )
        @rendering_error = nil
      rescue MailGenerator::UnresolvedMergeFieldError => e
        @rendered = MailGenerator.render_safely(
          campaign_step: @campaign_step,
          job_proposal:  @job_proposal
        )
        @rendering_error = e.message
      end
    end

    @from_address = ApplicationMailbox.for_proposal(@job_proposal)&.email
    @to_address   = @job_proposal.customer_email.presence
  end

  private

  def load_proposal_and_step_instance
    @job_proposal  = JobProposal.accessible_by(current_ability).find(params[:job_proposal_id])
    @step_instance = CampaignStepInstance.find(params[:id])
    instance = @step_instance.campaign_instance
    unless instance && instance.host_type == "JobProposal" && instance.host_id == @job_proposal.id
      raise ActiveRecord::RecordNotFound, "step instance does not belong to this proposal"
    end
  end
end
