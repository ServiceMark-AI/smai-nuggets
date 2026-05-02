# SPEC-03: Job Type Sub-Categories

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Job Type Sub-Categories |
| Spec ID | SPEC-03 |
| Version | 1.3.3 |
| Status | Ready for build |
| Date | 2026-04-29 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | April 6 Jeff demo session; Lovable UI audit April 8; MVP Scope Agreement v1.0; Reconciliation Report 2026-04-16 (DECISION 1); Reconciliation Report 2026-04-18 (Finding #29); Jeff text 2026-04-21 (sub-type set and scenario mappings); Jeff feedback round 2026-04-25/26 (scope reduction, taxonomy refinement); CC-Spec consistency audit 2026-04-29 (sub-type activation gate finding) |
| Related docs | PRD-02 New Job Intake; PRD-03 Campaign Engine; PRD-01 Job Record (v1.4.1); PRD-07 Analytics (v1.2); PRD-10 SMAI Admin Portal (v1.2); SPEC-11 Campaign Template Architecture (v2.0); SPEC-12 Template Authoring Methodology (v2.0); CC-06 Buc-ee's MVP Definition; MVP Scope Agreement v1.0 Dec 2025 |

**Revision note (v1.1):** Expanded the v1 picker from four options to seven RESTORATION sub-types per DECISION 1 / Reconciliation Report 2026-04-16.

**Revision note (v1.2):** Added §10 Taxonomy Governance to resolve Finding #29 from Reconciliation Report 2026-04-18. Locked the two-layer governance model (global SMAI-curated master list, per-tenant activation managed from the SMAI admin portal at onboarding).

**Revision note (v1.3):** Two related changes, both grounded in Jeff's 2026-04-21 input.

1. **Sub-type taxonomy reshaped to Jeff's official seven.** Per Jeff's 2026-04-21 confirmation, the seven RESTORATION sub-types his operation actually runs are: Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. This supersedes the April 16 reconciliation's seven (Water Damage, Fire & Smoke, Mold Remediation, Storm Damage, Biohazard / Sewage, Contents / Pack-Out, Specialty Cleaning). Per Jeff's classification logic: fire and smoke is structural cleaning done on a burned building; sewage is a water event; environmental covers biohazard and abatement work. Folding rules captured in §11 Edge Cases for any legacy `job_type` values that need migration.

2. **Scenario layer introduced beneath sub-types.** Each sub-type carries a controlled set of scenarios that further specify the damage situation. Scenarios are operator-selected at intake (deterministic, not AI-inferred) via a second required dropdown after Job Type. Scenario selection drives campaign template variant resolution per SPEC-11 v2.0. Scenario taxonomy follows the same two-layer governance model as Job Type (global master list, per-tenant activation). New §7.2 enumerates the v1 scenario set per sub-type. New §13.1 specifies the `scenario_key` field on `job_proposals`. New §13.2 specifies the `industry_classification` author-facing metadata field on scenario master list records (internal-only, never in customer prose; per Jeff's explicit guidance to avoid technical industry terminology in customer-facing communications).

Material section changes in v1.3: §2 (operator selects scenario at intake), §3 (scope expansion), §5 (objects updated), §6 (workflow updated), §7 (taxonomy reshape and new §7.2), §8.2 (intake includes scenario picker), §9 (validation rules extended), §10 (governance extended to scenarios), §11 (folding rules for legacy sub-types), §12 (UX-visible behavior extended), §13 (data model extended), §14 (slices extended), §15 (acceptance criteria extended), §17 (open questions updated), §18 (out of scope updated).

**Revision note (v1.3.1):** Surgical consistency cleanup per CONSISTENCY-REVIEW-2026-04-22 Wave 2. Two edits, no logic changes beyond closing the schema ambiguity.

1. **H-04 Path A: `scenario_key` is NOT NULL with no legacy nullable allowance.** §13.1 schema prose rewritten to state the field is NOT NULL for all job records. §11 Edge Cases legacy-null row rewritten to confirm the case is not applicable to Buc-ee's or any v1.3 production tenant; future tenant migration handled at onboarding. Aligns with PRD-01 v1.4.1 §8.1, which already declares NOT NULL. Closes the contradiction between the canonical schema (NOT NULL) and the prior SPEC-03 prose (legacy nullable).

2. **H-12: Related-doc version refresh.** §0 Related docs and §3 out-of-scope reference updated: PRD-01 (v1.2) → (v1.4.1), PRD-07 (v1.1) → (v1.2), PRD-10 (v1.1) → (v1.2). No content change beyond version pointers.

Patch note (2026-04-22): H-04 Path A + H-12. Ref CONSISTENCY-REVIEW-2026-04-22.

**Patch note (2026-04-23):** H2P-04-style one-off correction. §9 source-truth row 1 rewritten from `PRD-01 v1.2 §12, DL-026` to `PRD-01 v1.4.1 §12, DL-026`. The Wave 2 H-12 fix above swept §0 Related docs and §3 out-of-scope but missed the §9 inline reference; the parallel H2P-04 finding (originally scoped to SPEC-11) confirmed this pattern of operational `PRD-01 v1.2` references surviving prior sweeps. No version bump on SPEC-03 (single-token correction; pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-04 (SPEC-03 application).

**Revision note (v1.3.2):** Three substantive changes grounded in Jeff's 2026-04-25/26 feedback round on the v1 template authoring scope.

1. **Sub-type rename: `environmental_asbestos` → `trauma_biohazard`.** v1 active scope under this sub-type narrows to trauma scene work only (per Jeff's volume reality: trauma scene cleanup is 5-20 jobs per franchise per year; standalone asbestos, lead, meth, and non-sewage biohazard are too rare to author for v1). The legacy slug was misleading — it implied an asbestos-led sub-type that does not match v1 contents. Renaming to `trauma_biohazard` reflects actual v1 scope while leaving room for biohazard scenarios to expand into the sub-type later. The four dropped scenarios (`asbestos_abatement`, `lead_abatement`, `biohazard_non_sewage`, `meth_drug_remediation`) remain in the master scenario list under the renamed sub-type for future tenant activation; they are not active for any v1 tenant. §7.1, §7.2, §11 folding rules, §13.3, and acceptance criteria updated to reflect the rename.

2. **Scenario rename: `commercial_janitorial_deep_clean` → `commercial_deep_clean`.** Per Jeff: "we don't do recurring janitorial." The word "janitorial" in the slug created ambiguity with the recurring janitorial service ServPro does not offer; renaming removes that ambiguity. The scenario remains within `general_cleaning` and represents one-time deep cleaning beyond normal janitorial scope. §7.2 updated.

3. **`sewage_backup` description update.** Per Jeff's correction: contamination is a function of source AND time. A clean water source becomes category-3-equivalent if left untreated long enough; day 5 of a clean water source is treated the same as day 1 of a sewage source. The slug remains `sewage_backup` because operators identify the scenario at intake by the most common operational trigger (a sewer or sewage event), but the scenario description in §7.2 is broadened to reflect that the scenario applies to delayed-onset water losses where contamination has progressed to a level where sewage-equivalent treatment is required. No slug change. Description text only.

4. **Tenant activation note for v1 authoring scope.** Patch note added in §7.2 confirming that v1 template authoring scope for Jeff's tenant is a subset of the master scenario list (17 active variants of 33 master entries). Master list itself is unchanged. Per-tenant activation handles the scope-narrowing; deactivated scenarios remain in the master list for future tenant activation. Rationale: operator-driven scope reality, not taxonomy contraction.

Patch note (2026-04-27): Material renames propagate downstream. PRD-10 v1.3 enumerates the v1 activated scenario set for Jeff's tenant using the renamed slugs; SPEC-12 v2.0.1 reflects the actual variant count; SPEC-11 v2.0.1 acknowledges the gating relationship between master list scope and tenant activation in §17 open questions. Ref: Jeff feedback round 2026-04-25/26.

**Revision note (v1.3.3):** Two related changes grounded in the CC-Spec consistency audit 2026-04-29 and confirmed by Kyle's authored v1 scope reality (5 sub-types covering 17 scenarios, per the attached scope checklist).

1. **§7.1 v1 Active Job Types reduced from seven to five for Jeff's tenant.** Per the v1 authoring reality: 17 scenarios distribute across exactly 5 sub-types (Water Mitigation 6, Mold Remediation 4, Structural Cleaning 2, General Cleaning 4, Trauma/Biohazard 1). The other two sub-types previously listed in §7.1 — `contents` and `temporary_repairs` — have zero authored scenarios for v1 and therefore zero activated scenarios for Jeff's tenant. Activating them in the operator-facing picker would let an operator select a sub-type with no scenario options, producing either an empty Scenario dropdown (operational dead end) or, if scenarios were master-listed but unactivated, a SPEC-11 loud-failure path (unrecoverable mid-intake). Neither is acceptable. The two sub-types remain in the global master list for future tenant activation; they are removed from Jeff's tenant activation join and from the operator picker for v1.

2. **§10.3 sub-type activation gate added.** New rule: a sub-type is activated for a tenant only if at least one scenario under that sub-type is also activated for that tenant. The converse rule already existed (a scenario activation requires the parent sub-type to be activated); v1.3.3 adds the symmetric constraint to prevent the empty-Scenario-dropdown failure mode. This is the operational expression of the SPEC-11 v2.0 "loud failure on missing active template variant" discipline applied at the picker layer rather than at the campaign engine layer. New §11 edge case row added to make the failure mode and prevention explicit. PRD-10's tenant configuration UI must enforce the gate at activation time.

Material section changes in v1.3.3: §7.1 (table reduced from seven rows to five), §10.3 (new rule row added), §11 (new edge case row covering the empty-scenarios failure mode and the activation gate).

Patch note (2026-04-29): Audit-driven scope correction. Reflects Jeff's actual authored v1 scope of 5 sub-types covering 17 scenarios. The 7-sub-type framing in v1.3 and v1.3.2 was a transitional state during the scope reduction that completed with the authoring of the 17 v1 scenarios. Master list is unchanged; the global taxonomy still preserves the 7-sub-type structure (and the 2 unactivated sub-types remain available for future tenant activation). Per-tenant activation joins for Jeff's tenant are updated to reflect 5 active sub-types. Cross-doc references in CP-01 v1.1, CC-02 v2.0, CC-06 v1.1, CC-07 v1.0, and CP-02 v1.1 are now consistent with this spec at "5 sub-types covering 17 scenarios." Ref: CC-Spec consistency audit 2026-04-29; Kyle's v1 scope checklist.

---

## 1. What This Is in Plain English

The current Line of Business picker in the New Job intake has six options: Restoration, Reconstruction, HVAC, Plumbing, Roofing, Other. Jeff's operation runs inside Restoration and covers five v1 active sub-types that each have materially different campaign urgency, cadence, and prose. A water mitigation job needs follow-up in hours. A mold remediation job runs on a different rhythm. Each scenario inside each sub-type has different customer dynamics again. Treating all of them as "Restoration" produces a campaign that fits none of them well.

This spec replaces the current flat six-option picker with five RESTORATION sub-types active for Jeff's tenant in v1: **General Cleaning, Mold Remediation, Structural Cleaning, Trauma / Biohazard, Water Mitigation**. Two additional Restoration sub-types — Contents and Temporary Repairs — remain in the global master list for future tenant activation but have no activated scenarios for v1 (per §10.3 sub-type activation gate). Reconstruction, HVAC, Plumbing, Roofing, and Other are removed from the active picker for the Jeff pilot and deferred to future vertical expansion.

Underneath each sub-type, this spec also introduces a second taxonomy layer: **scenarios**. A scenario specifies the particular damage situation within a sub-type (for example, sewage backup vs clean water flooding within Water Mitigation, or trauma scene within Trauma / Biohazard). Scenarios are operator-selected at intake via a required second dropdown after Job Type. Scenario selection determines which campaign template variant resolves at Submit, so the prose of the follow-up emails fits the specific damage situation rather than reading as a generic per-sub-type message.

The job type and scenario selections together drive three things: (1) how the job is labeled everywhere it appears in the UI, (2) which campaign template variant the campaign engine resolves for the follow-up sequence, and (3) which filter options appear on the Analytics screen. They do not change the job status model, the stop conditions, the approval flow, or any other campaign mechanics.

This is a scoped taxonomy and selection change, not a campaign architecture change. Campaign assignment remains deterministic. No branching logic, no AI inference of either job type or scenario, no operator-configurable campaign rules. The architecture for how templates resolve and render is in SPEC-11 v2.0.

---

## 2. What Builders Must Not Misunderstand

1. **Job type and scenario assignments are both deterministic and operator-selected. Neither is inferred from the proposal PDF.** The AI extraction step in the New Job wizard parses proposal data but leaves both Job Type and Scenario blank for the operator to select. The operator must explicitly choose both. The system never auto-fills either field and never infers either.

2. **This spec does not build a campaign configuration UI.** Operators do not configure campaign timing or messaging. SMAI manages campaign templates internally per SPEC-11 v2.0. This spec only defines the taxonomy that feeds the deterministic template resolution.

3. **"Restoration" as a parent category is removed from the operator-facing UI.** The five v1 active options shown to Jeff's operators are: General Cleaning, Mold Remediation, Structural Cleaning, Trauma / Biohazard, Water Mitigation. The parent grouping (Restoration) is preserved in the data model for reporting and future use, but operators select from the leaf-level sub-types activated for their tenant.

4. **Reconstruction, HVAC, Plumbing, Roofing, and Other are not hidden — they are not activated for any tenant in v1.** These are future vertical options. They should not appear as grayed-out or disabled options. They simply do not surface in any tenant's dropdown. They remain in the global master list as valid values for forward compatibility (see §10), but no tenant has them activated. Jeff's tenant has the five v1 active RESTORATION sub-types activated and nothing else. Contents and Temporary Repairs remain in the master list as Restoration sub-types but are not activated for Jeff's tenant in v1, per the §10.3 sub-type activation gate (no activated scenarios under either).

5. **Every place the job type appears in the UI must use the new label.** This includes: the New Job intake picker, the job card on Jobs List, the job card on Needs Attention, the job detail header subtitle, the Analytics Job Type filter, and the campaign approval card. Inconsistent labeling is a launch defect.

6. **The campaign engine receives both `job_type` and `scenario_key` as deterministic inputs.** Per SPEC-11 v2.0, the engine resolves the active template variant by the (`job_type`, `scenario_key`) tuple. If no active template exists for the tuple, generation fails loudly. This spec does not define template behavior; it defines the taxonomy that the template lookup keys against.

7. **Reconstruction is a separate top-level category in the data model, deferred from v1.** It is not a sub-type of Restoration. The enum preserves it as a valid value for future use. It is not shown in the v1 picker.

8. **Industry-standard classifications (IICRC S500, IICRC S520, OSHA, EPA, etc.) live as internal author-facing metadata only.** They appear in the scenario master list record under `industry_classification` to inform template authors. They never appear in customer-facing prose. Per Jeff's explicit 2026-04-21 guidance: do not use technical industry terminology in communications to customers.

9. **Master list scope and per-tenant activation scope are distinct.** The master scenario list contains all scenarios SMAI supports across all tenants and all operational realities. Per-tenant activation scopes the master list down to what each tenant actually uses. v1 authoring scope (variants ready for production sending) is keyed to per-tenant activation, not to the master list. A scenario in the master list with no active template variant is permitted as long as it is also not activated for any tenant.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Jeff's requirement from the April 6 session: different RESTORATION sub-types need different campaign logic because their urgency, cadence, and customer dynamics are fundamentally different. Refined on 2026-04-21 with two updates: (a) Jeff's operation initially scoped seven specific sub-types (Contents, Environmental/Asbestos→Trauma/Biohazard, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation), and (b) within each sub-type, scenarios further specify the damage situation so campaign prose fits the actual job. Refined on 2026-04-25/26 with sub-type and scenario rename surgery and tenant-activation scope clarification. Refined on 2026-04-29 with v1 active sub-type set narrowed to five (the sub-types with at least one activated scenario for Jeff's tenant: General Cleaning, Mold Remediation, Structural Cleaning, Trauma/Biohazard, Water Mitigation). Contents and Temporary Repairs remain in the master list for future tenant activation.

**What this covers:**
- Replacing the current six-option Line of Business picker with the five v1 active RESTORATION sub-types for Jeff's tenant
- Updating the field label from "Line of Business" to "Job Type"
- Introducing a Scenario picker as a second required field at intake, scoped to the selected Job Type's activated scenarios
- Storing `job_type` and `scenario_key` as structured fields on the job record
- Displaying the correct job type label on all UI surfaces where job type currently appears
- Passing `job_type` and `scenario_key` to the campaign engine as deterministic inputs for template resolution per SPEC-11 v2.0
- Updating the Analytics Job Type filter to reflect the new taxonomy
- Preserving forward compatibility for deferred sub-types (Reconstruction, HVAC, Plumbing, Roofing, Other) and adding `industry_classification` as an author-facing metadata field on scenario records
- Extending the §10 governance model to cover scenarios (master list of scenarios per sub-type, per-tenant activation)

**What this does not cover:**
- Building campaign content, templates, or messaging variants for any sub-type or scenario (covered by SPEC-11 v2.0 architecture and SPEC-12 v2.0 authoring methodology)
- Any campaign configuration UI for operators
- AI inference or auto-detection of job type or scenario from the proposal PDF
- Reconstruction, HVAC, Plumbing, Roofing, or Other vertical support in the v1 picker
- Any changes to the campaign approval flow, stop conditions, or job status model
- Multi-type or multi-scenario jobs (a single job has exactly one job type and one scenario)
- Scenario-level analytics filtering in PRD-07 v1.2 (job type filter only for v1; scenario filter is a future PRD-07 revision)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Campaign assignment is deterministic, based on the job type and scenario selected at job creation. No branching, no conditional logic, no customer configuration. | MVP Scope Agreement v1.0 Dec 2025; SPEC-11 v2.0 |
| The MVP includes support for up to two follow-up campaigns per customer location. Each campaign corresponds to a distinct job. | MVP Scope Agreement v1.0 Dec 2025 |
| Campaigns stop only on: customer reply, delivery failure, explicit operator pause. Stop conditions are unchanged by this spec. | MVP Scope Agreement v1.0; Platform Spine v1.4 |
| Approval-first. No unapproved outbound. Campaign approval flow is unchanged by this spec. | Platform Spine v1.4 |
| Append-only proof tied to the job record. Job type and scenario are fields on the job record and are part of the proof. | Platform Spine v1.4 |
| Jobs, Needs Attention, and Analytics are the MVP operational surfaces. | CC-06 Buc-ee's MVP Definition |
| PDF-only file acceptance. The AI extraction reads the PDF but does not auto-fill job type or scenario. | Canonical constraint; locked decision |
| No Campaigns UI in MVP and early v1. | Platform Spine v1.4; CC-06 |
| Controlled terminology: "Originator" for the user role, "Job Type" for the field, "Scenario" for the second selection field, "Needs Attention" for the triage screen. | Decision Ledger |
| v1 active job types for Jeff's tenant are five RESTORATION sub-types (General Cleaning, Mold Remediation, Structural Cleaning, Trauma/Biohazard, Water Mitigation). The master list preserves seven Restoration sub-types; Contents and Temporary Repairs remain available for future tenant activation but are not activated for Jeff in v1 per the §10.3 sub-type activation gate. | Jeff text 2026-04-21; Jeff feedback 2026-04-25/26; v1 scope checklist 2026-04-29 |
| Industry-standard classifications never appear in customer-facing prose. | Jeff text 2026-04-21 |
| Physical job record table name is `job_proposals`. | PRD-01 v1.4.1 §12, DL-026 |

---

## 5. Actors and Objects

**Actors:**
- **Originator** — selects job type and scenario during the New Job intake. Cannot change either after campaign launch without stopping the campaign and creating a new job.
- **Admin** — same as Originator for intake purposes. Also sees job type and scenario in reporting and analytics views.
- **System / Campaign Engine** — receives `job_type` and `scenario_key` as deterministic inputs when resolving the campaign template variant per SPEC-11 v2.0.
- **SMAI (internal operations)** — curates the global master list of job types and scenarios; activates the relevant subset per tenant in the admin portal; authors campaign templates per SPEC-12 v2.0.

**Objects:**
- **Job record (`job_proposals`)** — stores `job_type` and `scenario_key` as structured fields. Both are set at intake and do not change after campaign activation without explicit job edit.
- **Job type master list** — the global SMAI-curated set of valid job type values. Master list contains seven Restoration sub-types (`contents`, `general_cleaning`, `mold_remediation`, `structural_cleaning`, `temporary_repairs`, `trauma_biohazard`, `water_mitigation`) plus deferred non-Restoration values (`reconstruction`, `hvac`, `plumbing`, `roofing`, `other`). v1 active values for Jeff's tenant (subset of master list per §10.3 activation gate): `general_cleaning`, `mold_remediation`, `structural_cleaning`, `trauma_biohazard`, `water_mitigation`. `contents` and `temporary_repairs` remain in the master list but are not activated for Jeff's tenant in v1.
- **Scenario master list** — the global SMAI-curated set of valid scenarios, each scoped to exactly one job type. v1 scenario set enumerated in §7.2.
- **Per-tenant activation joins** — separate joins for job types and scenarios, controlling which subset of each master list a given tenant can use. Managed by SMAI operators in the admin portal.
- **Campaign template variant** — the per-(`job_type`, `scenario_key`) template authored per SPEC-11 v2.0 and SPEC-12 v2.0. One active variant per tuple at any time.
- **New Job intake wizard** — the four-step modal where job type and scenario are both selected at Step 4.
- **Job card** — the row-level display on Jobs List and Needs Attention that shows the job type label.
- **Job detail** — the full job record view that shows job type in the header subtitle.
- **Analytics Job Type filter** — the filter dropdown on the Analytics screen.

---

## 6. Workflow Overview

Job type and scenario selection both happen once, at intake, during the Review step (Step 4) of the New Job wizard. Both are required fields. The operator cannot proceed to campaign generation without selecting both.

Once selected:
1. `job_type` and `scenario_key` are stored on the job record at the moment the durable write happens (per the collapsed intake flow specified in PRD-02, the durable write is at Approve and Begin Campaign in the Campaign Ready modal, not at intake Submit).
2. The job type label appears on the job card, job detail header, and the campaign approval card. (Scenario is internal context for template resolution; it is not displayed as a customer-facing or operator-facing label on the job card or detail header in v1.)
3. When the campaign engine resolves the template per SPEC-11 v2.0, it uses the (`job_type`, `scenario_key`) tuple to look up the active template variant.
4. The campaign approval card shows the selected job type in the summary. (Scenario is shown adjacent to the job type so the operator can confirm both selections before approving the plan; exact placement is a PRD-02 design decision.)
5. After campaign launch, both fields are read-only. They cannot be changed without stopping the campaign and creating a new job.

---

## 7. Job Type and Scenario Taxonomy

### 7.1 v1 Active Job Types (shown in the picker)

**Patch note (v1.3.3):** Reduced from seven sub-types to five for Jeff's tenant per v1 authoring scope. The 5 sub-types below are the ones with at least one activated scenario (and therefore at least one active campaign template variant) under them. The two sub-types previously listed — `contents` and `temporary_repairs` — remain in the global master list for future tenant activation but are removed from Jeff's tenant activation join. See §10.3 for the activation gate rule and §11 for the failure mode it prevents.

| Display label | Internal enum value | Parent category |
|---------------|---------------------|-----------------|
| General Cleaning | `general_cleaning` | Restoration |
| Mold Remediation | `mold_remediation` | Restoration |
| Structural Cleaning | `structural_cleaning` | Restoration |
| Trauma / Biohazard | `trauma_biohazard` | Restoration |
| Water Mitigation | `water_mitigation` | Restoration |

**Master list scope (preserved for future tenant activation):** Contents (`contents`), Temporary Repairs (`temporary_repairs`). These sub-types remain in the global master list. They have no activated scenarios for Jeff's tenant in v1, so they are not shown in Jeff's operator picker. A future tenant whose v1 authoring scope includes Contents or Temporary Repairs scenarios can have those sub-types activated.

### 7.2 v1 Active Scenarios (per sub-type)

Operator selects one scenario from the list scoped to the chosen Job Type. Scenarios are master-listed and per-tenant activated under the same governance model as Job Types (§10).

**Patch note (v1.3.2):** The master scenario list below contains 33 entries. Per-tenant activation for Jeff's tenant in v1 is a subset of this master list (17 entries with active template variants), per the operational scope reality identified in Jeff's 2026-04-25/26 feedback round. PRD-10 v1.3 enumerates Jeff's exact activated set. Master scenarios that are not activated for Jeff remain in the master list for future tenant activation; they do not require active template variants until activation. Per SPEC-11 v2.0, an activated (`job_type`, `scenario_key`) tuple for any tenant must have an active template variant before that tenant goes live.

**Water Mitigation** (`water_mitigation`)

| Display label | Internal enum value | Description |
|---------------|---------------------|-------------|
| Clean water flooding | `clean_water_flooding` | Standard clean-water loss; water from a non-contaminated source |
| Gray water | `gray_water` | Water with some level of contamination (washing machine overflow, dishwasher leak); not yet sewage-grade |
| Sewage backup | `sewage_backup` | Category-3-equivalent contamination scenario. Most commonly driven by sewage backup or sewer line failure, but applies broadly to scenarios where contamination is the dominant scope concern, including delayed-discovery water losses where time-since-event has shifted contamination category. Per Jeff: contamination severity is a function of source AND time; day 5 of a clean water source is treated the same as day 1 of a sewage source under IICRC S500. |
| Pipe burst | `pipe_burst` | Sudden water release from internal plumbing failure |
| Appliance failure | `appliance_failure` | Water release from dishwasher, washing machine, water heater, ice maker, or similar |
| Storm-related flooding | `storm_related_flooding` | Water intrusion driven by storm event; typically rising water exclusion applies to insurance |

**Mold Remediation** (`mold_remediation`)

| Display label | Internal enum value |
|---------------|---------------------|
| Visible mold growth | `visible_mold_growth` |
| Post-water mold discovered | `post_water_mold_discovered` |
| HVAC mold | `hvac_mold` |
| Crawlspace mold | `crawlspace_mold` |
| Structural mold | `structural_mold` |

Note: Jeff's team does mold remediation only, not mold prevention. The `post_water_mold_discovered` scenario covers mold discovered during or after a water event where remediation is required. Template authoring per SPEC-12 must not introduce preventive framing for any Mold Remediation scenario.

**Contents** (`contents`)

| Display label | Internal enum value |
|---------------|---------------------|
| Pack-out | `pack_out` |
| Inventory management | `inventory_management` |
| Off-site cleaning | `off_site_cleaning` |
| Storage | `storage` |

**Structural Cleaning** (`structural_cleaning`)

| Display label | Internal enum value |
|---------------|---------------------|
| Post-fire soot and smoke | `post_fire_soot_smoke` |
| Post-water deep clean | `post_water_deep_clean` |

Note: Per Jeff's classification, fire and smoke cleanup is Structural Cleaning done on a burned building.

**General Cleaning** (`general_cleaning`)

| Display label | Internal enum value |
|---------------|---------------------|
| Commercial deep clean | `commercial_deep_clean` |
| Post-construction cleanup | `post_construction_cleanup` |
| Move-in / move-out | `move_in_move_out` |
| Recurring commercial service | `recurring_commercial_service` |
| Odor remediation | `odor_remediation` |
| HVAC cleaning | `hvac_cleaning` |

Note: `commercial_deep_clean` is one-time deep cleaning beyond normal janitorial scope. ServPro does not offer recurring janitorial service; the slug rename from the prior `commercial_janitorial_deep_clean` reflects that distinction. Recurring commercial service (`recurring_commercial_service`) remains in the master list for future tenant use but is not activated for Jeff's tenant per his explicit scope direction.

**Trauma / Biohazard** (`trauma_biohazard`)

| Display label | Internal enum value |
|---------------|---------------------|
| Asbestos abatement | `asbestos_abatement` |
| Lead abatement | `lead_abatement` |
| Biohazard (non-sewage) cleanup | `biohazard_non_sewage` |
| Trauma / crime scene | `trauma_crime_scene` |
| Meth / drug remediation | `meth_drug_remediation` |

Note: The sub-type was previously slugged `environmental_asbestos`. The rename to `trauma_biohazard` reflects v1 active scope: Jeff's tenant activates `trauma_crime_scene` only. The other four scenarios remain in the master list under this sub-type for future tenant activation. Per Jeff's classification: sewage is a Water Mitigation scenario (`sewage_backup`), not a biohazard scenario. Trauma / Biohazard covers blood, bodily fluids, biohazard exposure, and abatement work where the operational character is closer to trauma scene work than to water-event work.

**Temporary Repairs** (`temporary_repairs`)

| Display label | Internal enum value |
|---------------|---------------------|
| Board-up | `board_up` |
| Tarp | `tarp` |
| Emergency dry-out setup | `emergency_dry_out_setup` |
| Roof temporary cover | `roof_temporary_cover` |
| Glass replacement | `glass_replacement` |

### 7.3 Deferred Job Types (in master list, not activated for any v1 tenant)

| Display label | Internal enum value | Parent category |
|---------------|---------------------|-----------------|
| Reconstruction | `reconstruction` | Reconstruction |
| HVAC | `hvac` | HVAC |
| Plumbing | `plumbing` | Plumbing |
| Roofing | `roofing` | Roofing |
| Other | `other` | Other |

Deferred job types have no scenarios defined in v1. Scenarios for these sub-types are authored only when the sub-type is activated for a tenant.

---

## 8. Detailed Behavior

### 8.1 Field Label: "Job Type" replaces "Line of Business"

The current field is labeled "LINE OF BUSINESS" in the intake form and "Line of Business" in the campaign approval card. This label is replaced everywhere with **"Job Type"** for the following reasons:

- "Line of Business" implies a business category (restoration as an industry). "Job Type" correctly describes what is being captured: the type of work being estimated for this specific job.
- Jeff's team talks about jobs as "a water job," "a fire job," "a mold job," "a contents job" — not "a restoration line of business job."
- "Job Type" is unambiguous and maps directly to how originators think about their work.

**Every instance of "Line of Business" or "line of business" in the UI is replaced with "Job Type" or "job type."** This includes: the intake form field label, the campaign approval card, the Analytics filter dropdown label, and any internal display references. The `lob` query parameter name on the Analytics endpoint is retained for backward compatibility with the Lovable wiring (see PRD-07 §6.3); only the visible label changes.

### 8.2 New Job Intake — Review Step (Step 4)

Step 4 includes both Job Type and Scenario as required fields. Job Type is selected first; Scenario is scoped to the selected Job Type's activated scenarios.

**Job Type field**

Field label: "JOB TYPE" (required, red asterisk)

Picker options (Jeff's tenant): the five sub-types from §7.1. Sourced from the per-tenant activation join.

Helper text below field: "Determines how the automated follow-up campaign is configured."

Validation: Required. The Submit button (advancing to the Campaign Ready modal per PRD-02) is disabled until Job Type is selected.

No auto-fill from PDF. The AI extraction step (Step 3) does not populate this field.

One selection only. Single-select dropdown.

**Scenario field**

Field label: "SCENARIO" (required, red asterisk)

Picker options: the scenarios from §7.2 scoped to the selected Job Type, sourced from the per-tenant activation join. The Scenario picker is disabled until a Job Type is selected. When the operator changes Job Type, the Scenario selection clears and the Scenario picker repopulates with the new Job Type's scenarios.

Helper text below field: "Specifies the damage situation. Determines the campaign template variant."

Validation: Required once a Job Type is selected. The Submit button is disabled until both Job Type and Scenario are selected.

No auto-fill from PDF.

One selection only. Single-select dropdown.

UX placement and helper-text presentation (subtext under each option, side panel, etc.) are PRD-02 design decisions. The requirement here is that Scenario is required, scoped to Job Type, and selected at Step 4 alongside Job Type.

### 8.3 Job Card Display (Jobs List and Needs Attention)

**Current display:**
```
restoration   [status tag]
reconstruction   [status tag]
```

**New display (representative examples):**
```
water mitigation   [status tag]
mold remediation   [status tag]
structural cleaning   [status tag]
general cleaning   [status tag]
trauma / biohazard   [status tag]
contents   [status tag]
temporary repairs   [status tag]
```

Display format: lowercase, matching existing card style. The slash in "trauma / biohazard" renders as shown.

Scenario is not displayed on the job card in v1. Scenario is internal context for template resolution and analytics cohort attribution; surfacing it on the card adds visual noise without operational value at v1 scope.

### 8.4 Job Detail Header Subtitle

**Current format:**
```
Reconstruction • Flood Damage – Finished Basement • $37,900
```
(Job type • Job description • Proposal value)

**New format — same pattern, updated job type label (representative examples):**
```
Water Mitigation • [Job description] • $[Proposal value]
Mold Remediation • [Job description] • $[Proposal value]
Structural Cleaning • [Job description] • $[Proposal value]
General Cleaning • [Job description] • $[Proposal value]
Trauma / Biohazard • [Job description] • $[Proposal value]
Contents • [Job description] • $[Proposal value]
Temporary Repairs • [Job description] • $[Proposal value]
```

Capitalization in the header subtitle follows title case. Scenario is not displayed in the header subtitle in v1.

---

## 9. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| Job Type is required at intake | Submit (advance to Campaign Ready modal per PRD-02) is disabled until Job Type is selected. |
| Scenario is required at intake | Submit is disabled until Scenario is selected. Scenario picker is disabled until Job Type is selected. |
| Job Type and Scenario are never auto-filled | AI extraction does not populate either. Operator always selects explicitly. |
| Both fields are set once at intake | After campaign activation, neither can be changed without stopping the campaign. Edit behavior post-activation is out of scope. |
| Scenario list is scoped to Job Type | Scenario picker shows only the scenarios activated for the selected Job Type for the requesting tenant. |
| Five sub-types in Jeff's tenant v1 picker | General Cleaning, Mold Remediation, Structural Cleaning, Trauma / Biohazard, Water Mitigation. Contents and Temporary Repairs remain in the master list but are not activated for Jeff in v1 per the §10.3 activation gate. |
| Master lists are forward-compatible | Job type master list stores all seven Restoration sub-types (`contents`, `general_cleaning`, `mold_remediation`, `structural_cleaning`, `temporary_repairs`, `trauma_biohazard`, `water_mitigation`) plus deferred non-Restoration values (`reconstruction`, `hvac`, `plumbing`, `roofing`, `other`) as valid entries even when they are not activated for any v1 tenant. |
| "Job Type" label everywhere | Every instance of "Line of Business" is replaced with "Job Type." The `lob` query parameter name is retained internally for backward compatibility (see §8.1). |
| Lowercase on job cards | Job type label on list cards uses lowercase to match current convention. |
| Title case in headers and badges | Job type label in the job detail header subtitle and campaign approval card uses title case. |
| Active campaign template variant required per (job_type, scenario_key) tuple activated for any tenant | Per SPEC-11 v2.0, all activated (job type, scenario) combinations for a tenant must have an active template variant before that tenant goes live. Master scenarios with no active variant are permitted as long as no tenant has them activated. If no active variant exists for a tenant-activated tuple at template lookup, generation fails loudly per SPEC-11 v2.0. |
| Industry classifications never in customer prose | The `industry_classification` metadata field on scenario master list records is author-facing only. Templates must not reference IICRC, OSHA, EPA, or other technical industry standards in customer-facing prose. |
| Analytics filter label updates | "All Lines of Business" → "All Job Types." Filter options reflect the v1 active sub-type taxonomy for the requesting tenant (five for Jeff). Scenario-level filtering is not added in v1. |

---

## 10. Taxonomy Governance

**Source:** Reconciliation Report 2026-04-18, Finding #29. Locked decision per Decision Ledger 2026-04-20. Extended in v1.3 to cover scenarios. Refined in v1.3.2 with sub-type and scenario rename surgery and explicit acknowledgment that master list scope and per-tenant activation scope are distinct concerns.

### 10.1 Two-Layer Model (Job Types and Scenarios)

Both Job Types and Scenarios in SMAI follow a two-layer governance model. The two layers are distinct concerns and must not be collapsed in implementation.

**Layer 1: Global master list.** The canonical set SMAI supports across all tenants and all industries. SMAI-curated, not tenant-scoped. Grows monotonically over time as SMAI adds verticals. Every entry that is activated for any tenant has exactly one active campaign template variant when activated for that tenant (per SPEC-11 v2.0).

**Layer 2: Per-tenant activation.** Which subset of the master list a given tenant can use. Set by SMAI operators at tenant onboarding via the admin portal. Mutable post-onboarding by SMAI operators only, audit-logged. Not exposed to the customer.

This applies to both the job type taxonomy and the scenario taxonomy. Each has its own master list and its own activation join.

**Master list scope vs activation scope.** The master list is broader than any single tenant's active scope. A scenario can exist in the master list without being activated for any tenant (e.g., scenarios authored for future operator profiles or scenarios that one tenant uses but another doesn't). Template authoring per SPEC-12 v2.0 is tenant-activation-driven, not master-list-driven: variants are authored when a tenant activates the scenario, not when the scenario enters the master list.

### 10.2 Data Shape

- **Job type master list:** a global reference table with no `tenant_id` column. Entries cover all supported types across all industries.
- **Job type activation join:** a per-tenant table with columns minimally including `tenant_id`, `job_type_id` (FK to master list), `is_active`, `activated_at`, `activated_by`.
- **Scenario master list:** a global reference table with no `tenant_id` column. Each entry has a foreign key to the job type master list (a scenario belongs to exactly one job type) plus an `industry_classification` author-facing metadata field (see §13.2).
- **Scenario activation join:** a per-tenant table with columns minimally including `tenant_id`, `scenario_id` (FK to scenario master list), `is_active`, `activated_at`, `activated_by`.
- **Tenant Job Type dropdown query:** the New Job intake Job Type dropdown queries the job type activation join filtered by the requesting tenant.
- **Tenant Scenario dropdown query:** the New Job intake Scenario dropdown queries the scenario activation join filtered by the requesting tenant AND scoped to the selected Job Type.

Physical form (reference table vs Postgres enum, table layout, FK structure) is Mark's engineering decision. Product requires that adding or modifying a master list entry does not require a code deploy.

### 10.3 Rules and Non-Negotiables

| Rule | Detail |
|------|--------|
| Master lists are SMAI-curated | Entries are added, renamed, or deprecated by SMAI operators only. A change to a master list is a doctrine-level change and requires a SPEC-03 revision. |
| Tenant activation is SMAI-curated | Activation changes are made by SMAI operators in the admin portal. No operator-facing self-service. No ORG_ADMIN CRUD. |
| Tenant dropdowns scoped to activation | The tenant's Job Type and Scenario dropdowns return only the subset of each master list activated for that tenant. A tenant never sees a value they do not have activated. |
| Scenario scoped to its parent job type | A scenario belongs to exactly one job type. Activating a scenario for a tenant requires that the parent job type is also activated for that tenant. Deactivating a job type also implicitly hides its scenarios from intake (whether the scenario activations are auto-cascaded is an engineering decision; product requires the dropdown behavior). |
| Sub-type activation requires at least one activated scenario | (v1.3.3) The symmetric rule to the row above. A sub-type may be activated for a tenant only if at least one scenario under that sub-type is also activated for that tenant. Activating a sub-type with zero activated scenarios produces an empty Scenario dropdown at intake (operational dead end) or, if scenarios exist in the master list but are not activated for the tenant, triggers the SPEC-11 v2.0 loud-failure path mid-intake. Both outcomes are unacceptable. PRD-10's tenant configuration UI must enforce this gate at activation time: attempting to activate a sub-type with no activated scenarios for the tenant is a validation error. Deactivating the last activated scenario under a sub-type also implicitly deactivates the sub-type for that tenant (whether the cascade is auto or requires SMAI operator confirmation is an engineering decision; product requires the dropdown behavior). |
| No per-location differentiation in v1 | Activation is per-tenant, not per-location. Per-location differentiation is explicitly out of scope for v1. |
| Campaign templates keyed to (job_type, scenario_key) | Per SPEC-11 v2.0, one active template variant per (job_type, scenario_key) tuple, globally. Activation for a tenant grants access to the tuple and its global template. Tenant-specific template variants are out of scope for v1. Per-tenant variable strings (phone, signature, hours) are injected as job context fields at template render time, not template forks. |
| Master list scope and activation scope are distinct | A scenario in the master list with no template variant is permitted as long as it is also not activated for any tenant. Template authoring is gated on tenant activation, not master list presence. |
| Historical jobs retain their values | A job type or scenario that is deactivated for a tenant, or deprecated from the master list, does not alter historical `job_type` or `scenario_key` values on `job_proposals`. Historical records remain legible. |
| Master list deprecation is non-destructive | Removing an entry marks it deprecated and prevents new activations. Existing tenant activations and historical jobs are unaffected. |
| Scenario rename within master list | A scenario or sub-type rename within the master list is a SPEC-03 revision (per row 1 of this table). The internal enum value changes; existing tenant activations migrate to the new value at the same database transaction; historical job records carry the old value for audit but are not re-mapped. v1.3.2's `commercial_janitorial_deep_clean` → `commercial_deep_clean` and `environmental_asbestos` → `trauma_biohazard` renames follow this pattern. Buc-ee's is a net-new tenant with no production records using the old slugs, so no migration of historical jobs is required. |

### 10.4 What This Replaces

The `admin/JobTypeController.kt` CRUD endpoints (`POST`, `PUT`, `DELETE` at `/admin/job-types/{tenantId}`, gated `GLOBAL_ADMIN`) are retained and repurposed as the backend surface for the admin portal Job Type activation UI. Scenario activation requires analogous endpoints; specification of those endpoints lives in PRD-10 v1.3. They are no longer unspecced scaffolding.

The frontend `LINES_OF_BUSINESS` hard-coded array in `NewJobModalMVP.tsx` and the `LOB_VALUE_TO_LABEL` all-to-one Restoration UUID mapping in `Jobs.tsx` are deleted. The Job Type dropdown sources from `useJobTypes()` against the activation join. The Scenario dropdown sources from a parallel hook (e.g., `useScenarios(jobTypeId)`) against the scenario activation join.

### 10.5 Non-Goals

- Operator-facing job type or scenario CRUD (not in Settings, not anywhere tenant-facing).
- Per-location activation differentiation.
- Tenant-specific campaign template variants.
- Automated activation changes based on customer self-service requests.
- Job type or scenario inference from proposal content.

---

## 11. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| Operator submits New Job without selecting Job Type or Scenario | Submit is disabled. If somehow submitted, backend validates presence of both fields and returns a validation error. Frontend highlights the missing fields. |
| Operator selects Job Type then changes it | Scenario selection clears. Scenario picker repopulates with the new Job Type's scenarios. Submit re-disabled until Scenario is reselected. |
| Existing jobs with legacy `job_type` values from prior taxonomy versions | Folding rules for legacy values: `restoration` → display as legacy; `water_damage` → migrate to `water_mitigation` (closest analog); `fire_smoke` → migrate to `structural_cleaning` (per Jeff's classification: fire and smoke is structural cleaning); `storm_damage` → migrate to `water_mitigation` with `scenario_key = storm_related_flooding`; `biohazard_sewage` → split case (sewage scenarios → `water_mitigation` / `sewage_backup`; biohazard scenarios → `trauma_biohazard` / `biohazard_non_sewage`); `contents_packout` → migrate to `contents` with `scenario_key = pack_out`; `specialty_cleaning` → migrate decision is per-record (most likely `general_cleaning` or `structural_cleaning` depending on description); `environmental_asbestos` (legacy slug per pre-v1.3.2) → migrate to `trauma_biohazard` (one-to-one rename); `commercial_janitorial_deep_clean` (legacy slug per pre-v1.3.2) → migrate to `commercial_deep_clean` (one-to-one rename). Mark decides whether migration is one-time bulk or leave-as-legacy per Open Questions §17. |
| Existing jobs with no `scenario_key` (created before v1.3) | Not applicable to Buc-ee's pilot or any v1.3 production tenant. `scenario_key` is NOT NULL on `job_proposals` per §13.1 and PRD-01 v1.4.1 §8.1. There is no production legacy backlog. If a future tenant arrives with pre-v1.3 records, those records get `scenario_key` populated at onboarding migration before the column constraint is enforced. No runtime null handling exists. |
| Campaign engine receives a (job_type, scenario_key) tuple with no active template variant | Per SPEC-11 v2.0, generation fails loudly with a logged error. Operator sees "Campaign could not be generated. Contact support." No fallback campaign is sent. |
| Operator selects Water Mitigation but the proposal is clearly a different sub-type | SMAI does not validate or override the operator's selection. The operator's explicit choice governs. This is an operational training issue, not a product validation issue. |
| Deferred job type (e.g., `hvac`, `reconstruction`) is somehow passed to the API | Backend accepts it as a valid master-list value (forward compatibility). Frontend picker does not show it. If somehow stored on a job record, the display falls back to the raw enum value label. |
| Scenario master list entry has `industry_classification` populated | Field is read by template authoring workflow only (per SPEC-12). Field is never returned in any operator-facing or customer-facing API response or render. |
| Analytics filter selection for a job type with zero jobs in the current period | Empty state in analytics charts and tables. No error. The filter option is hidden in PRD-07 if zero jobs exist for that type in scope (per PRD-07 §6.3). |
| Master scenario activated for a tenant has no active template variant | Per SPEC-11 v2.0, this is a launch defect. The activation should not have happened without an active variant. If it does happen, generation fails loudly when a job in that scenario tries to launch a campaign. The fix is either to deactivate the scenario for that tenant or to author the missing variant. |
| Sub-type activated for a tenant with no activated scenarios under it | (v1.3.3) Prevented by the §10.3 sub-type activation gate. PRD-10's tenant configuration UI rejects sub-type activation with no activated scenarios as a validation error. If somehow the gate is bypassed (engineering bug, manual DB write), the operator-facing Scenario dropdown returns empty after the operator selects the sub-type at intake; Submit remains disabled because Scenario is required (per §9). The fix is to either activate at least one scenario under the sub-type or deactivate the sub-type for that tenant. |

---

## 12. UX-Visible Behavior

### New Job intake — Step 4, Job Type field

| State | Visible |
|-------|---------|
| Default | "Select job type" placeholder, required indicator (red asterisk) |
| Dropdown open | Options sourced from tenant activation. For Jeff's tenant in v1: General Cleaning, Mold Remediation, Structural Cleaning, Trauma / Biohazard, Water Mitigation (five options). |
| Option selected | Selected label shown in field. Helper text: "Determines how the automated follow-up campaign is configured." |
| Submit attempted without selection | Field highlighted with error indicator. Submit remains disabled. |

### New Job intake — Step 4, Scenario field

| State | Visible |
|-------|---------|
| Default (no Job Type selected) | Picker disabled. Helper text indicates Job Type must be selected first. |
| Job Type selected, Scenario default | "Select scenario" placeholder, required indicator (red asterisk) |
| Dropdown open | Scenarios sourced from tenant activation, scoped to selected Job Type (set defined in §7.2) |
| Option selected | Selected label shown in field. Helper text: "Specifies the damage situation. Determines the campaign template variant." |
| Job Type changed after Scenario selected | Scenario field clears. Picker repopulates with new Job Type's scenarios. Submit re-disabled. |
| Submit attempted without Scenario | Field highlighted with error indicator. Submit remains disabled. |

### Job card (Jobs List and Needs Attention)

| Field | Display |
|-------|---------|
| Job type label | Lowercase: "water mitigation," "mold remediation," "structural cleaning," "general cleaning," "trauma / biohazard." (Contents and Temporary Repairs labels remain in the label dictionary for forward compatibility but are not displayed for Jeff's tenant in v1.) |
| Position | Below address line, left of status tag — unchanged from current layout |
| Scenario | Not displayed on the job card in v1 |

### Job detail header

| Field | Display |
|-------|---------|
| Job type in subtitle | Title case: "Water Mitigation • [description] • $[value]" (or the corresponding sub-type label) |
| Scenario | Not displayed in the header subtitle in v1 |

### Campaign approval card (Campaign Ready modal)

| Field | Display |
|-------|---------|
| Field label | "JOB TYPE" (replaces "LINE OF BUSINESS") |
| Job type badge | Teal badge showing the selected sub-type label |
| Scenario | Shown adjacent to the job type so the operator can confirm both selections before approving the plan; exact placement is a PRD-02 design decision |
| Goal | "Convert proposal to booked work" — unchanged |

### Analytics filter

| Field | Display |
|-------|---------|
| Filter button label | "All Job Types" (replaces "All Lines of Business") |
| Dropdown options | All Job Types / Contents / General Cleaning / Mold Remediation / Structural Cleaning / Temporary Repairs / Trauma / Biohazard / Water Mitigation |

Analytics filter options are further narrowed at runtime to types with at least one active job in scope, per PRD-07 §6.3. Scenario-level filtering is not added in v1.

---

## 13. Data Model Notes

### 13.1 `scenario_key` on `job_proposals`

A new `scenario_key` field is added to the `job_proposals` table, storing the scenario master list identifier. The field is NOT NULL for all job records: every job created under v1.3 carries a `scenario_key`. There is no legacy nullable allowance. Buc-ee's is a net-new tenant with no pre-v1.3 production records; if a future tenant arrives with pre-v1.3 data, that is a one-time schema migration at onboarding, not a structural carve-out in the canonical contract. This aligns with PRD-01 v1.4.1 §8.1.

Physical form (FK to scenario master list table vs string enum vs UUID) is Mark's engineering decision. Product requires that the field uniquely identifies one scenario record in the master list and is queryable for analytics cohort attribution.

### 13.2 `industry_classification` on scenario master list records

A new `industry_classification` field is added to the scenario master list record. The field is author-facing metadata only. Examples: `IICRC S500` for water mitigation scenarios, `IICRC S520` for mold remediation scenarios, `IICRC S540` for trauma scene scenarios, `OSHA 29 CFR 1926.1101` for asbestos abatement, `EPA RRP Rule` for lead abatement.

The field informs template authors per SPEC-12 v2.0 about the relevant industry standards governing each scenario. It never appears in customer-facing prose, never appears in operator-facing UI, and is not returned in any API response consumed by the operator-facing app.

Physical form (single string vs structured array vs JSON column) is Mark's engineering decision. Product requires that the field is readable by SMAI internal authoring workflows and not exposed in tenant-facing surfaces.

### 13.3 Job type enum

The job type master list contains all seven Restoration sub-types from the global taxonomy (`contents`, `general_cleaning`, `mold_remediation`, `structural_cleaning`, `temporary_repairs`, `trauma_biohazard`, `water_mitigation`) plus the five deferred non-Restoration values from §7.3 (`reconstruction`, `hvac`, `plumbing`, `roofing`, `other`), for twelve valid entries total. For Jeff's tenant in v1, only five of the seven Restoration sub-types are activated (per §7.1 and the §10.3 sub-type activation gate): `general_cleaning`, `mold_remediation`, `structural_cleaning`, `trauma_biohazard`, `water_mitigation`. `contents` and `temporary_repairs` remain in the master list available for future tenant activation but are not activated for Jeff.

Adding HVAC, Plumbing, Roofing, Reconstruction, or Other to a future tenant's picker is a master-list activation change in the admin portal, not a code change.

The v1.3.2 sub-type rename (`environmental_asbestos` → `trauma_biohazard`) is a master-list update propagated via SPEC-03 revision per §10.3. The rename does not affect deferred sub-types.

---

## 14. Implementation Slices

### Slice A — Backend: Job type and scenario master lists, activation joins
**Purpose:** Establish the master lists and per-tenant activation joins for both job types and scenarios.
**Components touched:** Database schema; job type master list table or enum; scenario master list table; activation join tables for both.
**Key behavior:** Master lists populated with v1 values per §7.1, §7.2, and §7.3, including the v1.3.2 renames (`environmental_asbestos` → `trauma_biohazard`; `commercial_janitorial_deep_clean` → `commercial_deep_clean`). Jeff's tenant activated for the five v1 active sub-types (§7.1) and the v1 scenario subset enumerated in PRD-10 v1.3 (17 scenarios). The two unactivated Restoration sub-types (`contents`, `temporary_repairs`) and the deferred non-Restoration sub-types remain in the master list, not activated for Jeff. The §10.3 sub-type activation gate is enforced at activation time: a sub-type is activated for a tenant only if at least one scenario under it is also activated.
**Dependencies:** None. Foundation for all other slices.
**Excluded:** Frontend. Templates. API changes.

### Slice B — Backend: Job type and scenario on API responses and filter support
**Purpose:** Expose `job_type` and `scenario_key` correctly and accept them as required intake inputs.
**Components touched:** Jobs list endpoint; job detail endpoint; analytics endpoint; New Job intake endpoint; tenant dropdown query endpoints.
**Key behavior:** All job responses include `job_type` and `scenario_key`. Jobs list and analytics endpoints accept `job_type` as a filter parameter (query param name `lob` retained on the analytics endpoint for backward compatibility per PRD-07 §6.3). Validation rejects job creation if either field is absent. Two new dropdown endpoints expose the tenant-activated job type list and the tenant-activated scenario list (scoped by job type).
**Dependencies:** Slice A complete.
**Excluded:** Frontend. Templates.

### Slice C — Backend: Template lookup integration with (job_type, scenario_key)
**Purpose:** Wire the campaign engine's template lookup to use the (`job_type`, `scenario_key`) tuple per SPEC-11 v2.0.
**Components touched:** Campaign engine template resolver.
**Key behavior:** When resolving a template for a job, the engine looks up the active template variant for the (`job_type`, `scenario_key`) tuple. Failure modes per SPEC-11 v2.0.
**Dependencies:** Slice A complete. SPEC-11 v2.0 template architecture in place.
**Excluded:** Frontend. Template authoring (per SPEC-12 v2.0).

### Slice D — Frontend: Job Type and Scenario pickers in New Job intake
**Purpose:** Replace the current six-option picker with the v1 active job types for Jeff's tenant (five sub-types) AND add the Scenario picker as a second required field.
**Components touched:** New Job wizard Step 4.
**Key behavior:** Job Type dropdown shows the v1 active sub-types from tenant activation (five for Jeff's tenant per §7.1). Scenario dropdown is disabled until Job Type is selected, then shows the activated scenarios for the selected Job Type. Both fields required. Field labels per §8.2. No auto-fill from AI extraction for either. Job Type change clears Scenario.
**Dependencies:** Slice B complete.
**Excluded:** All other UI surfaces. Backend validation.

### Slice E — Frontend: Job type label updates across all surfaces
**Purpose:** Display the correct job type label everywhere it appears.
**Components touched:** Job card (Jobs List); job card (Needs Attention); job detail header subtitle; Campaign Ready modal job type badge; Analytics Job Type filter.
**Key behavior:** All surfaces read `job_type` from the API and display the correct label. Casing per §8.3 and §8.4. "Line of Business" replaced with "Job Type" everywhere. Analytics filter options reflect the v1 active sub-type taxonomy for the requesting tenant (five sub-types for Jeff) and are narrowed at runtime to types with active data. Scenario is not displayed on cards or header in v1.
**Dependencies:** Slices B and D complete.
**Excluded:** Backend. Templates.

---

## 15. Acceptance Criteria

**Given** an Originator on Step 4 of the New Job wizard for Jeff's tenant,
**When** the Job Type picker is opened,
**Then** exactly five options are shown: General Cleaning, Mold Remediation, Structural Cleaning, Trauma / Biohazard, Water Mitigation. No other options appear. (Contents and Temporary Repairs are not activated for Jeff's tenant in v1 per the §10.3 sub-type activation gate.)

**Given** an Originator on Step 4 with no Job Type selected,
**When** the Scenario picker is inspected,
**Then** the picker is disabled. Helper text indicates Job Type must be selected first.

**Given** an Originator on Step 4 who selects "Water Mitigation,"
**When** the Scenario picker is opened,
**Then** the six Water Mitigation scenarios from §7.2 are shown: Clean water flooding, Gray water, Sewage backup, Pipe burst, Appliance failure, Storm-related flooding.

**Given** an Originator on Step 4 who selects "Trauma / Biohazard,"
**When** the Scenario picker is opened,
**Then** the activated Trauma / Biohazard scenarios for the requesting tenant are shown. For Jeff's tenant in v1, only Trauma / crime scene is activated; the other four master scenarios under this sub-type are not shown.

**Given** an Originator on Step 4 who has selected Water Mitigation and Sewage backup,
**When** they change Job Type to "Mold Remediation,"
**Then** the Scenario field clears and the Scenario picker repopulates with the activated Mold Remediation scenarios.

**Given** an Originator who has not selected both Job Type and Scenario,
**When** they attempt to submit Step 4,
**Then** Submit is disabled and the missing fields show error indicators.

**Given** an Originator who selects "Water Mitigation" and "Sewage backup" and completes intake,
**When** the Campaign Ready modal renders,
**Then** the summary shows "JOB TYPE" as the field label and "Water Mitigation" in the badge. "LINE OF BUSINESS" and "Restoration" do not appear anywhere. The Scenario "Sewage backup" is shown adjacent so the operator can confirm both selections before approving.

**Given** a job with type "Mold Remediation" in the Jobs List,
**When** the job card renders,
**Then** the type label reads "mold remediation" in lowercase, consistent with existing card label style. Scenario is not displayed on the card.

**Given** a job with type "Trauma / Biohazard" in the Jobs List,
**When** the job card renders,
**Then** the type label reads "trauma / biohazard" in lowercase. The slash renders as shown.

**Given** a job with type "Water Mitigation" in the Job Detail view,
**When** the header subtitle renders,
**Then** it reads "Water Mitigation • [job description] • $[proposal value]" in title case. Scenario is not displayed in the subtitle.

**Given** an Admin on the Analytics screen,
**When** the Job Type filter dropdown is opened,
**Then** the options are: All Job Types, Contents, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Trauma / Biohazard, Water Mitigation. Prior labels do not appear.

**Given** the campaign engine receives a job with `job_type = water_mitigation` and `scenario_key = sewage_backup` and an active template variant exists for that tuple,
**When** template resolution runs,
**Then** the matching template variant is returned and used for email rendering per SPEC-11 v2.0.

**Given** the campaign engine receives a job with a (job_type, scenario_key) tuple for which no active template variant exists,
**When** template resolution runs,
**Then** resolution fails loudly with a logged error per SPEC-11 v2.0. The operator sees "Campaign could not be generated. Contact support." No fallback campaign is sent.

**Given** any screen that previously showed "Line of Business" as a label,
**When** the spec is fully implemented,
**Then** "Line of Business" appears nowhere in the product UI. All instances read "Job Type."

**Given** a scenario master list record with `industry_classification` populated,
**When** any operator-facing or customer-facing API response is inspected,
**Then** the `industry_classification` value does not appear in the response payload.

**Given** the master scenario list,
**When** Jeff's tenant activation join is queried,
**Then** the activated scenarios are a subset of the master list per PRD-10 v1.3 §12.6 enumeration. Scenarios in the master list that are not in the activation join are not visible to Jeff's operators in the Scenario picker.

---

## 16. System Boundaries

| Responsibility | Owner |
|----------------|-------|
| Updating the job type master list to include all v1 active and deferred values | smai-backend (Mark) |
| Creating the scenario master list with the v1 scenario set per §7.2 and the `industry_classification` field per §13.2 | smai-backend (Mark) |
| Per-tenant activation joins for both job types and scenarios | smai-backend (Mark) |
| Storing `job_type` and `scenario_key` on the job record at creation time | smai-backend (Mark) |
| Validating both fields are present before campaign generation | smai-backend (Mark) |
| Exposing `job_type` and `scenario_key` in the job record API response | smai-backend (Mark) |
| Tenant Job Type dropdown query endpoint | smai-backend (Mark) |
| Tenant Scenario dropdown query endpoint (scoped by job_type) | smai-backend (Mark) |
| Supporting `job_type` as a filter parameter on the jobs and analytics endpoints (analytics endpoint uses `lob` query param name for backward compat) | smai-backend (Mark) |
| Template lookup by (`job_type`, `scenario_key`) tuple per SPEC-11 v2.0 | smai-backend / Campaign Engine (Mark) |
| Curating job type and scenario master list values | SMAI internal operations (Kyle / Ethan) |
| Activating tenant-specific subsets of master lists at onboarding via admin portal | SMAI internal operations (per PRD-10 v1.3) |
| Authoring campaign template variants per (job_type, scenario_key) tuple activated for any tenant | SMAI internal operations (per SPEC-12 v2.0) |
| Rendering the updated Job Type picker in the New Job intake wizard | Frontend |
| Rendering the new Scenario picker in the New Job intake wizard | Frontend |
| Displaying the correct job type label on all UI surfaces | Frontend |
| Updating the Analytics filter label and options | Frontend |
| Replacing all "Line of Business" label instances with "Job Type" | Frontend |

**Engineering decisions (not product scope):** physical form of master lists and activation joins (reference table vs enum, table layout, FK structure). Migration approach for legacy `job_type` values per §11 folding rules.

---

## 17. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Physical form of the job type and scenario master lists | Engineering decision | Reference tables recommended given the scale trajectory across industries and the second taxonomy layer. Enum + lookup table pattern also acceptable. Product requires that adding a new master list entry does not require a code deploy. |
| Existing `job_types` table migration path | Engineering decision | Carries forward from v1.2. Mark decides whether to reshape the existing `job_types` table into the activation join or create the join net-new. New work for v1.3: create the parallel scenario master list and scenario activation join. New work for v1.3.2: apply sub-type and scenario rename (`environmental_asbestos` → `trauma_biohazard`; `commercial_janitorial_deep_clean` → `commercial_deep_clean`) to master list. |
| Migration of legacy `job_type` values | Engineering decision | Per §11 folding rules. Mark decides bulk migration vs leave-as-legacy. Bulk migration recommended if any legacy records need to remain operationally active; leave-as-legacy acceptable if all legacy records are test data that will be cleared before go-live. |
| Cascade behavior when a job type is deactivated for a tenant | Engineering decision | When a tenant's job type activation is removed, do the scenario activations for that job type auto-deactivate, or remain in the join as orphans? Product requires that the dropdowns behave correctly (deactivated job type does not appear; its scenarios do not appear). The internal join structure is Mark's call. |
| Active campaign template variant required per (job_type, scenario_key) | Operational prerequisite | Per SPEC-11 v2.0 and SPEC-12 v2.0, all activated (job_type, scenario_key) tuples for a tenant must have an active template variant before that tenant goes live. If templates are not ready for some scenarios, those scenarios should not be activated for the tenant. Scenarios in the master list that are not activated for any tenant do not require active variants. Phased authoring per Jeff's tier priorities is captured in SPEC-12 v2.0 and the SMAI Save State 2026-04-21 §7. |
| Job type and scenario edit behavior after campaign activation | Out of scope for v1 | If an originator selects the wrong combination, the current path is to stop the campaign and create a new job. Edit flow post-activation is not in scope. |
| Scenario-level analytics filtering | Out of scope for v1 | Analytics in v1 filters by job type only. Scenario-level filtering is a future PRD-07 revision. Cohort attribution by `template_version_id` (per SPEC-11 v2.0) is the analytics path for per-scenario performance. |
| Per-location activation differentiation for either taxonomy | Out of scope for v1 | Activation is per-tenant. Per-location is a future enhancement requiring SPEC-03 revision. |

---

## 18. Out of Scope

- Building campaign content, email copy, or template variants for any sub-type or scenario (covered by SPEC-11 v2.0 and SPEC-12 v2.0)
- Any campaign configuration UI for operators
- AI inference or auto-detection of job type or scenario from the proposal PDF
- Reconstruction, HVAC, Plumbing, Roofing, or Other vertical support in the v1 picker
- Further subdivision within any scenario (e.g., Category 1/2/3 within `clean_water_flooding`)
- Multi-type or multi-scenario jobs (one job, one type, one scenario — always)
- Job type or scenario edit after campaign activation
- Scenario display on job cards or in the job detail header subtitle in v1
- Scenario-level analytics filtering in v1
- Sub-type or scenario grouping UI (no nested dropdowns, no parent/child pickers — flat lists)
- Any changes to stop conditions, the campaign approval flow, or the job status model
- Originator-facing explanation of what each job type or scenario means or when to use it (training/onboarding responsibility)
- Operator-facing surfacing of the `industry_classification` author metadata
- Per-location activation differentiation
- Tenant-specific template variants
```

---

