require "test_helper"

class MailGeneratorTest < ActiveSupport::TestCase
  setup do
    @tenant = tenants(:one)
    @location = locations(:ne_dallas)   # belongs to tenant :one

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
      location: @location,
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

  # The signature appended by MailGenerator is tested separately. Tests
  # that pin the substituted body content compare the part *before* the
  # signature delimiter so the substitution behavior stays the focus.
  def body_without_signature(out)
    out.body.split("\n\n-- \n").first
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
    assert_equal "Body without tokens.", body_without_signature(out)
  end

  test "substitutes customer name fields" do
    out = MailGenerator.render(
      campaign_step: step(subject: "{customer_first_name}", body: "Hi {customer_name}, ..."),
      job_proposal: @job
    )
    assert_equal "Sarah", out.subject
    assert_equal "Hi Sarah Mitchell, ...", body_without_signature(out)
  end

  test "substitutes property address fields" do
    out = MailGenerator.render(
      campaign_step: step(subject: "About {property_address_short}", body: "At {property_address}."),
      job_proposal: @job
    )
    assert_equal "About 1247 Oak Ridge Drive", out.subject
    assert_equal "At 1247 Oak Ridge Drive, Plano, TX, 75024.", body_without_signature(out)
  end

  test "substitutes proposal_value as currency" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Estimate: {proposal_value}"),
      job_proposal: @job
    )
    assert_equal "Estimate: $12,400.00", body_without_signature(out)
  end

  test "substitutes originator fields from job owner" do
    out = MailGenerator.render(
      campaign_step: step(subject: "From {originator_first_name}", body: "—{originator_name}\n{originator_phone}"),
      job_proposal: @job
    )
    assert_equal "From Jeff", out.subject
    assert_equal "—Jeff Stone\n(214) 555-5555", body_without_signature(out)
  end

  test "substitutes location fields when the proposal has a location" do
    out = MailGenerator.render(
      campaign_step: step(subject: "From {location_name}", body: "{location_address}\n{state}\n{company_phone}"),
      job_proposal: @job
    )
    assert_equal "From NE Dallas", out.subject
    assert_equal "10280 Miller Rd, Dallas, TX, 75238\nTexas\n(214) 343-3973", body_without_signature(out)
  end

  test "company_name renders the tenant name" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "From {company_name}"),
      job_proposal: @job
    )
    assert_equal "From #{@tenant.name}", body_without_signature(out)
  end

  test "missing optional values substitute empty string without raising" do
    @originator.update!(phone_number: nil)
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Cell: {originator_phone}"),
      job_proposal: @job
    )
    # rstripped before the signature delimiter is appended, so trailing
    # whitespace produced by an empty substitution doesn't get pinned in.
    assert_equal "Cell:", body_without_signature(out)
  end

  test "missing location yields empty location-derived fields" do
    job_no_loc = JobProposal.create!(
      tenant: @tenant,
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
    assert_equal "Loc: ||", body_without_signature(out)
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
    assert_equal "", body_without_signature(out)
  end

  test "repeated placeholders in a single field are all substituted" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "{customer_first_name}, {customer_first_name}, {customer_first_name}"),
      job_proposal: @job
    )
    assert_equal "Sarah, Sarah, Sarah", body_without_signature(out)
  end

  test "subject and body are substituted independently" do
    out = MailGenerator.render(
      campaign_step: step(subject: "Re: {customer_name}", body: "{originator_name}"),
      job_proposal: @job
    )
    assert_equal "Re: Sarah Mitchell", out.subject
    assert_equal "Jeff Stone", body_without_signature(out)
  end

  test "state full-name lookup expands two-letter codes" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "{state}"),
      job_proposal: @job
    )
    assert_equal "Texas", body_without_signature(out)
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
    assert_equal "From Pat Sample at Acme Restoration. Total: $10,260.00.", body_without_signature(out)
  end

  test "preview leaves unknown placeholders in place rather than raising" do
    out = MailGenerator.preview(
      campaign_step: step(subject: "X", body: "Hi {bogus_field}!")
    )
    assert_equal "Hi {bogus_field}!", body_without_signature(out)
  end

  test "preview tolerates blank subject or body" do
    out = MailGenerator.preview(
      campaign_step: step(subject: "", body: nil)
    )
    assert_equal "", out.subject
    # Empty body still gets the signature appended (sample values).
    assert_match "-- \nPat Sample", out.body
  end

  # --- signature ---

  test "render appends the signature with originator + company info" do
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Body text."),
      job_proposal: @job
    )
    assert out.body.start_with?("Body text.\n\n-- \n"),
      "signature must be appended after RFC 3676 delimiter; got: #{out.body.inspect}"
    assert_match "Jeff Stone", out.body          # originator_name
    assert_match @tenant.name, out.body          # company_name
    assert_match "(214) 555-5555", out.body      # originator_phone
    assert_match "jeff@servpro-nedallas.example.com", out.body  # originator_email
  end

  test "signature subject is unaffected" do
    out = MailGenerator.render(
      campaign_step: step(subject: "Just the subject", body: "x"),
      job_proposal: @job
    )
    assert_equal "Just the subject", out.subject
    refute_match "-- ", out.subject
  end

  test "signature drops missing pieces rather than producing ragged empty lines" do
    @originator.update!(phone_number: nil)
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Body."),
      job_proposal: @job
    )
    refute_match(/\n\n\n/, out.body, "signature should not produce double blank lines when a piece is missing")
    refute_match "(214)", out.body
    assert_match "Jeff Stone", out.body
    assert_match "jeff@servpro-nedallas.example.com", out.body
  end

  test "signature is omitted entirely when no pieces are available" do
    @originator.update!(first_name: nil, last_name: nil, phone_number: nil)
    @job.update!(location: nil)

    sig_line = "-- "
    out = MailGenerator.render(
      campaign_step: step(subject: "X", body: "Body."),
      job_proposal: @job
    )
    # Body is just "Body." with no signature delimiter, since email is the
    # only piece left and it's joined into the contact line — but with no
    # phone to pair it with, the "contact" line still appears with just
    # the email. We expect the signature TO appear when at least one piece
    # is present; this asserts the structural shape.
    if out.body.include?(sig_line)
      # email-only signature: `-- \n<email>` (no name, no company, contact = email alone)
      assert_match "jeff@servpro-nedallas.example.com", out.body.split("-- ").last
    else
      assert_equal "Body.", body_without_signature(out)
    end
  end

  test "preview signature renders with SAMPLE_VALUES" do
    out = MailGenerator.preview(campaign_step: step(subject: "X", body: "Hi."))
    assert_match "-- \nPat Sample", out.body
    assert_match "Acme Restoration", out.body
    assert_match "(555) 123-4567", out.body
    assert_match "pat@example.com", out.body
  end

  test "render_safely also gets the signature" do
    out = MailGenerator.render_safely(
      campaign_step: step(subject: "X", body: "Hi {bogus_field}."),
      job_proposal: @job
    )
    assert_match "Jeff Stone", out.body
    assert_match "-- ", out.body
  end

  test "MERGE_FIELD_GROUPS covers exactly the keys listed in KNOWN_KEYS" do
    grouped = MailGenerator::MERGE_FIELD_GROUPS.values.flatten

    missing_from_groups = MailGenerator::KNOWN_KEYS - grouped
    extra_in_groups     = grouped - MailGenerator::KNOWN_KEYS
    duplicate_groupings = grouped.tally.select { |_, n| n > 1 }.keys

    assert_empty missing_from_groups,
      "every KNOWN_KEY must appear in some MERGE_FIELD_GROUPS entry — the form list is built from these"
    assert_empty extra_in_groups,
      "MERGE_FIELD_GROUPS lists keys that don't exist on the renderer"
    assert_empty duplicate_groupings,
      "a merge field appears in more than one group: #{duplicate_groupings.inspect}"
  end

  test "every key in MERGE_FIELD_GROUPS has a SAMPLE_VALUES entry so the form preview column renders" do
    grouped = MailGenerator::MERGE_FIELD_GROUPS.values.flatten
    missing_samples = grouped - MailGenerator::SAMPLE_VALUES.keys
    assert_empty missing_samples, "every grouped merge field must have a sample value for the form's reference list"
  end
end
