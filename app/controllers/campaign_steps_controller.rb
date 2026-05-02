class CampaignStepsController < ApplicationController
  before_action :set_campaign

  def new
    @campaign_step = @campaign.steps.new(sequence_number: next_sequence_number, offset_min: 0)
  end

  def create
    @campaign_step = @campaign.steps.new(campaign_step_params)
    if @campaign_step.save
      redirect_to campaign_path(@campaign), notice: "Step added."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
    authorize! :update, @campaign
  end

  def campaign_step_params
    params.require(:campaign_step).permit(:sequence_number, :offset_min, :template_subject, :template_body)
  end

  def next_sequence_number
    (@campaign.steps.maximum(:sequence_number) || 0) + 1
  end
end
