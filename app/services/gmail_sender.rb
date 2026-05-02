require "net/http"
require "uri"
require "json"
require "base64"

# Sends a plain-text email via the Gmail API using an EmailDelegation's
# OAuth tokens. Refreshes the access token if expired.
#
# In test, no HTTP is performed — calls are recorded on `deliveries` so
# tests can assert on what was sent without any network access.
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

  def initialize(delegation)
    @delegation = delegation
  end

  def send_email(to:, subject:, body:)
    if Rails.env.test?
      self.class.deliveries << { from: @delegation.email, to: to, subject: subject, body: body }
      return true
    end

    refresh_if_needed
    raw = build_message(to: to, subject: subject, body: body)
    encoded = Base64.urlsafe_encode64(raw)

    response = post_json(GMAIL_SEND_URL, { raw: encoded }, bearer: @delegation.access_token)
    if response.code.to_i.between?(200, 299)
      true
    else
      Rails.logger.warn "[GmailSender] send failed (#{response.code}): #{response.body}"
      false
    end
  end

  private

  def refresh_if_needed
    return unless @delegation.expired? && @delegation.refresh_token.present?
    return if ENV["GOOGLE_CLIENT_ID"].blank? || ENV["GOOGLE_CLIENT_SECRET"].blank?

    response = Net::HTTP.post_form(URI(TOKEN_REFRESH_URL),
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      refresh_token: @delegation.refresh_token,
      grant_type: "refresh_token"
    )
    return unless response.code.to_i.between?(200, 299)

    data = JSON.parse(response.body)
    return if data["access_token"].blank?

    @delegation.update!(
      access_token: data["access_token"],
      expires_at: data["expires_in"] ? Time.current + data["expires_in"].to_i.seconds : nil
    )
  end

  def build_message(to:, subject:, body:)
    [
      "To: #{to}",
      "From: #{@delegation.email}",
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
