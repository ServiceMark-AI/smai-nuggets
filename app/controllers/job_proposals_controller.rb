class JobProposalsController < ApplicationController
  ALLOWED_SORTS = %w[created_at proposal_value].freeze
  ALLOWED_DIRS  = %w[asc desc].freeze

  EDITABLE_PARAMS = %i[
    customer_title customer_first_name customer_last_name customer_email
    customer_house_number customer_street customer_city customer_state customer_zip
    internal_reference loss_notes loss_reason
    owner_id job_type_id scenario_id proposal_value
  ].freeze

  before_action :load_proposal, only: [:edit, :update, :resume]

  def index
    scope = JobProposal
      .accessible_by(current_ability)
      .includes(:organization, :job_type, :owner, :created_by_user)

    @status_options = scope.distinct.pluck(:status).compact.sort
    user_ids = (scope.distinct.pluck(:owner_id) + scope.distinct.pluck(:created_by_user_id)).uniq
    @user_options = User.where(id: user_ids).order(:email)

    @selected_status = params[:status].presence
    @selected_owner_id = params[:owner_id].presence
    @selected_creator_id = params[:creator_id].presence
    @search = params[:q].to_s.strip

    scope = scope.where(status: @selected_status) if @selected_status
    scope = scope.where(owner_id: @selected_owner_id) if @selected_owner_id
    scope = scope.where(created_by_user_id: @selected_creator_id) if @selected_creator_id
    scope = apply_search(scope, @search) if @search.present?

    sort_column = ALLOWED_SORTS.include?(params[:sort]) ? params[:sort] : "created_at"
    sort_dir    = ALLOWED_DIRS.include?(params[:dir])  ? params[:dir]  : "desc"

    @job_proposals = scope.order(sort_column => sort_dir, id: :desc)
  end

  def show
    @job_proposal = JobProposal.accessible_by(current_ability).find(params[:id])
  end

  def new
  end

  def create
    file = params[:file]
    if file.blank?
      flash.now[:alert] = "Please choose a file to upload."
      render :new, status: :unprocessable_content and return
    end

    organization = current_user.organizations.first
    if current_user.tenant.blank? || organization.blank?
      flash.now[:alert] = "Your account isn't yet assigned to a tenant and organization."
      render :new, status: :unprocessable_content and return
    end

    proposal = JobProposal.new(
      tenant: current_user.tenant,
      organization: organization,
      owner: current_user,
      created_by_user: current_user
    )
    attachment = proposal.attachments.build(uploaded_by_user: current_user)
    attachment.file.attach(file)

    if proposal.save
      JobProposalProcessor.new(proposal).process
      redirect_to edit_job_proposal_path(proposal),
                  notice: "Proposal uploaded. Confirm the details below to launch the campaign."
    else
      flash.now[:alert] = proposal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def edit
    set_form_options
  end

  def resume
    instance = @job_proposal.campaign_instances.order(created_at: :desc).first

    if instance&.status_paused?
      JobProposal.transaction do
        instance.update!(status: :active)
        @job_proposal.update!(status_overlay: nil)
      end
      redirect_to job_proposals_path, notice: "Campaign resumed."
    else
      redirect_to job_proposals_path, alert: "This campaign isn't paused."
    end
  end

  def update
    if @campaign_in_flight
      set_form_options
      flash.now[:alert] = "This proposal's campaign is already in flight and can't be edited."
      render :edit, status: :unprocessable_content and return
    end

    if @job_proposal.update(proposal_params)
      result = CampaignLauncher.launch(@job_proposal)
      redirect_to job_proposal_path(@job_proposal), notice: launch_notice(result)
    else
      set_form_options
      flash.now[:alert] = @job_proposal.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  private

  def load_proposal
    @job_proposal = JobProposal.accessible_by(current_ability).find(params[:id])
    authorize! :update, @job_proposal
    @campaign_in_flight = @job_proposal.campaign_instances.exists?
  end

  def set_form_options
    @owner_options = @job_proposal.organization.users.order(:email)
    @job_type_options = JobType.order(:name)
    @scenario_options = Scenario.includes(:job_type).order("job_types.name", :short_name)
  end

  def proposal_params
    params.require(:job_proposal).permit(*EDITABLE_PARAMS)
  end

  def launch_notice(result)
    case result.reason
    when :launched      then "Proposal saved. Campaign launched."
    when :already_running then "Proposal saved."
    when :no_scenario   then "Proposal saved. Pick a scenario to launch a campaign."
    when :no_campaign   then "Proposal saved. The selected scenario has no campaign attached yet — ask an admin."
    else "Proposal saved."
    end
  end

  # Case-insensitive substring match across customer name, address fields,
  # and the internal reference. Single ILIKE pattern reused per column.
  def apply_search(scope, query)
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
    scope.where(<<~SQL.squish, p: pattern)
      customer_first_name   ILIKE :p OR
      customer_last_name    ILIKE :p OR
      customer_house_number ILIKE :p OR
      customer_street       ILIKE :p OR
      customer_city         ILIKE :p OR
      customer_zip          ILIKE :p OR
      internal_reference    ILIKE :p
    SQL
  end
end
