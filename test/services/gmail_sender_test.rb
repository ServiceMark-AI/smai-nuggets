require "test_helper"

class GmailSenderTest < ActiveSupport::TestCase
  setup do
    @mailbox = ApplicationMailbox.create!(
      provider: "google_oauth2",
      email: "ops@example.com",
      access_token: "tok",
      refresh_token: "rtok"
    )
  end

  test "send_self_test in the test env records a delivery from the mailbox to itself with a synthetic thread id" do
    sender = GmailSender.new(@mailbox)
    thread_id = sender.send_self_test

    assert_match(/^test-thread-/, thread_id)
    delivery = GmailSender.deliveries.last
    assert_equal "ops@example.com", delivery[:from]
    assert_equal "ops@example.com", delivery[:to]
    assert_match(/Integration self-test/, delivery[:subject])
    assert_match(/connectivity check/i, delivery[:body])
    assert_equal thread_id, delivery[:thread_id]
  end

  test "send_self_test returns a fresh thread id on each call" do
    sender = GmailSender.new(@mailbox)
    a = sender.send_self_test
    b = sender.send_self_test
    refute_equal a, b
  end

  test "send_email with attachments records them on the recorded delivery" do
    sender = GmailSender.new(@mailbox)
    sender.send_email(
      to: "alice@example.com",
      subject: "Your proposal",
      body: "See attached.",
      attachments: [{ filename: "p.pdf", content: "%PDF-1.4 fake bytes", mime_type: "application/pdf" }]
    )

    delivery = GmailSender.deliveries.last
    assert_equal 1, delivery[:attachments].size
    assert_equal "p.pdf", delivery[:attachments].first[:filename]
    assert_equal "application/pdf", delivery[:attachments].first[:mime_type]
    assert delivery[:attachments].first[:byte_size].positive?
  end

  test "send_email without attachments records an empty attachments array" do
    sender = GmailSender.new(@mailbox)
    sender.send_email(to: "alice@example.com", subject: "Hi", body: "Hello.")
    delivery = GmailSender.deliveries.last
    assert_equal [], delivery[:attachments]
  end

  test "send_email records the bcc address when passed" do
    sender = GmailSender.new(@mailbox)
    sender.send_email(to: "alice@example.com", subject: "Hi", body: "Hello.", bcc: "originator@example.com")
    delivery = GmailSender.deliveries.last
    assert_equal "originator@example.com", delivery[:bcc]
  end

  test "build_message includes a Bcc header when bcc is present" do
    sender = GmailSender.new(@mailbox)
    raw = sender.send(:build_message, to: "alice@example.com", subject: "Hi", body: "Hello.", bcc: "originator@example.com")
    assert_includes raw, "Bcc: originator@example.com"
  end

  test "build_message omits the Bcc header when bcc is blank" do
    sender = GmailSender.new(@mailbox)
    raw = sender.send(:build_message, to: "alice@example.com", subject: "Hi", body: "Hello.")
    refute_includes raw, "Bcc:"
  end

  test "build_multipart records the Bcc on the message object" do
    sender = GmailSender.new(@mailbox)
    msg = sender.send(:build_multipart,
      to: "alice@example.com",
      from: "bob@example.com",
      subject: "Test",
      body: "Hello.",
      attachments: [{ filename: "p.pdf", content: "%PDF-1.4 fake", mime_type: "application/pdf" }],
      bcc: "originator@example.com"
    )
    assert_equal ["originator@example.com"], Array(msg.bcc)
  end

  # Mail#encoded strips Bcc (it's the SMTP envelope's job), but the Gmail
  # API reads BCC recipients from the raw message. Inject the header back
  # in before base64 encoding so Gmail actually delivers the BCC.
  test "inject_bcc_header places Bcc in the header section, not the body" do
    sender = GmailSender.new(@mailbox)
    raw = "From: bob@example.com\r\nTo: alice@example.com\r\nSubject: Hi\r\n\r\nHello body."
    out = sender.send(:inject_bcc_header, raw, "originator@example.com")
    header_section, body_section = out.split("\r\n\r\n", 2)
    assert_includes header_section, "Bcc: originator@example.com"
    refute_includes body_section, "Bcc:"
    assert_equal "Hello body.", body_section
  end

  # Regression: a multipart message used to drop the body string entirely.
  # `msg.body = "..."` followed by `msg.attachments[...] = {...}` produced a
  # multipart/mixed message with only the attachment part — recipients saw
  # an empty email body next to the PDF. Build the body as an explicit
  # text/plain part so it survives the multipart promotion.
  test "build_multipart includes the body as a text/plain part alongside attachments" do
    sender = GmailSender.new(@mailbox)
    msg = sender.send(:build_multipart,
      to: "alice@example.com",
      from: "bob@example.com",
      subject: "Test",
      body: "Hello there. This is the body.",
      attachments: [{ filename: "p.pdf", content: "%PDF-1.4 fake", mime_type: "application/pdf" }]
    )

    encoded = msg.encoded
    assert_includes encoded, "Hello there. This is the body.",
      "the message body must appear in the encoded multipart output"
    assert_includes encoded, "Content-Type: text/plain"
    assert_includes encoded, "Content-Type: application/pdf"
    assert_match(/Content-Disposition: attachment;\s+filename=p\.pdf/, encoded)
    refute_nil msg.text_part, "multipart message must have a text part"
    assert_equal "Hello there. This is the body.", msg.text_part.body.decoded
  end

  test "multipart text part declares format=flowed so receivers reflow long paragraphs" do
    sender = GmailSender.new(@mailbox)
    msg = sender.send(:build_multipart,
      to: "alice@example.com", from: "bob@example.com",
      subject: "Test", body: "Single long paragraph.",
      attachments: [{ filename: "p.pdf", content: "%PDF-1.4", mime_type: "application/pdf" }]
    )
    assert_match(/format=flowed/, msg.text_part.content_type.to_s)
    assert_match(/delsp=no/, msg.text_part.content_type.to_s)
  end

  test "non-attachment send declares format=flowed in its Content-Type" do
    sender = GmailSender.new(@mailbox)
    raw = sender.send(:build_message,
      to: "alice@example.com", subject: "Test", body: "Single long paragraph."
    )
    assert_match(/Content-Type: text\/plain;.*format=flowed/, raw)
    assert_match(/delsp=no/, raw)
  end

  # --- refresh_if_needed ------------------------------------------------
  # Rails.env.test? short-circuits every public sender method (send_email,
  # probe_thread, ...) before it ever reaches refresh_if_needed, so the only
  # way to exercise the refresh path is to call the private method directly
  # and stub the Net::HTTP call it makes.
  #
  # Root cause this guards: refresh_if_needed used to `return unless
  # response.code.to_i.between?(200, 299)` with no log line and no state
  # change. All 11 production email_delegations rows are expired (3-122
  # days) and every refresh has been failing with invalid_grant, silently,
  # for months.

  test "refresh_if_needed logs Google's error and persists refresh_failed_at/refresh_error on a non-2xx response" do
    delegation = build_expired_delegation
    fake_response = http_response_double(
      "400", { error: "invalid_grant", error_description: "Token has been expired or revoked." }.to_json
    )

    log_output = with_google_client_env do
      capture_rails_log do
        with_post_form_returning(fake_response) do
          GmailSender.new(delegation).send(:refresh_if_needed)
        end
      end
    end

    assert_match(/invalid_grant/, log_output)
    assert_match(/expired or revoked/i, log_output)

    delegation.reload
    assert_not_nil delegation.refresh_failed_at
    assert_equal "invalid_grant", delegation.refresh_error
  end

  test "refresh_if_needed updates access_token/expires_at and clears a prior refresh failure on a 200 response" do
    delegation = build_expired_delegation(refresh_failed_at: 2.days.ago, refresh_error: "invalid_grant")
    fake_response = http_response_double(
      "200", { access_token: "fresh-access-token", expires_in: 3600 }.to_json
    )

    with_google_client_env do
      with_post_form_returning(fake_response) do
        GmailSender.new(delegation).send(:refresh_if_needed)
      end
    end

    delegation.reload
    assert_equal "fresh-access-token", delegation.access_token
    assert_in_delta 1.hour.from_now.to_i, delegation.expires_at.to_i, 5
    assert_nil delegation.refresh_failed_at
    assert_nil delegation.refresh_error
  end

  test "refresh_if_needed logs and does not call Google when GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET are blank" do
    delegation = build_expired_delegation

    log_output = with_blank_google_client_env do
      capture_rails_log do
        with_post_form_returning(->(*) { raise "must not call Google when client credentials are blank" }) do
          GmailSender.new(delegation).send(:refresh_if_needed)
        end
      end
    end

    assert_match(/GOOGLE_CLIENT_ID/, log_output)
    assert_match(/GOOGLE_CLIENT_SECRET/, log_output)
  end

  test "refresh_if_needed is a no-op when the credential is not expired" do
    delegation = build_expired_delegation
    delegation.update!(expires_at: 1.hour.from_now)

    with_google_client_env do
      with_post_form_returning(->(*) { raise "must not call Google when the credential is not expired" }) do
        GmailSender.new(delegation).send(:refresh_if_needed)
      end
    end

    delegation.reload
    assert_equal "stale-access-token", delegation.access_token
  end

  private

  # Matches the house style in test/jobs/campaign_sweep_job_test.rb
  # (with_production_environment, with_gmail_sender_returning, etc.) — this
  # Ruby/minitest version doesn't ship Object#stub (minitest 6 dropped
  # minitest/mock), so class-method stubbing goes through
  # define_singleton_method + restore instead.
  def with_post_form_returning(value_or_proc)
    original = Net::HTTP.singleton_method(:post_form)
    Net::HTTP.define_singleton_method(:post_form) do |*args, **kwargs|
      value_or_proc.respond_to?(:call) ? value_or_proc.call(*args, **kwargs) : value_or_proc
    end
    yield
  ensure
    Net::HTTP.define_singleton_method(:post_form, original)
  end

  def build_expired_delegation(refresh_token: "old-refresh-token", refresh_failed_at: nil, refresh_error: nil)
    EmailDelegation.create!(
      user: users(:one),
      provider: "google_oauth2",
      email: "originator@example.com",
      access_token: "stale-access-token",
      refresh_token: refresh_token,
      expires_at: 1.hour.ago,
      refresh_failed_at: refresh_failed_at,
      refresh_error: refresh_error
    )
  end

  def http_response_double(code, body)
    Struct.new(:code, :body).new(code, body)
  end

  def with_google_client_env
    prior_id = ENV["GOOGLE_CLIENT_ID"]
    prior_secret = ENV["GOOGLE_CLIENT_SECRET"]
    ENV["GOOGLE_CLIENT_ID"] = "test-client-id"
    ENV["GOOGLE_CLIENT_SECRET"] = "test-client-secret"
    yield
  ensure
    ENV["GOOGLE_CLIENT_ID"] = prior_id
    ENV["GOOGLE_CLIENT_SECRET"] = prior_secret
  end

  def with_blank_google_client_env
    prior_id = ENV["GOOGLE_CLIENT_ID"]
    prior_secret = ENV["GOOGLE_CLIENT_SECRET"]
    ENV.delete("GOOGLE_CLIENT_ID")
    ENV.delete("GOOGLE_CLIENT_SECRET")
    yield
  ensure
    ENV["GOOGLE_CLIENT_ID"] = prior_id
    ENV["GOOGLE_CLIENT_SECRET"] = prior_secret
  end

  def capture_rails_log
    original_logger = Rails.logger
    io = StringIO.new
    Rails.logger = Logger.new(io)
    yield
    io.string
  ensure
    Rails.logger = original_logger
  end
end
