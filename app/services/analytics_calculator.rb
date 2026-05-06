require "ostruct"

# Computes the dashboard metrics for both Admin::AnalyticsController
# (cross-tenant) and AnalyticsController (current user's tenant) from a
# single ActiveRecord proposals_scope. Keeping the math in one place
# means the two views can't drift on a metric definition — they only
# differ in what scope feeds in and which "pending data" callout
# accompanies them.
#
# proposals_scope: any ActiveRecord::Relation on JobProposal. Use
#   JobProposal.all for cross-tenant; JobProposal.where(tenant: …)
#   for tenant-scoped.
#
# Returns an OpenStruct with one accessor per metric the view reads.
class AnalyticsCalculator
  def initialize(proposals_scope:)
    @proposals = proposals_scope
  end

  def call
    activated_count = @proposals.joins(:campaign_instances).distinct.count

    # Constrain campaign + step instances to the proposal scope so the
    # tenant-facing call doesn't bleed in another tenant's email
    # activity. Pluck once and reuse.
    proposal_ids = @proposals.pluck(:id)
    instances_in_scope = CampaignInstance.where(host_type: "JobProposal", host_id: proposal_ids)
    steps_in_scope = CampaignStepInstance.where(campaign_instance_id: instances_in_scope)

    won_count          = @proposals.where(pipeline_stage: :won).count
    lost_count         = @proposals.where(pipeline_stage: :lost).count
    in_campaign_count  = @proposals.where(pipeline_stage: :in_campaign).count

    first_followup_delivered = instances_in_scope
      .joins(:step_instances)
      .where(campaign_step_instances: { email_delivery_status: :sent })
      .distinct.count

    closed_revenue        = @proposals.where(pipeline_stage: :won).sum(:proposal_value)
    active_pipeline_value = @proposals.where(pipeline_stage: :in_campaign).sum(:proposal_value)
    follow_ups_sent       = steps_in_scope.where(email_delivery_status: :sent).count

    conversion_rate_pct = activated_count.positive? ? ((won_count.to_f / activated_count) * 100).round : nil

    owner_ids = @proposals.distinct.pluck(:owner_id)
    originators = User.where(id: owner_ids).includes(:tenant).map do |user|
      user_proposals = @proposals.where(owner_id: user.id)
      activated      = user_proposals.joins(:campaign_instances).distinct.count
      won            = user_proposals.where(pipeline_stage: :won).count
      active_jobs    = user_proposals.where(pipeline_stage: :in_campaign).count
      pipeline_value = user_proposals.where(pipeline_stage: :in_campaign).sum(:proposal_value).to_f

      {
        user: user,
        activated_count: activated,
        active_jobs: active_jobs,
        pipeline_value: pipeline_value,
        close_rate_pct: activated.positive? ? ((won.to_f / activated) * 100).round : 0
      }
    end.sort_by { |row| [-row[:close_rate_pct], -row[:pipeline_value]] }

    follow_ups_by_day = steps_in_scope
      .where(email_delivery_status: :sent)
      .where("campaign_step_instances.updated_at >= ?", 30.days.ago)
      .group("DATE(campaign_step_instances.updated_at)")
      .count
      .sort
      .to_h

    OpenStruct.new(
      activated_count:          activated_count,
      first_followup_delivered: first_followup_delivered,
      won_count:                won_count,
      lost_count:               lost_count,
      in_campaign_count:        in_campaign_count,
      conversion_rate_pct:      conversion_rate_pct,
      closed_revenue:           closed_revenue,
      active_pipeline_value:    active_pipeline_value,
      follow_ups_sent:          follow_ups_sent,
      originators:              originators,
      follow_ups_by_day:        follow_ups_by_day,
      funnel_max:               [activated_count, 1].max,
      total_proposals:          @proposals.count
    )
  end
end
