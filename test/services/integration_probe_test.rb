require "test_helper"

class IntegrationProbeTest < ActiveSupport::TestCase
  setup do
    @prior_env = %w[GEMINI_API_KEY GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET REDIS_URL]
      .to_h { |k| [k, ENV[k]] }
    ApplicationMailbox.destroy_all
  end

  teardown do
    @prior_env.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end

  # --- run_all -----------------------------------------------------------

  test "run_all returns one Result per probe and converts exceptions into :missing" do
    # Force every probe to raise so we exercise the rescue path uniformly.
    stub_methods_to_raise(IntegrationProbe::PROBES) do
      results = IntegrationProbe.run_all
      assert_equal IntegrationProbe::PROBES.sort, results.keys.sort
      results.each_value do |r|
        assert_equal :missing, r.state
        assert_match(/Probe error/, r.details)
        assert_match(/RuntimeError: synthetic/, r.error_message)
      end
    end
  end

  # --- application_mailbox ----------------------------------------------

  test "application_mailbox is :missing when no mailbox is connected" do
    r = IntegrationProbe.run(:application_mailbox)
    assert_equal :missing, r.state
    assert_match "No application mailbox", r.details
  end

  test "application_mailbox is :warn when the mailbox has no refresh token" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "ops@example.com", access_token: "tok")
    r = IntegrationProbe.run(:application_mailbox)
    assert_equal :warn, r.state
    assert_match "no refresh token", r.details
  end

  test "application_mailbox is :warn when Google OAuth credentials are missing" do
    ApplicationMailbox.create!(
      provider: "google_oauth2", email: "ops@example.com",
      access_token: "tok", refresh_token: "rtok"
    )
    ENV.delete("GOOGLE_CLIENT_ID")
    ENV.delete("GOOGLE_CLIENT_SECRET")
    r = IntegrationProbe.run(:application_mailbox)
    assert_equal :warn, r.state
    assert_match "Google OAuth credentials are missing", r.details
  end

  test "application_mailbox is :ok when Google's token endpoint accepts the refresh" do
    ApplicationMailbox.create!(
      provider: "google_oauth2", email: "ops@example.com",
      access_token: "tok", refresh_token: "rtok"
    )
    ENV["GOOGLE_CLIENT_ID"] = "id"
    ENV["GOOGLE_CLIENT_SECRET"] = "secret"

    fake_response = Struct.new(:code, :body).new("200", "{}")
    stub_instance_method(:post_form, fake_response) do
      r = IntegrationProbe.run(:application_mailbox)
      assert_equal :ok, r.state
      assert_match "Token refresh succeeded", r.details
    end
  end

  test "application_mailbox is :missing when Google rejects the refresh token" do
    ApplicationMailbox.create!(
      provider: "google_oauth2", email: "ops@example.com",
      access_token: "tok", refresh_token: "rtok"
    )
    ENV["GOOGLE_CLIENT_ID"] = "id"
    ENV["GOOGLE_CLIENT_SECRET"] = "secret"

    fake_response = Struct.new(:code, :body).new("400", '{"error":"invalid_grant"}')
    stub_instance_method(:post_form, fake_response) do
      r = IntegrationProbe.run(:application_mailbox)
      assert_equal :missing, r.state
      assert_match "rejected the refresh token", r.details
      assert_match "invalid_grant", r.error_message
    end
  end

  # --- gemini ------------------------------------------------------------

  test "gemini is :missing without an API key" do
    ENV.delete("GEMINI_API_KEY")
    r = IntegrationProbe.run(:gemini)
    assert_equal :missing, r.state
  end

  test "gemini is :ok when the models endpoint returns 2xx" do
    ENV["GEMINI_API_KEY"] = "k"
    fake = Struct.new(:code, :body).new("200", "{}")
    stub_instance_method(:get, fake) do
      r = IntegrationProbe.run(:gemini)
      assert_equal :ok, r.state
    end
  end

  test "gemini is :missing when the models endpoint returns non-2xx" do
    ENV["GEMINI_API_KEY"] = "bad"
    fake = Struct.new(:code, :body).new("403", '{"error":{"message":"API key invalid"}}')
    stub_instance_method(:get, fake) do
      r = IntegrationProbe.run(:gemini)
      assert_equal :missing, r.state
      assert_match "API key invalid", r.error_message
    end
  end

  # --- active_storage ----------------------------------------------------

  test "active_storage reports :ok for the disk service without a remote call" do
    r = IntegrationProbe.run(:active_storage)
    assert_equal :ok, r.state
    assert_match(/Local disk service/i, r.details)
  end

  # --- redis -------------------------------------------------------------

  test "redis is :missing when REDIS_URL is unset" do
    ENV.delete("REDIS_URL")
    r = IntegrationProbe.run(:redis)
    assert_equal :missing, r.state
  end

  test "redis is :ok when PING returns PONG" do
    ENV["REDIS_URL"] = "redis://stub.example:6379/0"
    stub_sidekiq_redis(StubRedisConn.new("PONG")) do
      r = IntegrationProbe.run(:redis)
      assert_equal :ok, r.state
      assert_equal "PING -> PONG", r.details
    end
  end

  test "redis is :missing when PING returns something unexpected" do
    ENV["REDIS_URL"] = "redis://stub.example:6379/0"
    stub_sidekiq_redis(StubRedisConn.new("nope")) do
      r = IntegrationProbe.run(:redis)
      assert_equal :missing, r.state
      assert_match '"nope"', r.details
    end
  end

  # --- helpers -----------------------------------------------------------

  StubRedisConn = Struct.new(:reply) do
    def call(_command)
      reply
    end
  end

  private

  # Replace one instance method on IntegrationProbe with a constant return
  # value for the duration of the block.
  def stub_instance_method(method, return_value)
    original = IntegrationProbe.instance_method(method)
    IntegrationProbe.define_method(method) { |*_args, **_kwargs| return_value }
    yield
  ensure
    IntegrationProbe.define_method(method, original)
  end

  # Replace each named instance method on IntegrationProbe with one that
  # raises a synthetic error. Used to drive the rescue path in run_all.
  def stub_methods_to_raise(method_names)
    originals = method_names.to_h { |m| [m, IntegrationProbe.instance_method(m)] }
    method_names.each do |m|
      IntegrationProbe.define_method(m) { raise "synthetic" }
    end
    yield
  ensure
    originals.each { |m, original| IntegrationProbe.define_method(m, original) }
  end

  # Swap Sidekiq.redis for a block that yields the supplied connection
  # stub. Restores the original on exit.
  def stub_sidekiq_redis(conn)
    original = Sidekiq.singleton_class.instance_method(:redis)
    Sidekiq.define_singleton_method(:redis) { |&blk| blk.call(conn) }
    yield
  ensure
    Sidekiq.define_singleton_method(:redis, original)
  end
end
