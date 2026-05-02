class Tenant < ApplicationRecord
  has_many :organizations, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :job_types, dependent: :destroy
  has_many :job_proposals, dependent: :destroy

  validates :name, presence: true
end
