class CampaignInstance < ApplicationRecord
  belongs_to :campaign
  belongs_to :host, polymorphic: true

  has_many :step_instances, class_name: "CampaignStepInstance", dependent: :destroy

  enum :status, {
    active: 0,
    paused: 1,
    completed: 2,
    stopped_on_reply: 3,
    stopped_on_delivery_issue: 4,
    stopped_on_closure: 5
  }, prefix: true
end
