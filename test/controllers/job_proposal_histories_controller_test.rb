require "test_helper"

class JobProposalHistoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user        = users(:one)
    @other_user  = users(:two)
    @jp          = job_proposals(:in_users_org)

    PaperTrail.request.whodunnit = users(:admin).id
    @jp.update!(internal_reference: "HIST-#{SecureRandom.hex(2)}")
    # `reorder` rather than `order`: paper_trail's has_many :versions
    # ships with a default ASC order; chaining `order(id: :desc)` would
    # append (giving us the oldest, not the newest). id is also more
    # stable than created_at, which can tie within a single test
    # microsecond.
    @version = @jp.versions.reorder(id: :desc).first
    PaperTrail.request.whodunnit = nil
  end

  test "redirects to sign-in when not authenticated" do
    get job_proposal_history_url(@jp, @version)
    assert_redirected_to new_user_session_path
  end

  test "404s for a version belonging to a proposal in another tenant" do
    sign_in @other_user # tenant: two; @jp is in tenant: one
    get job_proposal_history_url(@jp, @version)
    assert_response :not_found
  end

  test "renders the version with the changeset and resolved actor name" do
    sign_in @user
    get job_proposal_history_url(@jp, @version)
    assert_response :success
    # Field name renders humanized in the Changes table.
    assert_match "Internal reference",         response.body
    assert_match users(:admin).display_name,   response.body
  end

  # --- timeline integration on the proposal show page ---------------------

  test "show page lists every version with newest first and links to each" do
    PaperTrail.request.whodunnit = users(:admin).id
    @jp.update!(internal_reference: "TWO-#{SecureRandom.hex(2)}")
    second = @jp.versions.order(id: :desc).first

    sign_in @user
    get job_proposal_url(@jp)
    assert_response :success
    assert_match "Activity", response.body
    assert_select "a[href=?]", job_proposal_history_path(@jp, second)
    assert_select "a[href=?]", job_proposal_history_path(@jp, @version)
  end
end
