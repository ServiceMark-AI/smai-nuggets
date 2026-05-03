require "test_helper"

class IntegrationStatusTest < ActiveSupport::TestCase
  ENV_KEYS = %w[
    GEMINI_API_KEY GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET BUGSNAG_API_KEY
    APP_HOST TEST_TO_EMAIL REDIS_URL
    GCS_PROJECT GCS_BUCKET GCS_CREDENTIALS
    AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_BUCKET
  ].freeze

  setup do
    @prior_env = ENV_KEYS.to_h { |k| [k, ENV[k]] }
    ENV_KEYS.each { |k| ENV.delete(k) }
    ApplicationMailbox.destroy_all
  end

  teardown do
    ENV_KEYS.each { |k| @prior_env[k].nil? ? ENV.delete(k) : ENV[k] = @prior_env[k] }
  end

  test "all returns one Status per integration" do
    statuses = IntegrationStatus.all
    assert_equal 8, statuses.size
    statuses.each do |s|
      assert_kind_of IntegrationStatus::Status, s
      assert_includes %i[ok warn missing], s.state
    end
  end

  # --- Application mailbox ------------------------------------------------

  test "application mailbox is :missing when no record exists" do
    s = find_status("Application Mailbox (Gmail)")
    assert_equal :missing, s.state
    assert_match(/Open Admin → Mailbox/, s.recommendation)
  end

  test "application mailbox is :ok when one is connected" do
    ApplicationMailbox.create!(
      provider: "google_oauth2",
      email: "ops@example.com",
      access_token: "tok",
      expires_at: 1.hour.from_now
    )
    s = find_status("Application Mailbox (Gmail)")
    assert_equal :ok, s.state
    assert_match "ops@example.com", s.details
    assert_match(/expires/, s.details)
  end

  test "application mailbox notes when its token has expired" do
    ApplicationMailbox.create!(
      provider: "google_oauth2",
      email: "ops@example.com",
      access_token: "tok",
      expires_at: 5.minutes.ago
    )
    s = find_status("Application Mailbox (Gmail)")
    assert_equal :ok, s.state
    assert_match(/token expired/, s.details)
  end

  # --- Google OAuth -------------------------------------------------------

  test "google oauth is :missing when client credentials are absent" do
    s = find_status("Google OAuth (sign-in / mailbox connect)")
    assert_equal :missing, s.state
    assert_match "GOOGLE_CLIENT_ID", s.details
  end

  test "google oauth is :ok when both client credentials are set" do
    ENV["GOOGLE_CLIENT_ID"] = "id"
    ENV["GOOGLE_CLIENT_SECRET"] = "secret"
    s = find_status("Google OAuth (sign-in / mailbox connect)")
    assert_equal :ok, s.state
  end

  # --- Gemini -------------------------------------------------------------

  test "gemini is :missing without an API key and :ok with one" do
    assert_equal :missing, find_status("Gemini API (PDF extraction)").state
    ENV["GEMINI_API_KEY"] = "k"
    assert_equal :ok, find_status("Gemini API (PDF extraction)").state
  end

  # --- Active Storage -----------------------------------------------------

  test "active storage is :missing when neither GCS nor AWS is configured" do
    s = find_status("Active Storage")
    assert_equal :missing, s.state
  end

  test "active storage is :ok when GCS is fully configured" do
    ENV["GCS_PROJECT"] = "p"
    ENV["GCS_BUCKET"] = "b"
    s = find_status("Active Storage")
    assert_equal :ok, s.state
    assert_match "Google Cloud Storage", s.details
    assert_match "b", s.details
  end

  test "active storage is :ok when AWS is fully configured" do
    ENV["AWS_ACCESS_KEY_ID"] = "k"
    ENV["AWS_SECRET_ACCESS_KEY"] = "s"
    ENV["AWS_REGION"] = "us-east-1"
    ENV["AWS_BUCKET"] = "smai-bucket"
    s = find_status("Active Storage")
    assert_equal :ok, s.state
    assert_match "Amazon S3", s.details
    assert_match "smai-bucket", s.details
  end

  test "active storage is :warn when GCS is partially configured" do
    ENV["GCS_PROJECT"] = "p"
    s = find_status("Active Storage")
    assert_equal :warn, s.state
    assert_match "GCS_BUCKET", s.details
  end

  test "active storage is :warn when AWS is partially configured" do
    ENV["AWS_ACCESS_KEY_ID"] = "k"
    s = find_status("Active Storage")
    assert_equal :warn, s.state
  end

  # --- Redis --------------------------------------------------------------

  test "redis is :missing when REDIS_URL is unset" do
    s = find_status("Redis (Sidekiq)")
    assert_equal :missing, s.state
  end

  test "redis is :ok and shows scheme + host when REDIS_URL is set" do
    ENV["REDIS_URL"] = "rediss://user:pass@example-redis.com:8450/0"
    s = find_status("Redis (Sidekiq)")
    assert_equal :ok, s.state
    assert_match "rediss", s.details
    assert_match "example-redis.com", s.details
    refute_match "pass", s.details # password is not surfaced
  end

  # --- Bugsnag ------------------------------------------------------------

  test "bugsnag is :warn (fallback key in use) when API key is unset" do
    s = find_status("Bugsnag (error reporting)")
    assert_equal :warn, s.state
    assert_match(/bundled default key/, s.details)
  end

  test "bugsnag is :ok when API key is set" do
    ENV["BUGSNAG_API_KEY"] = "abc"
    s = find_status("Bugsnag (error reporting)")
    assert_equal :ok, s.state
  end

  # --- Environment-conditional rows --------------------------------------

  test "TEST_TO_EMAIL row reports as :ok and not-required outside development" do
    s = find_status("Test override (TEST_TO_EMAIL)")
    assert_equal :ok, s.state
    assert_match(/Only relevant in development/, s.details)
  end

  test "APP_HOST row reports as :ok and not-required in development" do
    statuses_in_development do
      s = find_status("App host (mailer URLs)")
      assert_equal :ok, s.state
      assert_match(/Not required in development/, s.details)
    end
  end

  test "TEST_TO_EMAIL row is :missing in development when unset" do
    statuses_in_development do
      s = find_status("Test override (TEST_TO_EMAIL)")
      assert_equal :missing, s.state
    end
  end

  test "APP_HOST row is :missing in non-development when unset" do
    s = find_status("App host (mailer URLs)")
    assert_equal :missing, s.state
  end

  private

  def find_status(name)
    IntegrationStatus.all.find { |s| s.name == name } ||
      raise("no status named #{name.inspect}")
  end

  def statuses_in_development
    original = Rails.env
    Rails.env = "development"
    yield
  ensure
    Rails.env = original.to_s
  end
end
