require "test_helper"

# Regression guard for the 2026-05-11 incident: Devise password reset
# (POST /users/password) returning 422 InvalidAuthenticityToken because
# `config.assume_ssl = true` was making Rails ignore X-Forwarded-Proto.
# Result: force_ssl never redirected plain-HTTP requests, the password
# form rendered over http://, the browser POSTed back with
# Origin: http://app.servicemark.ai, but request.base_url was reported as
# https:// — the Rails 7.1+ forgery_protection_origin_check failed.
#
# The fix is two things this file pins down:
#   1. assume_ssl stays off in production.
#   2. ActionDispatch::SSL (which force_ssl installs) does in fact
#      redirect HTTP → HTTPS *before* any controller runs, so the
#      Origin check can never see a plain-HTTP form submit.
class ProductionSslTest < ActiveSupport::TestCase
  test "production does NOT set assume_ssl=true (breaks force_ssl redirects on Heroku)" do
    content = File.read(Rails.root.join("config/environments/production.rb"))
    refute_match(/^\s*config\.assume_ssl\s*=\s*true\b/, content,
      "assume_ssl=true overrides X-Forwarded-Proto and makes Rails treat every " \
      "request as SSL, so force_ssl never redirects plain-HTTP requests. Pages " \
      "render over http://, the password-reset form POSTs over http://, and " \
      "Rails 7.1+'s Origin-vs-base_url CSRF check fails with 422. Heroku's " \
      "router already sets X-Forwarded-Proto, so assume_ssl isn't needed.")
  end

  class SslMiddlewareBehaviorTest < ActiveSupport::TestCase
    setup do
      inner_app = ->(_env) { [200, { "Content-Type" => "text/plain" }, ["ok"]] }
      @ssl = ActionDispatch::SSL.new(inner_app, redirect: { exclude: ->(req) { req.path == "/up" } })
    end

    test "plain-HTTP X-Forwarded-Proto is 301-redirected to HTTPS (so the Origin check never sees a HTTP form submit)" do
      env = Rack::MockRequest.env_for("http://app.example.com/users/password/new",
        "HTTP_X_FORWARDED_PROTO" => "http")
      status, headers, _body = @ssl.call(env)
      assert_equal 301, status
      # Rack 3 (Rails 8) downcases response header keys.
      location = headers["location"] || headers["Location"]
      assert_match %r{\Ahttps://app\.example\.com/users/password/new\z}, location
    end

    test "X-Forwarded-Proto: https request passes through the SSL middleware without redirect" do
      env = Rack::MockRequest.env_for("http://app.example.com/users/password/new",
        "HTTP_X_FORWARDED_PROTO" => "https")
      status, _headers, _body = @ssl.call(env)
      assert_equal 200, status
    end

    test "/up health check stays reachable over plain HTTP (Heroku platform check needs this)" do
      env = Rack::MockRequest.env_for("http://app.example.com/up",
        "HTTP_X_FORWARDED_PROTO" => "http")
      status, _headers, _body = @ssl.call(env)
      assert_equal 200, status
    end
  end
end
