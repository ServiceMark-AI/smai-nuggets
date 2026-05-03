# Persisted result of the most recent live connectivity probe for one
# integration. There's at most one row per `key` (e.g. "application_mailbox",
# "gemini", "active_storage", "redis"). Updated by IntegrationCheckJob;
# read by Admin::IntegrationsController#index.
class IntegrationCheck < ApplicationRecord
  enum :state, { unknown: 0, ok: 1, warn: 2, missing: 3 }, prefix: true

  validates :key, presence: true, uniqueness: true

  def self.record(key:, state:, details:, error_message: nil)
    record = find_or_initialize_by(key: key)
    record.assign_attributes(
      state: state,
      details: details,
      error_message: error_message,
      last_checked_at: Time.current
    )
    record.save!
    record
  end
end
