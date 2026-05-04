require "test_helper"

class Admin::JobProposalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @org = organizations(:one)
    @owner = users(:one)
  end

  test "redirects to sign-in when not signed in" do
    get new_admin_job_proposal_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin cannot reach the new form" do
    sign_in @non_admin
    get new_admin_job_proposal_url
    assert_redirected_to root_path
    follow_redirect!
    assert_match(/not authorized/i, response.body)
  end

  test "admin sees the new form" do
    sign_in @admin
    get new_admin_job_proposal_url
    assert_response :success
    assert_select "form select[name='job_proposal[organization_id]']"
    assert_select "form input[name='job_proposal[customer_first_name]']"
    assert_select "form select[name='job_proposal[owner_id]']"
  end

  test "admin create with valid params persists, infers tenant, sets created_by" do
    sign_in @admin
    assert_difference "JobProposal.count", 1 do
      post admin_job_proposals_url, params: {
        job_proposal: {
          organization_id: @org.id,
          owner_id: @owner.id,
          customer_first_name: "Manual",
          customer_last_name: "Entry",
          customer_email: "manual@example.com",
          customer_house_number: "10",
          customer_street: "Hand St"
        }
      }
    end
    jp = JobProposal.order(:id).last
    assert_redirected_to job_proposal_path(jp)
    assert_equal @org, jp.organization
    assert_equal @org.tenant, jp.tenant
    assert_equal @admin, jp.created_by_user
    assert_equal @owner, jp.owner
    assert_equal "Manual", jp.customer_first_name
  end

  test "admin create re-renders the form when validations fail" do
    sign_in @admin
    assert_no_difference "JobProposal.count" do
      post admin_job_proposals_url, params: {
        job_proposal: {
          organization_id: "",
          owner_id: ""
        }
      }
    end
    assert_response :unprocessable_content
    assert_match(/Please fix/i, response.body)
  end

  test "non-admin cannot create" do
    sign_in @non_admin
    assert_no_difference "JobProposal.count" do
      post admin_job_proposals_url, params: {
        job_proposal: { organization_id: @org.id, owner_id: @owner.id }
      }
    end
    assert_redirected_to root_path
  end
end
