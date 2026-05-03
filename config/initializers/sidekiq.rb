require "sidekiq"
require "sidekiq-cron"

# Load recurring job schedule (e.g. CampaignSweepJob every 5 minutes) on
# Sidekiq server boot. The schedule lives in config/sidekiq_cron.yml and is
# re-loaded each time Sidekiq starts, so a deploy that changes the file is
# enough to publish updates.
Sidekiq.configure_server do |_config|
  schedule_path = Rails.root.join("config/sidekiq_cron.yml")
  next unless File.exist?(schedule_path)

  schedule = YAML.load_file(schedule_path) || {}
  Sidekiq::Cron::Job.load_from_hash!(schedule) if schedule.any?
end
