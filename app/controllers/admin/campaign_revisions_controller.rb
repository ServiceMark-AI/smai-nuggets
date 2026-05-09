class Admin::CampaignRevisionsController < Admin::BaseController
  before_action :set_campaign
  before_action :set_revision, only: [:show, :approve]

  def show
  end

  # Spawn a draft revision off the campaign's current active revision.
  # Steps are replicated verbatim into the draft so the operator can edit
  # them in isolation without affecting the live campaign or anything
  # already running through it.
  def create
    revision = nil
    CampaignRevision.transaction do
      revision = CampaignRevision.spawn_draft_from_active(campaign: @campaign, user: current_user)
    end
    redirect_to admin_campaign_revision_path(@campaign, revision),
                notice: "Draft revision ##{revision.revision_number} created — edit the steps below."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_campaign_path(@campaign),
                alert: "Couldn't create a new revision: #{e.message}"
  end

  # Promote a drafting revision to active. The previous active revision
  # is retired in the same transaction so the only-one-active-per-campaign
  # invariant always holds. Approval audit fields are stamped here.
  def approve
    unless @revision.status_drafting?
      redirect_to admin_campaign_revision_path(@campaign, @revision),
                  alert: "Only drafting revisions can be approved."
      return
    end

    CampaignRevision.transaction do
      @campaign.revisions
               .where(status: :active)
               .where.not(id: @revision.id)
               .update_all(status: CampaignRevision.statuses[:retired], updated_at: Time.current)

      @revision.update!(
        status:              :active,
        approved_by_user:    current_user,
        approved_at:         Time.current
      )
    end
    redirect_to admin_campaign_revision_path(@campaign, @revision),
                notice: "Revision ##{@revision.revision_number} is now active."
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def set_revision
    @revision = @campaign.revisions.find(params[:id])
  end
end
