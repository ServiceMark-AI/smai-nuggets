class TenantScenario < ApplicationRecord
  belongs_to :tenant
  belongs_to :scenario

  validates :tenant_id, uniqueness: { scope: :scenario_id }

  scope :active, -> { where(is_active: true) }
end
