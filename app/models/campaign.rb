class Campaign < ApplicationRecord
  belongs_to :approved_by_user, class_name: "User", optional: true
  belongs_to :paused_by_user, class_name: "User", optional: true
  belongs_to :attributed_to, polymorphic: true, optional: true

  has_many :steps, -> { order(:sequence_number) }, class_name: "CampaignStep", inverse_of: :campaign, dependent: :destroy
  has_many :scenarios, dependent: :nullify
  has_many :instances, class_name: "CampaignInstance", dependent: :destroy

  enum :status, { draft: 0, approved: 1, paused: 2 }, prefix: true

  validates :name, presence: true

  # Virtual setter so forms can pass a single scenario id without exposing
  # `attributed_to_type` to mass assignment. Future attribution targets
  # (Tenant, JobType, etc.) get their own typed setters here.
  def attributed_scenario_id
    attributed_to_type == "Scenario" ? attributed_to_id : nil
  end

  def attributed_scenario_id=(id)
    self.attributed_to = id.present? ? Scenario.find_by(id: id) : nil
  end
end
