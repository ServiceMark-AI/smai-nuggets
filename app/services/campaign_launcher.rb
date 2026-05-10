# Creates a CampaignInstance + per-step CampaignStepInstances for a JobProposal,
# anchored to the moment of launch. Idempotent: if any CampaignInstance already
# exists for the proposal it does nothing.
#
# Step instances are created with email_delivery_status `pending` and with
# final_subject / final_body left nil — at send time, CampaignSweepJob renders
# the live campaign step templates through MailGenerator and writes the
# rendered copy back to the step instance after a successful send.
#
# Result#reason values:
#   :launched         — instance + steps created
#   :already_running  — proposal already has a CampaignInstance
#   :not_ready        — required proposal fields are blank; result.blockers
#                       lists which (see JobProposal#campaign_readiness_blockers)
#   :no_campaign      — proposal's scenario has no campaign attached
class CampaignLauncher
  Result = Struct.new(:instance, :reason, :blockers, keyword_init: true) do
    def initialize(instance: nil, reason:, blockers: [])
      super
    end
  end

  def self.launch(job_proposal)
    new(job_proposal).launch
  end

  def initialize(job_proposal)
    @job_proposal = job_proposal
  end

  def launch
    return Result.new(reason: :already_running) if @job_proposal.campaign_instances.exists?

    blockers = @job_proposal.campaign_readiness_blockers
    return Result.new(reason: :not_ready, blockers: blockers) if blockers.any?

    campaign = @job_proposal.scenario.campaign
    return Result.new(reason: :no_campaign) unless campaign

    revision = campaign.active_revision
    return Result.new(reason: :no_campaign) unless revision

    instance = nil
    CampaignInstance.transaction do
      # New instance opens in :drafting so the operator can edit step copy
       # before the sweep starts shipping. JobProposalsController#approve
       # transitions it to :active when the operator signs off.
      instance = CampaignInstance.create!(
        host: @job_proposal,
        campaign: campaign,
        campaign_revision: revision,
        status: :drafting
      )

      # planned_delivery_at is left nil here — the operator hasn't approved
      # the campaign yet, so the start time is unknown. JobProposalsController#approve
      # stamps started_at and computes each step's planned_delivery_at = started_at + offset_min,
      # per PRD-03 §6.4 (timing relative to campaign_started_at).
      revision.steps.order(:sequence_number).each do |step|
        CampaignStepInstance.create!(
          campaign_instance: instance,
          campaign_step: step,
          planned_delivery_at: nil,
          email_delivery_status: :pending
        )
      end

      @job_proposal.update!(pipeline_stage: :in_campaign)
    end

    Result.new(instance: instance, reason: :launched)
  end
end
