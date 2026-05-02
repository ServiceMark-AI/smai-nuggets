# Singleton: the one OAuth-connected mailbox the application uses to send
# transactional email (invitations, Devise password resets, etc.). Distinct
# from per-user EmailDelegation, which is used for on-behalf-of operator
# sends from the user's own Gmail.
class ApplicationMailbox < ApplicationRecord
  validates :provider, :email, :access_token, presence: true

  validate :only_one_record

  def self.current
    first
  end

  def self.connected?
    exists?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  private

  def only_one_record
    if self.class.where.not(id: id).exists?
      errors.add(:base, "An application mailbox is already configured. Disconnect it first.")
    end
  end
end
