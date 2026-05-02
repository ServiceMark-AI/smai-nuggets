Bugsnag.configure do |config|
  config.api_key = ENV.fetch("BUGSNAG_API_KEY", "0209a17dc735ce3d5830d79ffb5dd260")
  config.release_stage = Rails.env
  config.notify_release_stages = %w[production staging]
end
