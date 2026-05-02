module ApplicationHelper
  # Env vars whose absence we want admins to see warned about in the UI.
  # Currently just the LLM API key driving PDF extraction — extend as needed.
  REQUIRED_ENV_VARS = %w[GEMINI_API_KEY].freeze

  def missing_env_vars
    REQUIRED_ENV_VARS.reject { |key| ENV[key].present? }
  end
end
