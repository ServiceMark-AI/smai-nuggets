require "test_helper"

class CatalogLoaderTest < ActiveSupport::TestCase
  setup do
    # Catalog loader is global — clean slate before each case.
    Scenario.destroy_all
    JobType.where(type_code: CatalogLoader::RESTORATION_JOB_TYPES.map { |attrs| attrs[:type_code] }).destroy_all
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

  test "is idempotent — second run creates nothing and reports everything as existing" do
    CatalogLoader.load!(io: @io)

    second = CatalogLoader.load!(io: StringIO.new)
    assert_equal 0, second.job_types_created
    assert_equal 5, second.job_types_existing
    assert_equal 0, second.scenarios_created
    assert_equal 17, second.scenarios_existing
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
    assert_match(/Done\./, @io.string)
  end
end
