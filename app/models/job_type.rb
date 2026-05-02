class JobType < ApplicationRecord
  belongs_to :tenant
  has_many :job_proposals, dependent: :nullify

  validates :name, presence: true
end
