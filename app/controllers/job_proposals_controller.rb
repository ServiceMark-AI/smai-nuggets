class JobProposalsController < ApplicationController
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

    scope = scope.where(status: @selected_status) if @selected_status
    scope = scope.where(owner_id: @selected_owner_id) if @selected_owner_id
    scope = scope.where(created_by_user_id: @selected_creator_id) if @selected_creator_id

    @job_proposals = scope.order(created_at: :desc)
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
      redirect_to job_proposals_path, notice: "Job proposal created."
    else
      flash.now[:alert] = proposal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end
end
