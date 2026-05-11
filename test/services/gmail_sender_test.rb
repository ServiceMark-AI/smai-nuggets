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
end
