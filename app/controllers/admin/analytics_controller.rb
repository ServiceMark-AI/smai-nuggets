# Read-only analytics view for admins. Builds the metrics inline today
# (small SQL surface, no caching needed at current scale). Move to a
# service object + materialized view when query pressure rises.
#
# PRD reference: docs/prd/PRD-07-Analytics.md
# What's intentionally not implemented here yet, and why:
#   - Reply-related metrics (Avg Time to First Reply tile, Customer
#     Replied funnel stage, Operator Responded funnel stage,
#     originator Reply Rate column) need an inbound-message store
#     that doesn't exist in the schema yet.
#   - Date / location / job-type filter bar — wireframe exists in
#     the PRD but this first pass is "all data, all-time" so the
#     queries stay simple. Adding a date scope is a follow-up.
#   - Originator-scoped visibility (PRD §9.5) — admin-only view for
#     now; non-admin scoping comes when we wire originator role.
class Admin::AnalyticsController < Admin::BaseController
  def show
    proposals = JobProposal.all

    # Funnel + tile counts.
    @activated_count             = proposals.joins(:campaign_instances).distinct.count
    @first_followup_delivered    = CampaignInstance
                                    .joins(:step_instances)
                                    .where(campaign_step_instances: { email_delivery_status: :sent })
                                    .distinct.count
    @won_count                   = proposals.where(pipeline_stage: :won).count
    @lost_count                  = proposals.where(pipeline_stage: :lost).count
    @in_campaign_count           = proposals.where(pipeline_stage: :in_campaign).count

    # Hero tiles.
    @conversion_rate_pct         = @activated_count.positive? ? ((@won_count.to_f / @activated_count) * 100).round : nil
    @closed_revenue              = proposals.where(pipeline_stage: :won).sum(:proposal_value)
    @active_pipeline_value       = proposals.where(pipeline_stage: :in_campaign).sum(:proposal_value)
    @follow_ups_sent             = CampaignStepInstance.where(email_delivery_status: :sent).count

    # Originator performance — one row per user who owns at least one
    # proposal. Sorted by close rate desc, ties broken by pipeline value
    # desc per PRD §9.2.
    owner_ids = proposals.distinct.pluck(:owner_id)
    @originators = User.where(id: owner_ids).includes(:tenant).map do |user|
      user_proposals = JobProposal.where(owner_id: user.id)
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

    # Activity chart — sends per day across the last 30 days.
    @follow_ups_by_day = CampaignStepInstance
                          .where(email_delivery_status: :sent)
                          .where("updated_at >= ?", 30.days.ago)
                          .group("DATE(updated_at)")
                          .count
                          .sort
                          .to_h

    # Funnel rendering helper data.
    @funnel_max = [@activated_count, 1].max

    # Total proposal count (for the "all-time scope" footer line).
    @total_proposals = proposals.count
  end
end
