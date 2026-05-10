class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :approve, :pause, :resume]
  before_action :set_discarded_campaign, only: [:restore]

  def index
    @campaigns = Campaign.includes(:approved_by_user, :paused_by_user, :steps).order(created_at: :desc)
  end

  def show
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.new(campaign_params)
    revision = nil
    saved = false
    Campaign.transaction do
      saved = @campaign.save
      if saved
        # Initial revision starts in :drafting so the admin can add steps
        # immediately. They promote it to :active via the revision's
        # Approve button once the steps are in place.
        revision = @campaign.revisions.create!(
          revision_number: 0,
          status:          :drafting,
          created_by_user: current_user
        )
      end
    end
    if saved
      redirect_to admin_campaign_revision_path(@campaign, revision),
                  notice: "Campaign created. Add the first step below, then click Approve when you're ready."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to admin_campaign_path(@campaign), notice: "Campaign updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Soft-delete via discard. Refuses while any active/drafting
  # CampaignInstance references this template — see Campaign#ensure_no_live_runs!.
  def destroy
    if @campaign.discard
      redirect_to admin_campaigns_path, notice: "Campaign moved to trash."
    else
      redirect_to admin_campaign_path(@campaign),
        alert: @campaign.errors.full_messages.to_sentence.presence || "Couldn't delete this campaign."
    end
  end

  def restore
    @campaign.undiscard
    redirect_to admin_campaign_path(@campaign), notice: "Campaign restored."
  end

  def approve
    @campaign.update!(status: :approved, approved_by_user: current_user, approved_at: Time.current)
    redirect_to admin_campaign_path(@campaign), notice: "Campaign approved."
  end

  def pause
    @campaign.update!(status: :paused, paused_by_user: current_user, paused_at: Time.current)
    redirect_to admin_campaign_path(@campaign), notice: "Campaign paused."
  end

  # Flips a paused campaign back to :approved without overwriting the
  # original `approved_by_user` / `approved_at` audit fields — that's
  # what distinguishes resume from approve. The pause-time fields are
  # cleared so the campaign reads as cleanly approved again.
  def resume
    @campaign.update!(status: :approved, paused_by_user: nil, paused_at: nil)
    redirect_to admin_campaign_path(@campaign), notice: "Campaign resumed."
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  # Restore acts on a discarded row, which default_scope { kept } hides from
  # a plain `find`. Pull from the unscoped relation here so admins can act
  # on rows that the rest of the app treats as gone.
  def set_discarded_campaign
    @campaign = Campaign.with_discarded.find(params[:id])
  end

  def campaign_params
    # Status is intentionally NOT permitted here — it's controlled by the
    # Approve / Pause buttons on the show page (which call dedicated
    # actions that also set approved_by_user / paused_by_user / timestamps).
    # Letting an admin set it from the edit form would skip those audit
    # writes and bypass the intended workflow.
    params.require(:campaign).permit(:name, :attributed_scenario_id)
  end
end
