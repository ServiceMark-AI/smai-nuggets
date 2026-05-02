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
    assert_redirected_to job_proposals_path

    proposal = JobProposal.order(:created_at).last
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
end
