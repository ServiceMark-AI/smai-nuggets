# Per-location list of email addresses we will not send to. Per PRD-09 §11,
# entries are added on hard bounce, explicit unsubscribe, or spam complaint
# and only cleared by a SMAI admin. Auto-population from inbound delivery
# events is future work — for now the table is empty unless an admin adds
# rows manually, and PreSendChecklist check #7 simply passes when nothing
# matches.
class EmailSuppression < ApplicationRecord
  belongs_to :location

  REASONS = %w[hard_bounce unsubscribe spam_complaint manual].freeze

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { scope: :location_id, case_sensitive: false }
  validates :reason, inclusion: { in: REASONS }

  before_validation :normalize_email

  def self.suppressed?(location:, email:)
    return false if location.blank? || email.blank?
    where(location_id: location.id).where("LOWER(email) = ?", email.to_s.strip.downcase).exists?
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
