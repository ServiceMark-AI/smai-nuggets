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

  # ---- Application mailbox: send a self-addressed probe email ---------
  # Sends a real test message from the connected mailbox to itself and
  # confirms Gmail returned a threadId. Catches revoked tokens, blocked
  # scopes, and "looks configured but actually broken" states that a
  # token-refresh-only check would miss. Cost: one email lands in the
  # mailbox per "Re-check now" click — easy to filter on subject prefix.

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

    thread_id = GmailSender.new(mailbox).send_self_test
    Result.new(
      state: :ok,
      details: "Self-test email accepted by Gmail. Thread #{thread_id} delivered to #{mailbox.email}."
    )
  rescue GmailSender::SelfTestError => e
    Result.new(
      state: :missing,
      details: "Connected as #{mailbox&.email}, but the self-test send failed.",
      error_message: e.message
    )
  end

  # ---- Gemini API: ask a real fact question on a cheap model -----------
  # Sends a single generateContent call against a low-cost model with a
  # tiny output cap (16 tokens). Confirms not just that the API key is
  # accepted but that the model actually responded — catches scenarios
  # where the key is valid but the model is unavailable, the project is
  # over quota, or content filtering is rejecting prompts.

  GEMINI_PROBE_MODEL = "gemini-2.5-flash-lite".freeze
  GEMINI_PROBE_PROMPT = "What is the capital of France? Answer in one word.".freeze

  def gemini
    key = ENV["GEMINI_API_KEY"]
    return Result.new(state: :missing, details: "GEMINI_API_KEY is not set.") if key.blank?

    url = "https://generativelanguage.googleapis.com/v1beta/models/#{GEMINI_PROBE_MODEL}:generateContent" \
          "?key=#{URI.encode_www_form_component(key)}"
    payload = {
      contents: [{ parts: [{ text: GEMINI_PROBE_PROMPT }] }],
      generationConfig: { maxOutputTokens: 16, temperature: 0 }
    }
    response = post_json(url, payload)

    unless response.code.to_i.between?(200, 299)
      return Result.new(
        state: :missing,
        details: "Gemini API rejected the request.",
        error_message: "HTTP #{response.code}: #{truncate(response.body)}"
      )
    end

    answer = extract_gemini_answer(response.body)
    if answer.blank?
      return Result.new(
        state: :warn,
        details: "Gemini returned 200 but no text content was found in the response.",
        error_message: truncate(response.body)
      )
    end

    Result.new(
      state: :ok,
      details: "#{GEMINI_PROBE_MODEL} answered “#{GEMINI_PROBE_PROMPT}” → #{truncate(answer, n: 60)}"
    )
  end

  def extract_gemini_answer(body)
    data = JSON.parse(body) rescue {}
    parts = data.dig("candidates", 0, "content", "parts") || []
    parts.map { |p| p["text"] }.compact.join(" ").strip
  end

  # ---- Active Storage: cheap auth-check via the underlying service -----

  def active_storage
    service = ActiveStorage::Blob.service
    # Compare by class name string so we don't force the autoload of
    # ActiveStorage::Service::DiskService when the app is configured for
    # a remote service (GCS / S3) and the disk service hasn't been
    # referenced anywhere. The constant is lazy-loaded.
    if service.class.name == "ActiveStorage::Service::DiskService"
      return Result.new(state: :ok, details: "Local disk service — no remote check.")
    end

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
    Net::HTTP.start(URI(url).host, URI(url).port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.get(URI(url).request_uri)
    end
  end

  def post_json(url, payload)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = payload.to_json
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.request(req)
    end
  end

  def post_form(url, **params)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.request(req)
    end
  end

  def truncate(s, n: 200)
    s = s.to_s
    s.length > n ? "#{s[0, n]}…" : s
  end
end
