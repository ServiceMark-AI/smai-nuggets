class JobProposalsController < ApplicationController
  def index
    @job_proposals = JobProposal
      .accessible_by(current_ability)
      .includes(:organization, :job_type, :owner)
      .order(created_at: :desc)
  end
end
