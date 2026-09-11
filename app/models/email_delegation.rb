class EmailDelegation < ApplicationRecord
  belongs_to :user

  # The Gmail scopes the app needs to run a campaign end to end: send the
  # outbound email and poll the thread for replies and bounces. Google's
  # granular consent lets a user connect their account while declining
  # individual permissions, so a delegation can exist missing either one.
  GMAIL_SEND_SCOPE = "https://www.googleapis.com/auth/gmail.send".freeze
  GMAIL_METADATA_SCOPE = "https://www.googleapis.com/auth/gmail.metadata".freeze
  REQUIRED_GMAIL_SCOPES = [GMAIL_SEND_SCOPE, GMAIL_METADATA_SCOPE].freeze

  validates :provider, :email, :access_token, presence: true
  validates :email, uniqueness: { scope: [:user_id, :provider] }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  # True once a refresh attempt against this delegation's refresh_token has
  # failed with invalid_grant (set by GmailSender#refresh_if_needed) — Google
  # revoked or expired the grant itself, so the stored token can never
  # succeed again no matter how many times the owner reconnects. This is
  # the "present but dead" refresh token case: refresh_token.blank? alone
  # can't see it.
  def refresh_failed?
    refresh_error == "invalid_grant"
  end

  # Single source of truth for "can this delegation actually send right
  # now, or does the owner need to reconnect Gmail" — shared by
  # PreSendChecklist and every "is this connected?" view (the user's own
  # profile page, the admin tenant roster) so a dead-but-present refresh
  # token doesn't read as "connected" in one place while blocking every
  # send in another.
  #
  # True when either:
  # - the access token has expired and there's no refresh_token to renew
  #   it (a delegation predating PR #266's guard against persisting one
  #   with no refresh token at all), or
  # - refresh_failed? — a refresh_token is present but Google has already
  #   rejected the last attempt to use it.
  def reconnect_required?
    (expired? && refresh_token.blank?) || refresh_failed?
  end

  # The scopes Google reported the user actually granted, parsed from the
  # space-delimited `scopes` string captured at the OAuth callback.
  def granted_scopes
    scopes.to_s.split
  end

  # Whether the user granted the scope required to send campaign email.
  def can_send?
    granted_scopes.include?(GMAIL_SEND_SCOPE)
  end

  # Required Gmail scopes the user did not grant during the OAuth consent.
  def missing_scopes
    REQUIRED_GMAIL_SCOPES - granted_scopes
  end

  # Whether every Gmail scope the app needs was granted.
  def all_scopes_granted?
    missing_scopes.empty?
  end
end
