# PRD-02: New Job Intake
**Version:** 1.5  
**Date:** April 21, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked); Session State v6.0; CC-06 (Buc-ee's MVP Definition); Spec 11 (Database Schema); PRD-01 v1.4.1 (Job Record); SPEC-03 v1.3 (Job Type and Scenario); SPEC-11 v2.0 (Campaign Template Architecture); PRD-03 v1.4.1 (Campaign Engine); Reconciliation Report 2026-04-16; PRD-08 v1.2 (user role/location model); SPEC-07 v1.1 (signature composition); Save State 2026-04-21 (collapsed intake flow, scenario selection, Campaign Ready modal, Pending Approval elimination)  
**Related PRDs and specs:** PRD-01 v1.4.1 (Job Record), PRD-03 v1.4.1 (Campaign Engine), PRD-06 (Job Detail), PRD-08 (Settings), PRD-10 v1.2 (SMAI Admin Portal); SPEC-03 v1.3, SPEC-07 v1.1, SPEC-11 v2.0, SPEC-12 v1.0  
**Closes:** 20 TODOs in `NewJobForm.tsx`  
**Revision note (v1.1):** Removed Save as Draft path and all references to `draft` and `awaiting_estimate` pipeline stages. Submit creates the job record and immediately triggers campaign plan generation (PRD-03).  
**Revision note (v1.2):** Removed voice intake and manual entry paths. For the launch, PDF upload is the only intake path.  
**Revision note (v1.3):** Replaced the eight-value Incident Type (Line of Business) field with the Job Type field, values governed by SPEC-03. Removed Job Type from the AI extraction contract — operator always selects explicitly.  
**Revision note (v1.4):** Reframed §8.2 Office Location field behavior by role to match the PRD-08 v1.2 single-location-per-Originator model.  
**Revision note (v1.5):** Three related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, PRD-01 v1.4, and PRD-03 v1.4 drive. Nothing else.
**Patch note (2026-04-22):** §12 "Loading and transition states" Submit timing line now clarifies that the 3-second budget is end-to-end HTTP round trip (inclusive of network overhead), with core render sub-100ms per SPEC-11 §9. No behavioral change. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 L-07).

1. **Collapsed intake flow.** Per PRD-01 v1.4 and PRD-03 v1.4, Submit no longer writes the durable job record. Submit triggers template lookup and render (per PRD-03 §6.3 and SPEC-11 v2.0 §6.1), and the rendered campaign plan is presented in the Campaign Ready surface (§8.4). The durable writes (`job_proposals`, `job_contacts`, `campaigns`, `campaign_steps`, `job_proposal_history` with `event_type = job_created` and `event_type = campaign_approved`) happen atomically on Approve and Begin Campaign. On Cancel or dismiss at any point before Approve, nothing persists. No Pending Approval state ever exists. §8.3 form actions rewritten; new §8.4 specifies the Campaign Ready surface; §10 event timing clarified; §11 edge cases updated; §14 Slice D rewritten; §15 AC-05 rewritten plus new ACs; new OQ on Campaign Ready surface form-factor.

2. **Scenario selection at Step 4.** Per SPEC-03 v1.3, operators now select both Job Type AND Scenario at intake. Scenario is scoped to the selected Job Type and sourced from the tenant-activated scenario set. Required. Deterministic, never auto-filled from the PDF (same rule as Job Type, same rationale per SPEC-03 §2 point 1). §8.1 Section 3 Incident Details adds the Scenario field; §9.1 extraction contract explicitly excludes it; §9.4 normalization note added; §8.3 validation sequence picks up the scenario check; new §8.5 specifies Scenario field behavior.

3. **Sub-type taxonomy refresh.** Per SPEC-03 v1.3 (refined on 2026-04-21 per Jeff's input), the seven active Restoration sub-types are now Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. Supersedes the prior seven-value list. §8.1 Section 3 table and AC-10 updated.

Material section changes in v1.5: §1 (plain-English flow reflects collapsed flow and scenario), §2 (builders list updated: points 2 and 3 rewritten, new points 9, 10, 11), §3 (scope updates), §4 (locked constraints updated), §5 (actors and objects updated), §8.1 Section 3 (new Scenario row, updated Job Type values), §8.3 (form actions rewritten for collapsed flow), new §8.4 (Campaign Ready surface), new §8.5 (Scenario field behavior), §9.1 and §9.4 (extraction contract updated for Scenario exclusion), §10 (event timing clarified), §11 (edge cases for Campaign Ready dismiss), §12 (submit confirmation wording), §14 Slice D and new Slice F, §15 (AC-05 rewritten, AC-10 updated, new AC-11 through AC-14), §16 (new OQ on Campaign Ready surface form-factor), §17 (Campaign Ready dismissal clarified).

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1` and `PRD-03 v1.4` → `PRD-03 v1.4.1` to match the parallel patches. No version bump on PRD-02 (no behavioral change in this doc; sweep is pointer-hygiene only). Audit-trail revision-note text preserved byte-exact. Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01.

---

## 1. What This Is in Plain English

New Job intake is the entry point for every job in the system. It is a modal flow — not a routed page — triggered by the "+ New Job" button in the nav. The modal never navigates away from the current screen. It opens, captures job data from a proposal PDF, resolves the campaign template, presents the rendered campaign plan for operator approval, and either writes the job on approval or exits cleanly without trace on cancellation.

For the launch, the only intake path is PDF upload. The operator drops in a proposal PDF. The system extracts structured fields using Gemini 2.5 Flash, presents the extracted data for operator review, and captures two required deterministic selections the extraction does not attempt: Job Type and Scenario (per SPEC-03 v1.3). When the operator clicks Submit, the engine performs template lookup for the (Job Type, Scenario) pair and renders the campaign plan using merge-field substitution (per SPEC-11 v2.0). The operator then reviews the rendered plan in the Campaign Ready surface and either Approves (which writes the durable job record, the campaign run with `template_version_id`, the rendered campaign steps, and the corresponding history events atomically) or Cancels (which leaves no trace).

No Pending Approval state ever exists. The render between Submit and Approve is ephemeral. Cancelling at any step before Approve is a clean exit — no job created, no history written.

This PRD defines the complete behavior of the New Job intake: every state, every field, every validation, every write, every event, and the exact handoff to PRD-01's job record contract and PRD-03's campaign engine.

---

## 2. What Builders Must Not Misunderstand

1. **New Job is a modal, not a route.** `/jobs/new` must not exist as a routed page. The New Job flow lives entirely inside the modal. Navigating to `/jobs/new` returns a 404 or redirects to `/jobs`. Do not build a routed page for it.

2. **Submission triggers template lookup and render, not a durable write.** When the operator clicks Submit, the engine performs template lookup and merge-field substitution (per PRD-03 §6.3 and SPEC-11 v2.0 §6.1) and returns a rendered campaign plan. Nothing is written to the database at Submit. The durable writes happen only on Approve and Begin Campaign in the Campaign Ready surface (§8.4). Operators who cancel or dismiss at any point before Approve leave no trace.

3. **PDF extraction populates the form — it does not create the job.** The AI extraction step produces a pre-fill payload. The operator reviews and edits this payload in the form before submitting. The job record is not written until the operator clicks Approve and Begin Campaign in the Campaign Ready surface. Extraction failure does not block the operator from proceeding manually within the form.

4. **`job_value_estimate` comes from PDF extraction only.** The operator cannot type a proposal value directly. It is extracted from the uploaded PDF. If extraction fails or the field is not found in the PDF, it is null. The operator cannot override it at intake. This field is read-only in the form.

5. **Office Location behavior depends on the user's role.** Originator-role users see a read-only text field showing their assigned location — they cannot change it. Admin-role users see a required dropdown scoped to all active locations in the account (Admins do not have an assigned location). The backend validates the submitted `location_id` per §8.2 regardless of what the frontend sends.

6. **DASH job number is required for Servpro NE Dallas.** It drives the email subject line format and DASH threadability. It maps to `job_number` in the job record. The intake form must accept it, and the PDF extraction must attempt to find it. If it is not found in the PDF, the field is left blank and the operator must enter it manually before the job can submit.

7. **Phone is not required for submission.** Customer Email is required (it is the campaign send target). Customer Phone is optional. Do not block submission on missing phone.

8. **Voice intake and manual entry do not exist in this build.** PDF upload is the only intake path for the launch. Do not build voice intake, manual entry, or any secondary intake path. These are deferred to a future release.

9. **Scenario is a required operator-selected field at Step 4, scoped to the selected Job Type.** Per SPEC-03 v1.3. The Scenario dropdown is disabled until a Job Type is selected. Changing Job Type clears the Scenario selection and repopulates the dropdown. The Scenario is passed to the template engine at Submit as part of the (Job Type, Scenario) lookup tuple. Like Job Type, Scenario is never auto-filled from PDF extraction (same rationale per SPEC-03 §2 point 1).

10. **The Campaign Ready surface is an owned part of the intake flow.** §8.4 specifies it. On Approve and Begin Campaign, the durable writes happen atomically per PRD-03 §6.4. On Cancel or dismiss, nothing persists. The rendered content shown in Campaign Ready is the same content that will be written to `campaign_steps` on Approve and sent verbatim at execution time; there is no re-render between Approve and send.

11. **No Pending Approval state exists.** Per PRD-01 v1.4.1. Builders migrating from v1.4 must remove any code path that wrote a durable job record at Submit with a pending-approval campaign status. The only code path that writes a durable job record is the Approve and Begin Campaign handler in §8.4.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- The complete modal state machine for PDF intake
- The AI extraction contract: what fields are extracted, confidence scoring, pre-fill rules
- The intake form: all sections, all fields, required vs optional, validation rules
- Office Location rendering by role (Originator read-only label, Admin required dropdown)
- Job Type and Scenario selections at Step 4 (both operator-selected, neither auto-filled)
- Submit behavior: template lookup and render, Campaign Ready surface population
- The Campaign Ready surface: what is displayed, available actions (Approve and Begin Campaign, Cancel/dismiss)
- The atomic durable write on Approve and Begin Campaign: job record, campaign run with `template_version_id`, campaign steps with rendered content, history events
- Clean-exit semantics on Cancel or dismiss (no trace)
- Required events emitted
- Error states and fallback behavior

**This PRD does not cover:**
- Campaign template architecture, render contract, or merge-field substitution semantics (SPEC-11 v2.0)
- Campaign template authoring (SPEC-12 v1.0)
- The (Job Type, Scenario) taxonomy itself (SPEC-03 v1.3)
- Campaign engine send lifecycle, pre-send checklist, stop conditions, Cloud Tasks (PRD-03 v1.4.1)
- Estimate upload from Job Detail (PRD-06)
- Edit Job form for existing jobs (PRD-06)
- Voice intake (deferred — not in this build)
- Manual entry (deferred — not in this build)
- Chrome extension architecture or its session handling
- SMS notifications (cut from MVP)
- Admin portal intake (separate codebase)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| New Job is a modal, not a route. `/jobs/new` must not exist. | Session State v6.0, Lovable FE audit |
| PDF upload is the only intake path for the launch build. | Lovable FE audit (April 10, 2026) |
| Submit triggers template lookup and render. No durable writes until Approve and Begin Campaign. | Save State 2026-04-21 (Pending Approval elimination); PRD-01 v1.4.1; PRD-03 v1.4.1 |
| Durable writes (`job_proposals`, `job_contacts`, `campaigns`, `campaign_steps`, `job_proposal_history` rows for `job_created` and `campaign_approved`) are atomic on Approve and Begin Campaign. | PRD-03 v1.4.1 §6.4 |
| No Pending Approval state. Cancel or dismiss at any step before Approve leaves no trace. | PRD-01 v1.4.1; Save State 2026-04-21 |
| `job_value_estimate` is extraction-only. Not operator-editable at intake. | Session State v6.0 |
| Customer Email is required. Customer Phone is optional. | PRD-01 v1.4.1 |
| Office Location locked after job creation. | PRD-01 v1.4.1, Session State v6.0 |
| Job reference number requirement is controlled by a per-Organization flag (job_reference_required) set in the admin portal. Required when flag is true. Jeff's tenant flag is true. | CC-06 (Buc-ee's MVP Definition) |
| Job Type values and behavior governed by SPEC-03 v1.3. Operator selects explicitly; system never auto-fills or infers. | SPEC-03 v1.3 |
| Scenario values and behavior governed by SPEC-03 v1.3. Required at intake, scoped to selected Job Type, operator-selected, never auto-filled. | SPEC-03 v1.3 |
| Campaign template lookup at Submit keys on (`job_type`, `scenario_key`). Missing active variant fails loudly with an operator-facing error; no Campaign Ready surface is shown. | SPEC-11 v2.0 §8, §10.3; PRD-03 v1.4.1 §6.3 |
| `campaigns.template_version_id` is written on every campaign run at Approve. Non-nullable. | SPEC-11 v2.0 §11.3; PRD-01 v1.4.1 §5; PRD-03 v1.4.1 §6.4 |
| AI model for extraction: Vertex AI / Gemini 2.5 Flash. | Session State v6.0 (forensic audit confirmed) |
| Stack is GCP / Cloud SQL / Kotlin / Micronaut. | Session State v6.0 (forensic audit) |
| Extraction failure must not block the operator from proceeding manually within the form. | Spec 5 (carried forward) |
| All intake creates the same job record structure defined in PRD-01 v1.4.1. | PRD-01 v1.4.1 |
| `on_behalf_of_user_id` does not exist. Every job attributed to logged-in user. | PRD-01 v1.4.1, Session State v6.0 |
| Physical table names per PRD-01 v1.4.1 §4 and DL-026, DL-027. | PRD-01 v1.4.1 |

---

## 5. Actors and Objects

**Actors:**
- **Originator or Admin** — the logged-in user who triggers and completes the intake flow. Approves or cancels in the Campaign Ready surface.
- **System (Gemini 2.5 Flash via smai-backend)** — performs PDF parsing and field extraction during the Scanning and AI Analysis states.
- **System (smai-backend)** — validates the submitted intake, performs template lookup and merge-field substitution at Submit, returns the rendered plan, and on Approve performs the atomic durable write per PRD-03 v1.4.1 §6.4.
- **System (Template Engine per SPEC-11 v2.0)** — performs template lookup by (`job_type`, `scenario_key`) and merge-field substitution at Submit.

**Core objects written by intake (ALL written atomically at Approve and Begin Campaign, never at Submit):**
- `job_proposals` — one new row created with `pipeline_stage = in_campaign`, `status_overlay = null`, `scenario_key` populated.
- `job_contacts` — one new row created alongside the job.
- `campaigns` (referred to as `job_campaigns` in prose) — one new row created with `status = active`, `template_version_id` populated with the variant ID from Submit-time render.
- `campaign_steps` — rows per rendered step (count defined by the active template variant), carrying rendered subject and body.
- `job_proposal_history` — rows with `event_type = job_created` and `event_type = campaign_approved` written in the same transaction.

**Transient objects (not persisted as records):**
- Extraction payload — the structured output from Gemini. Used to pre-fill the form. Not stored as its own record.
- Rendered campaign plan — output of template lookup and merge-field substitution at Submit. Held in memory between Submit and Approve. Discarded on Cancel or dismiss. Written to `campaign_steps` on Approve.

---

## 6. Modal Entry Points and Triggers

The New Job modal is triggered from exactly two places:
1. The "+ New Job" button in the top navigation bar (all screens).
2. The "+ New Job" button on the Needs Attention screen (empty state).

The modal opens centered on top of the current screen. The background content is dimmed. The modal does not navigate. Closing the modal or completing intake returns the operator to the screen they were on.

On mobile (390px), the modal renders as a full-screen sheet that slides up from the bottom.

---

## 7. Modal State Machine

The modal moves through four sequential states before the Campaign Ready surface. The operator cannot skip states in the forward direction. They can cancel at any state.

```
[Step 1: Upload] → [Step 2: Scanning] → [Step 3: AI Analysis] → [Step 4: Review & Submit] → [Campaign Ready surface (§8.4)]
```

**Step 1: Upload**

What the operator sees:
- Modal title: "New Job"
- A drag-and-drop upload zone. Label: "Drop your proposal PDF here"
- A secondary link: "Browse files"
- Accepted file types: PDF only
- File size limit: 25 MB

No job record exists yet at this step. Nothing is written to the database at any step before Approve and Begin Campaign in the Campaign Ready surface.

**Step 2: Scanning**

Triggered immediately on file drop or file selection. The operator cannot interact while scanning is in progress.

What the operator sees:
- Modal title: "Reading your proposal..."
- A progress indicator (spinner or animated bar)
- Sub-label: "This takes a few seconds"
- A "Cancel" link in the bottom-left corner

Backend behavior during this step:
1. smai-backend receives the PDF as a multipart upload.
2. The file is stored temporarily in GCS.
3. Gemini 2.5 Flash processes the PDF and returns an extraction payload.
4. The extraction payload includes field values and confidence scores (0.0 to 1.0 per field).

If the backend returns an extraction error (timeout, parse failure, unreadable file): skip to Step 3 with an empty or partial payload. Do not show an error modal. Surface the partial result with a visible notice: "We couldn't read some fields — please fill them in manually." The operator proceeds.

If the uploaded file is not a PDF or exceeds 25 MB: reject at the client before upload, show an inline error: "Please upload a PDF under 25 MB."

**Step 3: AI Analysis**

This state is the brief transition between processing completing and the form rendering. In most cases it is nearly instantaneous. It exists as a named state to handle race conditions and slow network responses gracefully.

What the operator sees:
- Modal title: "Preparing your job..."
- A progress indicator
- Sub-label: "Almost ready"

When the pre-fill payload is ready, the modal advances automatically to Step 4.

**Step 4: Review & Submit**

The intake form renders pre-filled with extracted data. The operator reviews, edits, selects Job Type and Scenario, and submits. This is the step where the Submit action lives.

On Submit (detailed in §8.3), the engine performs template lookup and render, and the operator advances to the Campaign Ready surface (§8.4). No durable writes occur at Submit.

---

## 8. Step 4: The Intake Form

### 8.1 Form structure

The form renders in a single scrollable panel within the modal. All six sections are visible on scroll. Required fields are marked with an asterisk.

**Section 1: Customer Information**

| Field | Required | Notes |
|---|---|---|
| Customer Name | Yes | Free text. Max 200 chars. |
| Customer Email | Yes | Email format validation. Locked after job creation. |
| Customer Phone | No | Phone format normalization applied. |
| Alternate Phone | No | |
| Preferred Contact Method | No | Dropdown: Email, Phone, Either. Defaults to Email. |
| Company Name | No | |
| Emergency Contact | No | |
| Emergency Contact Phone | No | |

**Section 2: Property Information**

| Field | Required | Notes |
|---|---|---|
| Property Address | Yes | At minimum address_line1 and city must be non-empty. |
| Property Type | Yes | Dropdown. Values defined by SMAI (e.g., Residential, Commercial). |
| Square Feet | No | Numeric. |
| Year Built | No | 4-digit year. |
| Levels Affected | No | Free text or numeric. |

**Section 3: Incident Details**

| Field | Required | Notes |
|---|---|---|
| Job Type | Yes | Maps to `job_type` in the job record. Dropdown values per SPEC-03 v1.3 §7.1 — seven Restoration sub-types: Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. Sourced from the tenant's Job Type activation per SPEC-03 §10. Operator selects explicitly; never auto-filled from PDF extraction (see SPEC-03 §2 point 1). Deferred Job Types (Reconstruction, HVAC, Plumbing, Roofing, Other) are not activated for any v1 tenant and do not appear in the dropdown. |
| Scenario | Yes | Maps to `scenario_key` in the job record. Required. Scoped to the selected Job Type; see §8.5 for field behavior. Values per SPEC-03 v1.3 §7.2. Sourced from the tenant's Scenario activation per SPEC-03 §10. Operator selects explicitly; never auto-filled from PDF extraction. |
| Cause of Loss | No | Free text. |
| Urgency Level | No | Dropdown. |
| Date of Loss | No | Date picker. |
| Area Affected | No | Free text. |
| Materials Affected | No | Free text. |
| Incident Description | No | Long text. |

**Section 4: Insurance Information**

| Field | Required | Notes |
|---|---|---|
| Insurance Carrier | No | Free text. |
| Policy Number | No | Free text. |
| Deductible Amount | No | Numeric. |

**Section 5: Job Classification**

| Field | Required | Notes |
|---|---|---|
| Job Number (DASH Job #) | Optional by default. Required if the account's job_reference_required flag is enabled. This flag is set per Organization in the admin portal at onboarding. Attempt PDF extraction. If not found, field is blank and operator must enter before submission. Maps to `job_number` on the job record. See OQ-01 for how this conditionality is managed. |
| Office Location | Auto-set | Not a free-text input. See §8.2. |
| Job Value (Proposal Value) | Read-only | Populated from PDF extraction only. Maps to `job_value_estimate`. Operator cannot edit. Displays "Not extracted" if not found in PDF. |

**Section 6: Notes and Attachments**

| Field | Required | Notes |
|---|---|---|
| Additional Notes | No | Long text. |
| Attachments | No | Drag-and-drop zone. Accepted types: PDF, JPG, PNG, DOCX. Max 25 MB per file. Files stored in GCS. Linked to the job record on Approve. Does not trigger campaign. |

---

### 8.2 Office Location field behavior

**Originator-role user:** The Office Location field renders as a read-only label showing the user's assigned location (from `users.location_id` per PRD-08 v1.2). There is no dropdown. The `job_proposals.location_id` is set automatically to the user's assigned location. The operator cannot change it. Originators are single-location by design per PRD-08 v1.2 §2 and Jeff's 2026-04-18 confirmation.

**Admin-role user:** The Office Location field renders as a required single-select dropdown populated with every active location in the account. Admins do not have an assigned location on their user record (`users.location_id = null`) — they must select the correct office for this job at intake. The dropdown defaults to the location currently selected in the nav sidebar, if any. The Admin can change it before submitting. Submission is blocked until a location is selected.

In both cases: `job_proposals.location_id` is locked immediately when the job record is written (at Approve, per §8.4). It cannot be changed after submission. This field is the single source of truth for the job's office throughout the rest of the system — including the office data that appears in the campaign email signature composed per SPEC-07 v1.1.

The backend validates the submitted `location_id`:
- For Originators, the submitted value must match `users.location_id`. A mismatch returns a validation error.
- For Admins, the submitted value must point to an active location in the Admin's `account_id`. A location outside the account returns a validation error.
- In both cases, a missing `location_id` returns a validation error and the job is not created.

---

### 8.3 Form actions

**Submit**

Validates all required fields before triggering template lookup and render.

Validation sequence:
1. Customer Name — non-empty.
2. Customer Email — non-empty, valid email format.
3. Property Address — address_line1 and city non-empty.
4. Property Type — selection made.
5. Job Type — selection made (per SPEC-03 v1.3).
6. Scenario — selection made and scoped to the selected Job Type (per SPEC-03 v1.3; §8.5 here).
7. Office Location — present and valid per §8.2.
8. Job Number — if the account is configured to require it (see OQ-01), non-empty.

If any required field fails validation: inline error shown under the offending field. The form does not submit. The operator must fix the error before trying again. No writes occur. No template lookup is performed.

On successful validation, smai-backend performs the §6.2 eligibility check from PRD-03 v1.4.1 and the §6.3 template lookup and render. Three outcomes:

- **Success:** Rendered campaign plan is returned. The Campaign Ready surface (§8.4) renders the plan for operator review.
- **No active template variant for the (Job Type, Scenario) pair:** Backend returns a typed error. The operator sees "Campaign could not be generated. Contact support." No Campaign Ready surface is shown. The modal returns the operator to Step 4 so they can adjust or cancel. No writes occur.
- **Unresolved merge field or missing required job context:** Same behavior as above. No writes occur.

**Cancel**

Available at all steps including the Campaign Ready surface. Closes the modal. No job record is written if the operator cancels before clicking Approve and Begin Campaign in the Campaign Ready surface.

---

### 8.4 The Campaign Ready surface

After a successful Submit (§8.3), the operator advances to the Campaign Ready surface to review the rendered campaign plan and decide whether to write the durable job record.

**Form factor:** This PRD specifies behavior, not form-factor. The Campaign Ready surface may be implemented as a separate modal that replaces the New Job modal, a new state within the same modal shell, or a full-screen step-5-of-5 transition. Each approach can satisfy the behavior specified here. Design decision captured in OQ-04.

**What is displayed:**

- A summary card showing the Job Type (as a badge with the sub-type label per SPEC-03 §8.3 casing rules) and the Scenario (adjacent, clearly labeled so the operator can confirm both selections before approving).
- The rendered campaign step sequence: one preview per step, in order, each showing:
  - Step order and name (e.g., "Step 1 of N")
  - `delay_from_prior` rendered as a human-readable interval (e.g., "Immediately on approval", "4 hours later")
  - Rendered subject line (with `[{job_number}]` prefix preview if `job_number` is present)
  - Rendered body content
- Customer information and property address as context so the operator can verify the plan is being sent to the right recipient.

The rendered content shown here is the same content that will be written to `campaign_steps` on Approve and sent verbatim at execution time (per PRD-03 v1.4.1 §7.2). There is no re-render between Approve and send.

**Available actions:**

- **Approve and Begin Campaign** — Primary action. Triggers the atomic durable write per PRD-03 v1.4.1 §6.4. See §8.4.1 below.
- **Cancel / Back to Review** — Returns the operator to the Step 4 form without writing anything. The extraction payload and form state are preserved so the operator can adjust and re-submit. (Implementation: whether this is a true "back" with preserved state or requires re-render is a UX design detail; product requires that the operator can return to adjust without re-uploading the PDF.)
- **Dismiss (X / Escape / click outside)** — Treated equivalently to Cancel. Modal closes. No writes. Clean exit.

#### 8.4.1 Approve and Begin Campaign

When the operator clicks Approve and Begin Campaign, the frontend calls the backend approval endpoint with the intake form data and the `template_version_id` of the rendered plan shown in the surface.

Backend behavior (from PRD-03 v1.4.1 §6.4, summarized here for intake-flow coherence):

1. Re-verify the `template_version_id` is retrievable and its content matches the render output. If the active variant has changed between Submit render and Approve, the write uses the variant whose `template_version_id` was returned at Submit — the operator approved THAT specific content. If the referenced variant is no longer retrievable, the write fails with a typed error and the operator must re-submit.
2. Perform the atomic transaction:
   - Write `job_proposals` with `pipeline_stage = in_campaign`, `status_overlay = null`, `job_type`, `scenario_key`, `location_id`, and all other intake form fields.
   - Write `job_contacts`.
   - Write `estimates` and attach the PDF to GCS (if not already uploaded during Submit).
   - Write `campaigns` with `status = active`, `template_version_id` populated, `started_at`, `approved_at`, `approved_by_user_id`.
   - Write `campaign_steps` rows with the rendered subject, body, step_order, and `delay_from_prior` for each step in the template variant.
   - Write `job_proposal_history` with `event_type = job_created`.
   - Write `job_proposal_history` with `event_type = campaign_approved`.
   - Enqueue Cloud Tasks at the cadence defined by the template variant.
3. On success: close the modal. The operator lands on the job record for the newly created job, or on the screen they were on when they triggered intake (design decision, not locked here).
4. On transaction failure: return a typed error. The operator sees a generic error. The modal remains open at the Campaign Ready surface. The operator can retry Approve or Cancel.

---

### 8.5 Scenario field behavior

The Scenario field renders as a required single-select dropdown in Section 3 of the intake form.

| State | Visible |
|---|---|
| Default (no Job Type selected) | Picker disabled. Helper text indicates Job Type must be selected first. |
| Job Type selected, Scenario default | "Select scenario" placeholder, required indicator (red asterisk) |
| Dropdown open | Scenarios sourced from the tenant's Scenario activation (per SPEC-03 v1.3 §10) scoped to the selected Job Type. |
| Option selected | Selected label shown in field. Helper text: "Specifies the damage situation. Determines the campaign template variant." |
| Job Type changed after Scenario selected | Scenario field clears. Picker repopulates with new Job Type's scenarios. Submit re-disabled until Scenario is reselected. |
| Submit attempted without Scenario | Field highlighted with error indicator. Submit remains disabled. |

The backend validates the submitted `scenario_key`:
- Must belong to the submitted `job_type`'s activated scenarios for the requesting tenant. A mismatch returns a validation error.
- A missing `scenario_key` returns a validation error and no render is performed.

UX placement of the helper text and dropdown presentation (subtext under each option, side panel, tooltip) is a design decision deferred to design. The requirement here is that Scenario is required, scoped to Job Type, clears on Job Type change, and selected at Step 4 alongside Job Type.

---

## 9. AI Extraction Contract

This section defines what the backend must extract from proposal PDFs and what it must return to the frontend.

### 9.1 Target fields for PDF extraction

Gemini 2.5 Flash receives the full PDF and must attempt to extract the following fields. Each field in the extraction response carries a confidence score from 0.0 to 1.0.

| Target field | Maps to | Notes |
|---|---|---|
| Customer name | `job_contacts.customer_name` | |
| Customer email | `job_contacts.customer_email` | |
| Customer phone | `job_contacts.customer_phone` | |
| Property address (full) | `job_proposals.address_line1`, `city`, `state`, `postal_code` | Parse and normalize. |
| Job Type | `job_proposals.job_type` | **Not extracted.** Operator always selects explicitly at Step 4. See SPEC-03 §2 point 1. Leave blank in the pre-fill payload regardless of what the PDF appears to suggest. |
| Scenario | `job_proposals.scenario_key` | **Not extracted.** Same rule as Job Type; the operator always selects explicitly at Step 4 after selecting Job Type. Leave blank in the pre-fill payload. |
| Cause of loss | `job_proposals.cause_of_loss` | |
| Date of loss | `job_proposals.lead_source_details` (jsonb) | Store as ISO date. |
| Insurance carrier | `job_proposals.lead_source_details` (jsonb) | |
| Policy number | `job_proposals.lead_source_details` (jsonb) | |
| Deductible amount | `job_proposals.lead_source_details` (jsonb) | |
| Job number / DASH job number | `job_proposals.job_number` | Required for Jeff's tenant. |
| Proposal / job value | `job_proposals.job_value_estimate` | Numeric. Extract the total proposal dollar amount. |
| Description / notes | `job_proposals.cause_of_loss` or `job_proposals.lead_source_details` | Use best available field. |

### 9.2 Confidence thresholds

| Tier | Score range | Pre-fill behavior |
|---|---|---|
| High | 0.75 to 1.0 | Auto-populate in the form. |
| Medium | 0.40 to 0.74 | Auto-populate in the form. |
| Low | Below 0.40 | Leave blank in the form. |

### 9.3 Extraction failure handling

Partial failure (some fields extracted, some not): return whatever was extracted. Pre-fill what was found. Leave missing fields blank. Show a non-blocking notice in the form: "Some fields couldn't be read — please check and fill in what's missing."

Total failure (no fields extracted, or API timeout): return an empty payload. Advance to the form with all fields blank. Show a non-blocking notice: "We couldn't read the proposal — please fill in the details manually."

In both cases, the operator proceeds with the form. Extraction failure is never a blocker.

### 9.4 Normalization

Before returning the extraction payload, apply:
- Phone numbers: strip non-numeric characters, format as (XXX) XXX-XXXX for US numbers.
- Property addresses: separate into address_line1, city, state, postal_code where parseable.
- Dates: normalize to ISO 8601 (YYYY-MM-DD).
- Job value: strip currency symbols and commas, return as a numeric value.
- Job Type and Scenario are never extracted or inferred. Always leave both blank in the pre-fill payload. Operator selects both at Step 4 (SPEC-03 v1.3).

---

## 10. Required Events

Every successful intake completion (Approve and Begin Campaign) writes the following rows to `job_proposal_history` atomically. These are non-negotiable.

| Event type | Trigger | Actor |
|---|---|---|
| `job_created` | Job record written at Approve and Begin Campaign | logged-in user (operator email) |
| `campaign_approved` | Campaign run record written at Approve and Begin Campaign (same transaction as `job_created`) | logged-in user (operator email) |

Both rows are written in the same atomic transaction per PRD-03 v1.4.1 §6.4. Neither is written at Submit. No event fires for Cancel or dismiss at any point before Approve.

All rows include `job_id = <new job id>` and `changed_by = <logged-in user email>`.

**Removed in v1.5:** The pattern where `job_created` fired at Submit is removed. Under the collapsed flow, `job_created` fires at Approve.

---

## 11. Edge Cases and Failure Handling

| Scenario | Behavior |
|---|---|
| Operator drops a non-PDF file in the upload zone | Client-side rejection before upload. Inline error: "Please upload a PDF file." |
| PDF exceeds 25 MB | Client-side rejection before upload. Inline error: "Please upload a file under 25 MB." |
| PDF is password-protected or corrupted | Backend returns extraction failure. Advance to form with notice. |
| Extraction takes more than 15 seconds | Timeout. Return empty payload. Advance to form with notice. |
| Operator refreshes browser during extraction | Extraction is lost. Operator restarts intake. No partial job record is written. |
| Operator closes the modal during Step 1, 2, or 3 | No job record written. Modal closes cleanly. |
| Operator clicks Submit with Scenario missing | Inline validation error. Submit disabled. No render performed. No writes. |
| Operator clicks Submit and no active template variant exists for the (Job Type, Scenario) pair | Backend returns typed error. Operator sees "Campaign could not be generated. Contact support." No Campaign Ready surface is shown. Operator returns to Step 4. No writes. |
| Operator clicks Submit and a required merge field has no value in the job context | Backend returns typed error. Same operator-facing message and flow as above. No writes. |
| Operator dismisses the Campaign Ready surface (Cancel, X, Escape, click outside) | No writes. Modal closes cleanly. No trace in the database. Operator returns to the screen they were on when they triggered intake. |
| Operator clicks Back to Review from Campaign Ready | Return to Step 4 with form state preserved. No writes. Operator can adjust and re-submit. |
| Approve and Begin Campaign is clicked but the Approve transaction fails | Generic error shown at the Campaign Ready surface. Modal remains open. Operator can retry Approve or Cancel. No partial writes committed. |
| Approve and Begin Campaign is clicked but the referenced `template_version_id` is no longer retrievable (soft-deleted between Submit and Approve) | Backend returns typed error. Operator sees "Campaign could not be generated. Contact support." Operator must Cancel and re-submit from Step 4. |
| Submitted email address already exists on another job | The system does not deduplicate on email. Two jobs can share the same customer email. This is expected — one customer may have multiple jobs. |
| Location_id submitted violates the role rule | Backend returns 403 or 422 per §8.2. Form shows a generic error. No job is created. |
| Scenario_key submitted does not belong to the submitted Job Type's activated scenarios | Backend returns a typed validation error. Form shows a scoped error. No render is performed. No writes. |
| Required field fails server-side validation after passing client-side | Backend returns a typed validation error per field. Frontend surfaces field-level inline errors. No writes. |

---

## 12. UX-Visible Behavior

### Loading and transition states
- Steps 2 and 3 (Scanning and AI Analysis) must display a visible progress indicator. The operator must never see a blank modal or an unresponsive state for more than 500ms without feedback.
- If extraction takes more than 5 seconds, the sub-label updates to: "This is taking a bit longer than usual..."
- Submit (template lookup and render) should return within 3 seconds under normal conditions. The 3-second budget covers the full HTTP round trip (client to backend to client), inclusive of network overhead; the core template render target is sub-100ms per SPEC-11 §9. If render exceeds 2 seconds, show a progress indicator on the Submit button.

### Form field states
- Empty required fields: shown without error until the operator attempts to submit.
- Validation errors: inline, below the offending field. Red border on the field. Error text in red.
- Pre-filled fields: visually indistinct from manually entered fields — no badge or highlight.
- Read-only fields (Job Value, Office Location for Originator-role users): rendered as disabled input or plain text. Visually distinct from editable fields.
- Scenario dropdown when Job Type is not yet selected: disabled, with helper text prompting Job Type selection.
- Scenario dropdown after Job Type change: cleared, repopulated with new scope.

### Progress indicator
The modal shows a step indicator at the top: 1 of 4, 2 of 4, 3 of 4, 4 of 4. The Campaign Ready surface is not numbered as part of this indicator (see OQ-04 on form-factor); it is presented as a distinct review-and-approve step after Step 4 completes.

### Submit confirmation
After successful Approve and Begin Campaign, the modal closes. The operator lands on the new job's Job Detail or on the screen they were on when they triggered intake (design decision).

---

## 13. System Boundaries

| Responsibility | Owner |
|---|---|
| Modal rendering and state transitions (Steps 1–4 plus Campaign Ready surface) | smai-frontend |
| File upload to GCS | smai-backend (signed URL or direct multipart) |
| PDF extraction (Gemini 2.5 Flash) | smai-backend |
| Extraction payload → pre-fill response | smai-backend |
| Field normalization (phone, address, date, value) | smai-backend |
| Tenant Job Type dropdown source | smai-backend (per SPEC-03 v1.3 §10) |
| Tenant Scenario dropdown source (scoped by Job Type) | smai-backend (per SPEC-03 v1.3 §10) |
| Template lookup and merge-field substitution at Submit | smai-backend / Template Engine (per SPEC-11 v2.0 and PRD-03 v1.4.1 §6.3) |
| Campaign Ready surface rendering | smai-frontend |
| Approve and Begin Campaign atomic write | smai-backend (per PRD-03 v1.4.1 §6.4) |
| `location_id` scope validation | smai-backend |
| `scenario_key` scope validation against Job Type and tenant activation | smai-backend |
| `job_proposal_history` writes | smai-backend (at Approve only) |
| Client-side file type and size validation | smai-frontend (pre-upload guard only) |
| Inline form validation (required field checks) | smai-frontend (UX) + smai-backend (authoritative) |
| Toast notifications | smai-frontend |

The frontend is responsible for UX-level validation and progression. The backend is authoritative for all writes and all validation that affects data integrity.

---

## 14. Implementation Slices

### Slice A: Modal shell and state machine
Build the modal container, the step indicator, and the state transitions (Upload → Scanning → AI Analysis → Review). Implement Cancel behavior at every step.

Dependencies: None.  
Excludes: AI extraction, form submission logic, Campaign Ready surface.

### Slice B: PDF upload and extraction
Implement the file upload endpoint (GCS), the Gemini extraction call, the confidence scoring response, and the pre-fill payload returned to the frontend. Implement extraction failure fallback (empty payload + notice).

Dependencies: Slice A.

### Slice C: Form rendering and field behavior
Build the full intake form (all six sections). Implement Office Location rendering by role (read-only label for Originators, required dropdown for Admins per §8.2). Implement read-only fields (Job Value, Office Location for Originators). Implement required field markers. Implement the Job Type dropdown populated from the tenant's Job Type activation per SPEC-03 v1.3. Implement the Scenario dropdown with Job Type-scoped behavior per §8.5 (disabled without Job Type, cleared on Job Type change).

Dependencies: Slice A; SPEC-03 v1.3 Slices A and B (master lists and activation joins in place).  
Excludes: Validation logic, submission writes, Campaign Ready surface.

### Slice D: Submit behavior (template lookup and render)
Implement client-side and server-side validation for required fields including Scenario. Implement Submit: the backend call that performs template lookup and merge-field substitution per PRD-03 v1.4.1 §6.3, returning the rendered campaign plan payload. Handle the three outcomes: success (advance to Campaign Ready surface), no active template variant (operator-facing error, return to form), unresolved merge field (operator-facing error, return to form). Implement `scenario_key` scope validation against Job Type and tenant activation.

Dependencies: Slices A, B, C; SPEC-11 v2.0 Slice B (template lookup and render in place); PRD-03 v1.4.1 Slice A template lookup integration.  
Excludes: Approve and Begin Campaign write (Slice F).

### Slice E: Campaign Ready surface
Build the Campaign Ready surface per §8.4. Render the summary card with Job Type and Scenario. Render the ordered campaign step preview with per-step `step_order`, `delay_from_prior`, subject, and body. Implement the Approve and Begin Campaign, Cancel / Back to Review, and Dismiss actions. Implement the form-state preservation on Cancel / Back.

Dependencies: Slice D.  
Excludes: Approve atomic write (Slice F).

### Slice F: Approve and Begin Campaign write
Implement the approval endpoint handler per PRD-03 v1.4.1 §6.4: the atomic transaction writing `job_proposals`, `job_contacts`, `estimates`, `campaigns` (with `template_version_id`), `campaign_steps` (rendered content), `job_proposal_history` (`job_created` and `campaign_approved` events), and enqueuing Cloud Tasks. Implement the `template_version_id` re-verification logic. Implement error handling for transaction failure and for template variant no longer retrievable.

Dependencies: Slice E; PRD-01 v1.4.1 Slice A (schema including `scenario_key`); PRD-03 v1.4.1 Slice A (template lookup integration and `campaigns.template_version_id` schema column).

### Slice G: Edge case hardening and TODOs
Close the 20 TODOs in `NewJobForm.tsx`. Implement all error states: corrupted PDF, timeout, server validation errors, location scope mismatch, scenario scope mismatch, missing template variant, render failure, approve transaction failure.

Dependencies: All preceding slices.

---

## 15. Acceptance Criteria

**AC-01: Route does not exist**
Given a browser navigating to `/jobs/new`, when the request resolves, then the page returns a 404 or redirects to `/jobs`. No routed intake page exists.

**AC-02: PDF path end-to-end**
Given an operator uploads a valid proposal PDF, when extraction completes, then the form opens pre-filled with all high- and medium-confidence fields populated, `job_value_estimate` is read-only and reflects the extracted value, the Job Type and Scenario fields are both empty, and the operator can submit successfully after selecting Job Type and Scenario.

**AC-03: Extraction failure does not block**
Given an operator uploads a PDF that fails extraction (corrupt, unreadable, or timeout), when the failure occurs, then the form opens with a non-blocking notice and all fields empty. The operator can fill the form manually, select Job Type and Scenario, and submit successfully.

**AC-04: Required field enforcement**
Given an operator attempts to submit without a required field (including Scenario), when Submit is tapped, then an inline error appears under the missing field, no template lookup is performed, no writes occur, and the form remains open.

**AC-05: Submit renders without writing; Approve writes atomically**
Given an operator submits a valid intake with `job_type` and `scenario_key` selected, when Submit is clicked, then within 3 seconds the Campaign Ready surface displays a rendered campaign plan sourced from the active template variant for the (`job_type`, `scenario_key`) pair with merge fields substituted. No `job_proposals`, `job_contacts`, `campaigns`, `campaign_steps`, or `job_proposal_history` rows exist for this submission. If the operator subsequently clicks Approve and Begin Campaign, then within 3 seconds: the `job_proposals` record has `pipeline_stage = in_campaign` and `scenario_key` populated, a `job_campaigns` record exists with `status = active` and `template_version_id` populated with the variant ID, `campaign_steps` rows exist matching the template variant's step count with rendered subject and body, `job_proposal_history` rows with `event_type = job_created` and `event_type = campaign_approved` are present, Cloud Tasks are enqueued per the template variant's cadence, the modal closes. If the operator clicks Cancel or dismisses the Campaign Ready surface, no database writes occur.

**AC-06: Originator cannot change Office Location**
Given an Originator-role user, when the intake form renders, then the Office Location field is read-only and the submitted `location_id` matches the user's assigned `users.location_id`.

**AC-07: Admin selects Office Location at intake**
Given an Admin-role user, when the intake form renders, then the Office Location field is a required dropdown showing every active location in the account. The submitted `location_id` is validated server-side against the account's location set.

**AC-08: Job Value is not editable**
Given intake, when the form renders, then `job_value_estimate` is read-only. No operator input changes it. If not extracted, it displays as empty or "Not extracted."

**AC-09: Campaign plan render triggered on submit (not write)**
Given a valid intake is submitted, when the backend processes Submit, then template lookup and merge-field substitution are performed per PRD-03 v1.4.1 §6.3, the rendered plan is returned to the frontend, and no database rows are written.

**AC-10: Job Type and Scenario are never auto-extracted**
Given an operator uploads a PDF whose contents suggest a specific job type or scenario (e.g., "water damage" or "sewage backup" appears in the filename or body), when the pre-fill payload is returned, then both the Job Type and Scenario fields are blank. The operator must select both explicitly at Step 4. The system does not infer or auto-populate either field.

**AC-11: Scenario scoped to Job Type**
Given an operator on Step 4 with no Job Type selected, when the Scenario picker is inspected, then the picker is disabled. Given an operator who selects Water Mitigation as Job Type, when the Scenario picker is opened, then the six Water Mitigation scenarios from SPEC-03 v1.3 §7.2 are shown. Given the operator changes Job Type to Mold Remediation, then the Scenario field clears and the picker repopulates with the five Mold Remediation scenarios.

**AC-12: Missing template variant fails loudly at Submit**
Given an intake submission with a (`job_type`, `scenario_key`) pair for which no active template variant exists, when the operator clicks Submit, then the backend returns a typed error with operator-facing message "Campaign could not be generated. Contact support." No Campaign Ready surface is shown. No database writes occur. The operator returns to Step 4.

**AC-13: Dismiss at any pre-Approve point is a clean exit**
Given an operator who has advanced to Step 4 or to the Campaign Ready surface, when the operator clicks Cancel, dismisses the modal via X or Escape, or clicks outside the modal, then the modal closes, no database rows are written, no `job_proposal_history` events fire, and the operator returns to the screen they were on.

**AC-14: Rendered content matches what operator approved**
Given a rendered plan displayed in the Campaign Ready surface at Submit, when the operator clicks Approve and Begin Campaign, then the `campaign_steps` rows written at Approve carry exactly the rendered subject and body that were shown in the Campaign Ready surface, keyed to the `template_version_id` that was returned at Submit. If a SPEC-11 v2.0 activation changed the active variant between Submit and Approve, the written content reflects the Submit-time variant, not the current-active variant.

---

## 16. Open Questions and Implementation Decisions

**OQ-01: DASH job number required flag — how is conditionality stored?**
RESOLVED. Job reference number is controlled by a per-Organization config flag (job_reference_required) set in the admin portal during Organization creation. When true, the field is required for submission. When false, it is optional. The flag is evaluated server-side at submission time. Jeff's tenant has this flag set to true.

**OQ-02: Extraction timeout threshold**
This PRD specifies 15 seconds as the extraction timeout. Mark to confirm p95 against real proposal PDFs. If Vertex AI cold start times or network latency push the p95 extraction time above 10 seconds, the UX copy in Step 2 needs updating and the timeout threshold needs revisiting.

**OQ-03: GCS upload — signed URL or direct multipart?**
The file upload path (PDF to GCS) can be implemented as a direct multipart upload to smai-backend (which then writes to GCS) or as a signed URL issued by smai-backend (client uploads directly to GCS). Either is valid. This is an engineering-design decision. The product requirement is: the file must be in GCS before extraction begins, and the operator must not wait more than 2 seconds for the upload progress indicator to appear.

**OQ-04: Campaign Ready surface form-factor**
§8.4 specifies behavior (what is displayed, what actions are available, what writes occur) but does not lock form-factor. Three implementation options:
- **Option A:** Separate modal that opens after the New Job modal closes on Submit. Two distinct modals.
- **Option B:** New state within the same modal shell (effectively a 5-state machine). One modal.
- **Option C:** Full-screen transition replacing the Step 4 content with Campaign Ready content while the modal shell stays open.

All three satisfy the behavior contract. The product requirement is that Cancel / dismiss at Campaign Ready produces the same clean-exit semantics as Cancel at any prior step (no writes, no trace), and that the operator can return to the Step 4 form with state preserved. Design lead to pick. Flagged here so the decision is visible.

**OQ-05: Render output transport between Submit and Approve**
At Submit, the backend returns the rendered plan. At Approve, the backend needs the `template_version_id` and rendered content to write `campaign_steps`. The implementation question is how the content travels: (a) full payload round-tripped through the frontend and sent back at Approve, (b) server-side short-lived cache keyed by a render session ID, (c) re-render at Approve using the same inputs (idempotent per SPEC-11 v2.0 §10.4 if no activation changes mid-dwell). AC-14 requires that the written content matches what was shown. Implementation must satisfy that constraint. Mark's engineering decision. Not a product scope question. Cross-referenced as PRD-03 v1.4.1 OQ-05.

---

## 17. Out of Scope

- Campaign template architecture, render contract, merge-field substitution semantics (SPEC-11 v2.0)
- Campaign engine send lifecycle, Cloud Task scheduling, stop conditions (PRD-03 v1.4.1)
- Template authoring methodology (SPEC-12 v1.0)
- Voice intake (deferred — not in this build)
- Manual entry (deferred — not in this build)
- Save as Draft (deferred — not in this build)
- Estimate upload from Job Detail (PRD-06)
- Edit Job form for existing jobs (PRD-06)
- Chrome extension architecture and its session handling
- SMS notifications (cut from MVP)
- Admin portal intake (separate codebase, post-MVP)
- Multi-contact per job (post-MVP)
- Duplicate detection across jobs sharing the same customer email (post-MVP)
- Operator-editable campaign tone or template selection during intake (not in MVP)
- Job Value as an operator-editable field (post-MVP, if ever)
- Scenario as an extracted field (per SPEC-03 v1.3; operator-selected only)
- Any Pending Approval persisted state (removed per PRD-01 v1.4.1)
