class CampaignsController < ApplicationController
  load_and_authorize_resource

  def index
    @campaigns = @campaigns.order(created_at: :desc)
  end

  def new
  end

  def create
    if @campaign.save
      redirect_to campaigns_path, notice: "Campaign created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to campaigns_path, notice: "Campaign updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: "Campaign deleted."
  end

  private

  def campaign_params
    params.require(:campaign).permit(:name, :status)
  end
end
