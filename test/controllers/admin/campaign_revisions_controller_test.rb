require "test_helper"

class Admin::CampaignRevisionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin     = users(:admin)
    @non_admin = users(:one)
    @campaign  = campaigns(:approved_campaign)
    @active    = @campaign.active_revision
  end

  # --- show -----------------------------------------------------------

  test "show redirects to sign-in when not authenticated" do
    get admin_campaign_revision_url(@campaign, @active)
    assert_redirected_to new_user_session_path
  end

  test "non-admin cannot see a revision" do
    sign_in @non_admin
    get admin_campaign_revision_url(@campaign, @active)
    assert_redirected_to root_path
  end

  test "show on an active revision lists steps without edit affordances" do
    sign_in @admin
    get admin_campaign_revision_url(@campaign, @active)
    assert_response :success
    assert_match @active.steps.first.template_subject, response.body
    assert_no_match(/Add step/, response.body)
    assert_select "form[action=?]", approve_admin_campaign_revision_path(@campaign, @active), count: 0
  end

  test "show on a drafting revision exposes Add step and Approve revision" do
    sign_in @admin
    draft = CampaignRevision.spawn_draft_from_active(campaign: @campaign, user: @admin)
    get admin_campaign_revision_url(@campaign, draft)
    assert_response :success
    assert_match(/Add step/, response.body)
    assert_select "form[action=?] button", approve_admin_campaign_revision_path(@campaign, draft), text: "Approve revision"
  end

  # --- create ---------------------------------------------------------

  test "non-admin cannot create a draft revision" do
    sign_in @non_admin
    assert_no_difference -> { @campaign.revisions.count } do
      post admin_campaign_revisions_url(@campaign)
    end
    assert_redirected_to root_path
  end

  test "admin create spawns a draft, copies steps, and redirects to the revision page" do
    sign_in @admin
    expected_steps = @active.steps.count
    assert_difference -> { @campaign.revisions.count }, 1 do
      assert_difference -> { CampaignStep.count }, expected_steps do
        post admin_campaign_revisions_url(@campaign)
      end
    end
    draft = @campaign.revisions.order(:revision_number).last
    assert draft.status_drafting?
    assert_equal expected_steps, draft.steps.count
    assert_redirected_to admin_campaign_revision_path(@campaign, draft)
  end

  # --- approve --------------------------------------------------------

  test "approve flips a draft to active and retires the previous active" do
    sign_in @admin
    draft = CampaignRevision.spawn_draft_from_active(campaign: @campaign, user: @admin)

    patch approve_admin_campaign_revision_url(@campaign, draft)
    assert_redirected_to admin_campaign_revision_path(@campaign, draft)

    @active.reload
    draft.reload
    assert_equal "active",  draft.status
    assert_equal "retired", @active.status
    assert_equal @admin,    draft.approved_by_user
    assert_not_nil draft.approved_at
  end

  test "approve refuses on an already-active revision" do
    sign_in @admin
    patch approve_admin_campaign_revision_url(@campaign, @active)
    assert_redirected_to admin_campaign_revision_path(@campaign, @active)
    assert_equal "active", @active.reload.status
  end

  test "non-admin cannot approve" do
    sign_in @non_admin
    draft = CampaignRevision.spawn_draft_from_active(campaign: @campaign, user: @admin)
    patch approve_admin_campaign_revision_url(@campaign, draft)
    assert_redirected_to root_path
    assert_equal "drafting", draft.reload.status
  end
end
