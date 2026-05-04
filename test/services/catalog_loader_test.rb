require "test_helper"

class CatalogLoaderTest < ActiveSupport::TestCase
  setup do
    # Catalog loader is global — clean slate before each case.
    CampaignStepInstance.destroy_all
    CampaignInstance.destroy_all
    CampaignStep.destroy_all
    Campaign.destroy_all
    Scenario.destroy_all
    JobType.where(type_code: CatalogLoader::RESTORATION_JOB_TYPES.map { |attrs| attrs[:type_code] }).destroy_all
    PdfProcessingRevision.where(instructions: CatalogLoader::PDF_EXTRACTION_PROMPT).destroy_all
    Model.where(model_id: CatalogLoader::PDF_EXTRACTION_MODEL[:model_id]).destroy_all
    @io = StringIO.new
  end

  test "creates the five restoration job types and the seventeen scenarios from disk" do
    result = CatalogLoader.load!(io: @io)

    assert_equal 5, result.job_types_created
    assert_equal 0, result.job_types_existing
    assert_equal 17, result.scenarios_created
    assert_equal 0, result.scenarios_existing

    expected_codes = %w[general_cleaning mold_remediation structural_cleaning trauma_biohazard water_mitigation]
    assert_equal expected_codes.sort, JobType.where(type_code: expected_codes).pluck(:type_code).sort
  end

  test "creates one campaign per scenario in status :new with steps populated from the source markdown" do
    result = CatalogLoader.load!(io: @io)

    assert_equal 17, result.campaigns_created
    assert_equal 0, result.campaigns_existing
    assert result.steps_created > 0,
      "expected campaign steps to be created from the markdown"

    Scenario.includes(:job_type).find_each do |scenario|
      campaign = Campaign.find_by(attributed_to_type: "Scenario", attributed_to_id: scenario.id)
      assert campaign, "scenario #{scenario.code} should have an attributed campaign"
      assert campaign.status_draft?, "default campaign should be status :draft pending operator approval"
      assert_equal "#{scenario.job_type.name} — #{scenario.short_name}", campaign.name

      assert campaign.steps.any?, "campaign for #{scenario.code} should have at least one step"
      campaign.steps.each do |step|
        assert step.template_subject.present?, "step #{step.sequence_number} of #{scenario.code} should have a subject"
        assert step.template_body.present?, "step #{step.sequence_number} of #{scenario.code} should have a body"
      end
    end
  end

  test "parses cadence-overview offsets into minutes (Hour N → N*60, Day N → N*1440)" do
    CatalogLoader.load!(io: @io)
    scenario = Scenario.joins(:job_type).find_by!(job_types: { type_code: "water_mitigation" }, code: "clean_water_flooding")
    campaign = Campaign.find_by!(attributed_to: scenario)

    step1 = campaign.steps.find_by!(sequence_number: 1)
    step6 = campaign.steps.find_by!(sequence_number: 6)
    assert_equal 0, step1.offset_min, "Hour 0 should map to 0 minutes"
    assert_equal 5 * 24 * 60, step6.offset_min, "Day 5 should map to 7200 minutes"
  end

  test "is idempotent — second run creates nothing and reports everything as existing" do
    first = CatalogLoader.load!(io: @io)

    second = CatalogLoader.load!(io: StringIO.new)
    assert_equal 0, second.job_types_created
    assert_equal 5, second.job_types_existing
    assert_equal 0, second.scenarios_created
    assert_equal 17, second.scenarios_existing
    assert_equal 0, second.campaigns_created
    assert_equal 17, second.campaigns_existing
    assert_equal 0, second.steps_created
    assert_equal first.steps_created, second.steps_existing
  end

  test "creates the PDF extraction Model + PdfProcessingRevision so AI extraction is configured" do
    CatalogLoader.load!(io: @io)
    model = Model.find_by(model_id: "gemini-2.5-flash")
    assert model, "Gemini model row should exist after catalog:load"
    assert_equal "gemini", model.provider

    rev = PdfProcessingRevision.is_current
    assert rev, "current PdfProcessingRevision should exist after catalog:load"
    assert_equal model, rev.model
    assert_match(/Extraction Fields/, rev.instructions)
  end

  test "PDF extraction setup is idempotent — second run reuses the same revision" do
    CatalogLoader.load!(io: @io)
    initial_rev = PdfProcessingRevision.is_current

    CatalogLoader.load!(io: StringIO.new)

    assert_equal 1, PdfProcessingRevision.where(instructions: CatalogLoader::PDF_EXTRACTION_PROMPT).count,
      "same prompt content should not produce a duplicate revision"
    assert_equal initial_rev.id, PdfProcessingRevision.is_current.id
  end

  test "auto-curates each scenario's campaign_id to the freshly-created campaign" do
    CatalogLoader.load!(io: @io)

    Scenario.includes(:job_type).find_each do |scenario|
      attributed = Campaign.find_by(attributed_to: scenario)
      assert attributed, "scenario #{scenario.code} should have an attributed campaign"
      assert_equal attributed.id, scenario.reload.campaign_id,
        "scenario #{scenario.code} should be auto-curated to the attributed campaign so CampaignLauncher can find it"
    end
  end

  test "auto-curation does not overwrite an admin's manual campaign pick" do
    CatalogLoader.load!(io: @io)

    # Simulate an admin picking a different campaign for one scenario
    # (an A/B variant attributed to the same scenario).
    scenario = Scenario.joins(:job_type).find_by!(job_types: { type_code: "water_mitigation" }, code: "pipe_burst")
    custom = Campaign.create!(
      name: "Custom A/B variant",
      status: :approved,
      attributed_to: scenario
    )
    scenario.update!(campaign: custom)

    CatalogLoader.load!(io: StringIO.new)

    assert_equal custom.id, scenario.reload.campaign_id,
      "operator's manual pick should survive a second catalog:load"
  end

  test "preserves operator edits to campaign name, status, and step content on a second run" do
    CatalogLoader.load!(io: @io)
    scenario = Scenario.joins(:job_type).find_by!(job_types: { type_code: "water_mitigation" }, code: "pipe_burst")
    campaign = Campaign.find_by!(attributed_to: scenario)
    campaign.update!(name: "Custom name", status: :approved, approved_by_user: users(:admin), approved_at: 1.day.ago)
    step = campaign.steps.first
    step.update!(template_subject: "Operator override", template_body: "Hand-edited body.")

    CatalogLoader.load!(io: StringIO.new)

    campaign.reload
    step.reload
    assert_equal "Custom name", campaign.name
    assert campaign.status_approved?
    assert_equal "Operator override", step.template_subject
    assert_equal "Hand-edited body.", step.template_body
  end

  test "preserves description and short_name when run a second time on a hand-edited scenario" do
    CatalogLoader.load!(io: @io)
    scenario = Scenario.joins(:job_type).find_by!(job_types: { type_code: "water_mitigation" }, code: "pipe_burst")
    scenario.update!(short_name: "Operator override", description: "Hand-edited.")

    CatalogLoader.load!(io: StringIO.new)

    scenario.reload
    assert_equal "Operator override", scenario.short_name
    assert_equal "Hand-edited.", scenario.description
  end

  test "skips directories whose name does not match a known job type" do
    CatalogLoader.load!(io: @io)
    initial_count = Scenario.count

    Dir.mktmpdir do |tmpdir|
      stranger_dir = Pathname.new(tmpdir).join("not_a_real_type")
      stranger_dir.mkpath
      File.write(stranger_dir.join("phantom.md"), "# Variant: Phantom\n**Authoring hypothesis:** test only.")
      # Walk a synthetic root to confirm unknown directories are ignored.
      original = CatalogLoader::CAMPAIGNS_ROOT
      CatalogLoader.send(:remove_const, :CAMPAIGNS_ROOT)
      CatalogLoader.const_set(:CAMPAIGNS_ROOT, Pathname.new(tmpdir))
      begin
        CatalogLoader.load!(io: StringIO.new)
      ensure
        CatalogLoader.send(:remove_const, :CAMPAIGNS_ROOT)
        CatalogLoader.const_set(:CAMPAIGNS_ROOT, original)
      end
    end

    assert_equal initial_count, Scenario.count
  end

  test "summary line includes counts" do
    result = CatalogLoader.load!(io: @io)

    assert_match(/5 job types/, result.summary)
    assert_match(/17 scenarios/, result.summary)
    assert_match(/17 campaigns/, result.summary)
    assert_match(/campaign steps/, result.summary)
    assert_match(/Done\./, @io.string)
  end
end
