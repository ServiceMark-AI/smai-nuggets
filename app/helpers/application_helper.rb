module ApplicationHelper
  # Env vars whose absence we want admins warned about in the UI.
  # Mirrors .env.example so a fresh deploy can spot what's missing at a glance.
  REQUIRED_ENV_VARS = %w[
    GEMINI_API_KEY
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    AWS_REGION
    AWS_BUCKET
  ].freeze

  def missing_env_vars
    REQUIRED_ENV_VARS.reject { |key| ENV[key].present? }
  end
end
