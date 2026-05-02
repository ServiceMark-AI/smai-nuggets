class Organization < ApplicationRecord
  belongs_to :tenant
  belongs_to :parent, class_name: "Organization", optional: true
  has_many :children, class_name: "Organization", foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent

  validates :name, presence: true
end
