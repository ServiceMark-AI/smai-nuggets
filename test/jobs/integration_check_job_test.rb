require "test_helper"

class IntegrationCheckJobTest < ActiveSupport::TestCase
  setup { IntegrationCheck.delete_all }

  test "writes one IntegrationCheck row per probe with the probe's result" do
    fake_results = {
      application_mailbox: IntegrationProbe::Result.new(state: :ok, details: "Token refresh succeeded.", error_message: nil),
      gemini:              IntegrationProbe::Result.new(state: :missing, details: "Bad key.", error_message: "HTTP 403"),
      active_storage:      IntegrationProbe::Result.new(state: :ok, details: "S3 reachable.", error_message: nil),
      redis:               IntegrationProbe::Result.new(state: :ok, details: "PING -> PONG", error_message: nil)
    }
    stub_run_all(fake_results) { IntegrationCheckJob.new.perform }

    assert_equal 4, IntegrationCheck.count
    mailbox = IntegrationCheck.find_by!(key: "application_mailbox")
    assert_equal "ok", mailbox.state
    assert_equal "Token refresh succeeded.", mailbox.details

    gemini = IntegrationCheck.find_by!(key: "gemini")
    assert_equal "missing", gemini.state
    assert_equal "HTTP 403", gemini.error_message
  end

  test "second run updates existing rows in place" do
    first_results = {
      redis: IntegrationProbe::Result.new(state: :ok, details: "PING -> PONG", error_message: nil)
    }
    second_results = {
      redis: IntegrationProbe::Result.new(state: :missing, details: "PING failed.", error_message: "Timeout")
    }

    stub_run_all(first_results) { IntegrationCheckJob.new.perform }
    assert_equal 1, IntegrationCheck.count

    stub_run_all(second_results) { IntegrationCheckJob.new.perform }
    assert_equal 1, IntegrationCheck.count
    assert_equal "missing", IntegrationCheck.find_by!(key: "redis").state
  end

  private

  def stub_run_all(results)
    original = IntegrationProbe.singleton_class.instance_method(:run_all)
    IntegrationProbe.define_singleton_method(:run_all) { results }
    yield
  ensure
    IntegrationProbe.define_singleton_method(:run_all, original)
  end
end
