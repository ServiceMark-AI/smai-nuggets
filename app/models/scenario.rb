class Scenario < ApplicationRecord
  belongs_to :job_type
  belongs_to :campaign, optional: true
  has_many :tenant_scenarios, dependent: :destroy
  has_many :job_proposals, dependent: :nullify
  has_many :attributed_campaigns, as: :attributed_to, class_name: "Campaign", dependent: :nullify

  validates :code,
            presence: true,
            length: { maximum: 64 },
            uniqueness: { scope: :job_type_id, case_sensitive: false }
  validates :short_name, presence: true
end
