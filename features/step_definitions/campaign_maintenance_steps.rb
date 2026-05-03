# Steps for features/campaign_maintenance.feature.

Given("my tenant has at least one job proposal") do
  org = @current_user.organizations.first
  JobProposal.find_or_create_by!(
    tenant: @current_user.tenant,
    organization: org,
    owner: @current_user,
    created_by_user: @current_user,
    customer_first_name: "Demo",
    customer_last_name: "Customer"
  )
end

Given("a proposal whose campaign instance is paused") do
  org = @current_user.organizations.first
  scenario = Scenario.first || begin
    job_type = JobType.find_or_create_by!(name: "Water", type_code: "water")
    Scenario.create!(job_type: job_type, code: "test_paused", short_name: "Paused")
  end
  campaign = scenario.campaign || Campaign.create!(name: "Cuke Pause", status: :approved, attributed_to: scenario)
  campaign.steps.find_or_create_by!(sequence_number: 1) do |s|
    s.template_subject = "Hi"
    s.template_body = "Body"
    s.offset_min = 0
  end
  scenario.update!(campaign: campaign) if scenario.campaign_id.nil?

  @paused_proposal = JobProposal.create!(
    tenant: @current_user.tenant,
    organization: org,
    owner: @current_user,
    created_by_user: @current_user,
    customer_first_name: "Pause",
    customer_last_name: "Test",
    pipeline_stage: "in_campaign",
    status_overlay: "paused"
  )
  @paused_instance = CampaignInstance.create!(host: @paused_proposal, campaign: campaign, status: :paused)
end

Given("a proposal whose latest state is {string}") do |overlay|
  org = @current_user.organizations.first
  campaign = Campaign.where(status: :approved).first || Campaign.create!(name: "Cuke Approved", status: :approved)
  step = campaign.steps.first || campaign.steps.create!(sequence_number: 1, template_subject: "S", template_body: "B", offset_min: 0)

  @gmail_proposal = JobProposal.create!(
    tenant: @current_user.tenant,
    organization: org,
    owner: @current_user,
    created_by_user: @current_user,
    customer_first_name: "Reply",
    customer_last_name: "Test",
    pipeline_stage: "in_campaign",
    status_overlay: overlay
  )
  instance = CampaignInstance.create!(host: @gmail_proposal, campaign: campaign, status: :stopped_on_reply)
  CampaignStepInstance.create!(
    campaign_instance: instance,
    campaign_step: step,
    email_delivery_status: :sent,
    gmail_thread_id: "CUKE-thread-1",
    planned_delivery_at: 1.hour.ago
  )
end

When("I open Job Proposals") do
  visit job_proposals_path
end

When("I click {string} on the proposal's row") do |label|
  unless page.has_css?("table tbody")
    raise "Expected the proposals index to render the table; got body excerpt: #{page.body[0,500]}"
  end
  within("table tbody") do
    click_on label
  end
end

Then("I should see the proposal listed with an Action button") do
  expect(page).to have_css("table thead th", text: "Action")
  expect(page).to have_css("table tbody tr", minimum: 1)
end

Then("the campaign instance should flip back to active") do
  expect(@paused_instance.reload).to be_status_active
end

Then("the proposal's status overlay should clear") do
  expect(@paused_proposal.reload.status_overlay).to be_nil
end

Then("the proposal's Action button should read {string}") do |label|
  within("table tbody") do
    expect(page).to have_link(text: /#{Regexp.escape(label)}/)
  end
end

Then("it should target a new tab pointing at the Gmail thread URL") do
  link = find("table tbody a", text: /Open in Gmail/)
  expect(link[:target]).to eq("_blank")
  expect(link[:href]).to include("mail.google.com")
  expect(link[:href]).to include("CUKE-thread-1")
end
