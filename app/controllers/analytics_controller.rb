# Tenant-scoped analytics for any signed-in user. Mirrors the admin
# dashboard but narrows the proposals_scope to the current user's
# tenant — so figures, originator leaderboard, and activity chart only
# reflect that tenant's data. Users without a tenant get a friendly
# empty state via JobProposal.none rather than a crash.
class AnalyticsController < ApplicationController
  def show
    tenant_scope = current_user.tenant ? current_user.tenant.job_proposals : JobProposal.none

    # Location options + the active selection. Originators (users scoped
    # to a single location) are forced to their own location regardless
    # of params — defense in depth so a tampered URL can't show them
    # other locations' data. Tenant admins / SMAI staff get the full
    # dropdown defaulting to "All locations" (selected_location_id = nil).
    if current_user.scoped_to_location?
      @location_options = current_user.location ? [current_user.location] : []
      @selected_location_id = current_user.location_id
    else
      @location_options = current_user.tenant&.locations&.order(:display_name) || Location.none
      requested = params[:location_id].presence
      @selected_location_id = requested if requested && @location_options.exists?(id: requested)
    end

    proposals_scope = tenant_scope
    proposals_scope = proposals_scope.where(location_id: @selected_location_id) if @selected_location_id

    @date_from = parse_date(params[:date_from])
    @date_to   = parse_date(params[:date_to])
    if @date_from
      proposals_scope = proposals_scope.where("job_proposals.created_at >= ?", @date_from.beginning_of_day)
    end
    if @date_to
      proposals_scope = proposals_scope.where("job_proposals.created_at <= ?", @date_to.end_of_day)
    end

    @analytics = AnalyticsCalculator.new(proposals_scope: proposals_scope).call
  end

  private

  # Permissive: silently drops a malformed string so a bad URL param
  # doesn't 500 the page. Returns nil for blank or unparseable input.
  def parse_date(raw)
    return nil if raw.blank?
    Date.parse(raw.to_s)
  rescue ArgumentError
    nil
  end
end
