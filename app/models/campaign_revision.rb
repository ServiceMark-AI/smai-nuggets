class CampaignRevision < ApplicationRecord
  belongs_to :campaign
  belongs_to :created_by_user,  class_name: "User"
  belongs_to :approved_by_user, class_name: "User", optional: true

  has_many :steps, -> { order(:sequence_number) },
           class_name: "CampaignStep",
           inverse_of: :campaign_revision,
           dependent: :destroy
  has_many :instances, class_name: "CampaignInstance",
           inverse_of: :campaign_revision,
           dependent: :destroy

  enum :status, { drafting: 0, active: 1, retired: 2 }, prefix: true

  validates :revision_number, presence: true, uniqueness: { scope: :campaign_id }

  validate :only_one_active_per_campaign

  # Build a brand-new draft revision off the campaign's current active
  # revision: copies every step verbatim and assigns the next available
  # revision_number. Caller wraps in a transaction.
  def self.spawn_draft_from_active(campaign:, user:)
    active = campaign.revisions.find_by(status: :active)
    next_number = (campaign.revisions.maximum(:revision_number) || -1) + 1

    draft = campaign.revisions.create!(
      revision_number:    next_number,
      status:             :drafting,
      created_by_user:    user
    )

    if active
      active.steps.order(:sequence_number).each do |step|
        draft.steps.create!(
          campaign_id:      campaign.id,
          sequence_number:  step.sequence_number,
          offset_min:       step.offset_min,
          template_subject: step.template_subject,
          template_body:    step.template_body
        )
      end
    end

    draft
  end

  private

  def only_one_active_per_campaign
    return unless status_active?
    other = self.class.where(campaign_id: campaign_id, status: :active).where.not(id: id)
    errors.add(:status, "can only be active on one revision per campaign") if other.exists?
  end
end
