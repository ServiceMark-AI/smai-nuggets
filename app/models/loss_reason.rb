class LossReason < ApplicationRecord
  has_many :job_proposals, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :display_name, presence: true

  scope :ordered, -> { order(:sort_order, :display_name) }
end
