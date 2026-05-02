class CampaignStep < ApplicationRecord
  belongs_to :campaign, inverse_of: :steps

  has_many :step_instances, class_name: "CampaignStepInstance", dependent: :destroy

  validates :sequence_number, presence: true, uniqueness: { scope: :campaign_id }
  validates :offset_min, presence: true
end
