require "test_helper"

class CampaignStepsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @campaign = campaigns(:approved_campaign)  # has steps with sequence_number 1, 2
    @empty_campaign = campaigns(:new_campaign) # no steps
  end

  test "redirects to sign-in when not signed in" do
    get new_campaign_step_url(@campaign)
    assert_redirected_to new_user_session_path
  end

  test "non-admin cannot reach the new form" do
    sign_in @non_admin
    get new_campaign_step_url(@campaign)
    assert_redirected_to root_path
  end

  test "admin sees the new form with the campaign pre-bound and a default sequence number" do
    sign_in @admin
    get new_campaign_step_url(@campaign)
    assert_response :success
    assert_match @campaign.name, response.body
    # Existing fixtures: sequence 1 + 2, so default for new should be 3
    assert_select "input[name='campaign_step[sequence_number]'][value='3']"
    assert_select "input[name='campaign_step[offset_min]'][value='0']"
  end

  test "admin sees default sequence_number 1 on a campaign with no steps" do
    sign_in @admin
    get new_campaign_step_url(@empty_campaign)
    assert_response :success
    assert_select "input[name='campaign_step[sequence_number]'][value='1']"
  end

  test "admin create with valid params adds a step to the campaign" do
    sign_in @admin
    assert_difference -> { @campaign.steps.count }, 1 do
      post campaign_steps_url(@campaign), params: {
        campaign_step: {
          sequence_number: 3,
          offset_min: 60,
          template_subject: "Third touch",
          template_body: "Body three."
        }
      }
    end
    assert_redirected_to campaign_path(@campaign)
    follow_redirect!
    assert_match "Step added.", response.body
    assert_match "Third touch", response.body
  end

  test "admin create with invalid params re-renders the form" do
    sign_in @admin
    assert_no_difference -> { @campaign.steps.count } do
      post campaign_steps_url(@campaign), params: {
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
      post campaign_steps_url(@campaign), params: {
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
      post campaign_steps_url(@campaign), params: {
        campaign_step: { sequence_number: 99, offset_min: 0, template_subject: "Sneaky", template_body: "x" }
      }
    end
    assert_redirected_to root_path
  end
end
