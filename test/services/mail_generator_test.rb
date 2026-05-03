require "test_helper"

class MailGeneratorTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @organization = organizations(:two) # has no fixture-side location
    @location = locations(:ne_dallas)   # belongs to organizations(:one)
    @org_with_location = organizations(:one)

    @originator = User.create!(
      email: "jeff@servpro-nedallas.example.com",
      password: "password123",
      first_name: "Jeff",
      last_name: "Stone",
      phone_number: "(214) 555-5555",
      tenant: @tenant,
      is_pending: false
    )

    @job = JobProposal.create!(
      tenant: @tenant,
      organization: @org_with_location,
      owner: @originator,
      created_by_user: @originator,
      customer_first_name: "Sarah",
      customer_last_name: "Mitchell",
      customer_house_number: "1247",
      customer_street: "Oak Ridge Drive",
      customer_city: "Plano",
      customer_state: "TX",
      customer_zip: "75024",
      job_description: "burst pipe in master bath",
      proposal_value: 12_400.00
    )
  end

  def step(subject:, body:)
    CampaignStep.new(
      campaign: campaigns(:approved_campaign),
      sequence_number: 99,
      offset_min: 0,
      template_subject: subject,
      template_body: body
    )
  end

  test "renders a template with no merge fields unchanged" do
    out = MailGenerator.render(
      campaign_step: step(subject: "Hello", body: "Body without tokens."),
      job_proposal: @job
    )
    assert_equal "Hello", out.subject
    assert_equal "Body without tokens.", out.body
  end

  test "substitutes customer name fields" do
    out = MailGenerator.render(
      campaign_step: step(subject: "{customer_first_name}", body: "Hi {customer_name}, ..."),
      job_proposal: @job
    )
    assert_equal "Sarah", out.subject
    assert_equal "Hi Sarah Mitchell, ...", out.body
  end

  test "substitutes property address fields" do
    out = MailGenerator.render(
      campaign_step: step(subject: "About {property_address_short}", body: "At {property_address}."),
      job_proposal: @job
    )
    assert_equal "About 1247 Oak Ridge Drive", out.subject
    assert_equal "At 1247 Oak Ridge Drive, Plano, TX, 75024.", out.body
  end

  test "substitutes proposal_value as currency" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Estimate: {proposal_value}"),
      job_proposal: @job
    )
    assert_equal "Estimate: $12,400.00", out.body
  end

  test "substitutes originator fields from job owner" do
    out = MailGenerator.render(
      campaign_step: step(subject: "From {originator_first_name}", body: "—{originator_name}\n{originator_phone}"),
      job_proposal: @job
    )
    assert_equal "From Jeff", out.subject
    assert_equal "—Jeff Stone\n(214) 555-5555", out.body
  end

  test "substitutes location fields when the organization has a location" do
    out = MailGenerator.render(
      campaign_step: step(subject: "From {location_name}", body: "{location_address}\n{state}\n{company_phone}"),
      job_proposal: @job
    )
    assert_equal "From NE Dallas", out.subject
    assert_equal "10280 Miller Rd, Dallas, TX, 75238\nTexas\n(214) 343-3973", out.body
  end

  test "company_name renders the organization name" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "From {company_name}"),
      job_proposal: @job
    )
    assert_equal "From #{@org_with_location.name}", out.body
  end

  test "missing optional values substitute empty string without raising" do
    @originator.update!(phone_number: nil)
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Cell: {originator_phone}"),
      job_proposal: @job
    )
    assert_equal "Cell: ", out.body
  end

  test "missing location yields empty location-derived fields" do
    job_no_loc = JobProposal.create!(
      tenant: @tenant,
      organization: @organization, # no location attached
      owner: @originator,
      created_by_user: @originator,
      customer_first_name: "Bob",
      customer_last_name: "Smith",
      proposal_value: 5000
    )
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Loc: {location_name}|{state}|{company_phone}"),
      job_proposal: job_no_loc
    )
    assert_equal "Loc: ||", out.body
  end

  test "unknown placeholder raises UnresolvedMergeFieldError" do
    err = assert_raises(MailGenerator::UnresolvedMergeFieldError) do
      MailGenerator.render(
        campaign_step: step(subject: "X", body: "{not_a_real_field}"),
        job_proposal: @job
      )
    end
    assert_match(/not_a_real_field/, err.message)
  end

  test "error message lists every unresolved field, sorted, deduped" do
    err = assert_raises(MailGenerator::UnresolvedMergeFieldError) do
      MailGenerator.render(
        campaign_step: step(subject: "{zzz_unknown}", body: "{aaa_unknown} and {zzz_unknown} again"),
        job_proposal: @job
      )
    end
    assert_match(/aaa_unknown.*zzz_unknown/, err.message)
  end

  test "nil template fields render as empty strings" do
    out = MailGenerator.render(
      campaign_step: step(subject: nil, body: nil),
      job_proposal: @job
    )
    assert_equal "", out.subject
    assert_equal "", out.body
  end

  test "repeated placeholders in a single field are all substituted" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "{customer_first_name}, {customer_first_name}, {customer_first_name}"),
      job_proposal: @job
    )
    assert_equal "Sarah, Sarah, Sarah", out.body
  end

  test "subject and body are substituted independently" do
    out = MailGenerator.render(
      campaign_step: step(subject: "Re: {customer_name}", body: "{originator_name}"),
      job_proposal: @job
    )
    assert_equal "Re: Sarah Mitchell", out.subject
    assert_equal "Jeff Stone", out.body
  end

  test "state full-name lookup expands two-letter codes" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "{state}"),
      job_proposal: @job
    )
    assert_equal "Texas", out.body
  end

  # --- preview (sample values, no JobProposal) ---

  test "preview substitutes SAMPLE_VALUES into both subject and body" do
    out = MailGenerator.preview(
      campaign_step: step(
        subject: "Hi {customer_first_name} about {property_address_short}",
        body:    "From {originator_name} at {company_name}. Total: {proposal_value}."
      )
    )
    assert_equal "Hi Jane about 123 Main Street", out.subject
    assert_equal "From Pat Sample at Acme Restoration. Total: $10,260.00.", out.body
  end

  test "preview leaves unknown placeholders in place rather than raising" do
    out = MailGenerator.preview(
      campaign_step: step(subject: "X", body: "Hi {bogus_field}!")
    )
    assert_equal "Hi {bogus_field}!", out.body
  end

  test "preview tolerates blank subject or body" do
    out = MailGenerator.preview(
      campaign_step: step(subject: "", body: nil)
    )
    assert_equal "", out.subject
    assert_equal "", out.body
  end
end
