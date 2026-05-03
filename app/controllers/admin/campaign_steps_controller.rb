class Admin::CampaignStepsController < Admin::BaseController
  before_action :set_campaign
  before_action :set_step, only: [:edit, :update, :destroy]

  def new
    @campaign_step = @campaign.steps.new(sequence_number: next_sequence_number, offset_min: 0)
  end

  def create
    @campaign_step = @campaign.steps.new(campaign_step_params)
    if @campaign_step.save
      redirect_to edit_admin_campaign_path(@campaign), notice: "Step added."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @campaign_step.update(campaign_step_params)
      redirect_to edit_admin_campaign_path(@campaign), notice: "Step updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @campaign_step.destroy
    redirect_to edit_admin_campaign_path(@campaign), notice: "Step removed."
  end

  def reorder
    ids = Array(params[:ids]).map(&:to_i)
    scoped = @campaign.steps.where(id: ids)
    if scoped.count != ids.length
      head :unprocessable_content and return
    end

    CampaignStep.transaction do
      scoped.each_with_index do |step, i|
        step.update_column(:sequence_number, -(i + 1))
      end
      ids.each_with_index do |id, i|
        @campaign.steps.find(id).update_column(:sequence_number, i + 1)
      end
    end
    head :no_content
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def set_step
    @campaign_step = @campaign.steps.find(params[:id])
  end

  def campaign_step_params
    params.require(:campaign_step).permit(
      :sequence_number, :offset_min,
      :offset_days, :offset_hours, :offset_minutes,
      :template_subject, :template_body
    )
  end

  def next_sequence_number
    (@campaign.steps.maximum(:sequence_number) || 0) + 1
  end
end
