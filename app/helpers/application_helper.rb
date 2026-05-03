module ApplicationHelper
  # Env vars whose absence we want admins warned about in the UI.
  # Mirrors .env.example so a fresh deploy can spot what's missing at a glance.
  REQUIRED_ENV_VARS = %w[
    APP_HOST
    GEMINI_API_KEY
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    AWS_REGION
    AWS_BUCKET
    GOOGLE_CLIENT_ID
    GOOGLE_CLIENT_SECRET
  ].freeze

  # Required only in development, where CampaignSweepJob refuses to send
  # unless either Rails.env is production or TEST_TO_EMAIL is set. Surface
  # it in the banner so a developer notices before wondering why nothing
  # is going out.
  DEV_REQUIRED_ENV_VARS = %w[TEST_TO_EMAIL].freeze

  def missing_env_vars
    required = REQUIRED_ENV_VARS.dup
    required.concat(DEV_REQUIRED_ENV_VARS) if development_environment?
    required.reject { |key| ENV[key].present? }
  end

  def development_environment?
    Rails.env.development?
  end

  GOOGLE_OAUTH_ENV_VARS = %w[GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET].freeze

  def google_oauth_configured?
    GOOGLE_OAUTH_ENV_VARS.all? { |key| ENV[key].present? }
  end

  def missing_google_oauth_env_vars
    GOOGLE_OAUTH_ENV_VARS.reject { |key| ENV[key].present? }
  end
end
