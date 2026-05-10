require "test_helper"

class Admin::TrashControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user  = users(:one)
    @campaign = campaigns(:approved_campaign)
    @proposal = job_proposals(:in_users_org)
  end

  test "non-admin is redirected away" do
    sign_in @user
    get admin_trash_url
    assert_redirected_to root_path
  end

  test "admin sees discarded campaigns and job proposals" do
    @campaign.discard
    @proposal.discard

    sign_in @admin
    get admin_trash_url
    assert_response :success
    assert_match @campaign.name, response.body
    assert_match (@proposal.short_address || "Job ##{@proposal.id}"), response.body
    # Restore buttons for both
    assert_select "form[action=?]", restore_admin_campaign_path(@campaign)
    assert_select "form[action=?]", restore_job_proposal_path(@proposal)
  end

  test "empty state when nothing is discarded" do
    sign_in @admin
    get admin_trash_url
    assert_response :success
    assert_match "No discarded campaigns.", response.body
    assert_match "No discarded job proposals.", response.body
  end
end
