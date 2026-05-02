class Organization < ApplicationRecord
  belongs_to :tenant
  belongs_to :parent, class_name: "Organization", optional: true
  has_many :children, class_name: "Organization", foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent
  has_many :organizational_members, dependent: :destroy
  has_many :users, through: :organizational_members
  has_many :job_proposals, dependent: :destroy
  has_one :location, dependent: :destroy

  validates :name, presence: true
end
