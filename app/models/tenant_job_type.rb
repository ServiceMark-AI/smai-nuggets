class TenantJobType < ApplicationRecord
  belongs_to :tenant
  belongs_to :job_type

  validates :tenant_id, uniqueness: { scope: :job_type_id }

  scope :active, -> { where(is_active: true) }
end
