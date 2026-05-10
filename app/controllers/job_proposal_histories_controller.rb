class JobProposalHistoriesController < ApplicationController
  def show
    # Authorize through the parent proposal — same scope as the show page
    # the timeline lives on. A 404 from accessible_by handles cross-tenant
    # access without leaking history existence.
    @job_proposal = JobProposal.accessible_by(current_ability).find(params[:job_proposal_id])
    @version      = @job_proposal.versions.find(params[:id])
    @actor        = User.find_by(id: @version.whodunnit)
  end
end
