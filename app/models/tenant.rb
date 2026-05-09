class Tenant < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :job_proposals, dependent: :destroy
  has_many :invitations, dependent: :destroy

  # PRD-10 v1.3.1 §7 / SPEC-07 v1.4 §9 — every campaign email signature
  # references the account's logo. Stored via Active Storage so SMAI staff
  # (or eventually the operator UI) can upload via the admin portal. The
  # string column `logo_url` is preserved as a manual override for tenants
  # who'd rather link to a logo hosted elsewhere.
  has_one_attached :logo
  has_many :tenant_job_types, dependent: :destroy
  has_many :tenant_scenarios, dependent: :destroy

  # Job types and scenarios this tenant is allowed to use. The activation
  # join rows are written by admins via the activations admin UI. The
  # "active" scope on the join itself filters out rows that were activated
  # then deactivated — those rows are kept (not destroyed) so an admin can
  # toggle without losing config history.
  has_many :activated_job_types,
           -> { where(tenant_job_types: { is_active: true }) },
           through: :tenant_job_types,
           source: :job_type
  has_many :activated_scenarios,
           -> { where(tenant_scenarios: { is_active: true }) },
           through: :tenant_scenarios,
           source: :scenario

  validates :name, presence: true

  # Resolves the right URL for templates / signatures: prefer the
  # uploaded logo blob if attached, else the manual `logo_url` string,
  # else nil. Callers handle the nil case.
  def logo_image_url
    return Rails.application.routes.url_helpers.rails_blob_url(logo, only_path: true) if logo.attached?
    logo_url.presence
  end
end
