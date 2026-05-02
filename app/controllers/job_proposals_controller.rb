class JobProposalsController < ApplicationController
  def index
    @job_proposals = JobProposal
      .accessible_by(current_ability)
      .includes(:organization, :job_type, :owner)
      .order(created_at: :desc)
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
      redirect_to job_proposals_path, notice: "Job proposal created."
    else
      flash.now[:alert] = proposal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end
end
