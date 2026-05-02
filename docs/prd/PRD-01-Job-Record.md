# PRD-01: Job Record
**Version:** 1.4.1  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked); Spec 11 (Database Schema) [legacy out-of-repo reference; superseded by canonical schema in this PRD §8 and in PRD-03/PRD-06/PRD-09 table definitions]; Specs 6 and 7 (Job Status Model and CTA Architecture) [legacy out-of-repo references; superseded by §6 and §7 of this PRD]; Spec 8 (Job Detail) [legacy out-of-repo reference; superseded by PRD-06 v1.3.1]; Session State v6.0; Reconciliation Report 2026-04-16; Save State 2026-04-21 (Pending Approval elimination; templated architecture commitment)  
**Related PRDs and specs:** PRD-02 (New Job Intake), PRD-03 (Campaign Engine, v1.4 in progress), PRD-04 (Needs Attention), PRD-05 (Jobs List), PRD-06 (Job Detail), PRD-09 (Gmail Layer), PRD-10 (SMAI Admin Portal, v1.2 in progress); SPEC-03 v1.3 (Job Type and Scenario taxonomy); SPEC-11 v2.0 (Campaign Template Architecture); SPEC-12 v1.0 (Template Authoring Methodology)  
**Revision note (v1.1):** Removed `draft` and `awaiting_estimate` pipeline stages. For the Buc-ee's launch, every job is created directly into `in_campaign` via the proposal upload flow. There is no intermediate pre-campaign state in the operator product. These stages may be reinstated in a future release when in-app job intake is rebuilt.  
**Revision note (v1.2):** Table naming aligned to code reality. Physical table name is `job_proposals` (prose continues to say "jobs" for readability). Campaign table is `campaigns` with polymorphic `target_id` + `target_type = JOB_PROPOSAL`. History tables consolidated from `job_status_history` + `event_logs` into a single `job_proposal_history` table discriminated by `event_type`. Added SPEC-09 clarifier to CTA Resolution noting Mark Won and Mark Lost are secondary outcome actions not represented in `cta_type`. See DL-024, DL-026, DL-027.  
**Revision note (v1.3):** Added four `event_type` values to the §12 enum that were introduced by downstream PRD rewrites and referenced but not yet canonical here: `operator_replied` (PRD-03 v1.3 §10.1, PRD-06 v1.2 §11.1), `job_needs_attention_flagged` (PRD-03 v1.3 §10.1 and §10.2, PRD-09 v1.1 §8.5 and §10.2), `campaign_step_dropped` (PRD-03 v1.3 §15), and `job_issue_flagged` (PRD-05 v1.2 §11.4). No other changes.  
**Revision note (v1.4):** Three surgical changes tied to the 2026-04-21 strategic commitments.

1. **Pending Approval eliminated as a persisted state.** Per the save state note on the collapsed intake flow, the durable job record is written only on Approve and Begin Campaign in the Campaign Ready modal, not at intake Submit. There is no `pending_approval` state persisted on any job record. Removed the Pending Approval row from the §6 operator-facing display mapping table. Removed the `review_plan` CTA and its row from the §7 CTA mapping table and priority ladder. CTA computation now reads from `pipeline_stage` and `status_overlay` only; the `job_campaigns.status` input is no longer a CTA discriminator and has been removed from the computation paragraph in §7 and the §6 display table. Removed `campaign_plan_generated` from the §12 `event_type` enum; under templated architecture (SPEC-11 v2.0) there is no generation event that persists separately from approval.

2. **Scenario field added to `job_proposals`.** Per SPEC-03 v1.3, a new `scenario_key` field is added to `job_proposals` as a required, locked-after-creation field. §8.1 schema updated; §10 editability table updated; §11 validation updated; §15 new AC-09 added.

3. **Template cohort attribution anchored on `campaigns`.** Per SPEC-11 v2.0 §7.3 and §11.3, the `campaigns` table carries a `template_version_id` foreign key for per-template cohort attribution. This PRD references the addition; the schema change itself lives in PRD-03 v1.4 (owner of the `campaigns` table definition). §5 related objects note updated.

No other changes in v1.4. Status updates for campaign lifecycle (`campaigns.status` enum cleanup to remove `pending_approval`) are in PRD-03 v1.4's scope, not here, since PRD-01 does not define that enum.

**Revision note (v1.4.1, 2026-04-22):** Three surgical corrections; no behavioral change. (1) B-04: OQ-01 text aligned to the v1.4 §7 canonical rule. `job_campaigns.status` removed as a listed CTA input (it was struck from §7 in v1.4 but the OQ-01 resolution narrative was missed). OQ-01 now reads: `cta_type` is computed from `pipeline_stage` and `status_overlay` only. (2) H-04 Path A: §8.1 `scenario_key` row rewritten to remove the legacy nullable allowance. The field is NOT NULL on every `job_proposals` record; Buc-ee's is a net-new tenant and pre-v1.4 records are test data. Aligns with SPEC-03 v1.3 §13.1 after the parallel SPEC-03 2026-04-22 patch. (3) L-01: §0 Source truth references to out-of-repo Specs 6, 7, 8, 11 annotated as legacy and superseded by canonical in-repo content. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 B-04, H-04, L-01).

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep. Operational references to `PRD-03 v1.4` updated to `PRD-03 v1.4.1` to match the parallel PRD-03 patch. No version bump on PRD-01 (no behavioral change in this doc; sweep is pointer-hygiene only). Audit-trail revision-note text preserved byte-exact. Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01.

**Patch note (2026-04-23, H2P-05 enum-casing convention):** New canonical enum-casing subsection added at the end of §12. Documents the locked rule (per Mark, transcribed call 2026-04-23): backend serializes all enums uppercase across Postgres and Firestore; PRD/SPEC text references enums in lowercase for readability; FE display layer translates between uppercase wire format and operator-facing labels. The convention applies retroactively across the suite and requires no operational text rewrites because the lowercase doc convention was always the readability form, not a claim about backend casing. Closes H2P-05 from CONSISTENCY-REVIEW-2026-04-23 (which had flagged divergent casing between PRD-03's lowercase and PRD-09's uppercase Firestore writes); the divergence was a brief Postgres-side regression Mark is reverting in code, not a doc problem. Suite-wide cross-reference: PRD-03, PRD-06, PRD-07, PRD-09, and any other doc referencing enum values inherits this convention from PRD-01 §12 without per-doc edits. No version bump on PRD-01 (convention documentation, not behavioral change). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-05; transcribed call with Mark 2026-04-23.

---

## 1. What This Is in Plain English

The job record is the atomic unit of the SMAI platform. Every operator interaction, every automated send, every status change, every proof event, and every outcome traces back to a single job record.

A job represents one service opportunity: one property, one customer contact, one pipeline trajectory from intake through closed outcome. It is not a campaign, not a conversation thread, not a contact record. It is the job.

The job record has two layers of state. The first is `pipeline_stage`: where the job sits in its lifecycle (in campaign, won, lost). The second is `status_overlay`: a condition that interrupts the pipeline lane and demands operator attention (customer waiting, delivery issue, paused). The overlay sits on top of the stage. Both layers are always present in the data; the overlay is null when no interruption exists.

The CTA engine reads both layers and resolves a single `cta_type` for every job at every moment. That value drives the operator-facing action on every surface: Needs Attention, Jobs list, and Job Detail header. One job, one CTA, always.

This PRD defines the complete job record contract. Every other PRD that touches jobs reads from or writes to this contract.

---

## 2. What Builders Must Not Misunderstand

1. **Pipeline stage and status overlay are two separate fields, not one.** The UI presents named statuses to operators, but the data model uses `pipeline_stage` + `status_overlay`. Every surface must derive the display status from these two fields, not from a single combined field.

2. **Status transitions are system-enforced, not UI-enforced alone.** The backend must validate every status transition server-side. The frontend cannot be the only guard.

3. **`on_behalf_of_user_id` does not exist.** OBO job creation is cut from the Buc-ee's release. Every job is attributed to the logged-in user via `created_by_user_id`. No engineer should add an OBO field to the jobs table.

4. **The CTA engine is a shared utility, not per-surface logic.** All surfaces (Needs Attention, Jobs list, Job Detail) must call the same resolution function. CTA logic must not be duplicated or reimplemented per screen.

5. **The job record is append-only for audit purposes.** Field edits are allowed, but the history table (`job_proposal_history`) is never modified or deleted. Every status change and every job-scoped event writes a new row. This is non-negotiable.

6. **Email address is locked after job creation.** It is the campaign send target. The only correction path is Fix Issue. No other edit surface can change it.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- The canonical field list for the jobs record and its primary contact record
- The two-layer status model and operator-facing display mapping
- The CTA resolution rule
- All valid status transitions, triggers, and actors
- Field-level editability rules by status
- Validation requirements
- Audit trail requirements

**This PRD does not cover:**
- The New Job intake modal flow (PRD-02)
- Campaign scheduling, sending, or stop condition logic (PRD-03)
- Needs Attention surfacing logic and card behavior (PRD-04)
- Jobs list rendering, filters, or sort order (PRD-05)
- Job Detail screen layout, sub-flows, or panel behavior (PRD-06)
- Estimate upload flow (PRD-02 or PRD-06)
- Gmail connection and OBO sending infrastructure (Gmail Layer PRD)
- Analytics data model (Analytics PRD)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| No OBO job creation. Every job attributed to logged-in user. | Session State v6.0, DL locked |
| Status transitions validated server-side. | Spec 7, Section 4 |
| CTA engine is a single shared utility. All surfaces call the same function. | Spec 7, Section 9 |
| Email address locked after job creation. Fix Issue is the only correction path. | Session State v6.0, Lovable FE audit |
| Append-only audit trail. `job_proposal_history` is never modified. | Platform Spine, trust contract |
| Manager role is dormant. No backend logic depends on it. | DL-015 |
| `on_behalf_of_user_id` field does not exist. | Session State v6.0 |
| Line of Business locked after job creation. | Lovable FE audit (April 10, 2026) |
| Scenario (`scenario_key`) locked after job creation. Required at intake alongside Job Type. | SPEC-03 v1.3; Save State 2026-04-21 |
| Office Location (location_id) locked after job creation. | Session State v6.0 |
| Proposal Value (job_value_estimate) updates only on new PDF upload. | Session State v6.0 |
| All jobs are created directly into `in_campaign`. No `draft` or `awaiting_estimate` stage in the launch build. | Lovable FE audit (April 10, 2026) |
| Physical table name is `job_proposals`. Campaign table is `campaigns` (polymorphic, `target_type = JOB_PROPOSAL`). History table is `job_proposal_history`. | DL-026, DL-027, Reconciliation Report 2026-04-16 |

---

## 5. Actors and Objects

**Actors:**
- **Originator** — the logged-in user who creates and manages jobs. Can edit permitted fields, mark outcomes, pause and resume campaigns, and trigger Fix Issue.
- **Admin** — same capabilities as Originator for job operations. Additionally manages team and location access (out of scope for this PRD).
- **System (SMAI)** — drives automated transitions: detects customer replies, detects delivery failures, advances campaign steps, writes all audit events.
- **Manager** — role exists in DB enum but is dormant. No job-level behavior is assigned. Do not implement any Manager-specific CTA or permission logic.

**Core objects in scope:**
- `job_proposals` — the primary record. One row per job. (Referred to as "jobs" in prose throughout this PRD for readability; the physical table name is `job_proposals`.)
- `job_contacts` — the customer contact for the job. One row per job (MVP supports one contact per job).
- `job_proposal_history` — single append-only table that captures both status transitions and job-scoped events, discriminated by `event_type`. See Section 12.

**Related objects (defined in their own PRDs):**
- `estimates` — attached to jobs at creation time via proposal upload; triggers campaign plan generation.
- `campaigns` — the campaign instance for a job; defined in PRD-03. Uses a polymorphic `target_id` + `target_type` pattern with `target_type = JOB_PROPOSAL`. Referred to as `job_campaigns` in prose throughout this PRD for readability. Carries a `template_version_id` field per SPEC-11 v2.0 for per-template cohort attribution; the field is written on Approve and Begin Campaign per PRD-02's collapsed intake flow and is non-nullable for new campaign runs.
- `messages` — outbound and inbound messages; defined in PRD-03.
- `delivery_issues` — delivery failure records; defined in PRD-03.

---

## 6. The Two-Layer Status Model

The job record carries two state fields simultaneously.

**Layer 1: `pipeline_stage`** — where the job sits in its lifecycle.

| `pipeline_stage` value | Meaning |
|---|---|
| `in_campaign` | Job created. Campaign plan generated or running or completed. |
| `won` | Operator marked the job as won. Terminal. |
| `lost` | Operator marked the job as lost. Terminal. |

**Layer 2: `status_overlay`** — an interruption condition overlaid on the pipeline stage.

| `status_overlay` value | Meaning |
|---|---|
| `customer_waiting` | Customer has replied. Campaign is stopped. Operator must respond. |
| `delivery_issue` | Email delivery has failed. Campaign is paused. Operator must fix contact info. |
| `paused` | Operator has manually paused the campaign. |
| `null` | No interruption. Job is progressing normally. |

**Overlays only apply while `pipeline_stage = in_campaign`.** Won and Lost have no overlays.

### Operator-facing display mapping

The UI presents named statuses. Each maps to a `pipeline_stage` + `status_overlay` combination.

| Operator-facing status | `pipeline_stage` | `status_overlay` |
|---|---|---|
| In Campaign | `in_campaign` | `null` |
| Reply Needed | `in_campaign` | `customer_waiting` |
| Delivery Issue | `in_campaign` | `delivery_issue` |
| Paused | `in_campaign` | `paused` |
| Won | `won` | `null` |
| Lost | `lost` | `null` |

The frontend derives the display status from these fields at render time. There is no separate "display status" field stored in the database.

**Note on Pending Approval:** Prior versions of this PRD carried a Pending Approval row in this table, discriminated by `job_campaigns.status = pending_approval`. Per the 2026-04-21 strategic commitment and PRD-02's collapsed intake flow, no job record is written with a pending-approval state. The durable job write occurs on Approve and Begin Campaign in the Campaign Ready modal, by which point the campaign is active. Any legacy job records in this state are superseded; see PRD-02 and PRD-03 v1.4.1 for the flow specification.

---

## 7. CTA Resolution

The system resolves exactly one `cta_type` per job at all times. This value is computed at query time from `pipeline_stage` and `status_overlay`. It is returned in every API response for a job. It is not persisted as a column on the jobs record. The mapping table and priority ladder below are the authoritative derivation rules. All surfaces read `cta_type` from the API response — no surface reimplements the derivation logic independently.

### CTA mapping

| `pipeline_stage` | `status_overlay` | `cta_type` |
|---|---|---|
| `in_campaign` | `null` | `view_job` |
| `in_campaign` | `customer_waiting` | `open_in_gmail` |
| `in_campaign` | `delivery_issue` | `fix_delivery_issue` |
| `in_campaign` | `paused` | `resume_campaign` |
| `won` | `null` | `view_job` |
| `lost` | `null` | `view_job` |

### Priority ladder

When multiple conditions could theoretically apply, the CTA engine resolves using this priority order (highest to lowest):

1. `open_in_gmail` (customer_waiting)
2. `fix_delivery_issue` (delivery_issue)
3. `resume_campaign` (paused)
4. `view_job` (in_campaign normal, won, lost)

In practice, only one overlay can be active at a time. The priority ladder governs edge cases during rapid sequential events (e.g., a customer reply arrives while a delivery issue is being resolved).

The `cta_type` value must be derived consistently using the mapping table above on every job fetch. No surface reimplements this logic independently. Confirmed: not a stored field. Mark confirmed April 8, 2026.

**Note on Pending Approval:** Prior versions of this PRD carried a `review_plan` CTA corresponding to a Pending Approval state discriminated by `job_campaigns.status`. Per the 2026-04-21 strategic commitment and PRD-02's collapsed intake flow, no persisted Pending Approval state exists. The `review_plan` CTA is removed. CTA computation no longer reads `job_campaigns.status` as an input.

### Secondary outcome actions (Mark Won and Mark Lost)

`cta_type` refers to the primary status-driven CTA only. Mark Won and Mark Lost are always-visible secondary outcome actions governed by SPEC-09 and are not represented in `cta_type`. Their visibility is derived from `pipeline_stage` directly: shown on active jobs (`in_campaign`), hidden on terminal jobs (`won`, `lost`). See SPEC-09 for placement, form-factor behavior, and confirmation modal rules. Builders must not attempt to encode Mark Won or Mark Lost as additional `cta_type` values.

---

## 8. Canonical Field List

### 8.1 `job_proposals` table

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | UUID (PK) | No | |
| `account_id` | FK → accounts | No | |
| `location_id` | FK → locations | No | Locked after job creation. |
| `job_name` | string | No | e.g. "Water Damage — Kitchen Flood" |
| `job_number` | string | Yes | Internal reference. Editable. |
| `job_type` | string | No | Job Type per SPEC-03 v1.3. Locked after job creation. |
| `scenario_key` | string | No | Scenario per SPEC-03 v1.3. Scoped to the selected `job_type`. Required (NOT NULL) on every `job_proposals` record. Locked after job creation. There is no legacy nullable allowance: Buc-ee's is a net-new tenant and any pre-v1.4 records are test data cleared before go-live. See SPEC-03 v1.3 §13.1. |
| `pipeline_stage` | enum | No | in_campaign, won, lost |
| `status_overlay` | enum | Yes | customer_waiting, delivery_issue, paused, null |
| `estimate_id` | FK → estimates | Yes | Primary/latest estimate attached to this job. |
| `source` | string | Yes | Lead source. e.g. "Google Ads", "Insurance referral". |
| `cause_of_loss` | string | Yes | e.g. "Burst pipe", "Kitchen fire". |
| `job_value_estimate` | numeric | Yes | Proposal value. Updates only on new PDF upload. Not directly editable by operator. |
| `lead_source_details` | jsonb | Yes | Additional lead source metadata. |
| `address_line1` | string | Yes | Property address. |
| `address_line2` | string | Yes | |
| `city` | string | Yes | |
| `state` | string | Yes | |
| `postal_code` | string | Yes | |
| `country` | string | Yes | |
| `campaign_started_at` | timestamp | Yes | |
| `campaign_paused_at` | timestamp | Yes | |
| `campaign_ended_at` | timestamp | Yes | |
| `won_at` | timestamp | Yes | |
| `lost_at` | timestamp | Yes | |
| `created_by_user_id` | FK → users | No | The logged-in user who created the job. Not editable. |
| `created_at` | timestamp | No | |
| `updated_at` | timestamp | No | |

**Explicitly absent:** `on_behalf_of_user_id`. OBO job creation is cut from the Buc-ee's release. This field must not be added.

**Explicitly absent:** `cta_type` as a stored column. It is computed at query time from `pipeline_stage` and `status_overlay` and returned in every API response. It is not persisted. Mark confirmed April 8, 2026. Per v1.4, `job_campaigns.status` is no longer a CTA discriminator input.

### 8.2 `job_contacts` table

One row per job. MVP supports exactly one contact per job.

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | UUID (PK) | No | |
| `job_id` | FK → job_proposals (unique) | No | |
| `customer_name` | string | No | Editable. |
| `customer_email` | string | Yes | **Locked after job creation.** Fix Issue is the only correction path. |
| `customer_phone` | string | Yes | Editable. |
| `preferred_channel` | enum | No | email, none. MVP email only. |
| `created_at` | timestamp | No | |
| `updated_at` | timestamp | No | |

---

## 9. Status Transitions

All transitions are validated server-side. The frontend may initiate a transition via user action, but the backend is the authority.

### Valid transitions

| From | To | Trigger | Actor |
|---|---|---|---|
| `in_campaign` (overlay: null) | `in_campaign` (overlay: customer_waiting) | Inbound email detected via Pub/Sub | System |
| `in_campaign` (overlay: null) | `in_campaign` (overlay: delivery_issue) | Delivery failure detected | System |
| `in_campaign` (overlay: null) | `in_campaign` (overlay: paused) | Operator selects Pause Campaign | Originator or Admin |
| `in_campaign` (overlay: customer_waiting) | `in_campaign` (overlay: null) | Operator responds to customer | Originator or Admin |
| `in_campaign` (overlay: delivery_issue) | `in_campaign` (overlay: null) | Operator fixes contact info and resumes | Originator or Admin |
| `in_campaign` (overlay: paused) | `in_campaign` (overlay: null) | Operator selects Resume Campaign | Originator or Admin |
| `in_campaign` | `won` | Operator marks won | Originator or Admin |
| `in_campaign` | `lost` | Operator marks lost | Originator or Admin |

**Terminal states:** `won` and `lost` have no outbound transitions. A won or lost job cannot be reopened in the MVP.

**Invalid transitions (must be rejected server-side):**
- `won` or `lost` → any other stage
- Any overlay applied to `won` or `lost`

Every transition writes a row to `job_proposal_history`. The write is not optional.

---

## 10. Field Editability Rules

Editability is determined by the job's current `pipeline_stage`, not the overlay. An overlay does not unlock or lock additional fields.

| Field | In Campaign | Won | Lost |
|---|---|---|---|
| Customer Name | Editable | Editable | Editable |
| Customer Phone | Editable | Editable | Editable |
| Property Address | Editable | Editable | Editable |
| Job Number | Editable | Editable | Editable |
| Job Description / Cause of Loss | Editable | Editable | Editable |
| Line of Business (`job_type`) | Locked | Locked | Locked |
| Scenario (`scenario_key`) | Locked | Locked | Locked |
| Customer Email | Fix Issue only | Fix Issue only | Fix Issue only |
| Proposal Value (`job_value_estimate`) | PDF upload only | PDF upload only | PDF upload only |
| Office Location (`location_id`) | Locked | Locked | Locked |
| On Behalf Of | Does not exist | Does not exist | Does not exist |

**Office Location** is locked immediately at job creation. It cannot be changed after the job record is written.

**Customer Email** is locked immediately at job creation. It can only be corrected through the Fix Issue flow, which clears the delivery issue overlay and resumes the campaign on correction.

**Line of Business** is locked immediately at job creation. It is set during the New Job intake form and cannot be changed after the job record is written.

**Scenario** is locked immediately at job creation. It is set during the New Job intake form alongside Job Type and cannot be changed after the job record is written. Scenario is a required input to template resolution per SPEC-11 v2.0; changing it after campaign activation would invalidate the template variant reference stored on the campaign run record.

**Proposal Value** is never directly editable by the operator. It is extracted from the uploaded PDF by the AI intake process. The only way it updates is when a new PDF is uploaded and processed.

---

## 11. Validation Requirements

### Required fields at job creation

All of the following must be present and non-empty for the job record to be written:

- Customer Name
- Customer Email (must pass basic format validation)
- Property Address (at minimum address_line1 and city)
- Line of Business (`job_type`)
- Scenario (`scenario_key`), scoped to the selected `job_type` per SPEC-03 v1.3
- Office Location (`location_id`)
- Proposal PDF (required to trigger campaign plan generation)

Customer Phone is not required.

### Email address validation

Customer Email must pass basic format validation (valid email string) before the job can be created. Invalid format blocks submission and shows a field-level error in the intake form. The system does not verify deliverability at intake; that check occurs when the first campaign message is sent.

### Location scope

`location_id` must be a location the creating user has access to. The backend validates this at job creation. A user cannot create a job in a location outside their permitted scope.

---

## 12. Audit Trail Requirements

These are non-negotiable. No exceptions.

### `job_proposal_history`

A single consolidated append-only table captures both status transitions and job-scoped events. Rows are distinguished by `event_type`. This table underpins the Activity Timeline shown on the Job Detail screen.

**Fields:**

| Field | Type | Notes |
|---|---|---|
| `id` | UUID (PK) | |
| `job_id` | FK → `job_proposals` | |
| `event_type` | enum | See valid values below. |
| `old_status` | string | For transition events, the prior status value. Null for non-transition events. |
| `new_status` | string | For transition events, the new status value. Null for non-transition events. |
| `details` | string | Short human-readable description (e.g., `customer_replied`, `operator_paused`, `delivery_failed`). |
| `changed_by` | string | Email address, not UUID. Null if system-driven. User email if operator-driven. |
| `metadata` | jsonb | Event-specific payload. Holds `changed_fields`, `old_values`, `new_values` for `job_fields_updated`, and similar structured payloads for other events. |
| `change_date` | timestamp | |

**Valid `event_type` values:**

| Event type | Trigger |
|---|---|
| `job_created` | Job record written |
| `job_fields_updated` | Edit Job save writes changed fields to `metadata` |
| `status_overlay_changed` | `status_overlay` transition (writes old/new) |
| `pipeline_stage_changed` | `pipeline_stage` transition (writes old/new) |
| `estimate_attached` | Estimate uploaded and linked |
| `campaign_approved` | Operator approves campaign plan in the Campaign Ready modal. This is the moment the durable job and campaign records are written atomically per PRD-02's collapsed intake flow; under templated architecture (SPEC-11 v2.0) there is no separate `campaign_plan_generated` event because plan resolution is ephemeral until approval. |
| `campaign_paused` | Operator pauses campaign |
| `campaign_resumed` | Operator resumes campaign |
| `campaign_step_sent` | Outbound email sent |
| `campaign_step_dropped` | Pre-send checklist fails and Cloud Task is dropped (system-driven; logged for audit, filtered from operator-facing Activity Timeline per PRD-06 §10.1) |
| `campaign_completed` | Final step sent without stop condition |
| `customer_replied` | Inbound email detected |
| `operator_replied` | Operator sends manual reply via Gmail; detected by smai-comms on outbound message from operational mailbox (PRD-03 §10.1, PRD-06 §11.1, PRD-09 §8.5) |
| `delivery_issue_detected` | Delivery failure detected |
| `delivery_issue_resolved` | Operator fixes contact and resumes |
| `job_needs_attention_flagged` | A reply or delivery failure has moved the job into a state requiring operator attention; written alongside `customer_replied` or `delivery_issue_detected` per PRD-03 §10.1 / §10.2 and PRD-09 §8.5 / §10.2 |
| `job_marked_won` | Operator marks won |
| `job_marked_lost` | Operator marks lost |
| `job_issue_flagged` | Operator flags an issue on a job via the Flag Issue action (PRD-05 §11.4); optional description stored in `metadata` |
| `job_deleted` | Operator soft-deletes job |

This table is never modified after insert. No deletions. No updates.

### Canonical enum-casing convention

This convention governs all enum references in the SMAI PRD/SPEC suite.

**Backend serialization is uppercase.** Every enum value written to or read from Postgres or Firestore by the backend is uppercase. This applies to all enums referenced anywhere in the suite, including (non-exhaustive): `pipeline_stage` (`IN_CAMPAIGN`, `WON`, `LOST`), `status_overlay` (`PAUSED`, `CUSTOMER_WAITING`, `DELIVERY_ISSUE`), `cta_type` (`OPEN_IN_GMAIL`, `FIX_DELIVERY_ISSUE`, `RESUME_CAMPAIGN`, `VIEW_JOB`), `event_type` in `job_proposal_history` (the 21 values listed above), `campaigns.status` (`ACTIVE`, `PAUSED`, `COMPLETED`, `STOPPED_ON_REPLY`, `STOPPED_ON_DELIVERY_ISSUE`), and `messages.status` (`PENDING`, `SENDING`, `SENT`, `FAILED`, `BOUNCED`).

**PRD/SPEC text references enums in lowercase for readability.** Throughout this PRD and the rest of the suite, enum values appear in lowercase inside backticks (e.g., `cta_type = open_in_gmail`, `pipeline_stage = in_campaign`, `event_type = job_marked_won`). This is a documentation convention only and does not reflect the wire format. Treat any operational text reference as case-insensitive equivalent to its uppercase backend serialization.

**Frontend display layer translates.** The FE does not render raw enum strings. A display layer between the backend response and the rendered UI maps uppercase enum values to operator-facing labels (e.g., `CUSTOMER_WAITING` → "Reply Needed", `STOPPED_ON_REPLY` → "Stopped on reply"). The display label, the backend enum value, and the PRD documentation reference can all differ in casing and wording without contradiction so long as the mapping is preserved.

This convention closes H2P-05 from CONSISTENCY-REVIEW-2026-04-23 (locked 2026-04-23 per Mark). It applies retroactively to all docs in the suite; no operational text rewrites are required because the lowercase doc convention was always the readability form, not a claim about backend casing.

---

## 13. System Boundaries

| Responsibility | Owner |
|---|---|
| Job record creation and field validation | smai-backend |
| Status transition enforcement | smai-backend |
| CTA engine resolution | smai-backend (shared utility) |
| `cta_type` computation and return in API response | smai-backend (computed at query time, not stored) |
| Inbound reply detection and overlay trigger | smai-comms (Pub/Sub → Cloud Tasks → smai-backend) |
| Delivery failure detection and overlay trigger | smai-comms → smai-backend |
| `job_proposal_history` write | smai-backend (on every transition and every job-scoped event) |
| Fix Issue flow (UI and correction write) | smai-frontend + smai-backend |
| PDF parsing and `job_value_estimate` extraction | Vertex AI / Gemini 2.5 Flash via smai-backend |
| CTA display per surface | smai-frontend (reads `cta_type` from API, does not recompute) |

The frontend must not reimplement CTA resolution logic. It reads `cta_type` from the API response and renders accordingly.

---

## 14. Implementation Slices

### Slice A: Core job record and contact schema
Confirm `job_proposals` and `job_contacts` tables match this spec. Add any missing fields. Add `scenario_key` to `job_proposals` as a required, locked-after-creation column per §8.1 and SPEC-03 v1.3 §13.1. Remove `on_behalf_of_user_id` if present. Remove `draft` and `awaiting_estimate` from `pipeline_stage` enum if present. Confirm `cta_type` is not a stored column — it is computed at query time from `pipeline_stage` and `status_overlay` only and returned in the API response. Confirm `location_id` is not nullable.

Dependencies: SPEC-03 v1.3 Slice A (scenario master list in place).  
Excludes: Campaign-related fields, estimate upload logic, `campaigns` schema changes (which include `template_version_id` addition and `pending_approval` removal from `campaigns.status`; those live in PRD-03 v1.4.1 Slice scope).

### Slice B: Status transition engine
Implement server-side transition validation. Reject invalid transitions with a typed error. Write to `job_proposal_history` on every transition, using the appropriate `event_type` (`status_overlay_changed` or `pipeline_stage_changed`) and populating `old_status`, `new_status`, `details`, and `changed_by`.

Dependencies: Slice A.  
Excludes: UI-facing transition triggers (those belong to PRD-02, PRD-03, PRD-06).

### Slice C: CTA engine (shared utility)
Implement the CTA resolution function as a single shared utility using `pipeline_stage` and `status_overlay`. Confirm all surfaces read `cta_type` from the API response. Remove any per-surface CTA logic that duplicates this function. Remove any prior code path that read `job_campaigns.status` as a CTA input; per v1.4 it is no longer a discriminator.

Dependencies: Slice B.  
Excludes: Surface-specific rendering logic (PRD-04, PRD-05, PRD-06).

### Slice D: Field editability enforcement
Enforce editability rules server-side. Reject edits to locked fields with typed errors. All fields locked at creation (email, location, line of business, scenario) must be rejected on any edit attempt. Implement Fix Issue as the only path to update `customer_email`.

Dependencies: Slice A, Slice B.  
Excludes: Fix Issue UI flow (PRD-06).

### Slice E: Audit trail validation
Confirm every required job event is written to `job_proposal_history` with the correct `event_type`. Confirm transitions write rows with the appropriate `event_type` and populated old/new status fields. Add missing events. Write a basic QA test that creates a job, runs it through all non-terminal transitions, and asserts a complete event history in `job_proposal_history`.

Dependencies: Slice B.  
Excludes: Activity Timeline rendering (PRD-06).

---

## 15. Acceptance Criteria

**AC-01: Status model**
Given any job record, when the frontend requests job data, then `pipeline_stage`, `status_overlay`, and `cta_type` are present in the response and consistent with the mapping table in Section 6.

**AC-02: CTA uniqueness**
Given any job in any state, when the CTA engine resolves, then exactly one `cta_type` is returned. No job returns multiple or null CTAs except as defined in the mapping table.

**AC-03: Transition enforcement**
Given a request to transition a job to an invalid state (e.g., won → in_campaign), when the backend receives the request, then it returns a typed error and the job record is unchanged.

**AC-04: Audit trail completeness**
Given a job that has been created, received a customer reply, had the reply cleared, and been marked Won, when `job_proposal_history` is queried for that job, then all required events from Section 12 are present with correct `event_type` values, timestamps, and `changed_by` attribution.

**AC-05: Email lock**
Given a job in any status, when an operator attempts to edit `customer_email` through the standard edit form, then the backend rejects the update and returns a typed error. The Fix Issue path succeeds.

**AC-06: OBO field absent**
Given any job creation or edit request, when the request includes an `on_behalf_of_user_id` field, then the backend ignores or rejects it. The field is not stored.

**AC-07: Location lock**
Given a job that has been created, when an operator attempts to change `location_id`, then the backend rejects the update regardless of job status.

**AC-08: Line of Business lock**
Given a job in any status, when an operator attempts to change `job_type`, then the backend rejects the update and returns a typed error.

**AC-09: Scenario lock**
Given a job in any status, when an operator attempts to change `scenario_key`, then the backend rejects the update and returns a typed error.

**AC-10: Scenario required at creation**
Given a job creation request without `scenario_key` populated, when the backend processes the request, then it returns a typed validation error and no job record is written. Given a job creation request with a `scenario_key` that does not belong to the submitted `job_type`'s activated scenarios for the requesting tenant, the backend returns a typed validation error and no job record is written.

---

## 16. Open Questions and Implementation Decisions

**OQ-01: `cta_type` computed vs. stored**
RESOLVED. `cta_type` is computed at query time from `pipeline_stage` and `status_overlay`. It is returned in every API response. It is not a stored column. Mark confirmed April 8, 2026. Note: prior versions of this OQ listed `job_campaigns.status` as a third input. Removed in v1.4 per §7 Pending Approval revision note; OQ-01 text aligned in v1.4.1.

**OQ-02: Overlay conflict handling in practice**
The priority ladder in Section 7 addresses theoretical overlay conflicts. In practice, can a job have both a `customer_waiting` and a `delivery_issue` overlay simultaneously? The spec says no: only one overlay can be active at a time. Engineering should confirm the transition logic enforces mutual exclusivity of overlays.

**OQ-03: Won/Lost reopening**
This spec treats `won` and `lost` as terminal with no outbound transitions. This is correct for Buc-ee's. If a future pilot requires reopening closed jobs (e.g., a customer reconsiders), that is a scope change requiring a new decision ledger entry. Do not build reopening logic now.

**OQ-04: Multi-contact per job**
The DB schema notes MVP supports one contact per job (`job_contacts` has a unique constraint on `job_id`). This is correct. Do not build multi-contact support. If a job has multiple customer contacts in Jeff's real workflow, this is a known MVP limitation to surface during the pilot.

---

## 17. Out of Scope

- New Job intake modal flow and PDF upload (PRD-02)
- Campaign scheduling, sending, stop conditions, reply detection (PRD-03)
- Needs Attention card behavior and surfacing logic (PRD-04)
- Jobs list rendering, filters, or sort order (PRD-05)
- Job Detail screen layout, messaging panel, activity timeline rendering (PRD-06)
- Gmail connection, OAuth, and OBO sending infrastructure (Gmail Layer PRD)
- Analytics data model and RPC queries (Analytics PRD)
- Admin portal (separate codebase, post-Buc-ee's)
- Manager role behavior (dormant, DL-015)
- SMS notifications (cut from Buc-ee's)
- Multi-contact per job (post-MVP)
- Job reopening from Won or Lost (post-MVP)
- `draft` and `awaiting_estimate` pipeline stages (deferred to future in-app job intake build)
