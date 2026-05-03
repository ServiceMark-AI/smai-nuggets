class Admin::IntegrationsController < Admin::BaseController
  def index
    @statuses = IntegrationStatus.all
    @counts = @statuses.each_with_object(Hash.new(0)) { |s, h| h[s.state] += 1 }
    @live_checks = IntegrationCheck.all.index_by(&:key)
  end

  # POST /admin/integrations/check — enqueues a background probe of every
  # integration. Results land on IntegrationCheck and are visible on the
  # next index render. Idempotent on the user side: clicking twice just
  # enqueues twice.
  def check
    IntegrationCheckJob.perform_later
    redirect_to admin_integrations_path,
      notice: "Connectivity check started. Refresh in a few seconds to see results."
  end
end
