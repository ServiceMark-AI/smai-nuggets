# Sentry error reporting (https://docs.sentry.io/platforms/ruby/).
#
# DSN reads from the SENTRY_DSN env var with a project-default fallback so a
# fresh deploy reports something even before config is set per-environment.
# Override SENTRY_DSN in production / staging to scope errors to a different
# Sentry project. Setting SENTRY_DSN to the empty string disables reporting.
DEFAULT_SENTRY_DSN = "https://b1dd8abf03ef01353e3a9f6e9d19bab1@o4511362792292352.ingest.us.sentry.io/4511362796879872".freeze

dsn = ENV.fetch("SENTRY_DSN", DEFAULT_SENTRY_DSN)

if dsn.present?
  Sentry.init do |config|
    config.dsn = dsn
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Ship request headers and IP for users so traces include the context
    # needed to reproduce. See https://docs.sentry.io/platforms/ruby/data-management/data-collected/.
    config.send_default_pii = true
  end
end
