require "test_helper"

class CampaignStepInstancesControllerTest < ActionDispatch::IntegrationTest
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
    @campaign  = campaigns(:approved_campaign)
    @step      = campaign_steps(:approved_step_one)
    @step.update!(
      template_subject: "Hi {customer_first_name} about {property_address_short}",
      template_body:    "From {originator_name} at {company_name}. Total: {proposal_value}."
    )
    @instance      = CampaignInstance.create!(host: @proposal, campaign: @campaign, status: :active)
    @step_instance = CampaignStepInstance.create!(
      campaign_instance: @instance,
      campaign_step: @step,
      planned_delivery_at: 1.day.from_now,
      email_delivery_status: :pending
    )
  end

  test "redirects to sign-in when not signed in" do
    get job_proposal_step_instance_url(@proposal, @step_instance)
    assert_redirected_to new_user_session_path
  end

  test "renders the draft preview with the proposal's data substituted in for pending steps" do
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)

    assert_response :success
    assert_match "Draft preview", response.body
    assert_match "Hi Alice about 100 Oak Ridge", response.body
    assert_match "$12,400.00", response.body
    assert_match "alice@example.com", response.body  # the To line
  end

  test "renders final_subject and final_body verbatim for sent steps (snapshot of what shipped)" do
    @step_instance.update!(
      email_delivery_status: :sent,
      final_subject: "Frozen subject as-shipped",
      final_body:    "Frozen body as-shipped — no live re-render."
    )

    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)

    assert_response :success
    assert_match "What was sent", response.body
    assert_match "Frozen subject as-shipped", response.body
    assert_match "Frozen body as-shipped", response.body
  end

  test "From line shows the connected mailbox email when one is connected" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)
    assert_match "noreply@app.example.com", response.body
  end

  test "From line warns when no mailbox is connected" do
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)
    assert_match(/No application mailbox connected/i, response.body)
  end

  test "To line warns when customer_email is blank" do
    @proposal.update!(customer_email: nil)
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)
    assert_match(/Customer email is blank/i, response.body)
  end

  test "404 when the step instance belongs to a different proposal" do
    other_proposal = job_proposals(:other_tenant)
    sign_in users(:admin) # bypass tenant scoping for the proposal lookup
    get job_proposal_step_instance_url(other_proposal, @step_instance)
    assert_response :not_found
  end

  test "404 when the parent proposal isn't accessible to the user" do
    sign_in @other_tenant_user
    get job_proposal_step_instance_url(@proposal, @step_instance)
    assert_response :not_found
  end

  test "draft preview goes through MailGenerator.render — substitutes proposal data byte-for-byte" do
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)

    # Subject + body are rendered with the live proposal's data, NOT
    # the template placeholders, NOT sample values. This is the same
    # output MailGenerator.render produces for the actual send.
    refute_match "{customer_first_name}", response.body, "preview should not show raw merge fields"
    assert_match "Hi Alice about 100 Oak Ridge", response.body
  end

  test "preview surfaces a warning banner when the template has unresolved merge fields" do
    @step.update!(template_body: "Hi {customer_first_name}, your contact for {totally_unknown_token} is here.")
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)

    assert_response :success
    assert_match(/Template has unresolved merge fields/i, response.body)
    assert_match "totally_unknown_token", response.body
    # Page still renders the partial preview — no 500.
    assert_match "Hi Alice", response.body
  end

  test "Gmail thread link appears when the step instance has a thread id" do
    @step_instance.update!(email_delivery_status: :sent, gmail_thread_id: "THREAD-XYZ", final_subject: "x", final_body: "y")
    sign_in @user
    get job_proposal_step_instance_url(@proposal, @step_instance)
    assert_match "THREAD-XYZ", response.body
    assert_match "mail.google.com", response.body
  end
end
