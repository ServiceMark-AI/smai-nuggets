class HomeController < ApplicationController
  def index
    if current_user.scoped_to_location?
      redirect_to job_proposals_path(filter: "needs_attention")
    end
  end
end
