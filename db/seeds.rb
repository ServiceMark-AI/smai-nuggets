# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "Password1"
  u.password_confirmation = "Password1"
  u.is_admin = true
  u.is_pending = false
end

gemini_flash = Model.find_or_create_by!(model_id: "gemini-2.5-flash") do |m|
  m.name = "Gemini 2.5 Flash"
  m.provider = "gemini"
end

pdf_extraction_prompt = <<~PROMPT
  You are an expert data extraction AI. Your task is to meticulously analyze the provided document and extract
    key details into a structured JSON format.

    **Instructions:**

    1.  **Analyze the Document:** Carefully read the entire document.
    2.  **Extract Key Information:** Identify and extract the following fields.
    3.  **Format as JSON:** Return **ONLY** the raw JSON object. Absolutely DO NOT include markdown code blocks,
    backticks (```), or explanatory text.
    4.  **Handle Missing Data:** If a field cannot be found, is ambiguous, or is not applicable, the value in the
    JSON output for that key **must be `null`**. Do not invent or guess data.
    5.  **Dates:** Format all dates as `YYYY-MM-DD`.
    6.  **Amounts:** Extract all monetary values as raw JSON numbers without currency symbols or commas (e.g.,
    12345.67). Make sure they are JSON numbers, not strings.

    **Extraction Fields:**

    *   `title`: The customer's formal title (e.g., Mr., Mrs., Ms., Dr.).
    *   `firstName`, `lastName`, `email`
    *   `jobDescription`: Concise one-sentence summary
    *   `internalRef`: Job number / estimate ID
    *   `jobType`: Inferred from `{{jobTypes}}` (templated at runtime)
    *   `estimateDate`, `expirationDate` (YYYY-MM-DD)
    *   `subtotal`, `taxAmount`, `discountAmount`, `depositAmount`, `totalAmount`
    *   `isEmergency`, `estimatedDuration`, `warrantyIncluded`, `optionsProvided`, `paymentTerms`
    *   `houseNumber`, `street`, `city`, `state`, `zip`

    **JSON Output Structure:** { ...all the above keys... }
PROMPT

PdfProcessingRevision.find_or_create_by!(instructions: pdf_extraction_prompt) do |r|
  r.model = gemini_flash
end

# --- Demo tenant + admin/owner membership ----------------------------------

demo_tenant = Tenant.find_or_create_by!(name: "Demo Roofing Co.")
demo_org = demo_tenant.organizations.find_or_create_by!(name: "HQ")

demo_owner = User.find_or_create_by!(email: "owner@example.com") do |u|
  u.password = "Password1"
  u.password_confirmation = "Password1"
  u.is_pending = false
  u.tenant = demo_tenant
end
demo_owner.update!(tenant: demo_tenant) if demo_owner.tenant != demo_tenant
OrganizationalMember.find_or_create_by!(organization: demo_org, user: demo_owner) { |m| m.role = :admin }
admin.update!(tenant: demo_tenant) if admin.tenant.nil?
OrganizationalMember.find_or_create_by!(organization: demo_org, user: admin) { |m| m.role = :admin }

# Baseline restoration job types — slug from SPEC-03 §7 becomes the type_code.
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

RESTORATION_JOB_TYPES.each do |attrs|
  JobType.find_or_create_by!(type_code: attrs[:type_code]) do |jt|
    jt.name = attrs[:name]
    jt.description = attrs[:description]
  end
end

# --- Scenarios sourced from docs/campaigns/v1-output/ ---------------------
# Layout: docs/campaigns/v1-output/<job_type_code>/<scenario_code>.md
# Each markdown file carries `# Variant: <short name>` and an
# `**Authoring hypothesis:** ...` line. Campaign content itself is not yet
# wired up — Scenario#campaign_id stays null until that work lands.

campaigns_root = Rails.root.join("docs", "campaigns", "v1-output")
if Dir.exist?(campaigns_root)
  Dir.children(campaigns_root).sort.each do |type_dir|
    type_path = campaigns_root.join(type_dir)
    next unless File.directory?(type_path)

    job_type = JobType.find_by(type_code: type_dir)
    next unless job_type # skip dirs whose type_code isn't a known JobType

    Dir.glob(type_path.join("*.md")).sort.each do |md_path|
      code = File.basename(md_path, ".md")
      content = File.read(md_path)

      short_name = content[/^#\s*Variant:\s*(.+?)\s*$/, 1] || code.tr("_", " ").capitalize
      description = content[/\*\*Authoring hypothesis:\*\*\s*(.+?)\s*$/, 1]

      Scenario.find_or_initialize_by(job_type: job_type, code: code).tap do |s|
        s.short_name = short_name if s.short_name.blank?
        s.description = description if s.description.blank?
        s.save!
      end
    end
  end
end
