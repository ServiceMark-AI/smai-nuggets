# PRD-06: Job Detail
**Version:** 1.3.1  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked); Session State v6.0; Spec 8 (Job Detail Screen and Sub-Flows) [legacy out-of-repo reference; superseded by this PRD §6 through §13]; Spec 14 (Error States and Edge Conditions) [legacy out-of-repo reference; no canonical in-repo successor; error states for the launch build are governed inline in this PRD's §11 sub-flows and §13.2 edit failure handling]; Spec 16 (System Events and Audit Logging) [legacy out-of-repo reference; superseded by PRD-01 v1.4.1 §12 canonical `job_proposal_history` schema and event_type enum]; Spec 17 (Workflow Event Map) [legacy out-of-repo reference; superseded by PRD-01 v1.4.1 §12 event_type enum and PRD-03 v1.4.1 §10 stop conditions]; PRD-01 v1.4.1 (Job Record); PRD-02 v1.5 (New Job Intake); PRD-03 v1.4.1 (Campaign Engine); SPEC-03 v1.3 (Job Type and Scenario); SPEC-09 (Mark Won/Lost CTA Visibility); SPEC-11 v2.0 (Campaign Template Architecture); Reconciliation Report 2026-04-16; Save State 2026-04-21 (Pending Approval elimination; templated architecture)  
**Related PRDs and specs:** PRD-01 v1.4.1 (Job Record), PRD-02 v1.5 (New Job Intake), PRD-03 v1.4.1 (Campaign Engine), PRD-04 (Needs Attention), PRD-05 (Jobs List); SPEC-03 v1.3, SPEC-08 (Office Location Display Bug — Display Name Priority), SPEC-09, SPEC-11 v2.0, SPEC-12 v1.0  
**Closes:** 7 TODOs in `EditJob.tsx`  
**Revision note (v1.1):** Removed `draft`, `awaiting_estimate`, `attach_estimate`, and `complete_job_setup` from header CTA table, pipeline tracker, Next Action Panel, Edit Job field table, activity timeline, and ACs. Added `review_plan` / Pending Approval. Updated LOB and email locking rules to reflect that all fields are locked at job creation. Removed Upload Estimate sub-flow from this build. Added Plan Review sub-flow (Section 11.6).  
**Revision note (v1.2):** Aligned history references to the consolidated `job_proposal_history` table per PRD-01 v1.2 §12. All writes previously split between `job_status_history` and `event_logs` now land in `job_proposal_history` discriminated by `event_type`. Activity Timeline reads from `job_proposal_history` directly. Added physical table naming clarifier to §4. Added SPEC-09 cross-reference to Mark Won / Mark Lost placement. See DL-026, DL-027.  
**Revision note (v1.3):** Three related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, PRD-01 v1.4, PRD-02 v1.5, and PRD-03 v1.4 drive. Nothing else.

1. **Pending Approval eliminated across all Job Detail surfaces.** Per PRD-01 v1.4, no job record ever sits in a Pending Approval state. Removed the `review_plan` row from the §6.2 header CTA table. Removed the Pending Approval row from the §7.1 pipeline tracker visual stages and the corresponding bullet in §7.3 current stage determination. Removed the Pending Approval Panel from §9.1. Removed `campaign_plan_generated` from the §10.1 timeline display. Removed §11.3 Plan Review sub-flow entirely — this surface moved to PRD-02 v1.5 §8.4 (Campaign Ready surface, owned by intake). Removed AC-06 and AC-07 (both were Plan Review ACs). Removed Slice F (Plan Review sub-flow). §15 system boundaries updated.

2. **Scenario field added to Job Detail.** Per SPEC-03 v1.3 and PRD-01 v1.4, `scenario_key` is a required, locked-after-creation field on `job_proposals`. §8.3 Incident Details adds a Scenario row; §13.1 Edit Job field list adds the Scenario row with locked status; new AC added for the scenario lock.

3. **Variable step count replaces hardcoded four-step cadence.** Per SPEC-11 v2.0 and PRD-03 v1.4, step count and cadence are sourced from the active template variant. §9.1 In Campaign Panel and §9.2 send progress updated: "Follow-up N of 4" becomes "Follow-up N of M" where M is the total step count from the active template variant (readable from `campaign_steps` for the active `job_campaigns`). §10.1 `campaign_completed` display text and AC-03 updated accordingly. §19 OQ-03 cleanup.

Material section changes in v1.3: §1 (sub-flow list, introductory framing), §2 (builder points on sub-flows and Pending Approval), §3 (Plan Review sub-flow removed from scope list), §4 (locked constraints for scenario), §6.2 (review_plan row removed), §7.1 and §7.3 (Pending Approval stage removed), §8.3 (scenario row added), §9.1 and §9.2 (Pending Approval Panel removed, variable step count), §10.1 (campaign_plan_generated removed, campaign_completed language updated), §11.3 (sub-flow removed; §11 introductory paragraph updated), §13.1 (scenario row added), §15 (plan review row removed from boundaries), §17 (Slice F removed; minor language updates), §18 (AC-03 wording updated, AC-06 and AC-07 removed, new AC added for scenario lock), §19 (OQ-03 wording updated).

**Revision note (v1.3.1):** Surgical consistency cleanup per CONSISTENCY-REVIEW-2026-04-22. Three edits, no logic changes:

1. **Office Location rendering aligned to SPEC-08 (B-05).** §8.5 row 3 rewritten to use the `display_name` priority rule: `locations.display_name` if non-null and non-empty, else `locations.name`, for `jobs.location_id`. Per SPEC-08 §7.1 and §8.2. PRD-06 v1.3 read literally as `locations.name` only, which would have recreated the very bug SPEC-08 was authored to fix once tenant data carries `display_name` values (e.g., the PRD-10 Servpro seed of "SERVPRO® of Northeast Dallas").

2. **SPEC-08 added to related-docs list (H-10).** SPEC-08 now appears in the Related PRDs and specs header line.

3. **"Customer Waiting" → "Reply Needed" at three operational sites (L-06).** Updated lines 32 (§1 prose describing the state), 46 (§2 builder point 3 referencing the state by old label), and 286 (§9.1 Customer Waiting Panel header) to use the canonical "Reply Needed" UI label per Lovable ground truth. The `cta_type = open_in_gmail` value, the `status_overlay = customer_waiting` enum value, and historical revision-note references are unchanged per the locked rename convention.

Patch note (2026-04-22): B-05 + H-10 + L-06. Ref CONSISTENCY-REVIEW-2026-04-22.

**Patch note (2026-04-23):** Two changes; no behavioral change. (1) H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1` and `PRD-03 v1.4` → `PRD-03 v1.4.1` to match the parallel patches. Audit-trail revision-note text preserved byte-exact. (2) M2P-08 L-01 legacy annotations applied to §0 source-truth line: Specs 8, 14, 16, 17 each annotated as out-of-repo references with their canonical in-repo successor (or noted as deferred / no-successor where applicable). Matches the L-01 treatment PRD-01 v1.4.1 received on 2026-04-22. No version bump on PRD-06 (sweep + annotation are pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01, M2P-08.

**Patch note (2026-04-23, M2P-07 color convention):** §9.1 Next Action Panel badge color descriptors normalized to canonical name + hex pairs per PRD-05 §10. All six panel descriptors now read `Badge: <Status> (<Name> / <#hex>)`: Reply Needed (Coral / `#F56B4B`), Delivery Issue (Red / `#E53935`), Paused (Amber / `#F5A623`), In Campaign (Teal / `#00B3B3`), Won (Green / `#27AE60`), Lost (Gray / `#9CA3AF`, outline style — per PRD-05 §10). The Lost panel descriptor includes the explicit `outline style` cue per the PRD-05 §10 canonical extension made in the same patch cycle (`Style` column added with default `solid`, Lost = `outline`); this preserves the de-emphasis intent the prior PRD-04 v1.2.1 text expressed via `Gray outline`. The name + hex format keeps the docs human-readable while pinning exact values; iterations earlier in this patch cycle that briefly tried hex-only were superseded. Closes the cross-doc naming drift the review flagged where PRD-06 used "coral/red/amber" while PRD-04 §8 used "Red/Red/Orange/Teal" for the same badges, and closes the M2P-07 follow-up gap (outline-vs-fill for Lost). The `fix_delivery_issue` CTA-button styling note at line 176 (`teal, prominent`) is a button-style descriptor not a badge color and was deliberately not converted; pipeline stage tracker color descriptors at §7.2 / §7.3 (Won = green, Lost = gray) reference the same canonical hex set but are stage-tracker primitives outside the badge-spec governance of PRD-05 §10 and were not converted in this patch. No behavioral change. Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-07.

---

## 1. What This Is in Plain English

Job Detail is the operational command center for a single job. It is a full-page view — not a modal, not a drawer — that shows the operator everything about one job on one screen.

It has three jobs: show where the job sits in the pipeline, make clear whether the operator needs to act, and give the operator every sub-flow they might need without navigating away.

The screen has eight components arranged vertically: a header bar, a pipeline stage tracker, six content sections (customer info, property info, incident details, insurance, classification, notes and attachments), a next action panel with campaign controls, and an activity timeline. Every component renders on every job, every status, every overlay. Nothing is hidden based on job type or vertical.

Below the main content are three sub-flows that open in place (modal or slide-out) without navigating away: Fix Delivery Issue, Pause Campaign confirmation, and Resume Campaign confirmation. A fourth sub-flow, Edit Job, opens as a slide-out panel from "Edit Details" in the header. The Reply Needed state does not use a sub-flow — it surfaces an "Open in Gmail" CTA that opens the Gmail thread directly.

Campaign plan approval lives in the New Job intake flow per PRD-02 v1.5 §8.4 (Campaign Ready surface) rather than on Job Detail. Under the collapsed intake flow, no job record is written until the operator approves the plan at intake, so Job Detail never sees a job sitting in a Pending Approval state.

The screen also hosts the Mark Won / Mark Lost outcome actions, which are accessible from the header "Update Outcome" button and the overflow menu. These are always-visible secondary actions governed by SPEC-09, not `cta_type` values.

---

## 2. What Builders Must Not Misunderstand

1. **Job Detail is always a full-page view, never a modal.** It lives at `/jobs/:jobId` or `/:locationId/jobs/:jobId`. Nothing opens Job Detail as a drawer or overlay. See PRD-05 and Spec 13.

2. **The header CTA and the Next Action Panel CTA must always match.** Both derive from `jobs.cta_type` via the shared CTA engine. If they show different actions, the CTA engine result is wrong or is being recomputed inconsistently. There is one source of truth: the stored `cta_type` field.

3. **The Next Action Panel has a different priority order than PRD-01's CTA ladder in one respect.** Spec 8 lists Delivery Issue as the highest-priority panel state, above Reply Needed. PRD-01's CTA priority ladder lists `open_in_gmail` (Reply Needed) at priority 1 and `fix_delivery_issue` at priority 2. This is a genuine inconsistency between Spec 8 and the CTA engine definition. Resolution: the CTA engine (PRD-01) governs. `open_in_gmail` is priority 1. `fix_delivery_issue` is priority 2. The Next Action Panel reflects the CTA engine result — it does not maintain its own priority system. Spec 8's panel priority order is superseded by PRD-01.

4. **The Edit Job form uses slide-out, not a routed page.** "Edit Details" opens a slide-out panel that overlays the Job Detail screen from the right. The URL does not change. The job detail content remains visible behind the panel. Unsaved changes warn before close.

5. **Customer Email is locked after job creation.** The only path to correct it is Fix Delivery Issue. This is enforced server-side. The frontend must render the email field as read-only at all times in the Edit Job form, displaying the note: "Update via Fix Delivery Issue."

6. **Job Type (`job_type`) is locked after job creation.** All jobs are created directly into In Campaign. The field is locked from the moment the job record is written. The backend rejects any update to this field.

7. **Office Location (`location_id`) is permanently locked after job creation.** It is never editable in the Edit Job form. It is displayed as read-only plain text.

8. **Proposal Value (`job_value_estimate`) is never editable by the operator.** It is displayed read-only in the Classification section. The only way it updates is through a new PDF upload that triggers AI extraction. There is no input field for this value.

9. **There is no Upload Estimate sub-flow on Job Detail in the launch build.** Estimates are attached during the New Job intake flow (PRD-02). Campaign plan generation is triggered at job creation. The Upload Estimate modal does not exist on the launch build of Job Detail.

10. **Sub-flows do not navigate away from Job Detail.** Fix Delivery Issue, Pause, Resume, and Edit Job all open and close within the Job Detail screen. Open in Gmail is not a sub-flow — it exits SMAI and opens Gmail directly. Only Mark Won / Mark Lost with their confirmation step result in the job's state changing visibly on screen — the job does not navigate away, but the Next Action Panel and header update immediately to reflect the Won or Lost state. Campaign plan approval is handled at intake per PRD-02 v1.5 §8.4, not on Job Detail.

11. **The Activity Timeline reads from `job_proposal_history` directly, scoped to the job.** It is append-only, newest first. Nothing in the timeline is editable or deletable by the operator. Rows are discriminated by `event_type` per PRD-01 v1.2 §12.

12. **Mark Won and Mark Lost are always-visible secondary outcome actions, not `cta_type` values.** Their placement, visibility, and confirmation behavior are governed by SPEC-09. They are not represented in `jobs.cta_type`. See §12 and SPEC-09.

13. **No Pending Approval state appears on Job Detail.** Per PRD-01 v1.4.1 and PRD-02 v1.5. The durable job record is written only on Approve and Begin Campaign at intake; by the time a job is viewable on Job Detail, its campaign is already active (or subsequently in another overlay state like delivery issue, paused, etc.). `cta_type = review_plan` does not exist. The Pending Approval Panel, pipeline stage, and header CTA have been removed from this PRD in v1.3.

14. **Scenario (`scenario_key`) is locked at job creation.** Per SPEC-03 v1.3 and PRD-01 v1.4.1. The field appears in the Edit Job slide-out as read-only, same treatment as `job_type`. It is displayed in the Incident Details section of the main Job Detail body. The backend rejects any PATCH request attempting to change it.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- The complete Job Detail screen: all eight components, every field, every state-conditional rendering rule
- The pipeline stage tracker display logic
- The Next Action Panel: all panel types and their exact text and CTA
- Campaign controls (Pause, Resume) within the Next Action Panel
- The header bar: all elements, all CTAs, overflow menu
- The Edit Job slide-out: all fields, editability rules by status, save/validation behavior
- Open in Gmail CTA — behavior and backend writes (operator reply detection via Pub/Sub)
- Sub-flow: Fix Delivery Issue slide-out — full behavior and backend writes
- Sub-flow: Pause Campaign confirmation — behavior and backend writes
- Sub-flow: Resume Campaign confirmation — behavior and backend writes
- Mark Won / Mark Lost outcome action — behavior and backend writes (visibility governed by SPEC-09)
- Activity Timeline: data source, event types displayed, rendering rules
- All error states specific to Job Detail
- 7 TODOs in `EditJob.tsx`

**This PRD does not cover:**
- Needs Attention screen (PRD-04)
- Jobs List screen (PRD-05)
- New Job intake modal, including the Campaign Ready surface (PRD-02 v1.5)
- Campaign Engine internals (PRD-03 v1.4.1)
- Campaign template architecture or render contract (SPEC-11 v2.0)
- Campaign template authoring (SPEC-12 v1.0)
- Analytics screen (Analytics PRD)
- Settings screens (Settings PRD)
- Mark Won / Mark Lost placement, form-factor rules, and confirmation modal copy (SPEC-09)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| Job Detail is always a full-page view. Route: `/jobs/:jobId` or `/:locationId/jobs/:jobId`. | Spec 13, Session State v6.0 |
| Header CTA and Next Action Panel CTA must always match — both derived from `jobs.cta_type`. | PRD-01, Spec 8 |
| Next Action Panel priority order follows PRD-01 CTA priority ladder, not Spec 8's internal ordering. | PRD-01 governs; Spec 8 superseded on this point |
| Edit Job opens as a slide-out panel, not a routed page. URL does not change. | Session State v6.0, Lovable FE audit |
| Customer Email locked after job creation. Fix Issue is the only correction path. | PRD-01 v1.4.1 |
| Job Type (`job_type`) locked after job creation. All jobs created directly into In Campaign. | PRD-01 v1.4.1, Lovable FE audit (April 10, 2026) |
| Scenario (`scenario_key`) locked after job creation. Never editable. | SPEC-03 v1.3; PRD-01 v1.4.1 |
| Office Location permanently locked after job creation. Never editable. | Session State v6.0, PRD-01 v1.4.1 |
| Proposal Value never operator-editable. Read-only in all statuses. | Session State v6.0, PRD-01 v1.4.1 |
| No Upload Estimate sub-flow in launch build. Estimates attached during New Job intake only. | PRD-02 v1.5, Lovable FE audit (April 10, 2026) |
| Sub-flows do not navigate away from Job Detail. | Spec 8, Lovable FE audit |
| Campaign plan approval happens at intake per PRD-02 v1.5 §8.4, not on Job Detail. No `review_plan` CTA. No Pending Approval state. | PRD-01 v1.4.1; PRD-02 v1.5; Save State 2026-04-21 |
| Step count and cadence are variable per active template variant. "Follow-up N of M" where M is sourced from `campaign_steps` count for the active `job_campaigns`. | SPEC-11 v2.0; PRD-03 v1.4.1 |
| Activity Timeline is append-only, newest first, from `job_proposal_history`. | PRD-01 v1.4.1 §12, Spec 16 |
| All users (Admin and Originator) can perform all job-level actions. Manager role is dormant. | Session State v6.0, DL-015, DL-016 |
| On Behalf Of field does not exist anywhere on this screen. | Session State v6.0, PRD-01 |
| Mark Won / Mark Lost placement and visibility governed by SPEC-09, not `cta_type`. | SPEC-09 |
| Physical table names: `job_proposals` (jobs), `campaigns` (job_campaigns), `job_proposal_history` (consolidated history). Prose in this PRD continues to say "jobs" and "job_campaigns" for readability. | PRD-01 v1.2 §12, DL-026, DL-027 |

---

## 5. Screen Route and Navigation

**Route:** `/jobs/:jobId` (single-location) or `/:locationId/jobs/:jobId` (multi-location).

**Entry points:** Tapping any job card on Needs Attention or Jobs List navigates to this route. Deep links to this route are supported.

**Back navigation:** The header contains a "Back to Jobs" link that returns to `/jobs` (or `/:locationId/jobs`) preserving the previously active filter in the URL query parameter.

**Deep link access control:** If the user does not have access to the location the job belongs to, the screen renders an access error: "You don't have access to this job." with a "Back to Jobs" link.

**If job does not exist:** Render an inline error: "This job couldn't be found." with a "Back to Jobs" link.

---

## 6. Component 1: Header Bar

The header is fixed or sticky at the top of the screen. It is visible at all scroll positions.

### 6.1 Left side elements

- **Back to Jobs** — a text link with a left chevron. Returns to `/jobs` or `/:locationId/jobs`.
- **Job Title** — formatted as `{Incident Type} — {Address or Room}`. Example: "Water Damage — 1234 Oak Street" or "Water Damage — Kitchen". Derived from `jobs.job_name`. If `jobs.job_name` is null, construct from `jobs.job_type + " — " + jobs.address_line1`.
- **Customer Name** — `job_contacts.customer_name`. Displayed below the job title in smaller secondary text.
- **Job Value** — displayed below or adjacent to customer name. Formatted as currency (e.g., "$4,200"). If `job_value_estimate` is null, not rendered.
- **Status Badge** — the canonical status badge for the current `cta_type` / status combination. Uses the exact colors from Spec 12 (Section 10 of PRD-05).
- **Created Date** — displayed in muted text. Format: "Created {Month D, YYYY}".

### 6.2 Right side: header CTAs

The header shows a primary CTA button and secondary actions. The primary CTA is determined by `jobs.cta_type`.

**Primary CTA button — conditional on `cta_type`:**

| `cta_type` | Primary CTA button shown |
|---|---|
| `open_in_gmail` | Open in Gmail (teal, prominent, external link icon) |
| `fix_delivery_issue` | Fix Delivery Issue (teal, prominent) |
| `resume_campaign` | Resume Campaign (teal, prominent) |
| `view_job` | No primary CTA button. Update Outcome and Edit Details remain. |

Note: `review_plan` is removed per v1.3. Campaign plan approval happens at intake per PRD-02 v1.5 §8.4; there is no Job Detail path to approve a plan.

**Always-present secondary actions (shown regardless of status):**

- **Update Outcome** — button that opens the Mark Won / Mark Lost modal (Section 12). Shown for all statuses including Won and Lost (to allow correction). Placement and form-factor behavior governed by SPEC-09.
- **Edit Details** — button that opens the Edit Job slide-out (Section 13). Always shown.
- **Three-dot overflow menu** — opens a dropdown with secondary actions:
  - Pause Campaign — shown only when `pipeline_stage = in_campaign` and `status_overlay = null` (campaign is actively running)
  - Mark Won — shown when `pipeline_stage` is not `won` or `lost` (SPEC-09 §7)
  - Mark Lost — shown when `pipeline_stage` is not `won` or `lost` (SPEC-09 §7)
  - Flag Issue — shown always
  - Delete Job — shown always

---

## 7. Component 2: Pipeline Stage Tracker

A horizontal visual progress bar displayed below the header showing where the job sits in its lifecycle.

### 7.1 Visual stages (display only)

| Display stage | Corresponds to |
|---|---|
| In Campaign | `pipeline_stage = in_campaign` |
| Won / Lost | `pipeline_stage = won` or `lost` |

Note: Prior versions carried a Pending Approval stage discriminated by `job_campaigns.status = pending_approval`. Removed in v1.3 per PRD-01 v1.4.1 (no Pending Approval state exists).

### 7.2 Stage rendering rules

| Stage state | Visual treatment |
|---|---|
| Completed stage | Teal fill with white checkmark icon |
| Current stage | Teal filled circle with stage label bold |
| Future stage | Gray outline circle with stage label in muted text |
| Won | Final stage shows green with "Won" label |
| Lost | Final stage shows gray with "Lost" label |

### 7.3 Current stage determination

- `pipeline_stage = in_campaign` → In Campaign is current (regardless of `job_campaigns.status` value among active, completed, paused, stopped)
- `pipeline_stage = won` → Won / Lost is current (green)
- `pipeline_stage = lost` → Won / Lost is current (gray)

Overlays (`status_overlay`) do not change which stage is current. A job with `status_overlay = customer_waiting` is still displayed as In Campaign in the pipeline tracker.

---

## 8. Components 3–6: Content Sections

Six content sections render in a single scrollable column below the pipeline tracker. All sections render for all jobs regardless of status. Fields with no data display ghost text: "Add {Field Name}." — this ghost text is tappable and opens the Edit Job slide-out focused on that field (see OQ-01).

### 8.1 Customer Information

Displays read-only. Edit via Edit Job slide-out.

| Field | Source | Display |
|---|---|---|
| Customer Name | `job_contacts.customer_name` | Full name |
| Email | `job_contacts.customer_email` | Clickable mailto link |
| Phone | `job_contacts.customer_phone` | Clickable tel link |
| Alternate Phone | `job_contacts.lead_source_details.alternate_phone` | Clickable tel link if present |
| Preferred Contact | `job_contacts.preferred_channel` | "Email", "Phone", or "Either" |
| Emergency Contact | `job_contacts.lead_source_details.emergency_contact_name` | If present |
| Emergency Contact Phone | `job_contacts.lead_source_details.emergency_contact_phone` | Clickable tel link if present |

### 8.2 Property Information

| Field | Source |
|---|---|
| Property Address | `jobs.address_line1`, `address_line2`, `city`, `state`, `postal_code` — rendered as full address block |
| Property Type | `jobs.lead_source_details.property_type` |
| Square Feet | `jobs.lead_source_details.square_feet` |
| Year Built | `jobs.lead_source_details.year_built` |
| Levels Affected | `jobs.lead_source_details.levels_affected` |

### 8.3 Incident Details

| Field | Source |
|---|---|
| Job Type | `jobs.job_type` (per SPEC-03 v1.3 §7.1 — display label in title case; see SPEC-03 §8.4 for header subtitle casing) |
| Scenario | `jobs.scenario_key` (per SPEC-03 v1.3 §7.2 — display the scenario's label resolved from the scenario master list) |
| Cause of Loss | `jobs.cause_of_loss` |
| Urgency Level | `jobs.lead_source_details.urgency_level` |
| Date of Loss | `jobs.lead_source_details.date_of_loss` — formatted as "Month D, YYYY" |
| Area Affected | `jobs.lead_source_details.area_affected` |
| Materials Affected | `jobs.lead_source_details.materials_affected` |
| Incident Description | `jobs.lead_source_details.incident_description` |

### 8.4 Insurance Information

| Field | Source |
|---|---|
| Insurance Carrier | `jobs.lead_source_details.insurance_carrier` |
| Policy Number | `jobs.lead_source_details.policy_number` |
| Deductible Amount | `jobs.lead_source_details.deductible_amount` — formatted as currency |

### 8.5 Classification and Estimates

| Field | Source | Notes |
|---|---|---|
| Priority Level | `jobs.lead_source_details.priority_level` | |
| Job Number (DASH #) | `jobs.job_number` | |
| Office Location | `locations.display_name` if non-null and non-empty, else `locations.name`, for `jobs.location_id` (per SPEC-08 §8.2) | Read-only always |
| Proposal Value | `jobs.job_value_estimate` | Read-only always. "Not extracted" if null. |

### 8.6 Notes and Attachments

Free-form notes section. Attachments list with an "Add Attachment" action.

---

## 9. Component 7: Next Action Panel

A prominent panel below the content sections showing the primary action for this job's current state. The panel is state-driven by `jobs.cta_type`.

### 9.1 Panel types

**Reply Needed Panel** (`cta_type = open_in_gmail`)
- Badge: Reply Needed (Coral / `#F56B4B`)
- Text: "Customer replied — respond before they go cold."
- Primary CTA button: **Open in Gmail** → opens Gmail thread directly

**Delivery Issue Panel** (`cta_type = fix_delivery_issue`)
- Badge: Delivery Issue (Red / `#E53935`)
- Text: "Email delivery failed. Fix their email to resume the campaign."
- Primary CTA button: **Fix Delivery Issue** → opens Fix Issue slide-out (Section 11.2)

**Paused Panel** (`cta_type = resume_campaign`)
- Badge: Paused (Amber / `#F5A623`)
- Text: "Campaign is on hold. Resume when ready."
- Primary CTA button: **Resume Campaign** → opens Resume Campaign confirmation (Section 11.4)

**In Campaign Panel** (`cta_type = view_job` AND `pipeline_stage = in_campaign`)
- Badge: In Campaign (Teal / `#00B3B3`)
- Text: "Campaign running." — followed by send progress: "Follow-up {N} of {M} sent." on a second line. `M` is the total step count from the active `job_campaigns` (sourced from the `campaign_steps` row count). See §9.2.
- No primary CTA (campaign is running normally)
- Secondary control: **Pause Campaign** button (right-aligned, secondary style) → triggers Pause Campaign confirmation (Section 11.3)

**Won Panel** (`pipeline_stage = won`)
- Badge: Won (Green / `#27AE60`)
- Text: "Estimate accepted. Coordinate with the customer to schedule work."
- No primary CTA. No campaign controls.

**Lost Panel** (`pipeline_stage = lost`)
- Badge: Lost (Gray / `#9CA3AF`, outline style — per PRD-05 §10)
- Text: "Customer declined estimate or went with another contractor."
- No primary CTA. No campaign controls.

Color names, hex codes, and the `Style` column (solid for all panels except Lost, which is outline) are canonical per PRD-05 §10. Use the name + hex pair (e.g., `Coral / #F56B4B`) when referencing badge colors in prose; both are pinned to the same row in PRD-05 §10 and never change independently.

Note: Prior versions carried a Pending Approval Panel (`cta_type = review_plan`). Removed in v1.3. Campaign plan approval now lives at intake per PRD-02 v1.5 §8.4.

### 9.2 In Campaign send progress

The "Follow-up N of M sent" line in the In Campaign panel requires (a) the count of successfully sent outbound messages for the active `job_campaigns` run, and (b) the total step count for the active campaign run. Both are derived at query time:

- N = count of `messages` rows with `direction = outbound`, `status = sent`, linked to the active `job_campaigns.id` for this job.
- M = count of `campaign_steps` rows linked to the active `job_campaigns.id` (i.e., the total step count of the template variant that rendered this campaign run).

If N is 0 (campaign just started, first step not yet sent), render "Campaign starting..." until the first send completes.

Step count is variable per template variant per SPEC-11 v2.0 and PRD-03 v1.4.1 §7.1. The prior hardcoded "4" is removed in v1.3.

---

## 10. Component 8: Activity Timeline

A chronological event log for this job, rendered as a vertical list below the Next Action Panel. Sorted newest first. Never editable. Never deletable. Append-only.

### 10.1 Events displayed in the timeline

These rows are sourced from `job_proposal_history` where `job_id` references this job. They are filtered to the subset visible to operators (internal system events are excluded). Each row's `event_type` discriminator drives the display text below.

| `event_type` | Display text |
|---|---|
| `job_created` | "Job created via PDF upload" |
| `estimate_attached` | "Estimate uploaded" |
| `campaign_approved` | "Campaign approved by {operator_name}" |
| `campaign_step_sent` | "Follow-up #{step_order} sent to {customer_first_name}" |
| `customer_replied` | "Customer replied — campaign stopped" |
| `operator_replied` | "You replied to {customer_first_name}" |
| `delivery_issue_detected` | "Email delivery failed — campaign stopped" |
| `delivery_issue_resolved` | "Delivery issue resolved — campaign resumed" |
| `campaign_paused` | "Campaign paused by {operator_name}" |
| `campaign_resumed` | "Campaign resumed by {operator_name}" |
| `campaign_completed` | "Campaign completed — all follow-ups sent" |
| `job_marked_won` | "Job marked Won by {operator_name}" |
| `job_marked_lost` | "Job marked Lost by {operator_name}" |
| `job_issue_flagged` | "Issue flagged: {description}" — or "Issue flagged" if no description |
| `job_fields_updated` | "Job details updated by {operator_name}" — tap to expand shows which fields changed |

Note: `campaign_plan_generated` is removed from the canonical enum per PRD-01 v1.4.1. No timeline row is ever written or displayed for plan generation under templated architecture (SPEC-11 v2.0), because the render is ephemeral and no event fires separately from approval. On Approve and Begin Campaign at intake, `job_created` and `campaign_approved` rows are written in the same atomic transaction per PRD-03 v1.4.1 §6.4; both appear in the timeline.

Events not shown in the operator-facing timeline: `campaign_step_dropped`, `status_overlay_changed`, `pipeline_stage_changed`, internal retries, auth events. The transition rows (`status_overlay_changed`, `pipeline_stage_changed`) are present in `job_proposal_history` for audit but duplicate information already conveyed by the discrete lifecycle event rows above, so they are filtered from the operator view.

The operator name derives from the `changed_by` email on the row. The frontend resolves email to display name using the account's user list.

### 10.2 Timeline entry anatomy

Each entry shows:
- An icon matching the event type (per Lovable design — match mockups exactly)
- The display text from the table above
- A timestamp: exact time for today's events (e.g., "10:32 AM"), date + time for older events (e.g., "Apr 4, 2:15 PM")
- For inbound messages (`customer_replied`): a collapsed preview of the message body, expandable on tap

### 10.3 Inbound message preview

When a `customer_replied` event is displayed, the timeline entry includes a collapsed snippet of the inbound message body (first 120 characters). Tapping "Show more" expands to the full message text. Tapping "Reply" opens the Gmail thread directly in Gmail (same behavior as the Open in Gmail CTA).

---

## 11. Sub-Flows

All sub-flows open within the Job Detail screen. None navigate away. The Job Detail content remains visible in the background (dimmed) for modal sub-flows, or partially visible for slide-out sub-flows.

Note: Prior versions carried a Plan Review sub-flow at §11.3. Removed in v1.3. Campaign plan approval now lives at intake per PRD-02 v1.5 §8.4 (Campaign Ready surface). Sub-flow numbering below has been compacted accordingly.

---

### 11.1 Open in Gmail (Customer Reply)

**Trigger:** "Open in Gmail" button in the header or Next Action Panel, or "Reply" link in the activity timeline for a customer reply event.

**Behavior:** SMAI does not provide a compose interface for operator replies. Tapping "Open in Gmail" opens the Gmail thread directly in the operator's Gmail. The operator composes and sends the reply natively in Gmail from the operational mailbox.

**How SMAI detects the reply:** smai-comms monitors the operational mailbox via Gmail Pub/Sub. When it detects an outbound message from the operational mailbox on the job's Gmail thread, it notifies smai-backend, which performs the following writes atomically:

1. Writes `messages` row: `direction = outbound`, `channel = email`, `status = sent`, body = reply text retrieved from Gmail message, `from_address = operational mailbox`, `to_address = customer email`. Thread headers preserved.
2. Clears `jobs.status_overlay` from `customer_waiting` to `null`.
3. Sets `jobs.cta_type = view_job`.
4. Writes `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = customer_waiting`, `new_status = null`, `details = operator_replied`, `changed_by = <operator email>`.
5. Writes `job_proposal_history` row: `event_type = operator_replied`, `changed_by = <operator email>`.
6. `job_campaigns.status` remains `stopped_on_reply`. No new campaign steps are scheduled.

**After detection:**
Job Detail updates in place on next load or via realtime subscription: header CTA disappears, Next Action Panel changes to In Campaign Panel, Activity Timeline adds the `operator_replied` entry.

**No in-app send failure state.** The operator sends from Gmail directly. SMAI records the result of detection, not of a send it initiated.

---

### 11.2 Sub-Flow: Fix Delivery Issue

**Trigger:** Fix Delivery Issue button in the header or Next Action Panel.

**Display:** A slide-out panel from the right side of the screen. Job Detail content remains partially visible to the left.

**Panel title:** "Fix Delivery Issue"

**Panel content:**

1. **Error summary** — displays the delivery failure reason from the most recent unresolved `delivery_issues` row. Format: "Email could not be delivered to {current_email_address}." If `issue_type` is available, include it: e.g., "Email bounced (invalid address)."
2. **Customer Email field** — pre-populated with the current `job_contacts.customer_email`. Editable. Email format validation. Labeled: "Customer email address."
3. **Customer Phone field** — pre-populated with `job_contacts.customer_phone`. Editable. For future channels; in the launch this is displayed but the retry path is email-only.
4. **Retry Delivery button** (primary teal) — "Retry Delivery"
5. **Cancel link** — closes slide-out without saving

**On Retry Delivery:**

smai-backend performs the following atomically:
1. Validates the new email address (format check, non-empty).
2. Updates `job_contacts.customer_email` to the corrected value.
3. Updates `job_contacts.customer_phone` if it was changed.
4. Marks all unresolved `delivery_issues` rows for this job as resolved (`resolved = true`, `resolved_at = now()`, `resolved_by_user_id = logged-in user`).
5. Clears `jobs.status_overlay` from `delivery_issue` to `null`.
6. Sets `jobs.cta_type = view_job`.
7. Writes `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = delivery_issue`, `new_status = null`, `details = delivery_issue_resolved`, `changed_by = <operator email>`.
8. Writes `job_proposal_history` row: `event_type = delivery_issue_resolved`, `changed_by = <operator email>`.
9. Triggers campaign resumption per PRD-03 v1.4.1 §12: creates a new `job_campaigns` row with `template_version_id` carried over from the prior run, copies unsent `campaign_steps` forward, determines next unsent step, schedules remaining Cloud Tasks with timing relative to now.

**After successful retry:**
- Slide-out closes.
- Job Detail updates in place: status badge changes to In Campaign, Next Action Panel changes to In Campaign Panel, Activity Timeline adds `delivery_issue_resolved` entry.
- Toast: "Delivery issue resolved — campaign resumed."

**If retry fails (same address still bounces):** A new `delivery_issues` row is created, the overlay is reapplied. The Fix Issue slide-out re-opens with the same error state. Toast: "Email still failed — please check the address."

**If validation fails (invalid email format):** Inline field error under the email input. Retry Delivery button remains disabled until a valid format is entered.

---

### 11.3 Sub-Flow: Pause Campaign

**Trigger:** "Pause Campaign" option in the header three-dot overflow menu. Only available when `pipeline_stage = in_campaign` and `status_overlay = null`.

**Display:** A confirmation dialog (small modal). No background dimming required — a simple in-place confirmation is acceptable.

**Dialog content:**
- Title: "Pause campaign?"
- Text: "Automated follow-ups will stop until you resume."
- Confirm button: "Pause Campaign" (teal)
- Cancel link: "Cancel"

**On confirm:**

smai-backend performs the following atomically:
1. Sets `jobs.status_overlay = paused`.
2. Sets `jobs.cta_type = resume_campaign`.
3. Sets `jobs.campaign_paused_at = now()`.
4. Sets `job_campaigns.status = paused`.
5. Writes `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = null`, `new_status = paused`, `details = operator_paused`, `changed_by = <operator email>`.
6. Writes `job_proposal_history` row: `event_type = campaign_paused`, `changed_by = <operator email>`.

**After confirm:**
- Dialog closes.
- Job Detail updates in place: header CTA changes to Resume Campaign, Next Action Panel changes to Paused Panel, status badge changes to Paused.
- Toast: "Campaign paused."

**On failure:**
- Dialog closes.
- Toast: "Unable to pause campaign. Please try again."

**On Cancel:** Dialog closes. No state changes.

---

### 11.4 Sub-Flow: Resume Campaign

**Trigger:** Resume Campaign button in the header (when `cta_type = resume_campaign`) or the Resume Campaign button in the Next Action Panel (Paused Panel).

**Display:** A confirmation dialog.

**Dialog content:**
- Title: "Resume campaign?"
- Text: "Automated follow-ups will restart from where they left off."
- Confirm button: "Resume Campaign" (teal)
- Cancel link: "Cancel"

**On confirm:**

smai-backend performs the following atomically per PRD-03 v1.4.1 §13.2:
1. Sets `jobs.status_overlay = null`.
2. Sets `jobs.cta_type = view_job`.
3. Clears `jobs.campaign_paused_at`.
4. Sets `job_campaigns.status = active`.
5. Determines the next unsent step (highest `step_order` successfully sent + 1).
6. Schedules Cloud Tasks for remaining steps with timing relative to now, sourced from the `delay_from_prior` values on `campaign_steps`.
7. Writes `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = paused`, `new_status = null`, `details = operator_resumed`, `changed_by = <operator email>`.
8. Writes `job_proposal_history` row: `event_type = campaign_resumed`, `changed_by = <operator email>`.

**After confirm:**
- Dialog closes.
- Job Detail updates in place: header CTA clears, Next Action Panel changes to In Campaign Panel (with Pause Campaign secondary control restored), status badge changes to In Campaign.
- Toast: "Campaign resumed."

**On failure:**
- Dialog closes.
- Inline banner on the Next Action Panel: "Couldn't resume — try again." with a Retry button.

---

## 12. Mark Won / Mark Lost

**Trigger:** "Update Outcome" button in the header (opens a choice modal), or "Mark Won" / "Mark Lost" items in the header three-dot overflow menu. Placement, form-factor behavior, and visibility rules are governed by SPEC-09. The writes and backend sequence below are the PRD-06 contract; SPEC-09 governs the surface.

### 12.1 Update Outcome modal

When "Update Outcome" is tapped:

A small modal appears with:
- Title: "Update outcome"
- Two options as large buttons:
  - "Mark Won" (green accent)
  - "Mark Lost" (gray)
- Cancel link

Selecting either option proceeds to a confirmation step.

### 12.2 Confirmation step

**Mark Won confirmation:**
- Text: "Mark this job as Won? This will stop all automated messaging."
- Confirm: "Mark Won"
- Cancel link

**Mark Lost confirmation:**
- Text: "Mark this job as Lost? This will stop all automated messaging."
- Confirm: "Mark Lost"
- Cancel link

### 12.3 On confirm (Mark Won or Mark Lost)

smai-backend performs the following atomically (same as PRD-03 Section 10.4 and PRD-01 Section 9):
1. Sets `jobs.pipeline_stage = won` or `lost`.
2. Sets `jobs.status_overlay = null`.
3. Sets `jobs.cta_type = view_job`.
4. Sets `jobs.won_at` or `jobs.lost_at = now()`.
5. Sets `job_campaigns.status` to terminal status (`stopped_on_closure` or equivalent).
6. Sets `job_campaigns.completed_at = now()`.
7. Writes `job_proposal_history` row: `event_type = pipeline_stage_changed`, `old_status = in_campaign`, `new_status = won` or `lost`, `details = operator_marked_won` or `operator_marked_lost`, `changed_by = <operator email>`.
8. Writes `job_proposal_history` row: `event_type = job_marked_won` or `job_marked_lost`, `changed_by = <operator email>`.

**After confirm:**
- Modal closes.
- Job Detail updates in place: pipeline tracker shows Won or Lost as final stage, Next Action Panel changes to Won Panel or Lost Panel, header CTA clears, status badge updates.
- Activity Timeline adds the outcome entry.
- Toast: "Job marked as Won." or "Job marked as Lost."

**On failure:**
- Toast: "Couldn't update outcome — try again." Job state unchanged.

### 12.4 Correcting an outcome

If a job is already Won or Lost and the operator taps "Update Outcome," the same modal appears. The operator can switch from Won to Lost or vice versa. The backend accepts this transition — Won → Lost and Lost → Won are permitted. The transition writes a new `job_proposal_history` row pair (`pipeline_stage_changed` and `job_marked_won` or `job_marked_lost`) with the appropriate `changed_by`.

---

## 13. Edit Job Slide-Out

**Trigger:** "Edit Details" button in the header. Always available.

**Display:** A slide-out panel from the right edge of the screen, approximately 40% of screen width on desktop, full-screen on mobile. The Job Detail content remains visible to the left (dimmed). The slide-out has its own scroll. The URL does not change.

**Panel title:** "Edit Job"

**Close behavior:** An X button in the top-right corner of the panel. If unsaved changes exist, a confirmation: "You have unsaved changes. Discard them?" before closing.

### 13.1 Edit Job field list and editability rules

All fields from the intake form appear in the Edit Job slide-out. Editability is governed by the job's current `pipeline_stage`. The backend enforces all locking rules server-side regardless of what the frontend renders. Since all jobs are created directly into In Campaign, the In Campaign column below represents the only operative state.

| Field | In Campaign | Won | Lost | Notes |
|---|---|---|---|---|
| Customer Name | Editable | Editable | Editable | |
| Customer Email | **Locked** | **Locked** | **Locked** | Locked at job creation. Read-only with note "Update via Fix Delivery Issue." |
| Customer Phone | Editable | Editable | Editable | |
| Alternate Phone | Editable | Editable | Editable | |
| Preferred Contact | Editable | Editable | Editable | |
| Emergency Contact | Editable | Editable | Editable | |
| Emergency Contact Phone | Editable | Editable | Editable | |
| Property Address | Editable | Editable | Editable | |
| Property Type | Editable | Editable | Editable | |
| Square Feet | Editable | Editable | Editable | |
| Year Built | Editable | Editable | Editable | |
| Levels Affected | Editable | Editable | Editable | |
| Job Type | **Locked** | **Locked** | **Locked** | Locked at job creation. Read-only, no edit path. Displayed label per SPEC-03 v1.3 §7.1. |
| Scenario | **Locked** | **Locked** | **Locked** | Locked at job creation per SPEC-03 v1.3 and PRD-01 v1.4.1. Read-only, no edit path. Displayed label per SPEC-03 v1.3 §7.2. |
| Cause of Loss | Editable | Editable | Editable | |
| Urgency Level | Editable | Editable | Editable | |
| Date of Loss | Editable | Editable | Editable | |
| Area Affected | Editable | Editable | Editable | |
| Materials Affected | Editable | Editable | Editable | |
| Incident Description | Editable | Editable | Editable | |
| Insurance Carrier | Editable | Editable | Editable | |
| Policy Number | Editable | Editable | Editable | |
| Deductible Amount | Editable | Editable | Editable | |
| Job Number (DASH #) | Editable | Editable | Editable | |
| Priority Level | Editable | Editable | Editable | |
| Proposal Value | **Locked** | **Locked** | **Locked** | Read-only always. "Updated from proposal PDF only." |
| Office Location | **Locked** | **Locked** | **Locked** | Read-only always. Display-only field. |
| On Behalf Of | Does not exist | Does not exist | Does not exist | Field must not appear |
| Additional Notes | Editable | Editable | Editable | |

### 13.2 Locked field rendering

Locked fields in the Edit Job slide-out are rendered as plain text (not input elements) with a lock icon.

### 13.3 Save Changes

On Save:

smai-backend performs the following:
1. Validates required fields and field format.
2. Enforces locking rules server-side. Any attempt to change a locked field returns a typed error and the save fails.
3. Updates the `job_proposals` and `job_contacts` records with the changed fields.
4. Writes a `job_proposal_history` row with `event_type = job_fields_updated`, `changed_by = <operator email>`, and `metadata = { changed_fields: [...], old_values: {...}, new_values: {...} }`. See PRD-01 v1.2 §12 for the `job_fields_updated` contract.

**After successful save:**
- Slide-out closes.
- Job Detail updates in place with the new field values.
- Activity Timeline adds a `job_fields_updated` entry: "Job details updated by {operator_name}." Tapping the entry expands to show which fields changed.
- Toast: "Changes saved."

**On validation failure:**
- Inline field-level error under the offending field.
- Save button remains available. The slide-out does not close.

---

## 14. Error States

| Scenario | Behavior |
|---|---|
| Job not found | Inline error: "This job couldn't be found." with Back to Jobs link |
| Access denied (location scope) | Inline error: "You don't have access to this job." with Back to Jobs link |
| CTA engine returns inconsistent result (header CTA != panel CTA) | Should not occur. If it does, log a backend warning and render the CTA from `jobs.cta_type` on both surfaces. Logged server-side. |
| Page load failure | Network error on initial load | Inline error banner: "Couldn't load this job. Check your connection and refresh." with Refresh button |
| Campaign pause failure | Backend returns error on pause | Toast: "Unable to pause campaign. Please try again." |
| Campaign resume failure | Backend returns error on resume | Inline banner on Next Action Panel: "Couldn't resume — try again." with Retry button |
| Missing contact info discovered post-campaign-start | `customer_email` null after `pipeline_stage = in_campaign` (data integrity issue only) | Inline banner: "Contact info is missing — update it to continue the campaign." with "Update Contact" CTA that opens Fix Issue slide-out |

---

## 15. System Boundaries

| Responsibility | Owner |
|---|---|
| Job Detail data fetch (job + contacts + messages + history) | smai-backend |
| CTA engine result (`cta_type`) — read by Job Detail, not recomputed | smai-backend (computed on job record per PRD-01) |
| Pipeline tracker current stage derivation | smai-frontend (from `pipeline_stage` + `job_campaigns.status`) |
| Next Action Panel state | smai-frontend (from `cta_type`) |
| Activity Timeline data | smai-backend (`job_proposal_history` query scoped to job, filtered by `event_type` per §10.1) |
| In Campaign send count (for panel progress) | smai-backend (messages count in API response) |
| Operator reply detection (after Open in Gmail) | Gmail API → Pub/Sub → smai-comms → smai-backend |
| Fix Issue retry execution and campaign resumption | smai-backend → PRD-03 v1.4.1 §12 resume path → smai-comms |
| Pause Campaign write | smai-backend |
| Resume Campaign write and Cloud Task scheduling | smai-backend → PRD-03 v1.4.1 §13.2 resume path |
| Mark Won / Mark Lost write and campaign stop | smai-backend → PRD-03 closure path |
| Edit Job field write and `job_fields_updated` history row | smai-backend (with server-side locking enforcement) |
| Sub-flow UI rendering (all modals and slide-outs) | smai-frontend |
| Unsaved changes warning on Edit Job slide-out close | smai-frontend |

---

## 16. API Response Shape

The Job Detail endpoint must return all data needed to render the full screen without additional fetches on load:

- Complete `jobs` (`job_proposals`) record with all fields
- `job_contacts` record
- Current `estimates` record (if attached) including file URL
- Active `job_campaigns` record (status, started_at, approved_at)
- Count of successfully sent outbound `messages` for the active campaign run
- Most recent unresolved `delivery_issues` row (if any) — for Fix Issue pre-population
- Last N rows from `job_proposal_history` for the Activity Timeline (suggest N=50, paginate beyond), filtered to operator-visible `event_type` values per §10.1
- Outbound and inbound `messages` scoped to this job, with `step_order` and body text, for the activity timeline expansion
- Campaign step content for the active `job_campaigns` record — for Activity Timeline expansion (`campaign_step_sent` entries) and Fix Issue context

All in a single response. No waterfall fetches on initial load.

---

## 17. Implementation Slices

### Slice A: Screen scaffold and data load
Build the Job Detail route. Implement the API endpoint returning all required data per Section 16. Implement the header bar (all elements, all conditional CTAs). Implement the pipeline tracker. Confirm the "Back to Jobs" link preserves the Jobs List filter.

Dependencies: PRD-01 (job record), PRD-05 (Jobs List filter state).  
Excludes: Content sections, Next Action Panel, sub-flows.

### Slice B: Content sections (Components 3–6)
Implement all six content sections with all fields from Section 8. Implement ghost text for empty fields. Implement the attachment list and "Add Attachment" file upload (non-campaign-triggering).

Dependencies: Slice A.  
Excludes: Edit Job slide-out.

### Slice C: Next Action Panel and campaign controls
Implement all panel types (Section 9). Implement the In Campaign send progress count. Implement the Pause Campaign secondary control within the In Campaign panel. Render panel based on `cta_type` from API response.

Dependencies: Slice A.  
Excludes: Sub-flows (panel CTAs trigger sub-flows defined in Slices D–H).

### Slice D: Open in Gmail and operator reply detection
Implement the "Open in Gmail" CTA deep link (Section 11.1). Implement the smai-backend operator reply detection path: receive notification from smai-comms, perform atomic writes, write `job_proposal_history` rows for `status_overlay_changed` and `operator_replied`. Implement in-place Job Detail update on detection (realtime subscription or next load).

Dependencies: Slices A, C. smai-comms OBO send confirmed working.

### Slice E: Fix Delivery Issue sub-flow
Implement the Fix Issue slide-out (Section 11.2): error summary, editable email/phone fields, Retry button. Implement the retry sequence via smai-backend (writes, campaign resume trigger per PRD-03 v1.4.1 §12 with `template_version_id` carried over and unsent `campaign_steps` copied forward). Implement in-place Job Detail update on success.

Dependencies: Slices A, C. PRD-03 v1.4.1 Slice E (Fix Issue resume path).

### Slice F: Pause and Resume sub-flows
Implement both confirmation dialogs (Sections 11.3 and 11.4). Implement the backend writes for pause and resume. Implement in-place Job Detail update on success. Implement the resume failure inline banner.

Dependencies: Slices A, C. PRD-03 v1.4.1 Slices D and E.

### Slice G: Mark Won / Mark Lost
Implement the Update Outcome modal with two-option choice and confirmation step (Section 12). Implement backend writes with the `job_proposal_history` row pair (`pipeline_stage_changed` and `job_marked_won` or `job_marked_lost`). Implement outcome correction (Won → Lost, Lost → Won). Implement in-place Job Detail update. Placement and visibility governed by SPEC-09.

Dependencies: Slice A. PRD-03 v1.4.1 §10.4. SPEC-09.

### Slice H: Edit Job slide-out — closes 7 TODOs in `EditJob.tsx`
Implement the Edit Job slide-out (Section 13) with all fields from Section 13.1 including the Scenario row as locked. Implement field-level editability rules — editable fields as inputs, locked fields as read-only text with lock icon and appropriate note. Implement Save Changes with client-side and server-side validation (server rejects any PATCH to `job_type` or `scenario_key`). Implement the `job_fields_updated` `job_proposal_history` write on save per §13.3. Implement the unsaved-changes close warning. Close all 7 TODOs in `EditJob.tsx`.

Dependencies: Slices A, B. PRD-01 v1.4.1 field editability rules; PRD-01 v1.4.1 §12 `job_fields_updated` schema.

### Slice I: Activity Timeline
Implement the Activity Timeline (Section 10) sourced from `job_proposal_history` filtered to operator-visible `event_type` values. Implement all event type display texts and icons per the §10.1 table (note: `campaign_plan_generated` is not in the enum under PRD-01 v1.4.1). Implement newest-first sort. Implement the inbound message preview and expand behavior. Implement the "Reply" link on customer reply entries that opens Gmail directly (same as the Open in Gmail CTA). Resolve `changed_by` email to operator display name using the account's user list.

Dependencies: Slice A. API response includes `job_proposal_history` data.

### Slice J: Error states and mobile
Implement all error states from Section 14. Implement mobile layout (390px). Confirm slide-outs render full-screen on mobile. Confirm all sub-flow modals render correctly on mobile.

Dependencies: All preceding slices.

---

## 18. Acceptance Criteria

**AC-01: Route renders correctly**
Given a valid `job_id` the user has access to, when navigating to `/jobs/:jobId`, then the Job Detail screen renders with all eight components populated from the API response.

**AC-02: Header CTA matches Next Action Panel CTA**
Given any job in any status, when the screen renders, then the primary CTA button in the header and the CTA button in the Next Action Panel both show the same label and trigger the same action.

**AC-03: Pipeline tracker — In Campaign reflects send progress**
Given a job with `pipeline_stage = in_campaign` where 2 of the active campaign run's total M steps have been sent (M is the step count of the active template variant), when the screen renders, then the pipeline tracker shows In Campaign as the current stage and the Next Action Panel text reads "Follow-up 2 of M sent" with the actual numeric value of M substituted.

**AC-04: Open in Gmail — operator reply detected and overlay cleared**
Given a job with `status_overlay = customer_waiting`, when the operator taps "Open in Gmail," replies in Gmail, and smai-comms detects the outbound message on the job thread, then `status_overlay` clears to `null`, a `job_proposal_history` row with `event_type = operator_replied` is written, the header CTA disappears, and the Next Action Panel changes to the In Campaign panel on next load or realtime update.

**AC-05: Fix Delivery Issue — corrects email and resumes campaign**
Given a job with `status_overlay = delivery_issue`, when the operator opens Fix Issue, corrects the email, and taps Retry Delivery, then `job_contacts.customer_email` is updated, the `delivery_issues` row is resolved, `status_overlay` clears, a new `job_campaigns` row is created as active with `template_version_id` matching the prior run, unsent `campaign_steps` are copied forward, remaining Cloud Tasks are scheduled, a `job_proposal_history` row with `event_type = delivery_issue_resolved` is written, and the Next Action Panel changes to In Campaign.

**AC-06: Pause Campaign**
Given a job with `pipeline_stage = in_campaign` and `status_overlay = null`, when the operator selects "Pause Campaign" from the overflow menu and confirms, then `status_overlay = paused`, `cta_type = resume_campaign`, `job_campaigns.status = paused`, a `job_proposal_history` row with `event_type = campaign_paused` is written, and the Next Action Panel shows the Paused panel.

**AC-07: Resume Campaign**
Given a job with `status_overlay = paused`, when the operator taps Resume Campaign and confirms, then `status_overlay = null`, `cta_type = view_job`, `job_campaigns.status = active`, remaining Cloud Tasks are scheduled relative to now, a `job_proposal_history` row with `event_type = campaign_resumed` is written, and the Next Action Panel shows the In Campaign panel.

**AC-08: Mark Won**
Given a job in any non-terminal status, when the operator marks it Won and confirms, then `pipeline_stage = won`, `won_at` is set, campaign is stopped, a `job_proposal_history` row with `event_type = job_marked_won` is written, and the pipeline tracker shows Won as the final stage.

**AC-09: Outcome correction**
Given a job already marked Won, when the operator taps Update Outcome and marks it Lost, then `pipeline_stage = lost`, `lost_at` is set, a `job_proposal_history` row with `event_type = job_marked_lost` is written, and the pipeline tracker updates to show Lost.

**AC-10: Edit Job — Customer Email locked always**
Given a job in any status, when the Edit Job slide-out opens, then the Customer Email field is read-only with a lock icon and the note "Update via Fix Delivery Issue." The backend rejects any PATCH request attempting to change `customer_email`.

**AC-11: Edit Job — Job Type locked always**
Given a job in any status, when the Edit Job slide-out opens, then the Job Type field is read-only with a lock icon and the note "Set at job creation and cannot be changed." The backend rejects any PATCH request attempting to change `job_type`.

**AC-12: Edit Job — Scenario locked always**
Given a job in any status, when the Edit Job slide-out opens, then the Scenario field is read-only with a lock icon and the note "Set at job creation and cannot be changed." The backend rejects any PATCH request attempting to change `scenario_key`.

**AC-13: Edit Job — Office Location locked always**
Given any job in any status, when the Edit Job slide-out opens, then the Office Location field is displayed as read-only plain text with the note "Location is set at job creation and cannot be changed." No input is rendered.

**AC-14: Edit Job — Proposal Value locked always**
Given any job in any status, when the Edit Job slide-out opens, then the Proposal Value field is displayed as read-only plain text with the note "Updated automatically from proposal PDF." No input is rendered.

**AC-15: Edit Job — unsaved changes warning**
Given the operator has made changes in the Edit Job slide-out and taps the X to close without saving, then a confirmation dialog appears: "You have unsaved changes. Discard them?" with Discard and Keep Editing options. Tapping Keep Editing returns to the slide-out with changes intact.

**AC-16: Activity Timeline — newest first**
Given a job with events spanning multiple days, when the Activity Timeline renders, then the most recent event appears at the top and events are in strict reverse chronological order.

**AC-17: Activity Timeline — customer reply expandable**
Given a job with a `customer_replied` event, when the timeline entry is tapped, then the full inbound message body is shown. A "Reply" link appears that opens Gmail directly (same as the Open in Gmail CTA).

**AC-18: No On Behalf Of field**
Given any job in any status, when the Edit Job slide-out opens, then no On Behalf Of field appears anywhere in the form.

**AC-19: Error state — job not found**
Given a browser navigating to `/jobs/nonexistent-id`, when the page loads, then the screen renders "This job couldn't be found." with a Back to Jobs link. No crash occurs.

**AC-20: Field edit logged in activity timeline**
Given an operator edits the customer name in the Edit Job slide-out and saves, when the save succeeds, then a `job_proposal_history` row with `event_type = job_fields_updated` exists with `changed_by = <operator email>` and `metadata` containing `changed_fields: ["customer_name"]` plus `old_values` and `new_values`. The Activity Timeline renders an entry: "Job details updated by {operator_name}."

---

## 19. Open Questions and Implementation Decisions

**OQ-01: Ghost text tap behavior — opens Edit Job or focused on field?**
Section 8 states that ghost text for empty fields is tappable and opens the Edit Job slide-out focused on that field. This is the expected UX. Engineering should confirm whether the Edit Job slide-out supports scrolling to a specific field on open (via a `focusField` parameter), or whether tapping ghost text simply opens the slide-out at the top. Either is acceptable for Buc-ee's; focus-to-field is better UX but adds implementation complexity.

**OQ-02: Edit Job field changes — history row entry?**
RESOLVED. Field-level edits are logged to `job_proposal_history` with `event_type = job_fields_updated` on every successful save. The activity timeline displays a "Job details updated" entry. Old and new values are stored in the row's `metadata` field for auditability. See PRD-01 v1.2 §12 for the schema. Implemented in PRD-06 Slice I.

**OQ-03: In Campaign panel — "Campaign starting..." edge case timing**
§9.2 specifies "Campaign starting..." when `pipeline_stage = in_campaign` but no messages have been sent yet (the zero-count state between activation and the first step firing). For templates where step 1's `delay_from_prior` is zero, the first step fires immediately on approval and this edge state may be imperceptibly brief in practice. For templates with a nonzero first delay, the state persists until the first send completes. Engineering should confirm the polling or real-time mechanism that updates the send count on the panel so the transition from "Campaign starting..." to "Follow-up 1 of M sent" is reflected correctly without requiring a full page reload.

**OQ-04: Prior campaign message display in Gmail thread**
RESOLVED. Prior campaign messages are threaded in Gmail natively — the operator sees the full thread context when they open Gmail. No SMAI-side message display is required. Closed.

---

## 20. Out of Scope

- Needs Attention screen (PRD-04)
- Jobs List screen (PRD-05)
- New Job intake modal (PRD-02)
- Campaign Engine internals (PRD-03)
- Analytics screen (Analytics PRD)
- Settings screens (Settings PRD)
- Upload Estimate sub-flow (deferred post-Buc-ee's)
- Voice intake and manual entry (deferred)
- SMS campaign steps (cut from Buc-ee's)
- Operator-editable campaign content (managed-service model)
- Multi-contact per job (post-MVP)
- Job reopening from Won or Lost (post-MVP)
- Manager role behavior (dormant, DL-015)
- Mark Won / Mark Lost placement and form-factor rules (SPEC-09 governs)
