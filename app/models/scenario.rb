class Scenario < ApplicationRecord
  belongs_to :job_type
  belongs_to :campaign, optional: true
  has_many :tenant_scenarios, dependent: :destroy

  validates :code,
            presence: true,
            length: { maximum: 64 },
            uniqueness: { scope: :job_type_id, case_sensitive: false }
  validates :short_name, presence: true
end
