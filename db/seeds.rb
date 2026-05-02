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

# --- Demo data for the Job Proposals index --------------------------------

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

def upsert_job_type!(tenant:, name:, type_code:, description:)
  jt = JobType.find_or_initialize_by(tenant: tenant, name: name)
  jt.type_code ||= type_code
  jt.description ||= description
  jt.save!
  jt
end

roof_type   = upsert_job_type!(tenant: demo_tenant, name: "Roof Replacement", type_code: "ROOF-REPL",   description: "Full tear-off and re-roof.")
gutter_type = upsert_job_type!(tenant: demo_tenant, name: "Gutter Install",   type_code: "GUTTER-INST", description: "Gutters and downspouts.")
siding_type = upsert_job_type!(tenant: demo_tenant, name: "Siding",           type_code: "SIDING",      description: "Siding replacement.")

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
  JobType.find_or_create_by!(tenant: demo_tenant, type_code: attrs[:type_code]) do |jt|
    jt.name = attrs[:name]
    jt.description = attrs[:description]
  end
end

DEMO_PROPOSALS = [
  { first: "Alice",    last: "Adams",     city: "Springfield",  state: "IL", value:  9_800.00, status: :new,    type: :roof,   pipeline: "lead",        overlay: nil },
  { first: "Brian",    last: "Becker",    city: "Naperville",   state: "IL", value: 12_450.50, status: :new,    type: :gutter, pipeline: "lead",        overlay: nil },
  { first: "Carla",    last: "Cohen",     city: "Madison",      state: "WI", value:  6_300.00, status: :new,    type: :siding, pipeline: "contacted",   overlay: nil },
  { first: "Devon",    last: "Diaz",      city: "Peoria",       state: "IL", value: 18_750.00, status: :open,   type: :roof,   pipeline: "qualified",   overlay: nil },
  { first: "Erin",     last: "Edwards",   city: "Rockford",     state: "IL", value:  7_200.00, status: :open,   type: :gutter, pipeline: "qualified",   overlay: "hot" },
  { first: "Felix",    last: "Foster",    city: "Joliet",       state: "IL", value: 22_400.00, status: :open,   type: :roof,   pipeline: "estimating",  overlay: nil },
  { first: "Gina",     last: "Gomez",     city: "Aurora",       state: "IL", value: 10_980.00, status: :open,   type: :siding, pipeline: "estimating",  overlay: nil },
  { first: "Henry",    last: "Hopkins",   city: "Champaign",    state: "IL", value: 14_500.00, status: :open,   type: :roof,   pipeline: "negotiating", overlay: nil },
  { first: "Iris",     last: "Ito",       city: "Decatur",      state: "IL", value:  4_750.00, status: :open,   type: :gutter, pipeline: "negotiating", overlay: "hot" },
  { first: "Jonas",    last: "Johnson",   city: "Bloomington",  state: "IL", value: 19_300.00, status: :open,   type: :roof,   pipeline: "won",         overlay: nil },
  { first: "Kira",     last: "Kim",       city: "Schaumburg",   state: "IL", value: 11_650.00, status: :open,   type: :siding, pipeline: "won",         overlay: nil },
  { first: "Liam",     last: "Lopez",     city: "Evanston",     state: "IL", value:  8_400.00, status: :open,   type: :gutter, pipeline: "negotiating", overlay: "stalled" },
  { first: "Maya",     last: "Mehta",     city: "Skokie",       state: "IL", value: 16_200.00, status: :open,   type: :roof,   pipeline: "estimating",  overlay: "stalled" },
  { first: "Noah",     last: "Nguyen",    city: "Cicero",       state: "IL", value:  5_900.00, status: :open,   type: :gutter, pipeline: "qualified",   overlay: nil },
  { first: "Olivia",   last: "Ortiz",     city: "Berwyn",       state: "IL", value: 13_750.00, status: :closed, type: :roof,   pipeline: "won",         overlay: nil, lost: false },
  { first: "Paul",     last: "Patel",     city: "Oak Park",     state: "IL", value:  9_600.00, status: :closed, type: :siding, pipeline: "won",         overlay: nil, lost: false },
  { first: "Quinn",    last: "Quintero",  city: "Wheaton",      state: "IL", value: 21_000.00, status: :closed, type: :roof,   pipeline: "won",         overlay: nil, lost: false },
  { first: "Rita",     last: "Reyes",     city: "Lombard",      state: "IL", value:  7_500.00, status: :closed, type: :gutter, pipeline: "lost",        overlay: nil, lost: true },
  { first: "Sam",      last: "Singh",     city: "Glen Ellyn",   state: "IL", value: 12_900.00, status: :closed, type: :roof,   pipeline: "lost",        overlay: nil, lost: true },
  { first: "Tina",     last: "Thomas",    city: "Hinsdale",     state: "IL", value:  4_200.00, status: :closed, type: :gutter, pipeline: "lost",        overlay: nil, lost: true },
  { first: "Uma",      last: "Underwood", city: "La Grange",    state: "IL", value: 17_800.00, status: :closed, type: :siding, pipeline: "won",         overlay: nil, lost: false },
  { first: "Victor",   last: "Vargas",    city: "Downers Grove", state: "IL", value:  8_950.00, status: :closed, type: :roof,   pipeline: "lost",        overlay: nil, lost: true },
  { first: "Willa",    last: "Wong",      city: "Lisle",        state: "IL", value: 15_400.00, status: :open,   type: :roof,   pipeline: "estimating",  overlay: nil },
  { first: "Xavier",   last: "Xu",        city: "Wheeling",     state: "IL", value: 19_950.00, status: :open,   type: :siding, pipeline: "negotiating", overlay: "hot" }
]

type_lookup = { roof: roof_type, gutter: gutter_type, siding: siding_type }

DEMO_PROPOSALS.each_with_index do |row, i|
  ref = "DEMO-#{1000 + i}"
  proposal = JobProposal.find_or_initialize_by(internal_reference: ref)
  proposal.tenant = demo_tenant
  proposal.organization = demo_org
  proposal.owner = demo_owner
  proposal.created_by_user = demo_owner
  proposal.job_type = type_lookup[row[:type]]
  proposal.customer_first_name = row[:first]
  proposal.customer_last_name = row[:last]
  proposal.customer_title = "Mr."
  proposal.customer_house_number = (100 + i * 7).to_s
  proposal.customer_street = "Main Street"
  proposal.customer_city = row[:city]
  proposal.customer_state = row[:state]
  proposal.customer_zip = "6000#{i % 10}"
  proposal.proposal_value = row[:value]
  proposal.job_description = "#{row[:type].to_s.tr('_', ' ').capitalize} job for #{row[:first]} #{row[:last]}."
  proposal.status = row[:status]
  proposal.pipeline_stage = row[:pipeline]
  proposal.status_overlay = row[:overlay]
  proposal.scenario_key = "demo"

  if row[:status] == :closed
    proposal.closed_at = (i + 1).days.ago
    proposal.closed_by_user = demo_owner
    if row[:lost]
      proposal.loss_reason = ["Price", "Timing", "Competitor"].sample
      proposal.loss_notes = "Customer chose another option."
    end
  end

  proposal.save!
end
