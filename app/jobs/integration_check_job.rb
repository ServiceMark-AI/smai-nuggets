# Runs every IntegrationProbe and upserts the result into IntegrationCheck.
# Triggered on demand from the Admin → Integrations page; not on a cron.
class IntegrationCheckJob < ApplicationJob
  queue_as :default

  def perform
    IntegrationProbe.run_all.each do |key, result|
      IntegrationCheck.record(
        key: key.to_s,
        state: result.state,
        details: result.details,
        error_message: result.error_message
      )
    end
  end
end
