class Tenant < ApplicationRecord
  has_many :organizations, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, presence: true
end
