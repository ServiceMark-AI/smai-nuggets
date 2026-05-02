class JobType < ApplicationRecord
  belongs_to :tenant
  has_many :job_proposals, dependent: :nullify

  validates :name, presence: true
  validates :type_code,
            presence: true,
            length: { maximum: 64 },
            uniqueness: { scope: :tenant_id, case_sensitive: false }
end
