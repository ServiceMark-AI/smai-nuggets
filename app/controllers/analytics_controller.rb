# Tenant-scoped analytics for any signed-in user. Mirrors the admin
# dashboard but narrows the proposals_scope to the current user's
# tenant — so figures, originator leaderboard, and activity chart only
# reflect that tenant's data. Users without a tenant get a friendly
# empty state via JobProposal.none rather than a crash.
class AnalyticsController < ApplicationController
  def show
    proposals_scope = current_user.tenant ? current_user.tenant.job_proposals : JobProposal.none
    @analytics = AnalyticsCalculator.new(proposals_scope: proposals_scope).call
  end
end
