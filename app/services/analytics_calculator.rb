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

    # MTD/YTD breakdown for the Conversion Rate hero tile per SPEC-05 v1.0.
    # Activated count is bucketed by the campaign instance's created_at;
    # won count is bucketed by the proposal's closed_at (set when the
    # pipeline_stage flipped to won or lost).
    now = Time.current
    mtd_start = now.beginning_of_month
    ytd_start = now.beginning_of_year

    mtd_activated = @proposals
      .joins(:campaign_instances)
      .where("campaign_instances.created_at >= ?", mtd_start)
      .distinct.count
    ytd_activated = @proposals
      .joins(:campaign_instances)
      .where("campaign_instances.created_at >= ?", ytd_start)
      .distinct.count
    mtd_won = @proposals.where(pipeline_stage: :won).where("closed_at >= ?", mtd_start).count
    ytd_won = @proposals.where(pipeline_stage: :won).where("closed_at >= ?", ytd_start).count

    conversion_rate_mtd_pct = mtd_activated.positive? ? ((mtd_won.to_f / mtd_activated) * 100).round : nil
    conversion_rate_ytd_pct = ytd_activated.positive? ? ((ytd_won.to_f / ytd_activated) * 100).round : nil

    # MTD/YTD revenue uses the same closed_at bucketing as the conversion
    # rate above so the two tiles tell a consistent story for the same
    # window. `closed_at` is stamped on the proposal when pipeline_stage
    # flips to :won or :lost, so it's a stable cohort marker.
    closed_revenue_mtd = @proposals.where(pipeline_stage: :won).where("closed_at >= ?", mtd_start).sum(:proposal_value)
    closed_revenue_ytd = @proposals.where(pipeline_stage: :won).where("closed_at >= ?", ytd_start).sum(:proposal_value)

    # SPEC-06 v1.0 — per-location Conversion Rate breakdown for the
    # tile expand-toggle. Computed from the same proposals_scope so it
    # respects whatever filter the caller applied. Empty array means
    # don't render the toggle at all.
    by_location = @proposals.where.not(location_id: nil)
      .joins(:location)
      .group("locations.id", "locations.display_name")
      .pluck("locations.id", "locations.display_name", Arel.sql("COUNT(*)"))
      .map do |loc_id, loc_name, total_in_loc|
        loc_proposals = @proposals.where(location_id: loc_id)
        activated = loc_proposals.joins(:campaign_instances).distinct.count
        won = loc_proposals.where(pipeline_stage: :won).count
        rate = activated.positive? ? ((won.to_f / activated) * 100).round : nil
        {
          location_id: loc_id,
          location_display_name: loc_name,
          activated_count: activated,
          won_count: won,
          conversion_rate_pct: rate,
          total_proposals: total_in_loc
        }
      end
      .sort_by { |row| row[:location_display_name].to_s }

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

    # Loss-reason breakdown for the analytics pie. Lost proposals with no
    # loss_reason_id (e.g. legacy rows the migration backfilled to NULL,
    # or anything that slips past the controller validation in the future)
    # are bucketed as "Unspecified" so the chart's slices add up to the
    # full lost_count regardless.
    loss_reasons_breakdown = @proposals
      .where(pipeline_stage: :lost)
      .left_outer_joins(:loss_reason)
      .group("loss_reasons.id", "loss_reasons.display_name", "loss_reasons.sort_order")
      .pluck(
        "loss_reasons.id",
        "loss_reasons.display_name",
        "loss_reasons.sort_order",
        Arel.sql("COUNT(*)")
      )
      .map { |id, label, sort_order, count|
        { loss_reason_id: id, display_name: label || "Unspecified", sort_order: sort_order, count: count }
      }
      .sort_by { |row| [row[:sort_order] || Float::INFINITY, row[:display_name]] }

    OpenStruct.new(
      activated_count:          activated_count,
      first_followup_delivered: first_followup_delivered,
      won_count:                won_count,
      lost_count:               lost_count,
      in_campaign_count:        in_campaign_count,
      conversion_rate_pct:      conversion_rate_pct,
      conversion_rate_mtd_pct:  conversion_rate_mtd_pct,
      conversion_rate_ytd_pct:  conversion_rate_ytd_pct,
      conversion_rate_by_location: by_location,
      closed_revenue:           closed_revenue,
      closed_revenue_mtd:       closed_revenue_mtd,
      closed_revenue_ytd:       closed_revenue_ytd,
      active_pipeline_value:    active_pipeline_value,
      follow_ups_sent:          follow_ups_sent,
      originators:              originators,
      follow_ups_by_day:        follow_ups_by_day,
      loss_reasons_breakdown:   loss_reasons_breakdown,
      funnel_max:               [activated_count, 1].max,
      total_proposals:          @proposals.count
    )
  end
end
