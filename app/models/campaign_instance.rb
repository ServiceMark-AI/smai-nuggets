class CampaignInstance < ApplicationRecord
  belongs_to :campaign
  belongs_to :campaign_revision, inverse_of: :instances
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

  # Default the revision off the campaign's currently-active revision when
  # the caller didn't pass one explicitly. CampaignLauncher always passes
  # both — this fallback is for fixtures, seeds, and test setup where the
  # specific revision doesn't matter.
  before_validation :default_revision_from_campaign

  private

  def default_revision_from_campaign
    return if campaign_revision_id.present?
    return unless campaign
    self.campaign_revision = campaign.active_revision
  end
end
