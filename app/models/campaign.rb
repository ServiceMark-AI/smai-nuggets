class Campaign < ApplicationRecord
  belongs_to :approved_by_user, class_name: "User", optional: true
  belongs_to :paused_by_user, class_name: "User", optional: true

  has_many :steps, -> { order(:sequence_number) }, class_name: "CampaignStep", inverse_of: :campaign, dependent: :destroy

  enum :status, { new: 0, approved: 1, paused: 2 }, prefix: true

  validates :name, presence: true
end
