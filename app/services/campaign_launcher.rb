# Creates a CampaignInstance + per-step CampaignStepInstances for a JobProposal,
# anchored to the moment of launch. Idempotent: if any CampaignInstance already
# exists for the proposal it does nothing and returns nil.
#
# Step instances are created with email_delivery_status `pending` and with
# final_subject / final_body left nil — at send time, CampaignSweepJob renders
# the live campaign step templates through MailGenerator and writes the
# rendered copy back to the step instance after a successful send.
#
# Returns the created CampaignInstance, or nil when no instance was created
# (already running, no scenario set, or no campaign attached to the scenario).
class CampaignLauncher
  Result = Data.define(:instance, :reason)

  def self.launch(job_proposal)
    new(job_proposal).launch
  end

  def initialize(job_proposal)
    @job_proposal = job_proposal
  end

  def launch
    return Result.new(instance: nil, reason: :already_running) if @job_proposal.campaign_instances.exists?

    scenario = @job_proposal.scenario
    return Result.new(instance: nil, reason: :no_scenario) unless scenario

    campaign = scenario.campaign
    return Result.new(instance: nil, reason: :no_campaign) unless campaign

    instance = nil
    CampaignInstance.transaction do
      instance = CampaignInstance.create!(
        host: @job_proposal,
        campaign: campaign,
        status: :active
      )

      anchor = Time.current
      campaign.steps.order(:sequence_number).each do |step|
        CampaignStepInstance.create!(
          campaign_instance: instance,
          campaign_step: step,
          planned_delivery_at: anchor + step.offset_min.minutes,
          email_delivery_status: :pending
        )
      end

      @job_proposal.update!(pipeline_stage: :in_campaign)
    end

    Result.new(instance: instance, reason: :launched)
  end
end
