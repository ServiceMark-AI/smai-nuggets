class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :approve, :pause]

  def index
    @campaigns = Campaign.order(created_at: :desc)
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
      redirect_to admin_campaigns_path, notice: "Campaign updated."
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

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :status, :attributed_scenario_id)
  end
end
