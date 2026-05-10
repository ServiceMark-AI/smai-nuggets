class Campaign < ApplicationRecord
  # Soft-delete via the discard gem. We set a default_scope so existing
  # queries (admin lists, scenario joins, sweep filters) treat a discarded
  # campaign as gone. The trash page bypasses this with `.with_discarded`.
  include Discard::Model
  default_scope -> { kept }

  belongs_to :approved_by_user, class_name: "User", optional: true
  belongs_to :paused_by_user, class_name: "User", optional: true
  belongs_to :attributed_to, polymorphic: true, optional: true

  has_many :steps, -> { order(:sequence_number) }, class_name: "CampaignStep", inverse_of: :campaign, dependent: :destroy
  has_many :scenarios, dependent: :nullify
  has_many :instances, class_name: "CampaignInstance", dependent: :destroy
  has_many :revisions, -> { order(:revision_number) }, class_name: "CampaignRevision", inverse_of: :campaign, dependent: :destroy
  has_one  :active_revision, -> { where(status: :active) }, class_name: "CampaignRevision"

  enum :status, { draft: 0, approved: 1, paused: 2 }, prefix: true

  validates :name, presence: true

  # Refuse to discard a campaign with any live run on it. Admins must pause
  # or close out every in-flight CampaignInstance before the template can
  # be deleted — keeps a customer's pending step from referencing a
  # template that vanished from the admin UI.
  before_discard :ensure_no_live_runs!

  # Returns ActiveRecord::Relation across both kept and discarded rows.
  # Counterpart to the default_scope above for places like the trash page
  # and any future cross-state lookups.
  def self.with_discarded
    unscoped
  end

  # Virtual setter so forms can pass a single scenario id without exposing
  # `attributed_to_type` to mass assignment. Future attribution targets
  # (Tenant, JobType, etc.) get their own typed setters here.
  def attributed_scenario_id
    attributed_to_type == "Scenario" ? attributed_to_id : nil
  end

  def attributed_scenario_id=(id)
    self.attributed_to = id.present? ? Scenario.find_by(id: id) : nil
  end

  private

  def ensure_no_live_runs!
    live = instances.where(status: %i[active drafting]).exists?
    if live
      errors.add(:base, "Cannot delete a campaign with active or drafting runs. Pause or close them first.")
      throw(:abort)
    end
  end
end
