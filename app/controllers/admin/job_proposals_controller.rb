class Admin::JobProposalsController < Admin::BaseController
  CREATE_PARAMS = %i[
    tenant_id location_id owner_id
    customer_title customer_first_name customer_last_name customer_email
    customer_house_number customer_street customer_city customer_state customer_zip
    internal_reference loss_notes loss_reason_id
    job_type_id scenario_id proposal_value
  ].freeze

  def new
    @job_proposal = JobProposal.new
    set_form_options
  end

  def create
    @job_proposal = JobProposal.new(create_params)
    @job_proposal.created_by_user = current_user

    if @job_proposal.save
      redirect_to job_proposal_path(@job_proposal), notice: "Job proposal created."
    else
      set_form_options
      flash.now[:alert] = @job_proposal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_form_options
    @tenant_options = Tenant.order(:name)
    tenant = @job_proposal.tenant || @tenant_options.first
    @location_options = tenant ? tenant.locations.order(:display_name) : Location.none
    @owner_options = tenant ? tenant.users.order(:email) : User.none
    @job_type_options = JobType.order(:name)
    @scenario_options = Scenario.includes(:job_type).order("job_types.name", :short_name)
    @loss_reason_options = LossReason.ordered
  end

  def create_params
    params.require(:job_proposal).permit(*CREATE_PARAMS)
  end
end
