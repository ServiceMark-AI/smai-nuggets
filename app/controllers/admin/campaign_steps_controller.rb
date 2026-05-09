class Admin::CampaignStepsController < Admin::BaseController
  before_action :set_campaign_and_revision
  before_action :require_drafting_revision, except: [:reorder]
  before_action :require_drafting_revision_for_reorder, only: [:reorder]
  before_action :set_step, only: [:edit, :update, :destroy]

  def new
    @campaign_step = @revision.steps.new(
      campaign:        @campaign,
      sequence_number: next_sequence_number,
      offset_min:      0
    )
  end

  def create
    @campaign_step = @revision.steps.new(campaign_step_params.merge(campaign: @campaign))
    if @campaign_step.save
      redirect_to admin_campaign_revision_path(@campaign, @revision), notice: "Step added."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @campaign_step.update(campaign_step_params)
      redirect_to admin_campaign_revision_path(@campaign, @revision), notice: "Step updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @campaign_step.destroy
    redirect_to admin_campaign_revision_path(@campaign, @revision), notice: "Step removed."
  end

  def reorder
    ids = Array(params[:ids]).map(&:to_i)
    scoped = @revision.steps.where(id: ids)
    if scoped.count != ids.length
      head :unprocessable_content and return
    end

    CampaignStep.transaction do
      scoped.each_with_index do |step, i|
        step.update_column(:sequence_number, -(i + 1))
      end
      ids.each_with_index do |id, i|
        @revision.steps.find(id).update_column(:sequence_number, i + 1)
      end
    end
    head :no_content
  end

  private

  def set_campaign_and_revision
    @campaign = Campaign.find(params[:campaign_id])
    @revision = @campaign.revisions.find(params[:revision_id])
  end

  # Only drafting revisions are editable. Active and retired revisions are
  # historical artifacts — reject any mutation on them so the live and
  # archived versions of the campaign content stay immutable.
  def require_drafting_revision
    return if @revision.status_drafting?
    redirect_to admin_campaign_revision_path(@campaign, @revision),
                alert: "Steps on a #{@revision.status} revision can't be edited. Create a new draft revision to make changes."
  end

  # Reorder is a JSON endpoint hit from JS, so a redirect won't help —
  # return an error status instead.
  def require_drafting_revision_for_reorder
    head :forbidden unless @revision.status_drafting?
  end

  def set_step
    @campaign_step = @revision.steps.find(params[:id])
  end

  def campaign_step_params
    params.require(:campaign_step).permit(
      :sequence_number, :offset_min,
      :offset_days, :offset_hours, :offset_minutes,
      :template_subject, :template_body
    )
  end

  def next_sequence_number
    (@revision.steps.maximum(:sequence_number) || 0) + 1
  end
end
