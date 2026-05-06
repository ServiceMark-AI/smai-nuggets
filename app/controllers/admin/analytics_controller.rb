# Cross-tenant analytics for admins. Delegates the metric math to
# AnalyticsCalculator so this view and the per-tenant AnalyticsController
# can't drift on a definition. The "all-time scope, all tenants" wording
# in the view is the only thing that distinguishes this page from the
# tenant-facing one — the rest is computed identically against a wider
# proposals_scope.
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
class Admin::AnalyticsController < Admin::BaseController
  def show
    @analytics = AnalyticsCalculator.new(proposals_scope: JobProposal.all).call
  end
end
