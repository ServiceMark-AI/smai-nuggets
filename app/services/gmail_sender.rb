require "net/http"
require "uri"
require "json"
require "base64"

# Sends mail via the Gmail API using OAuth credentials. Works against any
# object that responds to email / access_token / refresh_token / expires_at /
# expired? / update! — currently EmailDelegation (per-user OBO) and
# ApplicationMailbox (singleton transactional sender).
#
# In test, no HTTP is performed — calls are recorded on `deliveries` so tests
# can assert what was sent without any network access.
class GmailSender
  GMAIL_SEND_URL = "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"
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

  # Build a simple plain-text email and send it.
  def send_email(to:, subject:, body:)
    if Rails.env.test?
      self.class.deliveries << { from: @credentials.email, to: to, subject: subject, body: body }
      return true
    end

    refresh_if_needed
    raw = build_message(to: to, subject: subject, body: body)
    encoded = Base64.urlsafe_encode64(raw)
    post_send(encoded)
  end

  # Send an already-built Mail::Message (e.g., one ActionMailer rendered).
  # Replaces the From header with the credentials' email so Gmail accepts it.
  def send_mail(mail)
    if Rails.env.test?
      self.class.deliveries << {
        from: @credentials.email,
        to: Array(mail.to),
        subject: mail.subject,
        body: mail.body.to_s
      }
      return true
    end

    refresh_if_needed
    mail["From"] = @credentials.email
    encoded = Base64.urlsafe_encode64(mail.encoded)
    post_send(encoded)
  end

  private

  def post_send(encoded_raw)
    response = post_json(GMAIL_SEND_URL, { raw: encoded_raw }, bearer: @credentials.access_token)
    if response.code.to_i.between?(200, 299)
      true
    else
      Rails.logger.warn "[GmailSender] send failed (#{response.code}): #{response.body}"
      false
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

  def build_message(to:, subject:, body:)
    [
      "To: #{to}",
      "From: #{@credentials.email}",
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
end
