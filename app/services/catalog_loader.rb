# Loads the production-safe catalog data: restoration job types and the
# scenarios authored under docs/campaigns/v1-output/. Idempotent — safe to
# run any number of times against an existing database. No tenants, users,
# or demo proposals are touched here; that lives in db/seeds.rb for dev.
#
# Used by:
#   - rake task `catalog:load` (production setup, see docs/user-guide/00-production-setup.md)
#   - db/seeds.rb (dev seeding chains through here)
class CatalogLoader
  RESTORATION_JOB_TYPES = [
    {
      type_code: "general_cleaning",
      name: "General Cleaning",
      description: "One-time deep cleaning beyond normal janitorial scope: post-construction cleanup, move-in / move-out, odor remediation, and HVAC cleaning."
    },
    {
      type_code: "mold_remediation",
      name: "Mold Remediation",
      description: "Containment, removal, and remediation of mold growth — including mold discovered during or after a water event."
    },
    {
      type_code: "structural_cleaning",
      name: "Structural Cleaning",
      description: "Cleanup of structural surfaces after fire, smoke, or water damage. Soot and odor removal, deodorization, post-water deep cleaning."
    },
    {
      type_code: "trauma_biohazard",
      name: "Trauma / Biohazard",
      description: "Trauma scene cleanup and biohazard exposure work — blood, bodily fluids, regulated materials. Legal review required before any communication ships."
    },
    {
      type_code: "water_mitigation",
      name: "Water Mitigation",
      description: "Water removal, drying, and dehumidification after a water event. Time-sensitive — the first 48 hours determine downstream scope."
    }
  ].freeze

  CAMPAIGNS_ROOT = Rails.root.join("docs", "campaigns", "v1-output")

  Result = Struct.new(:job_types_created, :job_types_existing, :scenarios_created, :scenarios_existing, keyword_init: true) do
    def summary
      "#{job_types_created + job_types_existing} job types " \
      "(#{job_types_created} new, #{job_types_existing} existing); " \
      "#{scenarios_created + scenarios_existing} scenarios " \
      "(#{scenarios_created} new, #{scenarios_existing} existing)"
    end
  end

  def self.load!(io: $stdout)
    new(io: io).load!
  end

  def initialize(io: $stdout)
    @io = io
    @result = Result.new(
      job_types_created: 0, job_types_existing: 0,
      scenarios_created: 0, scenarios_existing: 0
    )
  end

  def load!
    log "Loading restoration job types..."
    load_job_types

    log "Loading scenarios from #{CAMPAIGNS_ROOT.relative_path_from(Rails.root)}..."
    load_scenarios

    log "Done. #{@result.summary}"
    @result
  end

  private

  def load_job_types
    RESTORATION_JOB_TYPES.each do |attrs|
      record = JobType.find_or_initialize_by(type_code: attrs[:type_code])
      if record.new_record?
        record.assign_attributes(name: attrs[:name], description: attrs[:description])
        record.save!
        @result.job_types_created += 1
        log "  created job type: #{attrs[:type_code]}"
      else
        @result.job_types_existing += 1
      end
    end
  end

  def load_scenarios
    return unless Dir.exist?(CAMPAIGNS_ROOT)

    Dir.children(CAMPAIGNS_ROOT).sort.each do |type_dir|
      type_path = CAMPAIGNS_ROOT.join(type_dir)
      next unless File.directory?(type_path)

      job_type = JobType.find_by(type_code: type_dir)
      next unless job_type # skip directories whose name doesn't match a known job type

      Dir.glob(type_path.join("*.md")).sort.each do |md_path|
        code = File.basename(md_path, ".md")
        content = File.read(md_path)

        short_name = content[/^#\s*Variant:\s*(.+?)\s*$/, 1] || code.tr("_", " ").capitalize
        description = content[/\*\*Authoring hypothesis:\*\*\s*(.+?)\s*$/, 1]

        record = Scenario.find_or_initialize_by(job_type: job_type, code: code)
        was_new = record.new_record?
        record.short_name = short_name if record.short_name.blank?
        record.description = description if record.description.blank?
        record.save!

        if was_new
          @result.scenarios_created += 1
          log "  created scenario: #{job_type.type_code}/#{code}"
        else
          @result.scenarios_existing += 1
        end
      end
    end
  end

  def log(message)
    @io.puts "[catalog:load] #{message}"
  end
end
