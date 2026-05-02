# SPEC-11: Campaign Template Architecture

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Campaign Template Architecture |
| Spec ID | SPEC-11 |
| Version | 2.0.2 |
| Status | Ready for build |
| Date | 2026-04-28 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | Save State 2026-04-21 (templated architecture commitment, approved verbally by Ethan and Mark); Jeff text 2026-04-21 (90% follow-up rate, scenario distribution, anti-jargon guidance); RestorAI strategic direction (managed-service positioning, vertical AI back-office product); Jeff feedback round 2026-04-25/26 (v1 authoring scope reality) |
| Related docs | SPEC-03 v1.3.2 (Job Type and Scenario taxonomy); SPEC-12 v2.0 (Template Authoring Methodology); PRD-01 v1.4.1 (Job Record); PRD-02 v1.5 (New Job Intake; collapsed flow per save state §5); PRD-03 v1.4.1 (Campaign Engine); PRD-07 v1.2 (Analytics; template cohort attribution); PRD-10 v1.3 (SMAI Admin Portal; template management); CC-01 ServiceMark AI Platform Spine v1.4; CC-06 Buc-ee's MVP Definition |

**Revision note (v2.0):** Clean replacement. SPEC-11 v1.0 (drafted 2026-04-20) described a runtime-AI generation architecture in which Gemini produced final email prose at plan generation time per job. That architecture is deprecated as the target architecture per the strategic commitment locked 2026-04-21 (verbally approved by Ethan and Mark). The save state rationale is fully captured here; the short version is that runtime AI generation structurally contradicts RestorAI's managed-service positioning ("AI employees that follow your SOPs"), produces no measurable lift over well-authored templates with merge-field personalization at SMAI's volumes for the next 18+ months, and creates a wider failure surface, higher per-campaign cost, and weaker analytics than a templated path.

v2.0 specifies the templated architecture: AI-authored templates with scenario-level granularity, deterministic lookup at generation time by (`job_type`, `scenario_key`), merge-field substitution, append-only versioning with cohort attribution, and a weekly review ritual operating on per-template cohort data. v1.0 is superseded in full. Mark's existing v1 runtime-generator code is an operational artifact for him to handle (archive, retain as scaffolding, evolve toward this engine) and is not described as target architecture anywhere in the document set.

**Patch note (2026-04-23):** Two changes; no behavioral change. (1) H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1` and `PRD-03 v1.4` → `PRD-03 v1.4.1` to match the parallel patches. Audit-trail revision-note text preserved byte-exact. (2) H2P-04 closure: §0 Related docs cell at line 18 corrected from `PRD-01 v1.2 (Job Record)` to `PRD-01 v1.4.1 (Job Record)`. SPEC-11 v2.0 was authored 2026-04-21 before the v1.3-cycle minor bumps; the original Related docs row sat at the pre-bump v1.2 pointer, an 18-day-stale schema model. No version bump on SPEC-11 (sweep + one-off correction are pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01, H2P-04.

**Revision note (v2.0.1):** Two surgical edits, no behavioral changes. Both grounded in the SPEC-03 v1.3.2 patch (sub-type and scenario rename surgery, master list vs activation scope clarification).

1. **§17 open questions: master list scope vs tenant activation scope clarification.** Added a row acknowledging the gating relationship surfaced by SPEC-03 v1.3.2: scenarios in the master list have no requirement for an active template variant until they are activated for some tenant. The §8 lookup contract is unchanged — loud failure on missing variant remains correct behavior, scoped to tenant-activated tuples. SPEC-12 v2.0 governs authoring sequencing; SPEC-11 governs only that an activated tuple must have an active variant.

2. **§15 acceptance criterion slug propagation.** Updated the acceptance criterion that previously referenced (`environmental_asbestos`, `meth_drug_remediation`) to use the SPEC-03 v1.3.2 canonical slug `trauma_biohazard`. Criterion meaning is unchanged; the meth scenario remains in the master list under the renamed sub-type and remains unactivated for any v1 tenant, which makes it a valid example of the loud-failure path. Stale-slug propagation hygiene only.

3. **§0 related docs version refresh.** SPEC-03 v1.3 → v1.3.2; SPEC-12 v1.0 → v2.0; PRD-10 v1.2 → v1.3.

Patch note (2026-04-27): SPEC-11 v2.0.1 reflects downstream propagation from SPEC-03 v1.3.2 sub-type/scenario rename surgery and SPEC-12 v2.0 methodology rebase. No engine behavior change. Ref: SPEC-03 v1.3.2 patch wave; Jeff feedback round 2026-04-25/26.

**Revision note (v2.0.2):** One additive schema change, non-breaking. Adds `{state}` to the §9.1 merge-field set, sourced from the job's location record, full state name (e.g., "Texas"), required by default per §9.3. Motivation: the calibrated R4 mold-remediation soft-licensing-allusion rule in SPEC-12 / master prompt v0.7 permits customer prose like "we're licensed in [state]." Without a `{state}` merge field, template authors must either hardcode a single state per variant (which does not scale across the four USDS states or any future tenant) or fall back to the state-agnostic phrasing ("we operate under state licensing"), which is acceptable but lands less credibly. Adding `{state}` once at the schema layer eliminates the per-variant authoring concern and is portable across all tenants.

Non-breaking: existing v1 variants do not reference `{state}` and remain valid without modification. The new field is required at render time per §9.3 because every location has a state (no grammatical-fallback case). Mark wires `location.state` into the job context bundle at render time per §6.1 step 2; no other engine behavior changes. Cross-doc propagation: master prompt v0.7 §Merge field handling list must be updated to include `{state}` so future variants know the field is available; that update lives in SPEC-12 / master prompt territory and ships alongside this schema bump. No changes to §10 render contract, §11 versioning, §12 operational contracts, §15 acceptance criteria, or any other section.

---

## 1. What This Is in Plain English

SMAI sends campaign emails to customers whose proposals are pending decision. Until v2.0 of this spec, the architecture called for an AI model to write each email's prose at the moment a campaign was generated. We are replacing that with a templated architecture: SMAI authors a library of campaign templates ahead of time, each tied to a specific (Job Type, Scenario) pair, and the engine resolves the right template at generation time and fills in job-specific details using merge-field substitution.

Concretely, when an operator submits a new job at intake with `job_type = water_mitigation` and `scenario_key = sewage_backup`, the engine looks up the active campaign template variant for that exact pair. The template defines: how many emails are in the campaign, the cadence between them, the subject line for each step, and the body copy for each step. The body copy contains merge fields (customer name, property address, proposal value, originator name, etc.). The engine substitutes the field values from the job record and produces the rendered email content. The Campaign Ready modal shows the operator the rendered emails. On approval, the engine writes the durable job record and enqueues the sends.

There is no AI call in the generation path. No Gemini. The engine reads a template, substitutes fields, and renders. Sub-100ms latency. Effectively zero per-campaign runtime cost. If no active template exists for the (Job Type, Scenario) pair, generation fails loudly and the operator sees an error.

Templates are versioned append-only. Every campaign run carries a `template_version_id` that records which version produced the emails. New template versions ship as new rows; old versions are preserved indefinitely. Exactly one version is active per (Job Type, Scenario) pair at any moment. Activation is a two-step atomic write. This versioning model is the backbone of the weekly review ritual: Kyle and Ethan look at per-template cohort performance (reply rates, conversion rates, drop-off patterns), form a hypothesis about what to change, ship a new version with the hypothesis recorded, and let the cohort accumulate before evaluating.

---

## 2. What Builders Must Not Misunderstand

1. **No AI in the campaign generation path.** Templates are authored offline by SMAI, vetted by Kyle and Ethan, and loaded into the template store. At generation time, the engine performs deterministic lookup and merge-field substitution. There is no Gemini call, no Claude call, no model invocation of any kind. This is a hard architectural constraint, not an implementation preference.

2. **Templates are versioned append-only.** Every change to a template's content (subject lines, body copy, step count, cadence) ships as a new version, not an in-place edit. The prior version is preserved for cohort attribution. This is non-negotiable.

3. **One active variant per (Job Type, Scenario) pair, globally.** The active variant is the one the engine resolves to when a job is submitted. Activation is atomic: when a new variant is activated, the prior active variant is deactivated in the same database transaction. There is no period during which two variants are simultaneously active for the same pair.

4. **Append-only is the precondition for cohort attribution.** Improvements ship as new versions. Old versions remain readable indefinitely. Cohort attribution depends on this; if a template is mutated in place, the analytics for past campaigns become unanchored.

5. **Exactly one active version per (Job Type, Scenario) pair.** At any moment. Activation is a two-step atomic write: insert new version with `is_active = true`, flip prior active version to `is_active = false`. Within a single transaction. If two writes overlap, the database is the arbiter and one of them fails.

6. **Failure on missing active template is loud, not silent.** If the engine resolves a (Job Type, Scenario) pair with no active template variant, generation fails with a logged error. The operator sees "Campaign could not be generated. Contact support." There is no fallback template, no generic catch-all, no graceful degradation. The phased rollout strategy (per SPEC-12 v2.0 and the save state §7) ensures only scenarios with authored templates are activated for any tenant.

7. **Merge-field substitution is the only personalization mechanism.** No conditional logic in template body copy. No if/else branches. No "if the proposal value is over $X, say Y." If different prose is needed for different cases, those are different scenarios with different templates.

8. **Industry-standard classifications never appear in customer prose.** The template's author-facing metadata may reference IICRC S500, IICRC S520, OSHA, EPA, etc. for author calibration. The body copy of any rendered email must contain none of those terms. Per Jeff's 2026-04-21 guidance.

9. **Templates are global, not tenant-scoped.** One active template variant per (Job Type, Scenario) pair globally. Per-tenant variable strings (originator name, signature, company phone, hours) are injected as merge-field values from the job record at render time. They are not template forks. If a tenant needs materially different prose, that is a future capability and out of scope for v1.

10. **The render output is what gets sent. The render output is what gets shown in the Campaign Ready modal.** No re-rendering between modal display and send. The operator sees exactly what the customer will receive (modulo the operator-facing originator preview vs the customer-facing send). This preserves the approval-first trust contract.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
The architecture for how SMAI's campaign engine produces email content for a job's follow-up sequence. Replaces the runtime-AI generation path with a templated path. Specifies the template data model, the lookup contract, the substitution contract, the render contract, the versioning model, and the operational contracts.

**What this covers:**
- Template record shape and the per-step substructure
- The lookup contract: how the engine queries for the active template variant given a (job_type, scenario_key) pair
- The merge-field set: which fields are available for substitution, where their values come from
- The render contract: input (template variant + job context) → output (rendered campaign step records)
- Append-only versioning and cohort attribution
- Activation semantics (two-step atomic write, one active version per pair)
- Failure modes (loud failure on missing template, render-time validation)
- Operational contracts for the weekly review ritual (data needed for per-template cohort analysis)

**What this does not cover:**
- Template authoring methodology (SPEC-12 v2.0)
- The (job_type, scenario_key) taxonomy itself (SPEC-03 v1.3.2)
- The campaign engine's broader send lifecycle: pre-send checklist, Cloud Tasks scheduling, stop conditions, retry behavior (PRD-03 v1.4.1)
- The intake flow including the Campaign Ready modal mechanics (PRD-02)
- The `cta_type` resolution and status enums on `campaigns` (PRD-01)
- The admin portal endpoints for managing template versions (PRD-10 v1.3)
- Analytics queries and dashboard views per template (PRD-07 v1.2)
- File format for template storage on disk (Mark's engineering decision)
- Template loader mechanism (manual script vs CI hook vs API call; Mark's engineering decision)
- Internationalization (templates are English-only in v1)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Template architecture is templated, not runtime-generated. No AI in the generation path. | Save State 2026-04-21 (verbally approved by Ethan and Mark); supersedes SPEC-11 v1.0 |
| Template lookup keys on (`job_type`, `scenario_key`) tuple. | Save State 2026-04-21; SPEC-03 v1.3.2 §7.2 |
| Template versioning is append-only. One active version per (job_type, scenario_key) pair, globally. | Save State 2026-04-21 |
| Activation is a two-step atomic write (insert new active, flip old to inactive). | Save State 2026-04-21 |
| `template_version_id` carried on every campaign run for cohort attribution. | Save State 2026-04-21; PRD-07 v1.2 |
| No fallback template. Missing active variant for a (job_type, scenario_key) pair fails loudly. | Save State 2026-04-21 |
| Merge-field substitution is the only personalization mechanism. | Save State 2026-04-21 |
| Industry-standard classifications (IICRC, OSHA, EPA, etc.) never appear in customer prose. | Jeff text 2026-04-21; SPEC-12 v2.0 |
| Templates are global, not tenant-scoped. | Save State 2026-04-21 |
| Render output is what is sent and what is shown to the operator. | Trust contract; CC-01 Platform Spine v1.4 |

---

## 5. Actors and Objects

**Actors:**
- **SMAI authoring lead** (Kyle, Ethan) — author template variants per SPEC-12 v2.0 methodology. Produce SPEC-11-conformant payloads.
- **SMAI activation operator** (SMAI internal) — load and activate template variants in the template store via the admin portal per PRD-10 v1.3.
- **Campaign engine** (smai-backend) — performs lookup, substitution, render at intake Submit per PRD-02 v1.5; persists rendered content on Approve and Begin Campaign per PRD-03 v1.4.1.
- **Operator** (Originator) — sees the rendered campaign plan in the Campaign Ready modal; approves or cancels.

**Objects:**
- **Template variant** — the unit of authoring and activation. Tied to a (`job_type`, `scenario_key`) pair. Versioned. Append-only. Schema in §7.
- **Step record** — one email in a campaign. Carries `step_order`, `delay_from_prior`, `subject_template`, `body_template`. Schema in §7.2.
- **Job context bundle** — the assembled set of merge-field values resolved from `job_proposals` and related entities at render time. Schema implied by §9.1.
- **Rendered campaign step** — the output of the render contract per §10.2. Persisted to `campaign_steps` on Approve and Begin Campaign.
- **`template_version_id`** — the foreign key carried on `campaigns` records linking each campaign run to the variant that produced it. Backbone of cohort attribution.

---

## 6. Workflow Overview

### 6.1 Generation/render flow (at intake Submit)

1. Operator completes intake form per PRD-02 v1.5 and taps Submit.
2. Backend assembles job context bundle from intake form data and supporting records (location, account, originator).
3. Backend looks up active template variant for (`job_type`, `scenario_key`) pair per §8.
4. Backend substitutes merge fields into each step's `subject_template` and `body_template` per §9.
5. Backend returns rendered campaign step records to the frontend.
6. Frontend displays the rendered plan in the Campaign Ready modal per PRD-02 v1.5 §8.4.

If lookup fails (no active variant) or substitution fails (missing required merge field, unresolved token), generation fails per §10.3 and the operator sees the standard error message. No durable job record is written.

### 6.2 Persistence flow (at Approve and Begin Campaign)

1. Operator taps Approve and Begin Campaign in the Campaign Ready modal.
2. Backend performs atomic durable write per PRD-03 v1.4.1 §6.4: writes `job_proposals`, `job_contacts`, `campaigns` (including `template_version_id`), `campaign_steps` (rendered subject and body content), and `job_proposal_history` rows.
3. Backend enqueues Cloud Tasks for each step per PRD-03 v1.4.1 §6.5.

The rendered content stored on `campaign_steps` at this moment is what gets sent at each step's send time. No re-rendering between Approve and send.

### 6.3 Send flow (at each step's scheduled time)

Per PRD-03 v1.4.1 §9. The engine retrieves the stored subject and body from `campaign_steps`, applies the `[{job_number}]` thread continuity prefix per PRD-03 v1.4.1 §7.3, and passes the content to smai-comms for sending. No further content manipulation.

---

## 7. Template Variant Schema (Logical)

### 7.1 Variant record (logical)

A template variant is a logical record carrying these fields. Physical storage form (single table with JSON, parent/child tables, file-based authoring with database loading) is Mark's engineering decision per §13.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `template_version_id` | UUID | Yes | Primary key. Stable across the variant's lifetime. Carried on `campaigns.template_version_id` for cohort attribution. |
| `job_type` | string (FK to job type master list per SPEC-03 v1.3.2) | Yes | One of the v1 active or deferred values. |
| `scenario_key` | string (FK to scenario master list per SPEC-03 v1.3.2) | Yes | Must belong to the parent `job_type`. Validated at template authoring/load time. |
| `version_number` | integer or string | Yes | Monotonically increasing within a (`job_type`, `scenario_key`) pair. Authoring identifier; not load-bearing for lookup logic, which uses `is_active`. |
| `is_active` | boolean | Yes | Exactly one variant per (`job_type`, `scenario_key`) pair has `is_active = true` at any moment. Enforced by activation logic and database constraint where possible. |
| `authoring_hypothesis` | text | Yes | Free text capturing what this version is testing or improving relative to the prior active version. Required on every new variant to enforce the weekly review ritual's hypothesis-first discipline. The first variant for a (`job_type`, `scenario_key`) pair carries an initial hypothesis (e.g., "v1 baseline informed by Jeff interview 2026-04-XX"). |
| `industry_classification` | string or null | No | Inherited from the scenario master list record (SPEC-03 v1.3.2 §13.2) but may be re-recorded on the template for author convenience. Author-facing only. Never rendered. |
| `created_by` | user identifier | Yes | Authoring attribution. |
| `created_at` | timestamp | Yes | When the variant was authored. |
| `activated_at` | timestamp or null | Conditional | Set at the moment `is_active` flips to true. Null until first activation. |
| `deactivated_at` | timestamp or null | Conditional | Set at the moment `is_active` flips back to false. Null while active. May be set multiple times if a variant is re-activated and deactivated, though re-activation is unusual; under normal flow each variant is activated once and deactivated when superseded. |
| `steps` | ordered collection of step records (see §7.2) | Yes | At least one step. Ordered. Defines the campaign structure. |

### 7.2 Step record (logical, per-template)

A template variant contains an ordered collection of step records. Each step represents one email in the sequence.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `step_order` | integer | Yes | 1-indexed. Monotonically increasing within a template variant. |
| `delay_from_prior` | duration | Yes | Time between this step and the prior step. For `step_order = 1`, time between approval and send. Expressed in hours or a structured duration type (Mark's call). Variable per step. |
| `subject_template` | string | Yes | The email subject line. May contain merge-field placeholders. |
| `body_template` | string | Yes | The email body copy. May contain merge-field placeholders. |

Step count is variable per variant (no hardcoded N). Cadence is variable per variant. Both are determined by the authored template, not the engine.

### 7.3 `template_version_id` on `campaigns`

Per PRD-03 v1.4.1 §5 and PRD-01 v1.4.1, the `campaigns` table carries a `template_version_id` foreign key referencing the variant used to render the campaign run. This field is non-nullable for new campaign runs. Legacy campaign runs (created before v1.4) may have null values; analytics treats null as a legacy cohort.

---

## 8. Lookup Contract

### 8.1 Inputs

The lookup function takes a (`job_type`, `scenario_key`) pair and returns the active template variant for that pair, or raises a typed error if no active variant exists.

### 8.2 Resolution rule

The active variant is the row in the template store where:
- `job_type` matches the input
- `scenario_key` matches the input
- `is_active = true`

Exactly one row should match under normal operation. The activation operation per §11.2 maintains this invariant.

### 8.3 Failure modes

1. **If zero matches**, raise a typed error (e.g., `TemplateNotActivatedError`). The engine surfaces this to the operator as "Campaign could not be generated. Contact support." A `job_proposal_history` event is NOT written because no durable job record exists yet (the failure occurs before the Approve write). The error is logged for operational visibility.
2. **If more than one match**, raise a typed error (e.g., `TemplateInvariantViolationError`). This is a system integrity failure and should not occur under normal activation flow. Logged at high severity. Same operator-facing message as the zero-match case.

### 8.4 Performance

Sub-100ms latency for lookup. With the template store being a small reference set (tens to low hundreds of variants in the foreseeable horizon), an indexed query on (`job_type`, `scenario_key`, `is_active`) is the expected implementation. Caching is optional and is Mark's call.

---

## 9. Merge-Field Substitution Contract

The engine performs substitution at step 4 of the generation/render flow.

### 9.1 Available merge fields (v1)

The merge-field set is the contract between template authors and the engine. Templates may reference any of these fields. Fields are resolved from the job context bundle assembled at render time.

| Merge field | Source | Example value |
|-------------|--------|---------------|
| `{customer_name}` | `job_proposals.customer_name` (or related contact record) | "Sarah Mitchell" |
| `{customer_first_name}` | First token of customer name | "Sarah" |
| `{property_address}` | `job_proposals.property_address` | "1247 Oak Ridge Drive, Plano TX" |
| `{property_address_short}` | Street address only, no city/state | "1247 Oak Ridge Drive" |
| `{proposal_value}` | `job_proposals.proposal_value`, formatted as currency | "$12,400" |
| `{proposal_date}` | `job_proposals.proposal_date`, formatted as natural language date | "April 18" |
| `{damage_description}` | `job_proposals.damage_description` (AI-extracted at intake) | "burst pipe in master bath, water damage to flooring and drywall" |
| `{originator_name}` | Originator's full name | "Jeff Stone" |
| `{originator_first_name}` | First token of originator name | "Jeff" |
| `{originator_title}` | Originator's title from profile | "VP of Operations" |
| `{originator_signature}` | Constructed signature block per SPEC-07 v1.1 | (multi-line block) |
| `{company_name}` | Tenant company name | "Servpro of NE Dallas" |
| `{company_phone}` | Tenant location phone | "(972) 555-0184" |
| `{location_name}` | Job's location label if relevant | "NE Dallas" |
| `{state}` | Job's location state, full name (resolved from the location record on the job) | "Texas" |

The set may grow over time. Adding a merge field requires (a) updating this contract, (b) confirming the field is reliably present in the job context bundle, (c) coordinating with template authors so existing templates remain valid. Removing a merge field is a breaking change and requires a migration of all templates that reference it.

### 9.2 Substitution behavior

1. For each step in the template variant, scan `subject_template` and `body_template` for merge-field placeholders (the `{field_name}` syntax).
2. Resolve each placeholder against the job context bundle.
3. Replace the placeholder with the resolved value in-place.
4. Validate: after substitution, no `{field_name}`-shaped tokens should remain in the subject or body. If any do, raise a typed error (e.g., `UnresolvedMergeFieldError`). This indicates either a typo in the template or a missing field in the job context bundle. Surface to the operator as "Campaign could not be generated. Contact support." Logged at high severity.
5. The result is a rendered subject and rendered body for each step.

### 9.3 Missing or empty job-context values

Some merge fields are conditionally present (e.g., `{originator_title}` may be empty for an originator who has no title set). Substitution behavior for missing values:

| Case | Behavior |
|------|----------|
| Required field, value present | Substitute. |
| Required field, value missing or empty | Raise `MissingRequiredJobContextError`. Generation fails loudly. Surface to operator. Logged. |
| Optional field, value present | Substitute. |
| Optional field, value missing | Substitute with empty string. The template author is responsible for ensuring the surrounding prose remains grammatical when the field is empty (e.g., a comma-separated suffix that cleanly elides). |

The required vs optional designation per merge field is part of the contract and is captured in the merge-field documentation maintained alongside SPEC-12 v2.0 authoring guidance. The default for v1 is: customer name, property address, proposal value, originator name, originator signature, company name, company phone, and state are required. Others are optional.

### 9.4 No conditional logic

Templates do not contain if/else logic, loops, or expressions. A merge field is either present in the template or it is not. If different prose is required for different cases, those cases are different scenarios with different templates. This rule preserves the determinism and readability of templates and prevents authoring of branched template logic that becomes a maintenance liability.

---

## 10. Render Contract

Render is the composition of lookup (§8) and substitution (§9). It is the end-to-end behavior the engine performs at step 4 of the generation/render flow.

### 10.1 Inputs

- The (`job_type`, `scenario_key`) pair from the intake.
- The job context bundle assembled from `job_proposals` and related entities.

### 10.2 Output

An ordered collection of rendered campaign step records, one per step in the template variant. Each rendered step contains:
- `step_order`
- `delay_from_prior`
- Rendered `subject` (post-substitution)
- Rendered `body` (post-substitution)
- Reference to the source template variant (`template_version_id`, `step_order`)

This output is what the Campaign Ready modal displays and what is written to `campaign_steps` on Approve.

### 10.3 Failure modes

The render contract surfaces three failure modes, all loud:

| Failure | Cause | Operator-facing message |
|---------|-------|-------------------------|
| `TemplateNotActivatedError` | No active template variant for (`job_type`, `scenario_key`) pair | "Campaign could not be generated. Contact support." |
| `TemplateInvariantViolationError` | More than one active template variant for the pair | Same as above. Logged at high severity. |
| `UnresolvedMergeFieldError` | Substitution left unresolved tokens in subject or body | Same as above. |
| `MissingRequiredJobContextError` | Required merge field has no value in the job context bundle | Same as above. |

All four errors abort generation. No partial rendering, no fallback, no "best-effort" send. The operator is informed and the issue is escalated through normal support channels.

### 10.4 Idempotency

Render is a pure function of (template variant, job context bundle). Calling render twice with the same inputs produces the same output. This property is load-bearing for: (a) the operator seeing in the modal exactly what the customer will receive, (b) the consistency between modal preview and stored `campaign_steps` content, (c) any future debugging that needs to reproduce a past render.

Note that "same template variant" means the same `template_version_id`. If the active variant changes between two render calls (because activation happened in between), the renders will differ. This is by design; the cohort attribution model anchors past campaign runs to the version they were rendered from.

---

## 11. Versioning and Cohort Attribution

### 11.1 Append-only

Template variants are never edited in place after they are written. Improvements ship as new variants with new `template_version_id`s. The prior variant's content remains readable indefinitely.

The single mutable field on a template variant is `is_active`, which transitions between true and false as activation and deactivation occur. All other fields (content, hypothesis, attribution, timestamps) are write-once.

The append-only rule is non-negotiable. It is the precondition for cohort attribution being trustworthy.

### 11.2 Activation

Activation is a two-step atomic write performed within a single database transaction:

1. Flip the new variant's `is_active` to `true`; set `activated_at = now()`.
2. If a prior active variant exists for the same (`job_type`, `scenario_key`) pair, flip it to `is_active = false`; set `deactivated_at = now()`.

If the transaction fails, neither write takes effect. Concurrent activation attempts for the same pair are serialized by a row lock (`FOR UPDATE` on the prior-active row) or equivalent; one succeeds, the other fails with a serialization or constraint error.

A unique partial index on (`job_type`, `scenario_key`) WHERE `is_active = true` enforces the one-active-per-pair invariant at the database layer. Application logic plus the index together guarantee correctness.

**First-ever activation:** If no prior active variant exists for the pair, step 2 is a no-op. The new variant simply becomes active.

### 11.3 Cohort attribution

Every campaign run carries a `campaigns.template_version_id` foreign key referencing the variant that rendered the run. This field is the cohort-attribution backbone:

- **Per-template performance** — group campaigns by `template_version_id` to compute reply rates, conversion rates, drop-off patterns per variant.
- **Variant comparison** — compare cohorts of v1 vs v2 vs v3 of a (`job_type`, `scenario_key`) pair to evaluate whether changes improved performance.
- **Hypothesis tracking** — pair the per-variant `authoring_hypothesis` with the cohort's measured outcomes to inform the next iteration.

The cohort grain is the variant. Past campaign runs retain their `template_version_id` reference even after the variant has been deactivated. This is what makes the analytics model work.

### 11.4 Weekly review ritual (operational contract)

SPEC-12 v2.0 owns the weekly review ritual methodology. SPEC-11's contribution is the data: every campaign run links back to the variant that produced it. The ritual reads from `campaigns` joined to the template store and produces a per-variant performance summary. Hypothesis-driven changes ship as new variants per §11.1 and §11.2.

---

## 12. Operational Contracts

### 12.1 Template store availability

The template store must be available at intake Submit time. If the store is unreachable, generation fails per §10.3 (variant lookup raises). The operator sees the standard error. This is no different from any other backend dependency outage.

### 12.2 Activation latency

After activation, the new variant should be visible to lookup queries within 5 seconds. If caching is implemented per §13, cache invalidation must complete within this window.

### 12.3 Authoring change cadence

Per save state §4 and SPEC-12 v2.0: one change per template per week maximum is the operational discipline target. This is not a system constraint; it is a discipline target that ensures hypotheses have time to accumulate cohort data before being modified. SPEC-11 does not enforce this; SPEC-12 v2.0 does.

---

## 13. Engineering Decisions Deferred to Mark

| Decision | Notes |
|----------|-------|
| Physical storage form for templates | Options include: a single `campaign_templates` table with a JSON column per variant containing the steps; a parent `campaign_templates` table with child `campaign_template_steps` rows; YAML or JSON files committed to the `smai-specs` repo and loaded into the database at deploy time; a hybrid where authoring happens in files and loading writes to the database. Product requires that lookup is fast (§8.4) and that activation is atomic (§11.2). Anything else is up to Mark. |
| Loader mechanism | Options include: a manual script run by SMAI staff after committing a new template to `smai-specs`; a CI hook on merge that loads automatically; an admin portal API endpoint that accepts the new variant payload directly. Product requires that loaded variants are not active by default; activation is a separate operator action via the admin portal (per PRD-10 v1.3). |
| Whether to denormalize template content into `campaign_steps` at render time | Already required by PRD-03 v1.3: rendered subject and body are stored on `campaign_steps`. v1.4 keeps this and adds the `template_version_id` reference for cohort attribution. Whether to ALSO store the source template's `step_order` reference on `campaign_steps` for easier joining is Mark's call. |
| Caching of active template variants in memory | Optional. Templates change rarely (max one per template per week per discipline); cache invalidation on activation is straightforward. Product requires sub-100ms lookup latency; whether this needs caching depends on Mark's measurement. |

---

## 14. Implementation Slices

### Slice A — Template store schema and seed
**Purpose:** Establish the storage layer for template variants per §7.
**Components touched:** Database schema (new tables or table modifications); seed data for initial template variants.
**Key behavior:** Schema supports the §7.1 logical fields. Append-only constraint on content fields (enforceable via application logic and auditing; database-level enforcement is optional). Unique partial index on (`job_type`, `scenario_key`) WHERE `is_active = true`. Initial seed loads the first wave of authored templates for Jeff's tier-1 scenarios per the SPEC-12 v2.0 rollout (Water Mitigation, Mold Remediation, General Cleaning per save state §7).
**Dependencies:** SPEC-03 v1.3.2 §10 master lists in place (Slice A of SPEC-03). Initial template variants authored per SPEC-12 v2.0.
**Excluded:** Engine integration. Activation UI.

### Slice B — Template lookup and render
**Purpose:** Wire the campaign engine to perform §8 lookup and §9 substitution against the template store.
**Components touched:** Campaign engine generation/render path.
**Key behavior:** On generation trigger (per PRD-03 v1.4.1), the engine performs the §6.1 generation/render flow: assemble job context, look up active template variant, substitute merge fields, return rendered campaign step records to the caller (the Campaign Ready modal preview path). Failure modes per §10.3.
**Dependencies:** Slice A complete. Job context assembly logic per existing PRD-03 patterns. Campaign Ready modal flow per PRD-02.
**Excluded:** Storage of campaign run on Approve (PRD-03 territory, depends on this slice). Activation UI.

### Slice C — Cohort attribution wiring
**Purpose:** Ensure `campaigns.template_version_id` is written on Approve and is queryable for analytics.
**Components touched:** Campaign run write path; `campaigns` table schema.
**Key behavior:** On Approve and Begin Campaign (per PRD-02), the campaign run record written to `campaigns` includes `template_version_id` referring to the variant used in render. The field is non-nullable for new campaign runs. Legacy campaign runs (created before v1.4) may have null values; analytics treats null as a legacy cohort.
**Dependencies:** Slice B complete. PRD-03 v1.4.1 Approve write path.
**Excluded:** Analytics dashboard (PRD-07 v1.2). Admin portal activation UI (PRD-10 v1.3).

### Slice D — Activation operation
**Purpose:** Provide the atomic two-step activation operation per §11.2.
**Components touched:** Backend activation endpoint or RPC; database transaction logic.
**Key behavior:** Accepts a `template_version_id` to activate. Verifies the variant exists and is currently inactive. Transactionally activates the variant and deactivates the prior active variant for the same (`job_type`, `scenario_key`) pair. Enforces the one-active-per-pair invariant via the partial index plus application logic. Returns success or a typed error on conflict.
**Dependencies:** Slice A complete.
**Excluded:** Admin portal UI for triggering activation (PRD-10 v1.3 surfaces this).

---

## 15. Acceptance Criteria

**Given** an active template variant exists for (`water_mitigation`, `sewage_backup`),
**When** the engine performs lookup for that pair,
**Then** the active variant is returned within 100ms, including all step records.

**Given** no active template variant exists for (`trauma_biohazard`, `meth_drug_remediation`),
**When** the engine performs lookup for that pair,
**Then** lookup raises `TemplateNotActivatedError`. The operator sees "Campaign could not be generated. Contact support." No durable job record is created. The error is logged.

**Given** an active template variant for (`water_mitigation`, `clean_water_flooding`) and a job context bundle with all required merge-field values,
**When** the engine performs render,
**Then** the output is an ordered collection of rendered campaign step records. Each rendered step has `step_order`, `delay_from_prior`, a substituted `subject`, a substituted `body`, and a reference to the source template variant (`template_version_id`, `step_order`). No `{field_name}` tokens remain in subject or body.

**Given** an active template variant whose body contains a merge field not in the v1 merge-field set,
**When** the engine performs render,
**Then** substitution raises `UnresolvedMergeFieldError`. The operator sees the standard error message. The variant is logged as having a defective merge field reference.

**Given** an active template variant requiring `{customer_name}` and a job context bundle with a missing customer name,
**When** the engine performs render,
**Then** substitution raises `MissingRequiredJobContextError`. Same operator-facing message and logging.

**Given** a successful render and operator approval (Approve and Begin Campaign per PRD-02),
**When** the campaign run is written to `campaigns`,
**Then** `campaigns.template_version_id` is populated with the `template_version_id` of the variant used at render time. `campaign_steps` rows are populated with the rendered `subject` and `body` content from the render output.

**Given** an attempt to activate a new template variant for (`mold_remediation`, `crawlspace_mold`) when a prior active variant exists for that pair,
**When** the activation operation runs,
**Then** within a single database transaction: the new variant's `is_active` flips to true and `activated_at` is set; the prior variant's `is_active` flips to false and `deactivated_at` is set. After commit, exactly one variant for the pair has `is_active = true`.

**Given** two concurrent activation attempts for the same (`job_type`, `scenario_key`) pair,
**When** both transactions execute,
**Then** at most one succeeds. The other fails with a serialization or constraint error.

**Given** a template variant whose `authoring_hypothesis` field is empty,
**When** the variant is loaded into the template store,
**Then** loading fails. The variant is rejected. `authoring_hypothesis` is required at load time.

**Given** a template variant referencing `industry_classification = "IICRC S500"`,
**When** the engine renders any email body from this variant,
**Then** the rendered output contains no occurrence of the string "IICRC" or "S500" — the field is author-facing metadata only.

**Given** any campaign run created post-v2.0,
**When** the campaign's `template_version_id` is queried,
**Then** the value is non-null and references a variant in the template store.

---

## 16. Out of Scope

- Template authoring methodology (covered by SPEC-12 v2.0)
- Specific template content for any (`job_type`, `scenario_key`) pair (deliverables produced under SPEC-12 v2.0, not spec content)
- Authoring tooling, prompt chains, persona reactions, legal review (SPEC-12 v2.0)
- (`job_type`, `scenario_key`) taxonomy itself (SPEC-03 v1.3.2)
- Campaign engine send lifecycle, pre-send checklist, Cloud Tasks scheduling, stop conditions (PRD-03 v1.4.1)
- Intake flow including the Campaign Ready modal mechanics (PRD-02 v1.5)
- `cta_type` resolution and status enums on `campaigns` (PRD-01 v1.4.1)
- Admin portal endpoints for managing template versions (PRD-10 v1.3)
- Analytics queries and dashboard views per template (PRD-07 v1.2)
- File format for template storage on disk (Mark's engineering decision per §13)
- Template loader mechanism (Mark's engineering decision per §13)
- Internationalization (templates are English-only in v1)
- Per-tenant template variants
- Conditional logic in templates
- Multi-variant testing (A/B) within a single (`job_type`, `scenario_key`) pair

---

## 17. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Physical storage form for templates | Engineering decision | Per §13. JSON column vs child rows vs file-based authoring with database loading. Mark's call. |
| Loader mechanism | Engineering decision | Per §13. Manual script vs CI hook vs admin portal API. Mark's call. Product requires that loaded variants default to inactive. |
| Caching of active variants | Engineering decision | Per §13. Optional based on measurement against the §8.4 latency target. |
| Body copy format (plain text vs constrained markup vs HTML) | Engineering decision | Mark's call. Product requires that what is rendered is what is sent (no operator-side editing layer between render and send). If constrained markup is used, the template authoring tooling per SPEC-12 v2.0 must produce content in that format. |
| Merge-field syntax (`{field_name}` vs alternative) | Engineering decision | Product specifies semantics, not syntax. Mark's call on the literal token shape. The §9 contract assumes a syntax that uniquely identifies field references and is unambiguously distinguishable from natural prose; the `{field_name}` form is recommended for readability by template authors. |
| Required vs optional merge field designations | Operational artifact | The default per §9.3 is documented as a starting point. The full per-field designation lives alongside SPEC-12 v2.0 authoring guidance. Reviewed and revised as templates are authored. |
| Master list scope vs tenant activation scope | Clarification | Per SPEC-03 v1.3.2 §10.1 and §10.3, the master scenario list is broader than any single tenant's active scope. A scenario can exist in the master list without being activated for any tenant; in that case, no active template variant is required. The §8 lookup contract still requires that any tenant-activated (`job_type`, `scenario_key`) tuple has an active template variant before that tenant can submit a job for that tuple — this is what the loud-failure path in §10.3 enforces. Authoring sequencing (which scenarios get variants when) is governed by SPEC-12 v2.0; this spec governs only that an activated tuple must have an active variant at lookup time. |
| Internationalization | Out of scope for v1 | Templates are English-only. Multi-language support is a future capability requiring template-level locale fields. Not in this spec. |
| Per-tenant template variants | Out of scope for v1 | All variants are global. Per-tenant variation is restricted to merge-field values from the job context. If customer demand for per-tenant prose surfaces post-pilot, it requires SPEC-11 revision. |
| Conditional logic in templates | Explicitly out of scope | Per §9.4. Different cases are different scenarios. |
| Multi-variant testing (A/B) within a single (`job_type`, `scenario_key`) pair | Out of scope for v1 | The architecture is single-active-variant per pair. A/B testing would require allowing two active variants with traffic-splitting logic, which contradicts the cohort attribution model. Not in this spec. |
| Authoring tooling | Out of scope (covered by SPEC-12 v2.0) | Master prompt, brief structure, Jeff correction loop, iteration triggers, legal review for regulated content. SPEC-12 v2.0 owns. |

---

## 18. Glossary

- **Template variant** — a versioned record tied to a (`job_type`, `scenario_key`) pair, containing the campaign structure (steps, cadence) and content (subject and body templates with merge-field placeholders).
- **`template_version_id`** — the foreign key carried on `campaigns` records linking each campaign run to the variant that produced it.
- **Job context bundle** — the assembled set of merge-field values resolved from `job_proposals` and related entities at render time.
- **Lookup** — the operation of finding the active template variant for a (`job_type`, `scenario_key`) pair.
- **Substitution** — the operation of replacing `{field_name}` placeholders in `subject_template` and `body_template` with values from the job context bundle.
- **Render** — the composition of lookup and substitution. The function `(job_type, scenario_key, job_context_bundle) → ordered_collection_of_rendered_step_records`.
- **Activation** — the two-step atomic write that transitions a variant from inactive to active and deactivates the prior active variant for the same pair.
- **Cohort attribution** — the analytics capability of grouping campaign runs by `template_version_id` for per-variant performance measurement.
