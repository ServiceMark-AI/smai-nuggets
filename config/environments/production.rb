require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Storage backend selection: prefer Google Cloud Storage when GCS_BUCKET is
  # set, fall back to Amazon S3 when AWS_BUCKET is set, otherwise use the
  # local disk service (ephemeral on Heroku — only useful for boot without
  # any cloud storage configured).
  config.active_storage.service =
    if ENV["GCS_BUCKET"].present?
      :google
    elsif ENV["AWS_BUCKET"].present?
      :amazon
    else
      :local
    end

  # NOTE: do NOT enable config.assume_ssl on Heroku. The Heroku router
  # already sets X-Forwarded-Proto correctly, and assume_ssl=true makes
  # Rails ignore that header and unconditionally treat every request as
  # SSL. The fallout: a user who visits the bare http:// URL is served
  # the page over plain HTTP (force_ssl thinks it's already SSL and
  # skips the redirect), so the rendered form's Origin is http://, but
  # request.base_url is reported as https:// — the Rails 7.1+
  # forgery_protection_origin_check fails with 422
  # InvalidAuthenticityToken. Rely on force_ssl + X-Forwarded-Proto
  # instead; force_ssl will correctly redirect HTTP → HTTPS before any
  # form is ever rendered, so Origin always matches base_url.

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Host used by absolute URLs in outbound mailer templates (invitations,
  # password resets, etc.). APP_HOST should be set on Heroku to your
  # public domain; the localhost fallback keeps a fresh deploy bootable
  # even before someone has run `heroku config:set APP_HOST=...`. The
  # admin missing-env banner surfaces APP_HOST as missing in production
  # when it's unset, so a deploy that boots with the fallback still gets
  # flagged loudly inside the app.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost"), protocol: "https" }

  # Outbound mail goes through the singleton ApplicationMailbox via Gmail
  # OAuth. Connect at /admin/application_mailbox before relying on Devise mail.
  config.action_mailer.delivery_method = :gmail_oauth

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
