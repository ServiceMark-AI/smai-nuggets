require "net/http"
require "uri"
require "json"

# Live connectivity probes for each external integration. Each probe
# returns a `Result` with `state`, `details`, and an optional
# `error_message` — same shape used by IntegrationCheck records and the
# admin Integrations page. Probes are intentionally cheap:
#
#   application_mailbox -> refresh the OAuth access token against Google's
#                          token endpoint (the same call GmailSender makes
#                          before sending). Catches revoked / expired
#                          refresh tokens early.
#   gemini              -> GET https://generativelanguage.googleapis.com/v1beta/models?key=...
#                          Lists models; doesn't consume tokens.
#   active_storage      -> ActiveStorage's underlying service object reports
#                          whether a sentinel key exists in the bucket.
#                          A "false" answer is success — it confirms we
#                          authenticated and were allowed to ask.
#   redis               -> Sidekiq.redis { |c| c.call("PING") }.
#
# Each probe must complete in well under a second on a healthy deploy.
# All exceptions are caught and converted to a :missing Result so that
# callers (jobs, controllers) don't have to wrap individual calls.
class IntegrationProbe
  Result = Struct.new(:state, :details, :error_message, keyword_init: true)

  PROBES = %i[application_mailbox gemini active_storage redis].freeze

  def self.run_all
    PROBES.to_h { |key| [key, run(key)] }
  end

  def self.run(key)
    new.public_send(key)
  rescue StandardError => e
    Result.new(state: :missing, details: "Probe error.", error_message: "#{e.class}: #{e.message}")
  end

  # ---- Application mailbox: refresh the OAuth token --------------------

  def application_mailbox
    mailbox = ApplicationMailbox.current
    return Result.new(state: :missing, details: "No application mailbox connected.") unless mailbox

    if mailbox.refresh_token.blank?
      return Result.new(
        state: :warn,
        details: "Connected as #{mailbox.email}, but no refresh token stored. Reconnect to enable automatic refresh."
      )
    end

    if ENV["GOOGLE_CLIENT_ID"].blank? || ENV["GOOGLE_CLIENT_SECRET"].blank?
      return Result.new(
        state: :warn,
        details: "Connected as #{mailbox.email}, but Google OAuth credentials are missing — token refresh will fail."
      )
    end

    response = post_form(
      "https://oauth2.googleapis.com/token",
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      refresh_token: mailbox.refresh_token,
      grant_type: "refresh_token"
    )

    if response.code.to_i.between?(200, 299)
      Result.new(state: :ok, details: "Token refresh succeeded for #{mailbox.email}.")
    else
      Result.new(
        state: :missing,
        details: "Connected as #{mailbox.email}, but Google rejected the refresh token.",
        error_message: "HTTP #{response.code}: #{truncate(response.body)}"
      )
    end
  end

  # ---- Gemini API: GET models ------------------------------------------

  def gemini
    key = ENV["GEMINI_API_KEY"]
    return Result.new(state: :missing, details: "GEMINI_API_KEY is not set.") if key.blank?

    response = get("https://generativelanguage.googleapis.com/v1beta/models?key=#{URI.encode_www_form_component(key)}")
    if response.code.to_i.between?(200, 299)
      Result.new(state: :ok, details: "models.list returned #{response.code}.")
    else
      Result.new(
        state: :missing,
        details: "Gemini API rejected the request.",
        error_message: "HTTP #{response.code}: #{truncate(response.body)}"
      )
    end
  end

  # ---- Active Storage: cheap auth-check via the underlying service -----

  def active_storage
    service = ActiveStorage::Blob.service
    return Result.new(state: :ok, details: "Local disk service — no remote check.") if service.is_a?(ActiveStorage::Service::DiskService)

    # `service.exist?` issues a HEAD against the bucket for the given key.
    # We don't care whether the sentinel exists — only that the call
    # didn't raise. A false return is success: "you're authed, the bucket
    # is reachable, the object isn't there."
    sentinel_key = "__integration_check__/#{SecureRandom.hex(4)}"
    service.exist?(sentinel_key)
    Result.new(state: :ok, details: "#{service.class.name.demodulize.sub('Service', '')} service reachable.")
  end

  # ---- Redis: PING -----------------------------------------------------

  def redis
    return Result.new(state: :missing, details: "REDIS_URL is not set.") if ENV["REDIS_URL"].blank?

    pong = Sidekiq.redis { |c| c.call("PING") }
    if pong == "PONG"
      Result.new(state: :ok, details: "PING -> PONG")
    else
      Result.new(state: :missing, details: "PING returned #{pong.inspect}")
    end
  end

  private

  def get(url)
    Net::HTTP.start(URI(url).host, URI(url).port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
      http.get(URI(url).request_uri)
    end
  end

  def post_form(url, **params)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
      http.request(req)
    end
  end

  def truncate(s, n: 200)
    s = s.to_s
    s.length > n ? "#{s[0, n]}…" : s
  end
end
