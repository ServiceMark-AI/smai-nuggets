# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "Password1"
  u.password_confirmation = "Password1"
  u.is_admin = true
  u.is_pending = false
end
admin.update!(first_name: "Avery", last_name: "Sloan") if admin.first_name.blank? && admin.last_name.blank?

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
demo_owner.update!(first_name: "Jordan", last_name: "Pierce") if demo_owner.first_name.blank? && demo_owner.last_name.blank?
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

# --- Demo job proposals -----------------------------------------------------
# Wired to the restoration job types and the scenario codes seeded above.
# `scenario_key` matches Scenario#code (per SPEC-07 / SPEC-11). Pipeline
# stages and overlays follow PRD-01 v1.4.1 §10: in_campaign + optional
# overlay (paused, customer_waiting, delivery_issue) for active jobs;
# won / lost for terminal jobs.

DEMO_PROPOSALS = [
  # --- Water mitigation -----------------------------------------------------
  { ref: "DEMO-WM-001", scenario: "pipe_burst", first: "Marcus", last: "Holloway", title: "Mr.",
    house: "1842", street: "Glenwood Drive", city: "Naperville", state: "IL", zip: "60540",
    value: 8_640.00, status: :new, stage: "in_campaign", overlay: nil,
    description: "Second-floor supply line burst overnight; water through hallway ceiling and into living room. Customer shut main off. Cat 1, ~600 sq ft affected." },

  { ref: "DEMO-WM-002", scenario: "appliance_failure", first: "Priya", last: "Raman", title: "Mrs.",
    house: "27", street: "Linden Court", city: "Schaumburg", state: "IL", zip: "60173",
    value: 4_215.50, status: :open, stage: "in_campaign", overlay: "customer_waiting",
    description: "Dishwasher supply hose failed during cycle. Water under cabinets and toe-kick, traveled into adjacent dining room subfloor.",
    last_reply_from: "priya.raman@example.com", last_reply_subject: "Re: Drying plan for kitchen",
    last_reply_snippet: "Just checking — would Tuesday work for the moisture re-check? My husband will be home." },

  { ref: "DEMO-WM-003", scenario: "storm_related_flooding", first: "Doug", last: "McAllister", title: "Mr.",
    house: "504", street: "Riverbend Lane", city: "Rockford", state: "IL", zip: "61107",
    value: 14_780.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "Basement flooded during Friday storm — ~4 inches standing water, finished rec room and home office both impacted. Three other bids on the property." },

  { ref: "DEMO-WM-004", scenario: "sewage_backup", first: "Beverly", last: "Okafor", title: "Ms.",
    house: "1201", street: "Commerce Park Blvd", city: "Aurora", state: "IL", zip: "60504",
    value: 22_540.00, status: :closed, stage: "won", overlay: nil,
    description: "Main line backup into ground-floor restrooms of single-tenant office building. Cat 3. Hard surfaces only on affected floor; carpet pad replaced." },

  { ref: "DEMO-WM-005", scenario: "clean_water_flooding", first: "Henry", last: "Vasquez", title: "Mr.",
    house: "318", street: "Chestnut Ave", city: "Joliet", state: "IL", zip: "60435",
    value: 6_320.00, status: :closed, stage: "lost", overlay: nil,
    description: "Water heater tank failure overnight; water across utility room and into hallway. Cat 1.",
    loss_reason: "Price",
    loss_notes: "Customer's plumber referred a competitor at lower bid; chose them after 24h." },

  { ref: "DEMO-WM-006", scenario: "gray_water", first: "Lacey", last: "Burke", title: "Ms.",
    house: "76", street: "Sycamore Trail", city: "Evanston", state: "IL", zip: "60201",
    value: 3_975.00, status: :open, stage: "in_campaign", overlay: "paused",
    description: "Washing machine drain hose overflow into laundry/mudroom. Cat 2. Customer requested pause while traveling — resume Wed." },

  { ref: "DEMO-WM-007", scenario: "pipe_burst", first: "Greg", last: "Torres", title: "Mr.",
    house: "9", street: "Maple Hill Court", city: "Wheaton", state: "IL", zip: "60187",
    value: 11_240.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "Outdoor hose bib failed mid-thaw; water tracked into finished basement through rim joist. Cat 1, drying day 2." },

  # --- Mold remediation -----------------------------------------------------
  { ref: "DEMO-MR-001", scenario: "visible_mold_growth", first: "Anita", last: "Park", title: "Mrs.",
    house: "412", street: "Brookline Way", city: "Oak Park", state: "IL", zip: "60302",
    value: 5_410.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "Visible black growth on bathroom ceiling and around exhaust fan; tenant complaint prompted call. Pre-remediation testing scheduled." },

  { ref: "DEMO-MR-002", scenario: "crawlspace_mold", first: "Walter", last: "Kessler", title: "Mr.",
    house: "2207", street: "Oak Ridge Drive", city: "Lombard", state: "IL", zip: "60148",
    value: 8_870.00, status: :new, stage: "in_campaign", overlay: nil,
    description: "HVAC tech flagged surface mold across crawlspace floor joists during AC service. Customer has not been under the house. Referral from MidAmerica HVAC." },

  { ref: "DEMO-MR-003", scenario: "structural_mold", first: "Diane", last: "Albrecht", title: "Dr.",
    house: "55", street: "Briarcliff Place", city: "Hinsdale", state: "IL", zip: "60521",
    value: 34_280.00, status: :open, stage: "in_campaign", overlay: "customer_waiting",
    description: "Whole-attic mold across roof sheathing — ventilation issue; testing complete; protocol in draft. Awaiting customer decision on insulation replacement scope.",
    last_reply_from: "dalbrecht@example.com", last_reply_subject: "Re: Protocol draft and insulation question",
    last_reply_snippet: "Thanks for the protocol draft. We're discussing the insulation R-value with our energy auditor — back to you Friday." },

  { ref: "DEMO-MR-004", scenario: "post_water_mold_discovered", first: "Roman", last: "Chen", title: "Mr.",
    house: "143", street: "Evergreen Circle", city: "Skokie", state: "IL", zip: "60076",
    value: 11_750.00, status: :closed, stage: "won", overlay: nil,
    description: "Mold discovered behind drywall during reno, six months after a 2025 water event; testing confirmed elevated spores; standard remediation protocol." },

  { ref: "DEMO-MR-005", scenario: "visible_mold_growth", first: "Sara", last: "Whitfield", title: "Ms.",
    house: "1018", street: "Coventry Road", city: "Glen Ellyn", state: "IL", zip: "60137",
    value: 6_900.00, status: :open, stage: "in_campaign", overlay: "delivery_issue",
    description: "Mold growth around basement window wells and along sill plate; tenant moving in next month. Email bouncing — needs phone follow-up." },

  # --- Structural cleaning --------------------------------------------------
  { ref: "DEMO-SC-001", scenario: "post_fire_soot_smoke", first: "Jerome", last: "Bachmann", title: "Mr.",
    house: "603", street: "Willowbrook Lane", city: "Downers Grove", state: "IL", zip: "60515",
    value: 19_410.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "Kitchen grease fire; soot through main floor and partial second floor; HVAC shut down at outage. Day 3 since loss; cleaning window narrowing." },

  { ref: "DEMO-SC-002", scenario: "post_water_deep_clean", first: "Inez", last: "Alvarado", title: "Mrs.",
    house: "88", street: "Park Forest Drive", city: "Cicero", state: "IL", zip: "60804",
    value: 7_820.00, status: :closed, stage: "won", overlay: nil,
    description: "Post-mitigation deep clean of finished basement after pipe burst job last month. Hard surfaces, baseboards, HVAC vent cleaning." },

  { ref: "DEMO-SC-003", scenario: "post_fire_soot_smoke", first: "Curtis", last: "Yeo", title: "Mr.",
    house: "315", street: "Hawthorne Street", city: "Berwyn", state: "IL", zip: "60402",
    value: 12_540.00, status: :new, stage: "in_campaign", overlay: nil,
    description: "Detached garage fire; smoke migration into adjacent home through shared wall and attic vents. Light soot on second-floor contents." },

  { ref: "DEMO-SC-004", scenario: "post_water_deep_clean", first: "Felicia", last: "Marsh", title: "Mrs.",
    house: "722", street: "Woodland Heights", city: "Bloomington", state: "IL", zip: "61704",
    value: 5_980.00, status: :closed, stage: "lost", overlay: nil,
    description: "Deep clean follow-up after gray water event. Customer attempted DIY cleanup before estimate.",
    loss_reason: "No response",
    loss_notes: "Customer went silent after Day 5 follow-up; assumed self-handled." },

  # --- General cleaning -----------------------------------------------------
  { ref: "DEMO-GC-001", scenario: "move_in_move_out", first: "Trevor", last: "Nakamura", title: "Mr.",
    house: "104", street: "Warwick Court", city: "La Grange", state: "IL", zip: "60525",
    value: 1_640.00, status: :closed, stage: "won", overlay: nil,
    description: "Three-bedroom rental turnover between tenants; deep clean including appliances, baseboards, and inside cabinets. Keys returned next Friday." },

  { ref: "DEMO-GC-002", scenario: "post_construction_cleanup", first: "Yvonne", last: "Petrov", title: "Mrs.",
    house: "2580", street: "Hollybrook Drive", city: "Lisle", state: "IL", zip: "60532",
    value: 4_915.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "New-build single-family — contractor rough-clean is done; customer needs occupy-ready clean before move-in date (June 12)." },

  { ref: "DEMO-GC-003", scenario: "odor_remediation", first: "Beth", last: "Hollander", title: "Ms.",
    house: "47", street: "Cobblestone Lane", city: "Wheeling", state: "IL", zip: "60090",
    value: 2_785.00, status: :open, stage: "in_campaign", overlay: "delivery_issue",
    description: "Cigarette/tobacco odor in inherited 1,200 sq ft condo; listing prep. Source-then-air sequence proposed." },

  { ref: "DEMO-GC-004", scenario: "commercial_deep_clean", first: "Phil", last: "Donovan", title: "Mr.",
    house: "8800", street: "Industrial Parkway", city: "Aurora", state: "IL", zip: "60506",
    value: 6_720.00, status: :new, stage: "in_campaign", overlay: nil,
    description: "9,400 sq ft office floor — quarterly deep clean covering items janitorial doesn't (HVAC vent fronts, high dusting, baseboards, glass partitions). Off-hours required." },

  { ref: "DEMO-GC-005", scenario: "move_in_move_out", first: "Marisol", last: "Greene", title: "Ms.",
    house: "16", street: "Heatherfield Court", city: "Champaign", state: "IL", zip: "61820",
    value: 2_080.00, status: :closed, stage: "lost", overlay: nil,
    description: "Estate sale prep clean before listing.",
    loss_reason: "Timing",
    loss_notes: "Customer needed crew within 48 hours; we couldn't accommodate before her open-house deadline." },

  { ref: "DEMO-GC-006", scenario: "odor_remediation", first: "Devin", last: "Ramos", title: "Mr.",
    house: "239", street: "Westridge Drive", city: "Decatur", state: "IL", zip: "62526",
    value: 3_410.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "Persistent musty odor in finished basement after a partial wet event last winter; customer wants source confirmation before treatment." },

  # --- Trauma / Biohazard ---------------------------------------------------
  { ref: "DEMO-TB-001", scenario: "trauma_crime_scene", first: "Karen", last: "Whitlock", title: "Ms.",
    house: "612", street: "Sunrise Place", city: "Peoria", state: "IL", zip: "61614",
    value: 8_410.00, status: :closed, stage: "won", overlay: nil,
    description: "Single-occupant apartment cleanup after coroner release. Property manager primary contact; daughter cc'd. Discreet entry; unmarked vehicles." },

  { ref: "DEMO-TB-002", scenario: "trauma_crime_scene", first: "Walter", last: "Eames", title: "Mr.",
    house: "47", street: "Larkspur Drive", city: "Madison", state: "WI", zip: "53704",
    value: 5_920.00, status: :open, stage: "in_campaign", overlay: nil,
    description: "Bathroom-confined incident; landlord-engaged after tenant family declined; standard biohazard protocol." }
].freeze

scenario_lookup = Scenario.includes(:job_type).index_by(&:code)

DEMO_PROPOSALS.each_with_index do |row, i|
  scenario = scenario_lookup[row[:scenario]]
  next unless scenario # skip if scenario seed didn't load (e.g., missing markdown)

  proposal = JobProposal.find_or_initialize_by(internal_reference: row[:ref])
  proposal.tenant = demo_tenant
  proposal.organization = demo_org
  proposal.owner = demo_owner
  proposal.created_by_user = (i.even? ? demo_owner : admin)
  proposal.job_type = scenario.job_type
  proposal.scenario = scenario
  proposal.scenario_key = scenario.code
  proposal.customer_first_name = row[:first]
  proposal.customer_last_name = row[:last]
  proposal.customer_title = row[:title]
  proposal.customer_house_number = row[:house]
  proposal.customer_street = row[:street]
  proposal.customer_city = row[:city]
  proposal.customer_state = row[:state]
  proposal.customer_zip = row[:zip]
  proposal.proposal_value = row[:value]
  proposal.job_description = row[:description]
  proposal.status = row[:status]
  proposal.pipeline_stage = row[:stage]
  proposal.status_overlay = row[:overlay]
  proposal.status_details = row[:overlay]&.humanize

  if row[:last_reply_from].present?
    proposal.last_reply = {
      from: row[:last_reply_from],
      at: ((i % 4) + 1).hours.ago.iso8601,
      subject: row[:last_reply_subject],
      snippet: row[:last_reply_snippet]
    }
  else
    proposal.last_reply = nil
  end

  if row[:status] == :closed
    proposal.closed_at = ((i % 14) + 1).days.ago
    proposal.closed_by_user = demo_owner
    proposal.loss_reason = row[:stage] == "lost" ? row[:loss_reason] : nil
    proposal.loss_notes = row[:stage] == "lost" ? row[:loss_notes] : nil
  else
    proposal.closed_at = nil
    proposal.closed_by_user = nil
    proposal.loss_reason = nil
    proposal.loss_notes = nil
  end

  proposal.save!
end

# --- A dozen demo tenants with seeded users -------------------------------
# Idempotent. Uses parameterized tenant names as the email domain so re-runs
# don't collide. First user in each list becomes the org admin (within
# OrganizationalMember); none get is_admin (that's reserved for SMAI staff).

DEMO_TENANTS = [
  { name: "Pacific Coast Restoration",        users: [["Sarah", "Chen"], ["Marcus", "Reyes"], ["Nicole", "Park"], ["David", "O'Brien"]] },
  { name: "Greater Boston Disaster Services", users: [["Liam", "Sullivan"], ["Mei", "Tanaka"], ["Kwame", "Adusei"]] },
  { name: "Heartland Restoration Group",      users: [["Avery", "Lindquist"], ["Jamal", "Booker"], ["Priya", "Shah"], ["Tomas", "Ortiz"]] },
  { name: "Sunbelt Cleanup Co.",              users: [["Jenna", "Whitcomb"], ["Hector", "Romero"], ["Aisha", "Bello"]] },
  { name: "Mountain View Restoration",        users: [["Eli", "Frost"], ["Maya", "Patel"], ["Diego", "Velasquez"], ["Naomi", "Liu"]] },
  { name: "Lakeshore Mitigation Partners",    users: [["Brett", "Donovan"], ["Camille", "Beaulieu"], ["Sergio", "Marin"]] },
  { name: "Desert Vista Services",            users: [["Lena", "Halverson"], ["Ravi", "Subramaniam"], ["Esme", "Caldera"]] },
  { name: "Northern Forest Restoration",      users: [["Soren", "Eklund"], ["Adaeze", "Okafor"], ["Felix", "Mueller"], ["Iris", "Hoang"]] },
  { name: "Coastal Cleanup Network",          users: [["Theo", "Marchetti"], ["Renee", "Aubert"], ["Kenji", "Nakamura"]] },
  { name: "Midwest Property Recovery",        users: [["Hank", "Brubaker"], ["Lucia", "Esposito"], ["Olamide", "Akande"], ["Margaret", "Doyle"]] },
  { name: "Gulf Stream Restoration",          users: [["Beatriz", "Quintero"], ["Jonas", "Van Houten"], ["Ines", "Carvalho"]] },
  { name: "River Valley Services",            users: [["Rowan", "Halloran"], ["Yusuf", "Demir"], ["Anika", "Khatri"], ["Pia", "Lindgren"]] }
].freeze

DEMO_TENANTS.each do |entry|
  tenant = Tenant.find_or_create_by!(name: entry[:name])
  org = tenant.organizations.find_or_create_by!(name: "HQ")
  domain = tenant.name.parameterize

  entry[:users].each_with_index do |(first, last), i|
    slug = "#{first}.#{last}".downcase.gsub(/[^a-z.]/, "")
    email = "#{slug}@#{domain}.example.com"
    user = User.find_or_create_by!(email: email) do |u|
      u.password = "Password1"
      u.password_confirmation = "Password1"
      u.first_name = first
      u.last_name = last
      u.is_pending = false
      u.tenant = tenant
    end
    user.update!(tenant: tenant) if user.tenant != tenant

    role = (i == 0) ? :admin : :member
    OrganizationalMember.find_or_create_by!(organization: org, user: user) { |m| m.role = role }
  end
end
