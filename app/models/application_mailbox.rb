# OAuth-connected mailboxes the application uses to send transactional
# email (invitations, Devise password resets, campaign sends). Distinct
# from per-user EmailDelegation, which is used for on-behalf-of operator
# sends from the user's own Gmail.
#
# Per PRD-09 §5, every location can have one dedicated operational
# mailbox. The legacy "no location" mailbox stays around as a singleton
# fallback for callers that aren't location-aware (e.g. Devise's
# password-reset flow), and as the migration path for accounts that
# haven't yet split per-location.
class ApplicationMailbox < ApplicationRecord
  belongs_to :location, optional: true

  validates :provider, :email, :access_token, presence: true

  validate :only_one_legacy_singleton

  # The legacy no-location mailbox. Used by callers that don't have a
  # location context (Devise transactional email, invitation send).
  def self.current
    where(location_id: nil).first
  end

  # Resolve the right mailbox for a given location. Prefers the
  # location-specific mailbox; falls back to the legacy singleton if
  # the location hasn't had one provisioned yet.
  def self.for_location(location)
    return current if location.nil?
    where(location_id: location.id).first || current
  end

  def self.for_proposal(job_proposal)
    for_location(job_proposal&.location)
  end

  def self.connected?
    exists?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  private

  def only_one_legacy_singleton
    return unless location_id.nil?
    if self.class.where(location_id: nil).where.not(id: id).exists?
      errors.add(:base, "A no-location application mailbox is already configured. Disconnect it first.")
    end
  end
end
