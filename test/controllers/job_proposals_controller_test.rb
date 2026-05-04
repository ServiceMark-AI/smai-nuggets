require "test_helper"

class JobProposalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)               # tenant: one, member of org one
    @other_tenant_user = users(:two)  # tenant: two, member of org three
    @admin = users(:admin)            # is_admin
  end

  test "redirects to sign-in when not signed in" do
    get job_proposals_url
    assert_redirected_to new_user_session_path
  end

  test "user sees proposals in their tenant and orgs they are a member of" do
    sign_in @user
    get job_proposals_url
    assert_response :success
    assert_match "Alice", response.body  # in_users_org: tenant=one, org=one ✓
  end

  test "user does not see proposals from orgs they are not in, even in same tenant" do
    sign_in @user
    get job_proposals_url
    assert_response :success
    assert_no_match "Bob", response.body  # same_tenant_other_org: tenant=one, org=two ✗ (user not in org two)
  end

  test "user does not see proposals from other tenants" do
    sign_in @user
    get job_proposals_url
    assert_response :success
    assert_no_match "Carol", response.body  # other_tenant: tenant=two ✗
  end

  test "user from another tenant only sees their own tenant's proposals" do
    sign_in @other_tenant_user
    get job_proposals_url
    assert_response :success
    assert_match "Carol", response.body
    assert_no_match "Alice", response.body
    assert_no_match "Bob", response.body
  end

  test "user with no organization memberships sees empty state" do
    lonely = User.create!(email: "lonely@example.com", password: "Password1", tenant: tenants(:one))
    sign_in lonely
    get job_proposals_url
    assert_response :success
    assert_no_match "Alice", response.body
    assert_no_match "Bob", response.body
    assert_no_match "Carol", response.body
    assert_match "No job proposals match these filters.", response.body
  end

  test "admin sees all proposals across tenants" do
    sign_in @admin
    get job_proposals_url
    assert_response :success
    assert_match "Alice", response.body
    assert_match "Bob", response.body
    assert_match "Carol", response.body
  end

  test "status filter narrows the list to that status" do
    sign_in @admin
    get job_proposals_url, params: { status: "open" }
    assert_response :success
    # Fixtures: in_users_org=new(0), same_tenant_other_org=open(1), other_tenant=new(0)
    assert_match "Bob", response.body
    assert_no_match "Alice", response.body
    assert_no_match "Carol", response.body
  end

  test "owner filter narrows the list to proposals owned by that user" do
    sign_in @admin
    get job_proposals_url, params: { owner_id: users(:two).id }
    assert_response :success
    assert_match "Carol", response.body                # other_tenant: owner=two
    assert_no_match "Alice", response.body             # in_users_org: owner=one
    assert_no_match "Bob", response.body               # same_tenant_other_org: owner=one
  end

  test "creator filter narrows the list to proposals created by that user" do
    sign_in @admin
    get job_proposals_url, params: { creator_id: users(:one).id }
    assert_response :success
    assert_match "Alice", response.body
    assert_match "Bob", response.body
    assert_no_match "Carol", response.body
  end

  test "filters compose with each other" do
    sign_in @admin
    get job_proposals_url, params: { status: "new", owner_id: users(:one).id }
    assert_response :success
    assert_match "Alice", response.body                # status=new + owner=one
    assert_no_match "Bob", response.body               # status=open
    assert_no_match "Carol", response.body             # owner=two
  end

  test "new renders the upload form" do
    sign_in @user
    get new_job_proposal_url
    assert_response :success
    assert_select "form#job-upload-form"
    assert_select "input[type='file'][name='file']"
    assert_match(/Drop a file here/i, response.body)
  end

  test "create with no file re-renders the form with an error" do
    sign_in @user
    assert_no_difference "JobProposal.count" do
      post job_proposals_url, params: {}
    end
    assert_response :unprocessable_content
    assert_match(/Please choose a file/i, response.body)
  end

  test "create persists a proposal with the uploaded file as an attachment" do
    sign_in @user
    file = Rack::Test::UploadedFile.new(StringIO.new("hello world"), "text/plain", original_filename: "proposal.txt")

    assert_difference "JobProposal.count", 1 do
      post job_proposals_url, params: { file: file }
    end
    proposal = JobProposal.order(:created_at).last
    assert_redirected_to edit_job_proposal_path(proposal)
    assert_match(/Confirm the details/i, flash[:notice])
    assert_equal @user, proposal.owner
    assert_equal @user, proposal.created_by_user
    assert_equal @user.tenant, proposal.tenant
    assert_equal 1, proposal.attachments.count
    assert proposal.attachments.first.file.attached?
    assert_equal "proposal.txt", proposal.attachments.first.file.filename.to_s

    # Without AI credentials (Rails.env.test? short-circuits the processor),
    # the stub fills in the customer fields.
    assert_equal "Sample", proposal.customer_first_name
    assert_equal "Customer", proposal.customer_last_name
    assert_equal 10260.00, proposal.proposal_value.to_f
    assert proposal.internal_reference.to_s.start_with?("STUB-")
  end

  test "create fails when user has no organization" do
    lonely = User.create!(email: "lonely2@example.com", password: "Password1", tenant: tenants(:one))
    sign_in lonely
    file = Rack::Test::UploadedFile.new(StringIO.new("x"), "text/plain", original_filename: "x.txt")

    assert_no_difference "JobProposal.count" do
      post job_proposals_url, params: { file: file }
    end
    assert_response :unprocessable_content
    assert_match(/tenant and organization/i, response.body)
  end

  # --- show action ---

  test "index links the address column to the show page" do
    sign_in @user
    @jp = job_proposals(:in_users_org)
    @jp.update!(customer_house_number: "1247", customer_street: "Oak Ridge Drive")
    get job_proposals_url
    assert_response :success
    assert_select "a[href=?]", job_proposal_path(@jp), text: "1247 Oak Ridge Drive"
  end

  test "show renders for a proposal the user can access" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(customer_house_number: "1247", customer_street: "Oak Ridge Drive")
    get job_proposal_url(jp)
    assert_response :success
    assert_match "1247 Oak Ridge Drive", response.body
    assert_match "Alice", response.body
  end

  test "show returns 404 for a proposal outside the user's scope (no info leak)" do
    sign_in @user
    other_jp = job_proposals(:other_tenant)
    get job_proposal_url(other_jp)
    assert_response :not_found
  end

  test "show returns 404 for a missing proposal" do
    sign_in @user
    get job_proposal_url(id: 0)
    assert_response :not_found
  end

  test "show falls back to a Job Proposal #N heading when address is missing" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(customer_house_number: nil, customer_street: nil)
    get job_proposal_url(jp)
    assert_response :success
    assert_match "Job Proposal ##{jp.id}", response.body
  end

  # --- sort ---

  test "default sort is created_at desc" do
    sign_in @admin
    get job_proposals_url
    assert_response :success
    # admin sees three fixture rows: created_at order is fixture-load order; assert presence
    assert_match "Alice", response.body
    assert_match "Bob", response.body
    assert_match "Carol", response.body
  end

  test "sort by proposal_value asc orders cheapest first" do
    sign_in @admin
    get job_proposals_url, params: { sort: "proposal_value", dir: "asc" }
    assert_response :success
    # Carol(5000) < Bob(8000) < Alice(12500): assert Carol appears before Alice
    assert_operator response.body.index("Carol"), :<, response.body.index("Alice")
  end

  test "sort by proposal_value desc orders priciest first" do
    sign_in @admin
    get job_proposals_url, params: { sort: "proposal_value", dir: "desc" }
    assert_response :success
    assert_operator response.body.index("Alice"), :<, response.body.index("Carol")
  end

  test "invalid sort columns silently fall back to default" do
    sign_in @admin
    get job_proposals_url, params: { sort: "customer_email" }
    assert_response :success
  end

  test "invalid sort direction silently falls back to desc" do
    sign_in @admin
    get job_proposals_url, params: { sort: "proposal_value", dir: "sideways" }
    assert_response :success
    assert_operator response.body.index("Alice"), :<, response.body.index("Carol")
  end

  test "sortable header renders the up arrow when active asc" do
    sign_in @admin
    get job_proposals_url, params: { sort: "proposal_value", dir: "asc" }
    assert_match "Proposal value", response.body
    assert_match "↑", response.body
  end

  test "sortable header renders the down arrow when active desc" do
    sign_in @admin
    get job_proposals_url, params: { sort: "created_at", dir: "desc" }
    assert_match "↓", response.body
  end

  test "sortable header renders the bidirectional icon for inactive columns" do
    sign_in @admin
    get job_proposals_url, params: { sort: "created_at", dir: "desc" }
    # Proposal value is not the active column, so it should show the bidir icon
    assert_match "↕", response.body
  end

  # --- search ---

  test "search filters by customer first name" do
    sign_in @admin
    get job_proposals_url, params: { q: "Alic" }
    assert_response :success
    assert_match "Alice", response.body
    assert_no_match "Bob", response.body
    assert_no_match "Carol", response.body
  end

  test "search is case-insensitive" do
    sign_in @admin
    get job_proposals_url, params: { q: "alice" }
    assert_response :success
    assert_match "Alice", response.body
  end

  test "search across address fields" do
    sign_in @admin
    jp = job_proposals(:in_users_org)
    jp.update!(customer_city: "Madison")
    get job_proposals_url, params: { q: "Madison" }
    assert_match "Alice", response.body
  end

  test "search uses parameterized SQL (no injection)" do
    sign_in @admin
    get job_proposals_url, params: { q: "'; DROP TABLE job_proposals; --" }
    assert_response :success
  end

  test "search preserves filters across submits via query params" do
    sign_in @admin
    get job_proposals_url, params: { q: "alice", status: "new" }
    assert_response :success
    assert_match "Alice", response.body
  end

  test "filter form preserves the active sort via hidden fields" do
    sign_in @admin
    get job_proposals_url, params: { sort: "proposal_value", dir: "asc" }
    assert_select "input[type=hidden][name=sort][value=?]", "proposal_value"
    assert_select "input[type=hidden][name=dir][value=?]", "asc"
  end

  # --- edit / update ---

  test "edit redirects to sign-in when not signed in" do
    get edit_job_proposal_url(job_proposals(:in_users_org))
    assert_redirected_to new_user_session_path
  end

  test "edit returns 404 for a proposal outside the user's scope" do
    sign_in @user
    get edit_job_proposal_url(job_proposals(:other_tenant))
    assert_response :not_found
  end

  test "edit renders the form with editable fields when no campaign is in flight" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    get edit_job_proposal_url(jp)
    assert_response :success
    assert_select "form[action=?][method=post]", job_proposal_path(jp)
    assert_select "input[name='job_proposal[customer_first_name]']:not([disabled])"
    assert_select "select[name='job_proposal[scenario_id]']:not([disabled])"
    assert_select "input[type=submit][value=Save]"
    assert_no_match(/in process/i, response.body)
  end

  test "edit renders read-only with a warning when a campaign instance exists" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active)
    get edit_job_proposal_url(jp)
    assert_response :success
    assert_match(/in process/i, response.body)
    assert_select "input[name='job_proposal[customer_first_name]'][disabled]"
    assert_select "input[type=submit][value=Save]", count: 0
  end

  test "update redirects to sign-in when not signed in" do
    patch job_proposal_url(job_proposals(:in_users_org)), params: { job_proposal: { customer_first_name: "X" } }
    assert_redirected_to new_user_session_path
  end

  test "update returns 404 for a proposal outside the user's scope" do
    sign_in @user
    patch job_proposal_url(job_proposals(:other_tenant)),
          params: { job_proposal: { customer_first_name: "X" } }
    assert_response :not_found
  end

  test "update saves editable fields and launches a campaign when scenario is set" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    other_owner = User.create!(email: "assistant@example.com", password: "Password1", tenant: jp.tenant)
    OrganizationalMember.create!(user: other_owner, organization: jp.organization, role: "member")

    assert_difference "CampaignInstance.count", 1 do
      assert_difference "CampaignStepInstance.count", 2 do  # approved_campaign has 2 steps
        patch job_proposal_url(jp), params: { job_proposal: {
          customer_first_name: "Edited",
          customer_email: "edited@example.com",
          customer_house_number: "100",
          customer_street: "Test Street",
          loss_reason: "Price",
          loss_notes: "Customer chose competitor.",
          internal_reference: "REF-123",
          owner_id: other_owner.id,
          job_type_id: job_types(:one).id,
          scenario_id: scenarios(:sewage_backup).id,
          proposal_value: 13_500.50
        } }
      end
    end

    assert_redirected_to job_proposal_path(jp)
    assert_match(/Campaign launched/i, flash[:notice])

    jp.reload
    assert_equal "Edited", jp.customer_first_name
    assert_equal "edited@example.com", jp.customer_email
    assert_equal "Price", jp.loss_reason
    assert_equal "Customer chose competitor.", jp.loss_notes
    assert_equal "REF-123", jp.internal_reference
    assert_equal other_owner, jp.owner
    assert_equal scenarios(:sewage_backup), jp.scenario
    assert_equal 13_500.50, jp.proposal_value.to_f

    instance = jp.campaign_instances.first
    assert_equal campaigns(:approved_campaign), instance.campaign
    assert instance.status_active?
    instance.step_instances.each do |si|
      assert si.email_delivery_status_pending?
      assert_nil si.final_subject
      assert_nil si.final_body
      assert_not_nil si.planned_delivery_at
    end
  end

  test "update without a scenario saves but does not launch — flash lists the gaps" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    assert_no_difference "CampaignInstance.count" do
      patch job_proposal_url(jp), params: { job_proposal: { customer_first_name: "Edited" } }
    end
    assert_redirected_to job_proposal_path(jp)
    assert_match(/missing/i, flash[:notice])
    assert_match(/scenario_id/, flash[:notice])
    assert_equal "Edited", jp.reload.customer_first_name
  end

  test "update is idempotent — does not create a second campaign instance" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(scenario: scenarios(:sewage_backup))
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active)

    assert_no_difference "CampaignInstance.count" do
      patch job_proposal_url(jp), params: { job_proposal: { customer_first_name: "Edited" } }
    end
    # Locked path: rejected with 422, original value unchanged.
    assert_response :unprocessable_content
    assert_equal "Alice", jp.reload.customer_first_name
  end

  test "update is rejected when a campaign is in flight" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active)

    patch job_proposal_url(jp), params: { job_proposal: { customer_first_name: "ShouldNotSave" } }
    assert_response :unprocessable_content
    assert_match(/in flight/i, response.body)
    assert_equal "Alice", jp.reload.customer_first_name
  end

  # --- resume ---

  test "resume redirects to sign-in when not signed in" do
    patch resume_job_proposal_url(job_proposals(:in_users_org))
    assert_redirected_to new_user_session_path
  end

  test "resume returns 404 for a proposal outside the user's scope" do
    sign_in @user
    patch resume_job_proposal_url(job_proposals(:other_tenant))
    assert_response :not_found
  end

  test "resume flips the paused instance back to active and clears the overlay" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "in_campaign", status_overlay: "paused")
    instance = CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :paused)

    patch resume_job_proposal_url(jp)
    assert_redirected_to job_proposals_path
    assert_match(/Campaign resumed/i, flash[:notice])

    assert instance.reload.status_active?
    assert_nil jp.reload.status_overlay
  end

  test "resume is a no-op alert when no campaign is paused" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active)

    patch resume_job_proposal_url(jp)
    assert_redirected_to job_proposals_path
    assert_match(/isn't paused/i, flash[:alert])
  end

  # --- launch_campaign (manual relaunch from the show page) ---------------

  test "launch_campaign redirects to sign-in when not signed in" do
    post launch_campaign_job_proposal_url(job_proposals(:in_users_org))
    assert_redirected_to new_user_session_path
  end

  # Helper: bring a proposal up to the readiness bar so launch isn't blocked
  # by missing customer fields. Tests that exercise the not_ready branch
  # explicitly blank specific fields after calling this.
  def make_ready(jp, scenario: scenarios(:sewage_backup))
    jp.update!(
      scenario:              scenario,
      customer_email:        "alice@example.com",
      customer_first_name:   "Alice",
      customer_house_number: "123",
      customer_street:       "Oak Ridge"
    )
    jp
  end

  test "launch_campaign creates a CampaignInstance when scenario + campaign are in place and proposal is ready" do
    sign_in @user
    jp = make_ready(job_proposals(:in_users_org))

    assert_difference "CampaignInstance.count", 1 do
      post launch_campaign_job_proposal_url(jp)
    end
    assert_redirected_to job_proposal_path(jp)
    assert_match(/Campaign launched/i, flash[:notice].to_s)
  end

  test "launch_campaign reports already-running on a second click" do
    sign_in @user
    jp = make_ready(job_proposals(:in_users_org))
    CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active)

    assert_no_difference "CampaignInstance.count" do
      post launch_campaign_job_proposal_url(jp)
    end
    assert_match(/already running/i, flash[:notice].to_s)
  end

  test "launch_campaign refuses and lists missing fields when proposal isn't ready" do
    sign_in @user
    jp = make_ready(job_proposals(:in_users_org))
    jp.update!(customer_email: nil, customer_first_name: nil)

    assert_no_difference "CampaignInstance.count" do
      post launch_campaign_job_proposal_url(jp)
    end
    assert_redirected_to edit_job_proposal_path(jp)
    assert_match(/missing/i, flash[:alert].to_s)
    assert_match(/customer_email/, flash[:alert].to_s)
    assert_match(/customer_first_name/, flash[:alert].to_s)
  end

  test "launch_campaign refuses when scenario has no attached campaign" do
    sign_in @user
    jp = make_ready(job_proposals(:in_users_org), scenario: scenarios(:clean_water)) # fixture: campaign: nil

    assert_no_difference "CampaignInstance.count" do
      post launch_campaign_job_proposal_url(jp)
    end
    assert_match(/no campaign attached/i, flash[:alert].to_s)
  end

  # --- CTA column on the index ---

  test "index renders View job CTA for proposals not in a campaign" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: nil, status_overlay: nil)
    get job_proposals_url
    assert_select "a[href=?]", job_proposal_path(jp), text: /View job/
  end

  test "index renders Resume campaign CTA for paused in-flight proposals" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "in_campaign", status_overlay: "paused")
    get job_proposals_url
    assert_select "form[action=?]", resume_job_proposal_path(jp) do
      assert_select "input[name=_method][value=patch]", true
      assert_select "button", text: /Resume campaign/
    end
  end

  test "index renders Fix delivery issue CTA pointing at the edit page" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "in_campaign", status_overlay: "delivery_issue")
    get job_proposals_url
    assert_select "a[href=?]", edit_job_proposal_path(jp), text: /Fix delivery issue/
  end

  test "index renders Open in Gmail CTA targeting a new tab" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "in_campaign", status_overlay: "customer_waiting")
    instance = CampaignInstance.create!(host: jp, campaign: campaigns(:approved_campaign), status: :active)
    CampaignStepInstance.create!(
      campaign_instance: instance, campaign_step: campaign_steps(:approved_step_one),
      gmail_thread_id: "THREAD-XYZ", email_delivery_status: :sent
    )

    get job_proposals_url
    assert_select "a[target=_blank][href*=?]", "THREAD-XYZ", text: /Open in Gmail/
  end

  # --- mark_won / mark_lost -----------------------------------------------

  test "mark_won redirects to sign-in when not signed in" do
    patch mark_won_job_proposal_url(job_proposals(:in_users_org))
    assert_redirected_to new_user_session_path
  end

  test "mark_won 404s for a proposal outside the user's scope" do
    sign_in @user
    patch mark_won_job_proposal_url(job_proposals(:other_tenant))
    assert_response :not_found
  end

  test "mark_won flips pipeline_stage to won and redirects with notice" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    patch mark_won_job_proposal_url(jp)
    assert_redirected_to job_proposal_path(jp)
    assert_match(/won/i, flash[:notice])
    assert_equal "won", jp.reload.pipeline_stage
  end

  test "mark_lost redirects to sign-in when not signed in" do
    patch mark_lost_job_proposal_url(job_proposals(:in_users_org))
    assert_redirected_to new_user_session_path
  end

  test "mark_lost 404s for a proposal outside the user's scope" do
    sign_in @user
    patch mark_lost_job_proposal_url(job_proposals(:other_tenant))
    assert_response :not_found
  end

  test "mark_lost flips pipeline_stage to lost and redirects with notice" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    patch mark_lost_job_proposal_url(jp)
    assert_redirected_to job_proposal_path(jp)
    assert_match(/lost/i, flash[:notice])
    assert_equal "lost", jp.reload.pipeline_stage
  end

  test "show page renders Mark Won and Mark Lost buttons when pipeline_stage is not won/lost" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: nil)
    get job_proposal_url(jp)
    assert_response :success
    assert_select "form[action=?] button", mark_won_job_proposal_path(jp), text: /Mark Won/
    assert_select "form[action=?] button", mark_lost_job_proposal_path(jp), text: /Mark Lost/
  end

  test "show page hides Mark Won/Lost when pipeline_stage is already won" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "won")
    get job_proposal_url(jp)
    assert_response :success
    assert_select "form[action=?]", mark_won_job_proposal_path(jp), count: 0
    assert_select "form[action=?]", mark_lost_job_proposal_path(jp), count: 0
  end

  # --- revert_pipeline_stage ----------------------------------------------

  test "revert_pipeline_stage redirects to sign-in when not signed in" do
    patch revert_pipeline_stage_job_proposal_url(job_proposals(:in_users_org))
    assert_redirected_to new_user_session_path
  end

  test "revert_pipeline_stage 404s for a proposal outside the user's scope" do
    sign_in @user
    patch revert_pipeline_stage_job_proposal_url(job_proposals(:other_tenant))
    assert_response :not_found
  end

  test "revert_pipeline_stage flips won back to in_campaign" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "won")
    patch revert_pipeline_stage_job_proposal_url(jp)
    assert_redirected_to job_proposal_path(jp)
    assert_match(/in campaign/i, flash[:notice])
    assert_equal "in_campaign", jp.reload.pipeline_stage
  end

  test "revert_pipeline_stage flips lost back to in_campaign" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "lost")
    patch revert_pipeline_stage_job_proposal_url(jp)
    assert_equal "in_campaign", jp.reload.pipeline_stage
  end

  test "show page renders Revert button when pipeline_stage is won" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "won")
    get job_proposal_url(jp)
    assert_response :success
    assert_select "form[action=?] button", revert_pipeline_stage_job_proposal_path(jp), text: /Revert/
    assert_select "form[action=?]", mark_won_job_proposal_path(jp), count: 0
  end

  test "show page renders Revert button when pipeline_stage is lost" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: "lost")
    get job_proposal_url(jp)
    assert_response :success
    assert_select "form[action=?] button", revert_pipeline_stage_job_proposal_path(jp), text: /Revert/
  end

  test "show page hides Revert button when pipeline_stage is not won/lost" do
    sign_in @user
    jp = job_proposals(:in_users_org)
    jp.update!(pipeline_stage: nil)
    get job_proposal_url(jp)
    assert_response :success
    assert_select "form[action=?]", revert_pipeline_stage_job_proposal_path(jp), count: 0
  end
end
