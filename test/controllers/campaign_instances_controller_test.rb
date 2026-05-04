require "test_helper"

class CampaignInstancesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_tenant_user = users(:two)
    @proposal = job_proposals(:in_users_org)
    @proposal.update!(
      customer_email: "alice@example.com",
      customer_first_name: "Alice",
      customer_last_name: "Anderson",
      customer_house_number: "100",
      customer_street: "Oak Ridge",
      customer_city: "Plano",
      customer_state: "TX",
      customer_zip: "75024",
      proposal_value: 12_400
    )
    @campaign = campaigns(:approved_campaign)
    @step_one = campaign_steps(:approved_step_one)
    @step_one.update!(
      template_subject: "Hi {customer_first_name} about {property_address_short}",
      template_body:    "Step one body for {customer_first_name}."
    )
    @step_two = campaign_steps(:approved_step_two)
    @step_two.update!(
      template_subject: "Following up on {property_address_short}",
      template_body:    "Step two body — proposal value {proposal_value}."
    )
    @instance = CampaignInstance.create!(host: @proposal, campaign: @campaign, status: :active)
    @si_one = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step_one,
      planned_delivery_at: 1.day.from_now,
      email_delivery_status: :pending
    )
    @si_two = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step_two,
      planned_delivery_at: 3.days.from_now,
      email_delivery_status: :pending
    )
  end

  test "redirects to sign-in when not signed in" do
    get job_proposal_campaign_instance_url(@proposal, @instance)
    assert_redirected_to new_user_session_path
  end

  test "renders every step's email fully populated through the template engine" do
    sign_in @user
    get job_proposal_campaign_instance_url(@proposal, @instance)

    assert_response :success
    assert_match @campaign.name, response.body
    # Both steps' subjects are rendered with this proposal's live data.
    assert_match "Hi Alice about 100 Oak Ridge", response.body
    assert_match "Following up on 100 Oak Ridge", response.body
    # Both steps' bodies render too.
    assert_match "Step one body for Alice", response.body
    assert_match "$12,400.00", response.body
    # No raw merge tokens leaked.
    refute_match "{customer_first_name}", response.body
    refute_match "{property_address_short}", response.body
  end

  test "renders final_subject and final_body for sent steps (snapshot of what shipped)" do
    @si_one.update!(
      email_delivery_status: :sent,
      final_subject: "Frozen subject as-shipped",
      final_body:    "Frozen body as-shipped"
    )

    sign_in @user
    get job_proposal_campaign_instance_url(@proposal, @instance)

    assert_response :success
    assert_match "Frozen subject as-shipped", response.body
    assert_match "Frozen body as-shipped", response.body
  end

  test "warning banner appears for steps with unresolved merge fields" do
    @step_two.update!(template_body: "Body with {totally_unknown_token}.")
    sign_in @user
    get job_proposal_campaign_instance_url(@proposal, @instance)
    assert_response :success
    assert_match(/Template has unresolved merge fields/i, response.body)
    assert_match "totally_unknown_token", response.body
  end

  test "404 when the instance belongs to a different proposal" do
    other_proposal = job_proposals(:other_tenant)
    sign_in users(:admin)
    get job_proposal_campaign_instance_url(other_proposal, @instance)
    assert_response :not_found
  end

  test "404 when the parent proposal is not accessible to the user" do
    sign_in @other_tenant_user
    get job_proposal_campaign_instance_url(@proposal, @instance)
    assert_response :not_found
  end

  test "admin sees a link to the campaign template" do
    sign_in users(:admin)
    get job_proposal_campaign_instance_url(@proposal, @instance)
    assert_response :success
    assert_match admin_campaign_path(@campaign), response.body
  end

  test "non-admin does not see the campaign template link" do
    sign_in @user
    get job_proposal_campaign_instance_url(@proposal, @instance)
    assert_response :success
    refute_match admin_campaign_path(@campaign), response.body
  end
end
