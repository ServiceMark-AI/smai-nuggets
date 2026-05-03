class Admin::IntegrationsController < Admin::BaseController
  def index
    @statuses = IntegrationStatus.all
    @counts = @statuses.each_with_object(Hash.new(0)) { |s, h| h[s.state] += 1 }
  end
end
