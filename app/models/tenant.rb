class Tenant < ApplicationRecord
  has_many :organizations, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :job_proposals, dependent: :destroy
  has_many :invitations, dependent: :destroy
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
end
