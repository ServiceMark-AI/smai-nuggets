require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "missing_env_vars surfaces TEST_TO_EMAIL in development when unset" do
    with_env(test_to_email: nil) do
      with_development(true) do
        assert_includes missing_env_vars, "TEST_TO_EMAIL"
      end
    end
  end

  test "missing_env_vars omits TEST_TO_EMAIL in development when it is set" do
    with_env(test_to_email: "qa@example.com") do
      with_development(true) do
        refute_includes missing_env_vars, "TEST_TO_EMAIL"
      end
    end
  end

  test "missing_env_vars does not surface TEST_TO_EMAIL outside development" do
    with_env(test_to_email: nil) do
      with_development(false) do
        refute_includes missing_env_vars, "TEST_TO_EMAIL"
      end
    end
  end

  test "missing_env_vars surfaces APP_HOST outside development when unset" do
    with_app_host(nil) do
      with_development(false) do
        assert_includes missing_env_vars, "APP_HOST"
      end
    end
  end

  test "missing_env_vars omits APP_HOST in development even when unset" do
    with_app_host(nil) do
      with_development(true) do
        refute_includes missing_env_vars, "APP_HOST"
      end
    end
  end

  test "missing_env_vars omits APP_HOST outside development when set" do
    with_app_host("app.example.com") do
      with_development(false) do
        refute_includes missing_env_vars, "APP_HOST"
      end
    end
  end

  # --- humanize_offset_minutes ---

  test "humanize_offset_minutes returns Immediately for zero" do
    assert_equal "Immediately", humanize_offset_minutes(0)
    assert_equal "Immediately", humanize_offset_minutes(nil)
  end

  test "humanize_offset_minutes pluralizes minutes / hours / days" do
    assert_equal "1 minute",  humanize_offset_minutes(1)
    assert_equal "45 minutes", humanize_offset_minutes(45)
    assert_equal "1 hour",     humanize_offset_minutes(60)
    assert_equal "4 hours",    humanize_offset_minutes(240)
    assert_equal "1 day",      humanize_offset_minutes(1440)
    assert_equal "5 days",     humanize_offset_minutes(7200)
    assert_equal "7 days",     humanize_offset_minutes(10080)
  end

  test "humanize_offset_minutes joins mixed units with spaces" do
    assert_equal "1 hour 30 minutes",       humanize_offset_minutes(90)
    assert_equal "1 day 1 hour",            humanize_offset_minutes(1500)
    assert_equal "1 day 1 hour 30 minutes", humanize_offset_minutes(1530)
    assert_equal "2 days 12 hours",         humanize_offset_minutes(3600)
  end

  # --- storage env-var detection ---

  test "missing_env_vars surfaces a generic storage hint when neither GCS nor AWS is configured" do
    with_storage_env(gcs: {}, aws: {}) do
      assert_includes missing_env_vars, "GCS_BUCKET (or AWS_BUCKET)"
      refute_includes missing_env_vars, "AWS_ACCESS_KEY_ID"
    end
  end

  test "missing_env_vars surfaces only GCS gaps once any GCS_* is set" do
    with_storage_env(gcs: { "GCS_PROJECT" => "p" }, aws: {}) do
      assert_includes missing_env_vars, "GCS_BUCKET"
      refute_includes missing_env_vars, "GCS_PROJECT"
      refute_includes missing_env_vars, "AWS_BUCKET"
      refute_includes missing_env_vars, "AWS_ACCESS_KEY_ID"
    end
  end

  test "missing_env_vars surfaces AWS gaps when only AWS_* is partially set" do
    with_storage_env(gcs: {}, aws: { "AWS_ACCESS_KEY_ID" => "k" }) do
      assert_includes missing_env_vars, "AWS_SECRET_ACCESS_KEY"
      refute_includes missing_env_vars, "AWS_ACCESS_KEY_ID"
      refute_includes missing_env_vars, "GCS_BUCKET"
    end
  end

  test "missing_env_vars no longer flags AWS when GCS is fully configured" do
    with_storage_env(gcs: { "GCS_PROJECT" => "p", "GCS_BUCKET" => "b" }, aws: {}) do
      gcs_or_aws_misses = missing_env_vars.select { |v| v.start_with?("AWS_") || v.start_with?("GCS_") }
      assert_empty gcs_or_aws_misses
    end
  end

  private

  def with_env(test_to_email:)
    prior = ENV["TEST_TO_EMAIL"]
    if test_to_email.nil?
      ENV.delete("TEST_TO_EMAIL")
    else
      ENV["TEST_TO_EMAIL"] = test_to_email
    end
    yield
  ensure
    if prior.nil?
      ENV.delete("TEST_TO_EMAIL")
    else
      ENV["TEST_TO_EMAIL"] = prior
    end
  end

  def with_app_host(value)
    prior = ENV["APP_HOST"]
    if value.nil?
      ENV.delete("APP_HOST")
    else
      ENV["APP_HOST"] = value
    end
    yield
  ensure
    if prior.nil?
      ENV.delete("APP_HOST")
    else
      ENV["APP_HOST"] = prior
    end
  end

  def with_development(value)
    original = ApplicationHelper.instance_method(:development_environment?)
    ApplicationHelper.define_method(:development_environment?) { value }
    yield
  ensure
    ApplicationHelper.define_method(:development_environment?, original)
  end

  # Set/clear all GCS_* and AWS_* env vars for the duration of the block,
  # restoring whatever was there before.
  STORAGE_KEYS = %w[GCS_PROJECT GCS_BUCKET GCS_CREDENTIALS
                    AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_BUCKET].freeze

  def with_storage_env(gcs:, aws:)
    prior = STORAGE_KEYS.to_h { |k| [k, ENV[k]] }
    STORAGE_KEYS.each { |k| ENV.delete(k) }
    gcs.each { |k, v| ENV[k] = v }
    aws.each { |k, v| ENV[k] = v }
    yield
  ensure
    STORAGE_KEYS.each do |k|
      prior[k].nil? ? ENV.delete(k) : ENV[k] = prior[k]
    end
  end
end
