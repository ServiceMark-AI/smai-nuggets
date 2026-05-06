require "net/http"
require "uri"
require "json"
require "base64"
require "mail"

# Sends mail via the Gmail API using OAuth credentials. Works against any
# object that responds to email / access_token / refresh_token / expires_at /
# expired? / update! — currently EmailDelegation (per-user OBO) and
# ApplicationMailbox (singleton transactional sender).
#
# In test, no HTTP is performed — calls are recorded on `deliveries` so tests
# can assert what was sent without any network access.
class GmailSender
  GMAIL_SEND_URL = "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"
  GMAIL_THREAD_URL = "https://gmail.googleapis.com/gmail/v1/users/me/threads"
  TOKEN_REFRESH_URL = "https://oauth2.googleapis.com/token"

  class << self
    def deliveries
      @deliveries ||= []
    end

    def reset_deliveries!
      @deliveries = []
    end
  end

  def initialize(credentials)
    @credentials = credentials
  end

  # Build a simple plain-text email and send it. Returns the parsed Gmail
  # API response hash on success ({"id" => ..., "threadId" => ...,
  # "labelIds" => [...]}) and nil on failure. In test, returns a synthetic
  # hash with the same shape so callers (CampaignSweepJob) can persist it
  # without branching on env.
  #
  # Pass attachments: as an array of hashes [{ filename:, content:,
  # mime_type: }, ...] to send a multipart/mixed message. The plain
  # body becomes the first text/plain part and each attachment is added
  # via the Mail gem. With no attachments, the original hand-rolled
  # plain-text path is used so the bytes on the wire are unchanged from
  # the pre-attachment behavior.
  def send_email(to:, subject:, body:, from_name: nil, attachments: [])
    from_address = from_name.present? ? %("#{from_name}" <#{@credentials.email}>) : @credentials.email

    if Rails.env.test?
      stub = synthetic_send_response
      self.class.deliveries << {
        from: from_address, to: to, subject: subject, body: body,
        attachments: Array(attachments).map { |a| a.slice(:filename, :mime_type).merge(byte_size: a[:content].to_s.bytesize) },
        response: stub
      }
      return stub
    end

    refresh_if_needed
    encoded = if Array(attachments).any?
                mail = build_multipart(to: to, from: from_address, subject: subject, body: body, attachments: attachments)
                Base64.urlsafe_encode64(mail.encoded)
              else
                raw = build_message(to: to, subject: subject, body: body, from_name: from_name)
                Base64.urlsafe_encode64(raw)
              end
    post_send(encoded)
  end

  # Send an already-built Mail::Message (e.g., one ActionMailer rendered).
  # Replaces the From address with the credentials' email so Gmail accepts
  # the message, but preserves the original display name (e.g. "SMAI User
  # Support") set via Devise's `mailer_sender`. Recipients see
  #   "SMAI User Support" <connected-mailbox@gmail.com>.
  # Returns the parsed Gmail API response hash on success, nil on failure.
  def send_mail(mail)
    rewritten_from = rewrite_from(mail)

    if Rails.env.test?
      stub = synthetic_send_response
      self.class.deliveries << {
        from: rewritten_from,
        to: Array(mail.to),
        subject: mail.subject,
        body: mail.body.to_s,
        response: stub
      }
      return stub
    end

    refresh_if_needed
    mail["From"] = rewritten_from
    encoded = Base64.urlsafe_encode64(mail.encoded)
    post_send(encoded)
  end

  # Fetches a Gmail thread by id with metadata-only formatting (headers
  # but no message bodies — enough to detect replies via From/Date and
  # message count). Returns the parsed JSON hash on success, nil on
  # failure. In test, returns a synthetic single-message thread so callers
  # can persist a snapshot without making an HTTP call.
  def fetch_thread(thread_id)
    return nil if thread_id.blank?

    if Rails.env.test?
      return synthetic_thread_response(thread_id)
    end

    refresh_if_needed
    uri = URI("#{GMAIL_THREAD_URL}/#{thread_id}?format=metadata")
    response = get_json(uri, bearer: @credentials.access_token)
    return nil unless response.code.to_i.between?(200, 299)
    JSON.parse(response.body) rescue nil
  end

  # Sends a self-addressed probe email from the connected mailbox and
  # returns the Gmail thread id from the API response. Used by the
  # Integrations health check to confirm end-to-end sending — the
  # threadId in the response proves Gmail accepted the message and
  # filed it on a real conversation, not just that auth worked.
  #
  # Raises a SelfTestError on any failure (auth, send, or missing
  # threadId in response). In test, no HTTP is made — a synthetic
  # thread id is returned and the message is recorded on `deliveries`.
  class SelfTestError < StandardError; end

  def send_self_test
    subject = "[SMAI] Integration self-test #{Time.current.iso8601}"
    body    = "Automated connectivity check from the Integrations page. Safe to delete."

    if Rails.env.test?
      thread_id = "test-thread-#{SecureRandom.hex(4)}"
      self.class.deliveries << {
        from: @credentials.email, to: @credentials.email,
        subject: subject, body: body, thread_id: thread_id
      }
      return thread_id
    end

    refresh_if_needed
    raw = build_message(to: @credentials.email, subject: subject, body: body)
    encoded = Base64.urlsafe_encode64(raw)
    response = post_json(GMAIL_SEND_URL, { raw: encoded }, bearer: @credentials.access_token)

    unless response.code.to_i.between?(200, 299)
      raise SelfTestError, "Gmail send failed (#{response.code}): #{response.body.to_s.slice(0, 200)}"
    end

    data = JSON.parse(response.body) rescue {}
    thread_id = data["threadId"]
    if thread_id.blank?
      raise SelfTestError, "Gmail accepted the send but returned no threadId: #{response.body.to_s.slice(0, 200)}"
    end

    thread_id
  end

  private

  # Returns "Display Name" <connected@gmail.com> when the original From
  # carried a display name; otherwise just the connected email.
  def rewrite_from(mail)
    display = mail[:from]&.display_names&.first
    display.present? ? %("#{display}" <#{@credentials.email}>) : @credentials.email
  end

  def post_send(encoded_raw)
    response = post_json(GMAIL_SEND_URL, { raw: encoded_raw }, bearer: @credentials.access_token)
    if response.code.to_i.between?(200, 299)
      JSON.parse(response.body) rescue nil
    else
      Rails.logger.warn "[GmailSender] send failed (#{response.code}): #{response.body}"
      nil
    end
  end

  def refresh_if_needed
    return unless @credentials.expired? && @credentials.refresh_token.present?
    return if ENV["GOOGLE_CLIENT_ID"].blank? || ENV["GOOGLE_CLIENT_SECRET"].blank?

    response = Net::HTTP.post_form(URI(TOKEN_REFRESH_URL),
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      refresh_token: @credentials.refresh_token,
      grant_type: "refresh_token"
    )
    return unless response.code.to_i.between?(200, 299)

    data = JSON.parse(response.body)
    return if data["access_token"].blank?

    @credentials.update!(
      access_token: data["access_token"],
      expires_at: data["expires_in"] ? Time.current + data["expires_in"].to_i.seconds : nil
    )
  end

  # Builds a multipart/mixed Mail::Message with a plain-text body and
  # one part per attachment hash. The Mail gem handles MIME boundaries,
  # base64 encoding of binary content, and Content-Disposition headers.
  def build_multipart(to:, from:, subject:, body:, attachments:)
    msg = Mail.new
    msg.to      = to
    msg.from    = from
    msg.subject = subject
    msg.body    = body
    Array(attachments).each do |att|
      msg.attachments[att[:filename]] = {
        content:   att[:content],
        mime_type: att[:mime_type] || "application/octet-stream"
      }
    end
    msg
  end

  def build_message(to:, subject:, body:, from_name: nil)
    from_header = if from_name.present?
                    %("#{from_name.gsub('"', '\\"')}" <#{@credentials.email}>)
                  else
                    @credentials.email
                  end
    [
      "To: #{to}",
      "From: #{from_header}",
      "Subject: #{subject}",
      "MIME-Version: 1.0",
      "Content-Type: text/plain; charset=UTF-8",
      "",
      body
    ].join("\r\n")
  end

  def post_json(url, payload, bearer:)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{bearer}"
    req["Content-Type"] = "application/json"
    req.body = payload.to_json
    http.request(req)
  end

  def get_json(uri, bearer:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{bearer}"
    http.request(req)
  end

  def synthetic_send_response
    thread_id = "test-thread-#{SecureRandom.hex(4)}"
    {
      "id" => "test-msg-#{SecureRandom.hex(4)}",
      "threadId" => thread_id,
      "labelIds" => ["SENT"]
    }
  end

  def synthetic_thread_response(thread_id)
    {
      "id" => thread_id,
      "historyId" => "1",
      "messages" => [
        {
          "id" => "test-msg-#{SecureRandom.hex(4)}",
          "threadId" => thread_id,
          "labelIds" => ["SENT"],
          "payload" => {
            "headers" => [
              { "name" => "From", "value" => @credentials.email }
            ]
          }
        }
      ]
    }
  end
end
