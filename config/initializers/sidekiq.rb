require "sidekiq"
require "sidekiq-cron"

# Heroku Key-Value Store (heroku-redis) issues self-signed TLS certs that
# the Ruby Redis client refuses by default, raising
# `RedisClient::CannotConnectError: certificate verify failed
# (self-signed certificate in certificate chain)` from anything that
# touches Redis (Sidekiq Web UI, enqueueing a job, the sweep cron).
#
# The documented Heroku workaround is to drop verification on the TLS
# connection — gated to `rediss://` URLs only so that local
# `redis://localhost` and dev/test stay strict.
def redis_options
  url = ENV["REDIS_URL"]
  options = { url: url }
  options[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE } if url&.start_with?("rediss://")
  options
end

Sidekiq.configure_server do |config|
  config.redis = redis_options

  schedule_path = Rails.root.join("config/sidekiq_cron.yml")
  next unless File.exist?(schedule_path)

  # Load recurring job schedule on Sidekiq server boot. The schedule lives
  # in config/sidekiq_cron.yml and is re-loaded each time Sidekiq starts.
  # ERB is evaluated first so the schedule can vary by environment
  # (e.g. CampaignSweepJob runs every minute in dev, every 5 in prod).
  require "erb"
  schedule = YAML.safe_load(ERB.new(File.read(schedule_path)).result, aliases: true) || {}
  Sidekiq::Cron::Job.load_from_hash!(schedule) if schedule.any?
end

Sidekiq.configure_client do |config|
  config.redis = redis_options
end
