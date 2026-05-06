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
end
