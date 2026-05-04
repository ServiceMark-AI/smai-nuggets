require "test_helper"

class Admin::CampaignStepsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @campaign = campaigns(:approved_campaign)  # has steps with sequence_number 1, 2
    @empty_campaign = campaigns(:draft_campaign) # no steps
  end

  test "redirects to sign-in when not signed in" do
    get new_admin_campaign_step_url(@campaign)
    assert_redirected_to new_user_session_path
  end

  test "non-admin cannot reach the new form" do
    sign_in @non_admin
    get new_admin_campaign_step_url(@campaign)
    assert_redirected_to root_path
  end

  test "admin sees the new form with the campaign pre-bound and a default sequence number" do
    sign_in @admin
    get new_admin_campaign_step_url(@campaign)
    assert_response :success
    assert_match @campaign.name, response.body
    # Existing fixtures: sequence 1 + 2, so default for new should be 3
    assert_select "input[name='campaign_step[sequence_number]'][value='3']"
    # Offset is now collected via days/hours/minutes triplets that compose
    # into offset_min on save; for a new step all three default to 0.
    assert_select "input[name='campaign_step[offset_days]'][value='0']"
    assert_select "input[name='campaign_step[offset_hours]'][value='0']"
    assert_select "input[name='campaign_step[offset_minutes]'][value='0']"
  end

  test "admin sees default sequence_number 1 on a campaign with no steps" do
    sign_in @admin
    get new_admin_campaign_step_url(@empty_campaign)
    assert_response :success
    assert_select "input[name='campaign_step[sequence_number]'][value='1']"
  end

  test "admin create with valid params adds a step to the campaign" do
    sign_in @admin
    assert_difference -> { @campaign.steps.count }, 1 do
      post admin_campaign_steps_url(@campaign), params: {
        campaign_step: {
          sequence_number: 3,
          offset_min: 60,
          template_subject: "Third touch",
          template_body: "Body three."
        }
      }
    end
    assert_redirected_to edit_admin_campaign_path(@campaign)
    follow_redirect!
    assert_match "Step added.", response.body
    assert_match "Third touch", response.body
  end

  test "admin create with invalid params re-renders the form" do
    sign_in @admin
    assert_no_difference -> { @campaign.steps.count } do
      post admin_campaign_steps_url(@campaign), params: {
        campaign_step: {
          sequence_number: nil,
          offset_min: nil,
          template_subject: "Bad",
          template_body: "Bad."
        }
      }
    end
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
  end

  test "admin create with a duplicate sequence_number is rejected" do
    sign_in @admin
    assert_no_difference -> { @campaign.steps.count } do
      post admin_campaign_steps_url(@campaign), params: {
        campaign_step: {
          sequence_number: 1,  # already taken on @campaign
          offset_min: 0,
          template_subject: "Dup",
          template_body: "Dup."
        }
      }
    end
    assert_response :unprocessable_content
    assert_match(/has already been taken/i, response.body)
  end

  test "non-admin cannot create a step" do
    sign_in @non_admin
    assert_no_difference -> { @campaign.steps.count } do
      post admin_campaign_steps_url(@campaign), params: {
        campaign_step: { sequence_number: 99, offset_min: 0, template_subject: "Sneaky", template_body: "x" }
      }
    end
    assert_redirected_to root_path
  end

  test "admin sees the edit form" do
    sign_in @admin
    step = @campaign.steps.first
    get edit_admin_campaign_step_url(@campaign, step)
    assert_response :success
    assert_select "input[name='campaign_step[template_subject]'][value=?]", step.template_subject
  end

  test "edit page shows a breadcrumb back to the campaign" do
    sign_in @admin
    step = @campaign.steps.first
    get edit_admin_campaign_step_url(@campaign, step)
    assert_response :success
    assert_select "nav[aria-label=breadcrumb] a[href=?]", admin_campaigns_path, text: "Campaigns"
    assert_select "nav[aria-label=breadcrumb] a[href=?]", admin_campaign_path(@campaign), text: @campaign.name
    assert_select "nav[aria-label=breadcrumb] li.active", text: "Edit Step"
  end

  test "admin update with valid params changes the step" do
    sign_in @admin
    step = @campaign.steps.first
    patch admin_campaign_step_url(@campaign, step), params: {
      campaign_step: { sequence_number: step.sequence_number, offset_min: 999, template_subject: "Changed", template_body: "Updated body" }
    }
    assert_redirected_to edit_admin_campaign_path(@campaign)
    step.reload
    assert_equal "Changed", step.template_subject
    assert_equal 999, step.offset_min
  end

  test "admin update with invalid params re-renders the form" do
    sign_in @admin
    step = @campaign.steps.first
    patch admin_campaign_step_url(@campaign, step), params: {
      campaign_step: { sequence_number: nil }
    }
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
  end

  test "admin destroy removes the step" do
    sign_in @admin
    step = @campaign.steps.first
    assert_difference -> { @campaign.steps.count }, -1 do
      delete admin_campaign_step_url(@campaign, step)
    end
    assert_redirected_to edit_admin_campaign_path(@campaign)
  end

  test "non-admin cannot edit, update, or destroy a step" do
    sign_in @non_admin
    step = @campaign.steps.first

    get edit_admin_campaign_step_url(@campaign, step)
    assert_redirected_to root_path

    patch admin_campaign_step_url(@campaign, step), params: { campaign_step: { template_subject: "Bad" } }
    assert_redirected_to root_path

    assert_no_difference -> { @campaign.steps.count } do
      delete admin_campaign_step_url(@campaign, step)
    end
    assert_redirected_to root_path
  end

  test "admin reorder swaps sequence numbers" do
    sign_in @admin
    s1 = @campaign.steps.find_by!(sequence_number: 1)
    s2 = @campaign.steps.find_by!(sequence_number: 2)

    patch reorder_admin_campaign_steps_url(@campaign), params: { ids: [s2.id, s1.id] }, as: :json
    assert_response :no_content

    assert_equal 1, s2.reload.sequence_number
    assert_equal 2, s1.reload.sequence_number
  end

  test "reorder rejects ids that don't belong to the campaign" do
    sign_in @admin
    other_step = campaign_steps(:approved_step_one)  # belongs to @campaign already
    foreign_id = 999_999

    patch reorder_admin_campaign_steps_url(@campaign), params: { ids: [other_step.id, foreign_id] }, as: :json
    assert_response :unprocessable_content
  end

  test "non-admin cannot reorder" do
    sign_in @non_admin
    s1 = @campaign.steps.find_by!(sequence_number: 1)
    s2 = @campaign.steps.find_by!(sequence_number: 2)

    patch reorder_admin_campaign_steps_url(@campaign), params: { ids: [s2.id, s1.id] }, as: :json
    assert_redirected_to root_path

    assert_equal 1, s1.reload.sequence_number
    assert_equal 2, s2.reload.sequence_number
  end
end
