class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :approve, :pause, :resume]

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
    if @campaign.save
      redirect_to admin_campaigns_path, notice: "Campaign created."
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

  def destroy
    @campaign.destroy
    redirect_to admin_campaigns_path, notice: "Campaign deleted."
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

  def campaign_params
    # Status is intentionally NOT permitted here — it's controlled by the
    # Approve / Pause buttons on the show page (which call dedicated
    # actions that also set approved_by_user / paused_by_user / timestamps).
    # Letting an admin set it from the edit form would skip those audit
    # writes and bypass the intended workflow.
    params.require(:campaign).permit(:name, :attributed_scenario_id)
  end
end
