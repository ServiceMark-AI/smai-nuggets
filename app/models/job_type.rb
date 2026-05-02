class JobType < ApplicationRecord
  has_many :job_proposals, dependent: :nullify
  has_many :scenarios, dependent: :destroy

  validates :name, presence: true
  validates :type_code,
            presence: true,
            length: { maximum: 64 },
            uniqueness: { case_sensitive: false }
end
