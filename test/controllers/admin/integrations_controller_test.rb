require "test_helper"

class Admin::IntegrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @prior_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end

  teardown do
    ActiveJob::Base.queue_adapter = @prior_adapter
  end

  test "redirects to sign-in when unauthenticated" do
    get admin_integrations_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin users are turned away" do
    sign_in @non_admin
    get admin_integrations_url
    assert_redirected_to root_path
  end

  test "admin sees the integrations page with each integration listed" do
    sign_in @admin
    get admin_integrations_url
    assert_response :success
    assert_match "Integrations", response.body
    assert_match "Application Mailbox", response.body
    assert_match "Google OAuth", response.body
    assert_match "Gemini API", response.body
    assert_match "Active Storage", response.body
    assert_match "Redis (Sidekiq)", response.body
    assert_match "Sentry", response.body
  end

  test "admin sees persisted live-check results next to each integration" do
    IntegrationCheck.delete_all
    IntegrationCheck.create!(key: "redis", state: :ok, details: "PING -> PONG", last_checked_at: 1.minute.ago)
    IntegrationCheck.create!(key: "gemini", state: :missing, details: "Bad key.", error_message: "HTTP 403", last_checked_at: 2.minutes.ago)

    sign_in @admin
    get admin_integrations_url
    assert_response :success
    assert_match "PING -&gt; PONG", response.body
    assert_match "HTTP 403", response.body
    # Integrations without a probe should still render (e.g. App host) but
    # show "N/A" in the live column.
    assert_match "N/A", response.body
  end

  test "POST check enqueues the IntegrationCheckJob and redirects with a notice" do
    sign_in @admin
    assert_enqueued_with(job: IntegrationCheckJob) do
      post check_admin_integrations_url
    end
    assert_redirected_to admin_integrations_path
    follow_redirect!
    assert_match(/Connectivity check started/i, response.body)
  end

  test "POST check is admin-only" do
    sign_in @non_admin
    assert_no_enqueued_jobs only: IntegrationCheckJob do
      post check_admin_integrations_url
    end
    assert_redirected_to root_path
  end
end
