# PRD-03: Campaign Engine
**Version:** 1.4.1  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked); Session State v6.0 (forensic audit April 4); CC-06 (Buc-ee's MVP Definition); Platform Spine v1.4; Spec 9 (Campaign Engine — used as parts bin where it conflicts with confirmed stack); Spec 17 (Workflow Event Map — stack references superseded); PRD-01 v1.4.1 (Job Record); PRD-02 (New Job Intake; collapsed intake flow); Reconciliation Report 2026-04-16; Save State 2026-04-21 (templated architecture commitment; Pending Approval elimination)  
**Related PRDs and specs:** PRD-01 v1.4.1 (Job Record), PRD-02 (New Job Intake), PRD-04 (Needs Attention), PRD-06 (Job Detail), PRD-09 (Gmail Layer), PRD-10 v1.2 (SMAI Admin Portal, in progress); SPEC-03 v1.3 (Job Type and Scenario taxonomy); SPEC-11 v2.0 (Campaign Template Architecture); SPEC-12 v1.0 (Template Authoring Methodology)  
**Tracking issues:** [#54 A lookup/render/approve](https://github.com/frizman21/smai-server/issues/54) · [#55 B pre-send checklist](https://github.com/frizman21/smai-server/issues/55) · [#56 C send execution](https://github.com/frizman21/smai-server/issues/56) · [#57 D stop conditions](https://github.com/frizman21/smai-server/issues/57) · [#58 E Fix Issue + pause/resume](https://github.com/frizman21/smai-server/issues/58) · [#59 F controller boundary](https://github.com/frizman21/smai-server/issues/59) · [#60 G QA tests](https://github.com/frizman21/smai-server/issues/60)  
**Closes:** 4 TODOs in `CampaignService.kt`; CampaignController internal-boundary TODO; 4 TODOs in `ProposalService.kt` (partially — proposal send behavior)  
**Revision note (v1.1):** Removed `awaiting_estimate` as the campaign activation trigger. Campaign plan generation now fires on job creation (PRD-02 submit), not on estimate upload.  
**Revision note (v1.2):** Removed all static template and token-substitution language. The correct model was then: AI (Gemini) generates final prose (subject lines and body copy) per step at plan generation time, with job context already resolved. (Superseded by v1.4.)  
**Revision note (v1.3):** Table naming aligned to code reality. Physical table names are `job_proposals` (referred to as "jobs" in prose), `campaigns` (referred to as "job_campaigns" in prose; uses polymorphic `target_id` + `target_type = JOB_PROPOSAL`), and `job_proposal_history` (single consolidated history table). All transition and event writes now land in `job_proposal_history` discriminated by `event_type`.  
**Revision note (v1.4):** Three related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, and PRD-01 v1.4 drive. Nothing else.

1. **Templated architecture replaces runtime AI generation.** Per SPEC-11 v2.0. At campaign generation time, the engine performs template lookup by the (`job_type`, `scenario_key`) tuple, performs merge-field substitution against the job context, and renders campaign step records. There is no Gemini call in the generation path. No AI prose generation at any point in the engine's execution. Step count and cadence are variable per template (not the hardcoded 4-step / T+0/T+4h/T+12h/T+24h of v1.3). `campaigns.template_version_id` is added to the schema and written on every campaign run for per-template cohort attribution. Failure modes: loud failure on missing active template variant per SPEC-11 v2.0 §10.3.

2. **Pending Approval state eliminated.** Per PRD-01 v1.4 and the save state's collapsed intake flow. At intake Submit, the engine performs template lookup and render in-memory only. Nothing persists. The rendered output populates the Campaign Ready modal. On Cancel or dismiss, nothing is written. On Approve and Begin Campaign, the durable job record, the campaign run record, the campaign step records, and the relevant `job_proposal_history` events are all written atomically. `pending_approval` is removed from `campaigns.status`. The `review_plan` CTA and the entire "generate now, approve later" two-phase flow are removed. `campaign_plan_generated` is removed from the `event_type` enum (per PRD-01 v1.4); there is no plan-generation event separate from approval because the render is ephemeral until Approve.

3. **Scenario selection is a required input.** Per SPEC-03 v1.3. Campaign template lookup requires both `job_type` and `scenario_key`. Both are passed from the intake modal. Both are locked on `job_proposals` after creation. Existing sections updated to reflect the (`job_type`, `scenario_key`) tuple throughout.

Material section changes in v1.4: §1 (Plain English rewrite of phases), §2 (builders list points 1, 7, and step-count references updated), §3 (scope wording), §4 (locked constraints updated), §5 (core objects descriptions), §6 (full rewrite of plan generation, eligibility, render, approval, Cloud Task payload to reflect collapsed flow and templated architecture), §7 (renamed from "Four Email Steps" to "Campaign Step Sequence"; rewritten for variable step count and template-driven content), §8 (pre-send checklist — minor update, check 4 text unchanged but `pending_approval` no longer appears anywhere), §9 (send execution — minor language updates removing "AI-generated"), §10 (stop conditions — unchanged structurally), §11 (operator reply — unchanged), §12 (Fix Issue — `template_version_id` propagation added), §13 (pause/resume — unchanged structurally), §14 (`job_campaigns` status lifecycle — `pending_approval` row removed), §15 (required events — `campaign_plan_generated` removed, `job_created` noted as firing at Approve), §16 (system boundaries — wording updates), §17 (implementation slices — Slice A rewritten, Slices C, E, G minor updates), §18 (AC-02, AC-03, AC-08, AC-15 rewritten; AC-14 and AC-09 wording adjusted for variable step count), §19 (OQ-03 resolved and removed; new OQ on Fix Issue template-version handling added).

Out of scope for v1.4: reply detection behavior, Pub/Sub wiring, stop condition semantics, operator reply path, pause/resume logic, OBO sending path, quiet hours. All unchanged from v1.3.

**Revision note (v1.4.1, 2026-04-22):** Two surgical corrections; no behavioral change. (1) B-06 cta_type writes stripped: PRD-03 v1.4 and earlier instructed smai-backend to write `jobs.cta_type = <value>` on five operational paths — §10.1 customer reply, §10.2 delivery failure, §10.3 operator pause, §11 operator reply, §13.2 Resume — plus a parenthetical reference in §12.1 Fix Issue step 9. Per PRD-01 v1.4 §7 (and v1.4.1 OQ-01), `cta_type` is computed at query time from `pipeline_stage` and `status_overlay` only. It is never stored. All six write/reference sites rewritten: the `Set jobs.cta_type = ...` lines are removed, step sequences renumbered, and a short read-time clarification added after each path explaining what `cta_type` computes to. AC-06, AC-07, AC-11 softened per the same pattern: each now asserts the `status_overlay` and `job_campaigns.status` state and notes `cta_type` computes at read time, rather than asserting a stored value. This matches the parallel PRD-09 v1.3.1 fix. No behavioral change: the CTA the operator sees is identical. (2) H-06 OBO disambiguation: §2 point 6 now distinguishes PRD-09's Gmail delegated OAuth mechanism from the eliminated `on_behalf_of_user_id` job-attribution field referenced in earlier drafts of PRD-01 and PRD-02. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 B-06, H-06).

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1` to match the parallel PRD-01 patch. No version bump on PRD-03 (no behavioral change in this doc; sweep is pointer-hygiene only). Audit-trail revision-note text preserved byte-exact. Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01.

---

## 1. What This Is in Plain English

The Campaign Engine is the execution layer of SMAI. It does exactly one thing: after an operator creates a job and approves the campaign plan at intake, it sends a sequence of follow-up emails to the customer per the cadence defined by the active template variant, stops the moment the customer replies or something goes wrong, and surfaces every event for the operator to see.

There is no AI in the execution path. There is also no AI in the generation path. Once the operator selects Job Type and Scenario at intake, the engine resolves the active campaign template variant for that (Job Type, Scenario) pair, substitutes merge fields from the job record into the template, and renders the campaign step content. The campaign plan is not generated by an AI at any point. It is authored offline per SPEC-12 and resolved deterministically at intake per SPEC-11 v2.0.

The Campaign Engine has three phases:

**Phase 1: Render and approval.** Triggered by the operator's Submit action in the New Job intake modal (PRD-02). The engine looks up the active template variant for the (`job_type`, `scenario_key`) pair, substitutes merge fields against the job context assembled from the intake form and AI extraction, and renders the campaign step records in-memory. The Campaign Ready modal displays the rendered preview. If the operator cancels or dismisses the modal, nothing persists — no job record, no campaign, no history. If the operator clicks Approve and Begin Campaign, a single atomic transaction writes the durable job record, the campaign run record (carrying `template_version_id` for cohort attribution), the rendered campaign step records, and the corresponding `job_proposal_history` events. Cloud Tasks are scheduled at this moment — one per campaign step — at the cadence defined by the template variant.

**Phase 2: Execution.** Each Cloud Task fires at its scheduled time. Before sending, the engine runs a pre-send checklist against the current job state. If the job is send-eligible, it retrieves the OBO token from smai-comms, retrieves the rendered email content stored on the campaign step (already resolved at render time), and sends via the Gmail API from the operator's dedicated mailbox. Every send result — success or failure — is written immediately.

**Phase 3: Stop and recovery.** Four conditions stop the campaign immediately and permanently for that run: customer reply, delivery failure, operator pause, and job closure (Won or Lost). Each condition writes a distinct overlay, updates the job's `cta_type`, and prevents any further sends for that job. Recovery paths exist for delivery failure (Fix Issue) and operator pause (Resume). Reply and closure have no automated recovery — the campaign stays stopped.

This PRD defines the complete behavior of all three phases: every trigger, every pre-send check, every write, every stop condition, every recovery path, every event, and the exact boundary between what is tenant-callable and what is internal-only.

---

## 2. What Builders Must Not Misunderstand

1. **Campaign initialization is internal-only. No frontend call triggers a durable write outside the approved intake flow.** The `CampaignController` must not expose a campaign initialization endpoint that tenants can call. Initialization — which now means the atomic durable write on Approve and Begin Campaign — is triggered exclusively by the intake flow inside smai-backend. The forensic audit flagged a TODO on this boundary; this PRD resolves it. Any existing tenant-callable initialization endpoint must be removed or locked to internal-only before go-live.

2. **The pre-send checklist runs at send time, not at scheduling time.** Cloud Tasks are scheduled at Approve. Whether to actually send is decided when the task fires, not when it is enqueued. A job can change state between scheduling and send time. The checklist is the gate. If the job fails the checklist when the task fires, the task is dropped silently (no retry, no error, no send).

3. **Missed steps are never re-sent.** If a delivery failure blocks a step and the operator fixes it later, the campaign resumes from the next unsent step. The skipped step is not retried. If the operator pauses during a step and resumes later, the campaign continues from the next unsent step. No step is ever re-sent regardless of the reason it was skipped.

4. **After a customer reply, the campaign stays stopped.** Once `job_campaigns.status = stopped_on_reply`, no further automated sends occur for that job in MVP. The operator can respond to the customer manually. The campaign does not resume after a reply — not automatically, not by operator action. This is a permanent stop for that campaign run.

5. **`stopped_on_reply` and `stopped_on_delivery_issue` are terminal campaign statuses.** They cannot be reversed. A new campaign run would require a new `job_campaigns` record. Fix Issue is the only path that creates a new run. For the Jeff pilot: one campaign run per job, and a stopped-on-reply run does not restart.

6. **The sending identity is the dedicated operational mailbox, not the operator's personal account.** Emails are sent from `{location-identifier}@mail.{customer-primary-domain}` via OBO (On Behalf Of) Gmail API. The token is retrieved from smai-comms at send time, not cached in smai-backend. If the token is missing or expired, the send fails and triggers the delivery failure path. **"OBO" here means Gmail delegated OAuth** (the location-scoped token used by smai-comms to call the Gmail API on behalf of the customer's mailbox, per PRD-09). It is unrelated to the eliminated `on_behalf_of_user_id` job-attribution field referenced in earlier drafts of PRD-01 and PRD-02.

7. **The Campaign Engine does not generate email content with AI. Ever.** Per SPEC-11 v2.0, campaign content comes from templates authored offline per SPEC-12. At intake Submit, the engine performs template lookup by the (`job_type`, `scenario_key`) tuple and substitutes merge fields against the job context to produce rendered subject and body for each step. That rendered content is what the operator sees in the Campaign Ready modal and what is written to `campaign_steps` on Approve. At send time, the backend retrieves the stored content and sends it verbatim. The only element constructed at send time is the `[{job_number}]` subject prefix (§7.3). No Gemini call, no runtime inference, no template mutation, no re-render between approval and send.

8. **Quiet hours are not enforced in the Jeff pilot.** Cadence is defined by the active template variant and fires at the scheduled times regardless of time of day. Quiet hours enforcement is post-MVP. Do not build it now.

9. **The workspace-level campaign pause is a global send block, not a per-job overlay.** If the workspace `campaign_active` flag is false, no sends occur for any job in that workspace, regardless of individual job state. The pre-send checklist checks this flag first.

10. **`CampaignService` handles state logic. `smai-comms` handles sending.** Do not merge these responsibilities. `CampaignService` in smai-backend decides whether to send, what to send, and writes all state transitions. `smai-comms` holds the OBO token and executes the Gmail API call. The boundary is a service call from smai-backend to smai-comms.

11. **Step count and cadence are not hardcoded.** Both come from the active template variant resolved at intake. A Water Mitigation / Sewage Backup campaign might be 3 steps over 36 hours; a Mold Remediation / Crawlspace Mold campaign might be 5 steps over 10 days. Implementation must treat step count as variable and read cadence from the template, not from constants in code.

12. **`pending_approval` is not a state.** Per PRD-01 v1.4.1. No job record or campaign run ever sits in a Pending Approval state. The render between Submit and Approve is ephemeral, in-memory only. Operators who cancel or dismiss the Campaign Ready modal leave no trace in the database. Builders migrating from v1.3 should remove any `pending_approval` handling, any `review_plan` CTA wiring, and any `campaign_plan_generated` event writes.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- Template lookup and render: trigger, eligibility checks, substitution, render output
- Operator approval gate: what Approve and Begin Campaign does, the atomic durable write, Cloud Task scheduling on approval
- Pre-send checklist: all conditions evaluated at task fire time
- Email send execution: token retrieval, stored content retrieval, Gmail API call via smai-comms, result handling
- The campaign step sequence: timing, subject prefix, thread continuity, send sequence
- Reply detection: Pub/Sub push path, thread-to-job resolution, overlay write
- Stop conditions: all four, their triggers, their writes, their downstream effects
- Delivery failure recovery: Fix Issue flow, retry behavior, resume logic
- Operator pause and resume: what pausing does, what resuming does
- Operator response to customer: the manual reply path and its effect on campaign state
- All database writes and events required by this subsystem
- The CampaignController internal-boundary requirement
- Cohort attribution via `campaigns.template_version_id`

**This PRD does not cover:**
- The New Job intake modal flow, including the Campaign Ready modal UX (PRD-02)
- The Needs Attention card behavior and surfacing logic (PRD-04)
- Job Detail screen layout (PRD-06)
- The Open in Gmail CTA behavior and Gmail thread handoff (PRD-06)
- The Fix Issue slide-out UI behavior (PRD-06)
- Gmail OAuth connection and token lifecycle (PRD-09)
- Campaign template authoring (SPEC-12)
- Campaign template data model, versioning, and activation operation (SPEC-11 v2.0)
- The (Job Type, Scenario) taxonomy itself (SPEC-03 v1.3)
- Admin portal template management endpoints (PRD-10 v1.2)
- Notification/alerting layer — SMS alerts on reply and delivery failure (post-MVP)
- Campaign step content editing UI (operators cannot edit rendered campaign content; managed-service model)
- Quiet hours enforcement (post-MVP)
- Campaign regeneration or multi-run per job (post-MVP; the Fix Issue new-run path is the sole exception)
- SMS campaign steps (cut from MVP)
- Non-Google email providers (out of scope permanently for MVP)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| No outbound message sent without `pipeline_stage = in_campaign` and approved campaign plan. | Platform Spine DA-12, PRD-01 v1.4.1 |
| Campaign template lookup and render fires on intake Submit. Nothing persists until Approve. | Save State 2026-04-21 (Pending Approval elimination); PRD-02 collapsed intake flow |
| Durable job record, campaign run, and campaign steps are written atomically on Approve and Begin Campaign. | Save State 2026-04-21; PRD-01 v1.4.1 |
| Campaign initialization is internal-only. No tenant-callable endpoint triggers durable writes outside the approved intake flow. | Session State v6.0 (forensic audit TODO), Platform Spine |
| Operator must approve campaign plan before any send. | Platform Spine DA-06, DA-07, DA-09, DA-10 |
| Pre-send checklist runs at task fire time, not at scheduling time. | This PRD; PRD-01 determinism requirement |
| Missed steps are never re-sent. | Spec 9, Session State v6.0 |
| After customer reply, campaign stays stopped. No automated resume. | Session State v6.0, Platform Spine |
| Sending identity: dedicated operational mailbox via OBO Gmail API. | Session State v6.0 (locked Gmail model, DL-017) |
| Campaign content comes from template render (merge-field substitution on active template variant). No AI in generation or send path. | SPEC-11 v2.0; Save State 2026-04-21 |
| Template lookup keys on (`job_type`, `scenario_key`) tuple. Missing active variant fails loudly. No fallback. | SPEC-11 v2.0 §8, §10.3 |
| `campaigns.template_version_id` written on every campaign run for cohort attribution. Non-nullable for new runs. | SPEC-11 v2.0 §11.3; PRD-01 v1.4.1 §5 |
| Step count and cadence are variable per template variant. No hardcoded 4-step / 24h pattern. | SPEC-11 v2.0 §7.2 |
| Execution layer: Cloud Tasks (scheduling), smai-comms (sending), smai-backend (state). | Session State v6.0 forensic audit |
| Every send, every event, every outcome writes to the append-only audit trail. | Platform Spine, PRD-01 v1.4.1 |
| Physical table names: `job_proposals` (jobs), `campaigns` (job_campaigns; polymorphic with `target_type = JOB_PROPOSAL`), `job_proposal_history` (consolidated history). Prose continues to say "jobs", "job_campaigns", and "history" for readability. | PRD-01 v1.4.1 §4, DL-026, DL-027 |
| `pending_approval` is not a state. `review_plan` is not a CTA. `campaign_plan_generated` is not an event. All removed per PRD-01 v1.4.1. | PRD-01 v1.4.1; Save State 2026-04-21 |

---

## 5. Actors and Objects

**Table naming note:** Prose in this PRD uses the readable labels `jobs`, `job_campaigns`, and "history writes." The physical table names are `job_proposals`, `campaigns` (with `target_type = JOB_PROPOSAL` and `target_id = job.id`), and `job_proposal_history`. All history writes referenced below land in the single `job_proposal_history` table, discriminated by `event_type`. See PRD-01 v1.4.1 §12 for the full schema.

**Actors:**
- **System (smai-backend / CampaignService)** — orchestrates template lookup, render, pre-send checks, state transitions, and event writes.
- **System (Cloud Tasks)** — holds and fires the scheduled send tasks.
- **System (smai-comms)** — holds OBO tokens, executes Gmail API send calls, receives Pub/Sub push for inbound replies.
- **System (Gmail API / Google Pub/Sub)** — the external email and reply detection infrastructure.
- **System (Template Engine per SPEC-11 v2.0)** — the component that performs template lookup and merge-field substitution. Functionally part of smai-backend; called into by `CampaignService` at intake Submit and again on Approve write.
- **Originator or Admin** — submits the intake form, approves the campaign plan in the Campaign Ready modal, triggers operator pause, operator resume, Fix Issue, manual reply, Won/Lost marking.

**Core objects:**

| Object | Table | Role |
|---|---|---|
| Campaign steps | `campaign_steps` | One row per step per job campaign run. Stores rendered subject and body (output of template merge-field substitution), timing offset, and step sequence. Variable row count per run, defined by the active template variant's step count. |
| Job campaign run | `campaigns` (referred to as `job_campaigns` in prose) | One instance per job. Tracks campaign status, timing, run lifecycle, and the `template_version_id` of the template variant used to render this run. Polymorphic — uses `target_id` + `target_type = JOB_PROPOSAL` to link to the job. |
| Template variant | (defined in SPEC-11 v2.0) | The authored template content for a (`job_type`, `scenario_key`) pair, with step structure and merge-field body. One active variant per pair globally. Referenced here via `campaigns.template_version_id`. |
| Messages | `messages` | One row per outbound send and per inbound reply. Append-only. |
| Message events | `message_events` | Delivery confirmations, bounces, opens. Append-only. |
| Delivery issues | `delivery_issues` | One row per delivery failure episode. Resolved on Fix Issue success. |
| Job history | `job_proposal_history` | Append-only. Written on every `pipeline_stage` or `status_overlay` change and on every job-scoped lifecycle event. Discriminated by `event_type`. See PRD-01 v1.4.1 §12. |

---

## 6. Template Lookup, Render, and Campaign Activation

This section defines the flow from intake Submit through Approve and Begin Campaign. It replaces the v1.3 two-phase "generate plan then approve later" flow with a single collapsed flow in which the render is ephemeral until approval.

### 6.1 Trigger

Template lookup and render fires when the operator submits the New Job intake modal (PRD-02). It does not fire on any frontend campaign-initialization endpoint; no such endpoint is exposed (§2 point 1). The render is triggered inside smai-backend as a consequence of the intake Submit request.

No durable writes occur at this point. No `jobs` row, no `job_campaigns` row, no `campaign_steps` rows, no `job_proposal_history` rows. The render output lives in memory only, is returned to the frontend to populate the Campaign Ready modal, and is discarded if the operator cancels or dismisses the modal.

### 6.2 Render eligibility check

Before performing template lookup and render, smai-backend evaluates the following against the intake form submission:

| Check | Pass condition | Fail behavior |
|---|---|---|
| Required intake fields | `job_type`, `scenario_key`, `customer_email`, `customer_name`, `location_id`, `address_line1`, `city`, and proposal PDF all present | Return intake validation error. Frontend highlights the missing field. No render. |
| `scenario_key` scoped to `job_type` | `scenario_key` belongs to the selected `job_type`'s activated scenarios for the requesting tenant (per SPEC-03 v1.3 §10) | Return intake validation error. No render. |
| `customer_email` format | Passes basic email format validation | Return intake validation error at the field level. No render. |
| Workspace `campaign_active` flag | `= true` | Render proceeds (campaign won't actually send until workspace is active, but render is not blocked). For the Jeff pilot this flag must be true at all times. |
| Active template variant exists for (`job_type`, `scenario_key`) | Exactly one active variant returned by template lookup per SPEC-11 v2.0 §8 | Return a typed error: "Campaign could not be generated. Contact support." Logged at high severity. No render. No Campaign Ready modal shown. |

The customer_email bounce-history check that existed in v1.3 §6.2 no longer fires at this point. Since no job record is written at Submit, there is no record against which to hold a delivery issue overlay. Bounce detection happens at actual send time via the pre-send checklist and §10.2 delivery failure path. If the operator enters a known-bad email, it still advances past Submit, the operator approves, and the first send fails into the delivery-issue recovery flow.

### 6.3 Render (in-memory)

If all eligibility checks pass, smai-backend performs:

1. **Template lookup** per SPEC-11 v2.0 §8: query the template store for the active variant matching (`job_type`, `scenario_key`). Exactly one variant returned.
2. **Job context assembly:** assemble the merge-field bundle from intake form values plus AI extraction output. Required merge fields per SPEC-11 v2.0 §9.1: customer name, property address, proposal value, proposal date, damage description, originator name and signature per SPEC-07, company name and phone, location label. Optional merge fields populated where available.
3. **Merge-field substitution** per SPEC-11 v2.0 §9: for each step in the template variant, scan subject and body for merge-field placeholders, resolve against the job context, and produce the rendered subject and rendered body. Validation: no `{field_name}` tokens remain in output; all required fields resolved. Failure raises a typed error per SPEC-11 v2.0 §10.3 and surfaces as "Campaign could not be generated. Contact support."
4. **Return rendered output** to the frontend for Campaign Ready modal display. The output is an ordered collection of rendered campaign step records including `step_order`, `delay_from_prior`, rendered `subject`, rendered `body`, and a reference to the source template variant (`template_version_id`, `step_order`).

Nothing is written to the database in this step. The rendered output is held in whatever mechanism the frontend uses to display the Campaign Ready modal (response payload, client-side state, or short-lived server-side cache — implementation detail for Mark and the frontend team).

### 6.4 Operator approval (durable write)

The operator reviews the rendered plan in the Campaign Ready modal (PRD-02). Three outcomes:

**On Cancel or dismiss:** No database writes. No API call to the approval endpoint fires. The render output is discarded. Operator returns to the Jobs list or wherever they came from. Clean exit. No trace.

**On Approve and Begin Campaign:** The frontend calls the approval endpoint with the intake form data and the rendered output (or the identifiers needed to reconstruct it; exact payload shape is Mark's call). smai-backend performs the following atomic transaction:

1. Write `jobs` (`job_proposals`) row with all intake form values, including `job_type`, `scenario_key`, `pipeline_stage = in_campaign`, `status_overlay = null`, `campaign_started_at = now()`. `created_by_user_id = <operator id>`.
2. Write `job_contacts` row.
3. Write `estimates` row and attach the proposal PDF to GCS (if not already uploaded during Submit).
4. Write `job_campaigns` row:
   - `target_id = job.id`, `target_type = JOB_PROPOSAL`
   - `status = active`
   - `template_version_id = <variant id returned from §6.3 lookup>`
   - `started_at = now()`
   - `approved_at = now()`
   - `approved_by_user_id = <operator id>`
5. Write `campaign_steps` rows, one per rendered step, with the rendered `subject`, rendered `body`, `step_order`, and `delay_hours` (or equivalent duration field) from the template variant's step definition.
6. Write `job_proposal_history` row: `event_type = job_created`, `changed_by = <operator email>`.
7. Write `job_proposal_history` row: `event_type = campaign_approved`, `changed_by = <operator email>`.
8. Enqueue Cloud Tasks — one per campaign step — at execution times computed from `campaign_started_at` plus the cumulative `delay_from_prior` of each step (per the template variant's cadence).

If any write fails, the entire transaction rolls back. No job record is created. The operator sees an error and can retry Approve. Log the failure.

**Third outcome: the approval endpoint must re-verify the active template variant at write time.** If the operator dwells in the Campaign Ready modal long enough that a SPEC-11 v2.0 activation changes the active variant between Submit render and Approve write, the write MUST use the variant that was shown to the operator (whose `template_version_id` was returned in step 4 of §6.3), not a different current-active variant. The operator approved specific rendered content; the durable record must reflect that. Implementation: the approval endpoint includes `template_version_id` as a request parameter, and the write uses it directly for `campaigns.template_version_id` and re-renders the stored `campaign_steps` using that variant's step definitions. If the variant referenced is no longer retrievable (soft-deleted etc.), the write fails with a typed error and the operator must re-submit.

### 6.5 Cloud Task payload

Each Cloud Task carries:

```
{
  job_id: <uuid>,
  job_campaign_id: <uuid>,
  campaign_step_id: <uuid>,
  step_order: <integer, 1-indexed>,
  scheduled_for: <ISO 8601 timestamp>
}
```

The task does not carry email content. Content is retrieved from `campaign_steps` at execution time.

---

## 7. Campaign Step Sequence

### 7.1 Step count and cadence

Step count and cadence are variable, defined by the active template variant resolved at intake (§6.3). A template variant specifies:

- `step_order` (1-indexed, monotonically increasing)
- `delay_from_prior` (duration; for `step_order = 1`, time between approval and send)
- `subject_template` (with merge-field placeholders)
- `body_template` (with merge-field placeholders)

All timing is relative to the moment the operator approves the campaign plan (`jobs.campaign_started_at`, written in §6.4 step 1). Cloud Tasks are enqueued with `scheduled_for` timestamps computed as `campaign_started_at + cumulative_delay_from_prior` across the step sequence.

There is no minimum or maximum step count enforced by this PRD; the template authoring process (SPEC-12) establishes what step counts and cadences are appropriate per scenario.

### 7.2 Campaign content model

Campaign content is produced by template merge-field substitution at intake Submit (§6.3), not by AI generation. The template variant holds subject and body templates with merge-field placeholders. Substitution resolves the placeholders against the job context bundle. The rendered output is stored on `campaign_steps` at Approve (§6.4 step 5) and is sent verbatim at execution time (§9).

At send time, smai-backend retrieves the stored subject and body from `campaign_steps` for the relevant step, applies the `[{job_number}]` subject prefix (§7.3), and passes the content to smai-comms. No further content manipulation occurs in the execution path. No re-render. No mutation.

### 7.3 Subject prefix for thread continuity

The `[{job_number}]` prefix is prepended to the rendered subject at send time for Jeff's DASH threadability. It uses the DASH job number extracted at intake. If `job_number` is null on the job record at send time, the prefix is omitted entirely — the rendered subject is sent as-is. This must not result in a broken or malformed subject line (no `[]` or `[null]`).

This is the only element constructed at send time. All other content is the pre-rendered output stored on `campaign_steps`.

### 7.4 Estimate attachment in the first step

The first step of the campaign (`step_order = 1`) is the estimate delivery email. The estimate PDF must be attached to this email. The attachment is retrieved from GCS using the path stored in `estimates.file_storage_path`. If `file_storage_path` is null or the file cannot be retrieved from GCS at send time, the first step is sent without the attachment. This failure is logged as a warning event but does not trigger the delivery failure path. The email still sends.

Subsequent steps do not include the estimate attachment.

---

## 8. Pre-Send Checklist

This checklist runs every time a Cloud Task fires, before any send is attempted. If any check fails, the task is dropped silently. No send occurs. No retry is enqueued. The check failure is logged.

Checks run in this order:

| Order | Check | Pass condition | Fail behavior |
|---|---|---|---|
| 1 | Workspace campaign active | `accounts.campaign_active = true` | Drop task. Log. No send. |
| 2 | Job pipeline stage | `jobs.pipeline_stage = in_campaign` | Drop task. Log. No send. |
| 3 | Job status overlay | `jobs.status_overlay = null` | Drop task. Log. No send. |
| 4 | Job campaign run status | `job_campaigns.status = active` | Drop task. Log. No send. |
| 5 | Step already sent | No existing `messages` row for this `job_campaign_id` and `step_order` | Drop task. Log. No send. (Idempotency guard.) |
| 6 | OBO token available | smai-comms returns a valid token for this location's operational mailbox | Trigger delivery failure path (§10.2). |
| 7 | Customer email present | `job_contacts.customer_email` non-null and valid format | Trigger delivery failure path (§10.2). |

Check 5 is the idempotency guard. If a Cloud Task is delivered more than once (GCP at-least-once delivery), the second execution sees an existing `messages` row and drops without sending a duplicate. This is the only mechanism preventing duplicate sends. It must be implemented.

---

## 9. Send Execution

When all pre-send checks pass:

### 9.1 Step-by-step send sequence

1. Retrieve OBO access token from smai-comms for the job's location operational mailbox.
2. Retrieve the stored email content from `campaign_steps` for this `campaign_step_id`: the rendered subject and rendered body (produced at §6.3 render).
3. Construct the email:
   - `From`: operational mailbox address (`{location-identifier}@mail.{customer-primary-domain}`)
   - `To`: `job_contacts.customer_email`
   - `Reply-To`: operational mailbox address (so customer replies go to the monitored mailbox)
   - `Subject`: rendered subject with `[{job_number}]` prefix prepended if `job_number` is non-null
   - `Body`: rendered body retrieved from `campaign_steps`
   - `Attachment` (first step only): estimate PDF from GCS
   - `Thread headers`: set `References` and `In-Reply-To` headers using the Gmail thread ID from the prior sent message (if `step_order > 1`) to keep all steps in a single Gmail thread
4. Call smai-comms `EmailSendingService.send()` with the above payload.
5. smai-comms calls the Gmail API with the OBO token.

### 9.2 On send success

smai-backend receives a success response from smai-comms (Gmail message ID returned):

1. Write `messages` row:
   - `job_id`, `job_campaign_id`
   - `direction = outbound`
   - `channel = email`
   - `subject`: rendered subject with prefix applied
   - `body`: rendered body
   - `from_address`: operational mailbox
   - `to_address`: customer email
   - `status = sent`
   - `external_message_id`: Gmail message ID
   - `sent_at = now()`
2. Write `message_events` row: `event_type = delivered` (if delivery confirmation received) or leave status as `sent` until confirmation arrives via Pub/Sub.
3. Write `job_proposal_history` row: `event_type = campaign_step_sent`, `changed_by = null`, `metadata = { step_order, message_id }`.
4. Store Gmail thread ID for use in subsequent step thread headers.

If this is the final step (highest `step_order` in the template variant) and the send succeeds:
- Set `job_campaigns.status = completed`.
- Set `job_campaigns.completed_at = now()`.
- Write `job_proposal_history` row: `event_type = campaign_completed`, `changed_by = null`.
- Job remains `pipeline_stage = in_campaign`, `status_overlay = null`, `cta_type = view_job`. It does not auto-close.

### 9.3 On send failure

smai-comms returns an error (Gmail API error, network failure, invalid address rejection, bounce):

1. Write `messages` row with `status = failed` or `status = bounced`, `failure_reason = <error detail>`.
2. Write `message_events` row: `event_type = failed` or `event_type = bounced`.
3. Trigger the delivery failure path (§10.2).

---

## 10. Stop Conditions

All four stop conditions are immediate and non-negotiable. When any fires, the associated `job_campaigns` run is stopped and no further automated sends occur for that job.

### 10.1 Stop Condition: Customer Reply

**Trigger:** smai-comms receives a Pub/Sub push notification from Gmail indicating an inbound message to the operational mailbox.

**Detection sequence:**

1. Gmail push notification arrives at smai-comms `GmailPushController`.
2. smai-comms passes the message to `InboundMessageProcessor`.
3. `InboundMessageProcessor` resolves the Gmail thread to a `job_id` using:
   - Gmail thread ID matched against `messages.external_message_id` (prior sent messages store the thread ID).
   - Fallback: subject line parsing for the `[{job_number}]` prefix to resolve `job_id` via `jobs.job_number`.
4. If `job_id` is resolved, smai-comms notifies smai-backend via Cloud Tasks.

**Writes (smai-backend, atomic):**

1. Write `messages` row: `direction = inbound`, `channel = email`, `status = sent`, body = message body.
2. Set `jobs.status_overlay = customer_waiting`.
3. Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = null`, `new_status = customer_waiting`, `details = customer_replied`, `changed_by = null`.
4. Set `job_campaigns.status = stopped_on_reply`.
5. Write `job_proposal_history` row: `event_type = customer_replied`, `changed_by = null`.
6. Write `job_proposal_history` row: `event_type = job_needs_attention_flagged`, `changed_by = null`.

`cta_type` is not written. It computes to `open_in_gmail` at read time per PRD-01 §7 (derived from `pipeline_stage = in_campaign` + `status_overlay = customer_waiting`).

**Effect on pending Cloud Tasks:** Any Cloud Tasks already enqueued for subsequent steps will fire but fail the pre-send checklist at check 4 (`job_campaigns.status != active`). They are dropped silently. No further sends occur.

**Recovery:** None in MVP. The campaign run stays `stopped_on_reply`. The operator responds manually (§11). No new campaign run starts.

**If `job_id` cannot be resolved from the inbound message:** The message is stored as an unmatched inbound message. It does not trigger any job state change. This is logged for investigation. It does not block other sends or operations.

### 10.2 Stop Condition: Delivery Failure

**Trigger:** Send execution returns a failure or bounce from the Gmail API (§9.3), or the pre-send checklist fails check 6 (OBO token unavailable) or check 7 (customer email missing).

**Writes (smai-backend, atomic):**

1. Write `delivery_issues` row:
   - `job_id`
   - `message_id` (FK to the failed `messages` row, nullable if pre-send check failed before a message row was written)
   - `channel = email`
   - `issue_type`: one of `invalid_address`, `bounced`, `blocked`, `unknown`
   - `resolved = false`
2. Set `jobs.status_overlay = delivery_issue`.
3. Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = null`, `new_status = delivery_issue`, `details = delivery_failed`, `changed_by = null`.
4. Set `job_campaigns.status = stopped_on_delivery_issue`.
5. Write `job_proposal_history` row: `event_type = delivery_issue_detected`, `changed_by = null`.
6. Write `job_proposal_history` row: `event_type = job_needs_attention_flagged`, `changed_by = null`.

`cta_type` is not written. It computes to `fix_delivery_issue` at read time per PRD-01 §7 (derived from `pipeline_stage = in_campaign` + `status_overlay = delivery_issue`).

**Effect on pending Cloud Tasks:** Subsequent tasks fire but fail the pre-send checklist at check 3 (`status_overlay != null`) or check 4 (`job_campaigns.status != active`). They are dropped silently.

**Recovery:** See §12 (Fix Issue and Resume).

### 10.3 Stop Condition: Operator Pause

**Trigger:** Operator selects "Pause Campaign" on the Job Detail screen (PRD-06).

**Writes (smai-backend, atomic):**

1. Set `jobs.status_overlay = paused`.
2. Set `jobs.campaign_paused_at = now()`.
3. Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = null`, `new_status = paused`, `details = operator_paused`, `changed_by = <operator email>`.
4. Set `job_campaigns.status = paused`.
5. Write `job_proposal_history` row: `event_type = campaign_paused`, `changed_by = <operator email>`.

`cta_type` is not written. It computes to `resume_campaign` at read time per PRD-01 §7 (derived from `pipeline_stage = in_campaign` + `status_overlay = paused`).

**Effect on pending Cloud Tasks:** Subsequent tasks fire but fail the pre-send checklist at check 3 (`status_overlay != null`) or check 4 (`job_campaigns.status != active`). They are dropped silently.

**Recovery:** See §13 (Resume).

### 10.4 Stop Condition: Job Closure (Won or Lost)

**Trigger:** Operator marks the job Won or Lost from the Job Detail overflow menu or the three-dot menu.

**Writes (smai-backend, atomic):**

1. Set `jobs.pipeline_stage = won` or `lost`.
2. Set `jobs.status_overlay = null`.
3. Set `jobs.won_at` or `jobs.lost_at = now()`.
4. Write `job_proposal_history` row: `event_type = pipeline_stage_changed`, `old_status = in_campaign`, `new_status = won` or `lost`, `details = operator_marked_won` or `operator_marked_lost`, `changed_by = <operator email>`.
5. Set `job_campaigns.status = stopped_on_closure`.
6. Set `job_campaigns.completed_at = now()`.
7. Write `job_proposal_history` row: `event_type = job_marked_won` or `job_marked_lost`, `changed_by = <operator email>`.

**Effect on pending Cloud Tasks:** Subsequent tasks fail the pre-send checklist at check 2 (`pipeline_stage != in_campaign`). They are dropped.

**Recovery:** None. Won and Lost are terminal. No new campaign run starts.

---

## 11. Operator Reply to Customer (Manual Send)

When a customer replies, the operator sees an "Open in Gmail" CTA on the job card and in Job Detail. Tapping it opens the Gmail thread directly in Gmail. SMAI does not provide a compose interface for operator replies. The operator replies natively in Gmail from the operational mailbox. smai-comms detects the outbound reply via the Gmail Pub/Sub channel and notifies smai-backend, which performs the following writes:

**Writes (atomic):**

1. Write `messages` row: `direction = outbound`, `channel = email`, `status = sent`, body = operator's reply text, `from_address = operational mailbox`, `to_address = customer email`. Include thread headers to keep the reply in the same Gmail thread.
2. Clear `jobs.status_overlay` from `customer_waiting` to `null`.
3. Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = customer_waiting`, `new_status = null`, `details = operator_replied`, `changed_by = <operator email>`.
4. Write `job_proposal_history` row: `event_type = operator_replied`, `changed_by = <operator email>`.

`cta_type` is not written. It computes to `view_job` at read time per PRD-01 §7 (derived from `pipeline_stage = in_campaign` + `status_overlay = null`).

**Campaign state after operator reply:**

`job_campaigns.status` remains `stopped_on_reply`. The campaign does not resume. No new automated steps are scheduled. The job stays `in_campaign` with no overlay — meaning it is an open job with a completed or stopped campaign run. The operator can still mark it Won or Lost.

---

## 12. Fix Issue and Campaign Resume After Delivery Failure

**Triggered by:** Operator corrects the customer email in the Fix Issue slide-out (PRD-06) and taps "Retry Delivery."

### 12.1 Retry sequence

1. smai-backend receives the corrected email address.
2. Validate the new email address (format check).
3. Update `job_contacts.customer_email` to the corrected value.
4. Mark all unresolved `delivery_issues` rows for this job as resolved (`resolved = true`, `resolved_at = now()`, `resolved_by_user_id = <operator id>`).
5. Create a new `job_campaigns` record with `status = active`, `started_at = now()`, `template_version_id = <same variant as the prior run>`. **This is a new campaign run, not a resumption of the stopped run.** The new run reuses the `template_version_id` of the prior run so the operator-approved content (per the originally approved variant) is preserved across the Fix Issue boundary. See §19 OQ-03 for the rationale and open discussion.
6. Copy the unsent `campaign_steps` rows from the prior run to the new run: the rendered `subject` and `body` carry over unchanged. `step_order` is preserved. `campaign_step_id`s are new (rows are new).
7. Determine the next step to send: find the highest `step_order` that was successfully sent in the previous run. The new run begins at the next step (step_order + 1). If no steps were sent in the prior run, the new run starts at step 1.
8. Schedule Cloud Tasks for the remaining steps from the next step through the final step, with timing offsets relative to `now()` (not relative to the original `campaign_started_at`). Cadence is read from the `delay_from_prior` values stored on the copied `campaign_steps` rows.
9. Perform activation writes for the new run (overlay cleared, etc. — same as §6.4 steps 6-7 adjusted for resume context). `cta_type` is not written; it computes to `view_job` at read time per PRD-01 §7.
10. Write `job_proposal_history` row: `event_type = delivery_issue_resolved`, `changed_by = <operator email>`.
11. Write `job_proposal_history` row: `event_type = campaign_resumed`, `changed_by = <operator email>`.

### 12.2 If the retry itself fails

The new send attempt runs through the same send execution path (§9). If it fails again, the new `job_campaigns` record is set to `stopped_on_delivery_issue` and a new `delivery_issues` row is written. The operator sees the Delivery Issue overlay again and must attempt Fix Issue again.

### 12.3 Missed steps on resume

Steps from the failed run that were not sent are not re-sent. The resumed run starts from the next unsent step. If step 2 failed and steps 3+ were not yet sent, the resumed run sends from step 3. Step 2 is permanently skipped.

---

## 13. Operator Pause and Resume

### 13.1 Pause

Defined in §10.3. The `job_campaigns` record is set to `paused`. Pending Cloud Tasks are dropped by the pre-send checklist.

### 13.2 Resume

**Triggered by:** Operator taps "Resume Campaign" from the Job Detail screen or Needs Attention (PRD-06).

**Writes (atomic):**

1. Set `jobs.status_overlay = null`.
2. Clear `jobs.campaign_paused_at`.
3. Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = paused`, `new_status = null`, `details = operator_resumed`, `changed_by = <operator email>`.
4. Set `job_campaigns.status = active`.
5. Determine the next step to send: same logic as §12.1 step 7 — find the highest `step_order` successfully sent; resume from step_order + 1.
6. Schedule Cloud Tasks for remaining steps with timing offsets relative to `now()`, read from the `delay_from_prior` values on the `campaign_steps` rows.
7. Write `job_proposal_history` row: `event_type = campaign_resumed`, `changed_by = <operator email>`.

`cta_type` is not written. It computes to `view_job` at read time per PRD-01 §7 (derived from `pipeline_stage = in_campaign` + `status_overlay = null`).

**Missed steps on resume:** Steps that were scheduled but dropped during the pause period are not re-sent. The campaign resumes from the next unsent step with timing relative to the resume moment.

Unlike Fix Issue, Resume does NOT create a new `job_campaigns` row. The existing row's status flips back to `active`. `template_version_id` is unchanged.

---

## 14. The `job_campaigns` Status Lifecycle

| Status | Meaning | Outbound sends allowed |
|---|---|---|
| `active` | Campaign running normally. Written at §6.4 (durable approval) for new runs and at §12.1 step 5 for Fix Issue runs. | Yes (subject to pre-send checklist). |
| `paused` | Operator has manually paused the campaign. | No. |
| `completed` | All steps sent successfully with no stops. | No (run is done). |
| `stopped_on_reply` | Customer replied. Permanent stop for this run. | No. |
| `stopped_on_delivery_issue` | Delivery failure stopped the run. | No (new run created on Fix Issue). |
| `stopped_on_closure` | Operator marked Won or Lost. | No. |

A new `job_campaigns` row is created when a campaign run begins (at Approve and Begin Campaign per §6.4, or at Fix Issue per §12.1). It is never modified once set to a terminal status (`completed`, `stopped_on_reply`, `stopped_on_delivery_issue`, `stopped_on_closure`). Fix Issue creates a new row. Pause and resume modify the active row.

**Removed in v1.4:** `pending_approval`. No campaign run sits in a pending-approval state. The render between Submit and Approve is ephemeral and no database row is written until Approve. Any existing database rows with `pending_approval` from v1.3 data are legacy; they are not produced by v1.4 code. Migration handling is Mark's engineering call.

---

## 15. Required Events

All events are written to `job_proposal_history` as rows discriminated by `event_type`. All are append-only. None are ever modified or deleted. See PRD-01 v1.4.1 §12 for the full `job_proposal_history` schema and the canonical `event_type` enum.

| `event_type` | Trigger | Actor (`changed_by`) |
|---|---|---|
| `job_created` | Durable job row written at Approve and Begin Campaign (§6.4). Under the collapsed flow this fires at Approve, not at Submit. | operator email |
| `campaign_approved` | Operator approves plan in the Campaign Ready modal and the atomic durable write completes (§6.4). Fires at the same transaction as `job_created` for new jobs. | operator email |
| `campaign_step_sent` | Outbound email send succeeds (§9.2). | null (system) |
| `campaign_step_dropped` | Pre-send checklist fails (§8). | null (system, log only, not user-visible per PRD-06 §10.1) |
| `campaign_completed` | Final step in the template variant sends successfully (§9.2). | null (system) |
| `campaign_paused` | Operator pauses (§10.3). | operator email |
| `campaign_resumed` | Operator resumes (§13.2) or Fix Issue creates a new run (§12.1). | operator email |
| `customer_replied` | Inbound email detected and resolved to job (§10.1). | null (system) |
| `job_needs_attention_flagged` | Customer reply or delivery failure (§10.1, §10.2). | null (system) |
| `operator_replied` | Operator sends manual reply (§11). | operator email |
| `delivery_issue_detected` | Send failure triggers delivery issue (§10.2). | null (system) |
| `delivery_issue_resolved` | Fix Issue succeeds (§12.1). | operator email |
| `job_marked_won` | Operator marks Won (§10.4). | operator email |
| `job_marked_lost` | Operator marks Lost (§10.4). | operator email |

`status_overlay_changed` and `pipeline_stage_changed` rows are also written for every state transition per PRD-01 v1.4.1 §12. Those are not repeated here.

**Removed in v1.4:** `campaign_plan_generated`. Under templated architecture, there is no plan-generation event separate from approval. The render is ephemeral; no event fires for it. Per PRD-01 v1.4.1, the canonical `event_type` enum removes this value.

---

## 16. System Boundaries

| Responsibility | Owner |
|---|---|
| Template lookup (§6.3 step 1) | smai-backend / Template Engine per SPEC-11 v2.0 |
| Job context assembly (§6.3 step 2) | smai-backend (`CampaignService`) |
| Merge-field substitution (§6.3 step 3) | smai-backend / Template Engine per SPEC-11 v2.0 |
| Render-output delivery to frontend for Campaign Ready modal | smai-backend (response payload to Submit endpoint) |
| Approve and Begin Campaign atomic write (§6.4) | smai-backend (`CampaignService`) |
| Cloud Task enqueue at approval | smai-backend (via Cloud Tasks API) |
| Cloud Task execution and pre-send checklist | smai-backend (Cloud Task handler) |
| OBO token retrieval | smai-comms (`OboTokenService`) |
| Gmail API send execution | smai-comms (`EmailSendingService`) |
| Gmail send result handling | smai-comms → smai-backend |
| Pub/Sub push receipt for inbound replies | smai-comms (`GmailPushController`) |
| Thread-to-job resolution | smai-comms (`InboundMessageProcessor`) |
| Job state transitions (overlays, pipeline stage, cta_type) | smai-backend |
| `job_proposal_history` writes | smai-backend |
| `delivery_issues` writes | smai-backend |
| `messages` and `message_events` writes | smai-backend |
| Rendered template content storage (`campaign_steps`) | Cloud SQL (write on §6.4; Fix Issue copy on §12.1) |
| `campaigns.template_version_id` write on every campaign run | smai-backend (schema add per this PRD Slice A) |
| GCS retrieval for estimate attachment | smai-backend |
| Tenant-callable API surface | smai-backend (`CampaignController`) — campaign initialization **must not** be exposed |
| Campaign pause/resume UI triggers | smai-frontend → smai-backend API |
| Fix Issue and corrected email write | smai-frontend → smai-backend API |
| Operator reply send | smai-frontend → smai-backend → smai-comms |

**Explicit boundary enforcement:** `CampaignController` endpoints that accept tenant-origin requests (user JWTs) must not include campaign initialization. Initialization is triggered internally, via the approval endpoint called from the collapsed intake flow. If an endpoint for direct campaign initialization exists today, it must be removed or restricted to service-account authentication before go-live.

---

## 17. Implementation Slices

### Slice A: Template lookup, render, and approval path ([#54](https://github.com/frizman21/smai-server/issues/54))

Implement the Submit-to-Approve flow. On Submit: evaluate §6.2 eligibility, perform §6.3 template lookup and merge-field substitution, return rendered output to the frontend. On Approve and Begin Campaign: perform the §6.4 atomic transaction (job, campaign with `template_version_id`, campaign_steps, history events, Cloud Task enqueue). Implement the `campaigns.template_version_id` schema column (non-nullable for new rows). Remove `pending_approval` from the `campaigns.status` enum. Remove any prior two-phase generation path from `CampaignService.kt`. Close the 4 TODOs in `CampaignService.kt` related to campaign initialization.

Dependencies: PRD-01 v1.4.1 Slice A (job record schema including `scenario_key`); SPEC-11 v2.0 Slice A (template store) and Slice B (template lookup and render) must be in place; SPEC-11 v2.0 initial template variants seeded for the (job_type, scenario_key) pairs activated for the tenant (Tier 1 scenarios per SPEC-12 §9).  
Excludes: Send execution, stop conditions.

### Slice B: Pre-send checklist and idempotency guard ([#55](https://github.com/frizman21/smai-server/issues/55))

Implement the Cloud Task handler in smai-backend. Implement all seven pre-send checks in order. Implement the idempotency guard (check 5). Implement silent task drop with logging on any check failure.

Dependencies: Slice A.  
Excludes: Token retrieval, actual send call.

### Slice C: Send execution and result handling ([#56](https://github.com/frizman21/smai-server/issues/56))

Implement the send sequence (§9.1): token retrieval from smai-comms, rendered content retrieval from `campaign_steps`, email construction with thread headers, smai-comms call. Implement success writes (§9.2). Implement failure writes (§9.3). Implement the first-step estimate attachment.

Dependencies: Slices A, B. smai-comms `EmailSendingService` and `OboTokenService` confirmed working (per forensic audit).  
Excludes: Stop condition downstream writes (Slice D).

### Slice D: Stop conditions ([#57](https://github.com/frizman21/smai-server/issues/57))

Implement all four stop conditions: customer reply (§10.1), delivery failure (§10.2), operator pause (§10.3), job closure (§10.4). Each stop condition's atomic write sequence must be implemented in full. Confirm all subsequent Cloud Tasks are dropped by pre-send checklist without requiring explicit cancellation.

Dependencies: Slices A, B, C. Pub/Sub reply detection path in smai-comms (confirmed wired per forensic audit).  
Excludes: Fix Issue recovery path (Slice E).

### Slice E: Fix Issue recovery and operator pause/resume ([#58](https://github.com/frizman21/smai-server/issues/58))

Implement the Fix Issue sequence (§12): new campaign run creation with `template_version_id` carried over from the prior run, `campaign_steps` copy for unsent steps, next-step determination, Cloud Task re-enqueue with new timing. Implement operator pause write (§10.3) and operator resume write (§13.2). Implement operator manual reply write (§11).

Dependencies: Slice D.  
Excludes: Fix Issue slide-out UI (PRD-06), Open in Gmail CTA behavior (PRD-06).

### Slice F: CampaignController boundary enforcement ([#59](https://github.com/frizman21/smai-server/issues/59))

Audit `CampaignController.kt` for any tenant-callable campaign initialization endpoints. Remove or restrict them. Confirm that no user JWT can trigger campaign initialization or the §6.4 approval endpoint outside the intake flow context. Close the CampaignController TODO from the forensic audit.

Dependencies: None — can run in parallel with any other slice.  
Excludes: Nothing.

### Slice G: Event audit and QA ([#60](https://github.com/frizman21/smai-server/issues/60))

Confirm all required events (§15) are written to `job_proposal_history` with the correct `event_type` on every path. Write a QA test that: creates a job via the collapsed intake flow, approves, sends all steps in the template variant, and asserts the complete history. Write a QA test that fires each stop condition and asserts the correct overlay, `job_campaigns` status, and history rows. Write a QA test that confirms Submit-then-Cancel produces no database writes.

Dependencies: All preceding slices.

---

## 18. Acceptance Criteria

**AC-01: Activation is internal-only**
Given an authenticated user (with a valid user JWT) sending a POST request to any `CampaignController` endpoint that would initialize a campaign outside the approved intake flow, when the request is received, then the backend returns a 403 or 404. Campaign initialization cannot be triggered by a tenant-origin request outside the intake flow.

**AC-02: Render on Submit, durable write only on Approve**
Given a valid intake submission via the New Job intake modal including `job_type`, `scenario_key`, a valid customer email, and a proposal PDF, when the operator clicks Submit, then within 3 seconds the backend returns rendered campaign step content (subject and body per step) sourced from the active template variant for the (`job_type`, `scenario_key`) pair with merge fields substituted. No `jobs` row, no `job_campaigns` row, no `campaign_steps` rows, and no `job_proposal_history` rows exist for this submission. If the operator subsequently clicks Approve and Begin Campaign, then within 3 seconds: `jobs.pipeline_stage = in_campaign`, a `job_campaigns` row exists with `status = active` and `template_version_id` populated with the active variant ID, `campaign_steps` rows exist matching the template variant's step count with rendered subject and body, `job_proposal_history` rows exist with `event_type = job_created` and `event_type = campaign_approved`, and Cloud Tasks are enqueued per the template variant's cadence. If the operator clicks Cancel or dismisses the Campaign Ready modal, no database writes occur.

**AC-03: Missing template variant fails loudly at Submit**
Given an intake submission with a (`job_type`, `scenario_key`) pair for which no active template variant exists, when the operator clicks Submit, then the backend returns a typed error with operator-facing message "Campaign could not be generated. Contact support." No Campaign Ready modal is shown. No database writes occur. The error is logged at high severity.

**AC-04: Pre-send checklist blocks ineligible sends**
Given a job with `status_overlay = paused`, when the Cloud Task for any step fires, then no email is sent, no `messages` row is written for this step, and the task is dropped silently. The job state is unchanged.

**AC-05: Idempotency guard prevents duplicate sends**
Given a Cloud Task for step 1 that is delivered twice (GCP retry simulation), when the second execution runs, then the pre-send checklist finds an existing `messages` row for step 1 and drops the task without sending a second email.

**AC-06: Customer reply stops campaign**
Given a job with `job_campaigns.status = active`, when smai-comms detects an inbound email on the operational mailbox and resolves it to the job, then within 5 seconds: `status_overlay = customer_waiting`, `job_campaigns.status = stopped_on_reply`, `job_proposal_history` rows with `event_type = customer_replied` and `event_type = job_needs_attention_flagged` are present, and all subsequent Cloud Tasks are dropped by the pre-send checklist. `cta_type` is not written; it computes to `open_in_gmail` at read time per PRD-01 §7.

**AC-07: Delivery failure stops campaign**
Given an outbound send that returns a Gmail API failure, then `status_overlay = delivery_issue`, `job_campaigns.status = stopped_on_delivery_issue`, a `delivery_issues` row with `resolved = false` exists, and `job_proposal_history` rows with `event_type = delivery_issue_detected` and `event_type = job_needs_attention_flagged` are present. `cta_type` is not written; it computes to `fix_delivery_issue` at read time per PRD-01 §7.

**AC-08: Fix Issue creates new campaign run with preserved template_version_id**
Given a job with `status_overlay = delivery_issue` and one prior failed `job_campaigns` run, when the operator corrects the email and retries, then a new `job_campaigns` row is created with `status = active` and `template_version_id` matching the prior run, the old row remains `stopped_on_delivery_issue`, the `delivery_issues` row is marked resolved, `campaign_steps` rows for unsent steps are copied from the prior run to the new run with rendered content unchanged, and the new run schedules only the steps not yet successfully sent.

**AC-09: Missed steps not re-sent on resume**
Given a job that was paused after one step was sent, when the operator resumes, then Cloud Tasks are enqueued only for steps whose `step_order` is greater than the highest successfully sent step. No prior step is re-sent.

**AC-10: Job closure stops campaign**
Given a job with `job_campaigns.status = active`, when the operator marks it Won, then `pipeline_stage = won`, `status_overlay = null`, `job_campaigns.status = stopped_on_closure`, a `job_proposal_history` row with `event_type = job_marked_won` is present, and all subsequent Cloud Tasks are dropped by the pre-send checklist.

**AC-11: After customer reply, operator response clears overlay but does not resume campaign**
Given a job with `status_overlay = customer_waiting` and `job_campaigns.status = stopped_on_reply`, when the operator sends a manual reply, then `status_overlay = null`, a `job_proposal_history` row with `event_type = operator_replied` is present, and `job_campaigns.status` remains `stopped_on_reply`. No new Cloud Tasks are enqueued. `cta_type` is not written; it computes to `view_job` at read time per PRD-01 §7.

**AC-12: Subject line includes DASH job number**
Given a job with `job_number = "12345"`, when the first step is sent, then the subject line begins with `[12345]`.

**AC-13: Subject line without DASH job number**
Given a job with `job_number = null`, when the first step is sent, then the subject line does not contain `[null]`, `[]`, or any broken prefix. The subject line begins with the rendered subject directly.

**AC-14: Thread continuity across variable step count**
Given a campaign with N steps (N defined by the active template variant) where step 1 has been sent, when step 2 is sent, then the Gmail `References` and `In-Reply-To` headers are set using the thread ID from step 1, placing step 2 in the same Gmail thread. The same thread-continuation behavior applies to all subsequent steps through step N.

**AC-15: All required events present for completed campaign**
Given a job that completes a full campaign sequence (all steps in the template variant sent) without stops, when `job_proposal_history` is queried for that job, then all of the following `event_type` rows are present in order: `job_created`, `campaign_approved` (same transaction as `job_created`), `campaign_step_sent` (one per step in the template variant), `campaign_completed`.

**AC-16: Rendered content matches what operator approved**
Given a render output returned to the Campaign Ready modal at Submit, when the operator clicks Approve and Begin Campaign, then the `campaign_steps` rows written at Approve carry exactly the rendered subject and body that were shown in the Campaign Ready modal. Specifically, if a template variant activation changed between Submit render and Approve write, the written content reflects the variant whose `template_version_id` was returned at Submit, not a different current-active variant.

---

## 19. Open Questions and Implementation Decisions

**OQ-01: `stopped_on_closure` enum value**
§14 includes `stopped_on_closure` as a distinct `job_campaigns.status` value used at job closure (Won/Lost). Carried forward from v1.3 OQ-01. Mark to confirm in schema before implementation.

**OQ-02: Pub/Sub push authentication hardening**
Two additional security improvements to `GmailPushController` (beyond the OIDC validation already in place) are tracked in ADR-001-comms-ingress-allUsers.md in `smai-infra/docs/adrs/`. The ADR is the governing document. This PRD does not re-specify those changes. Carried forward from v1.3 OQ-02.

**OQ-03: Fix Issue `template_version_id` handling**
§12.1 specifies that Fix Issue reuses the prior run's `template_version_id` and copies unsent `campaign_steps` content forward. This preserves operator-approved content across the Fix Issue boundary. Alternative behavior would be to re-resolve the current active variant at Fix Issue time, which would ensure the resumed run uses the most recent template improvements but would potentially send content the operator did not explicitly approve. The current-PRD default is preservation (reuse prior variant, copy content). If product judgment shifts toward re-resolution in the future, the change requires: (a) revising §12.1, (b) a new AC, (c) a decision on whether the operator should re-approve at Fix Issue time. Flagged here so the tradeoff is visible during Slice E build.

**OQ-04: Operational mailbox suppression clearing**
When Fix Issue corrects a customer email that was previously hard-bounced to a different address, `SuppressionService` (defined in PRD-09) does not auto-clear. This is conservative for hard bounces but adds friction when the original address was genuinely wrong. PRD-09 OQ-02 carries this open question. No change required in this PRD. Carried forward from v1.3 OQ-04.

**OQ-05: Render output transport between Submit and Approve**
§6.3 step 4 returns the rendered output to the frontend. §6.4 approval writes `campaign_steps` using that output. The implementation question is how the rendered content travels from the Submit response to the Approve request: (a) full payload round-tripped through the frontend and sent back at Approve, (b) server-side short-lived cache keyed by a render session ID, (c) re-render at Approve using the same inputs (idempotent per SPEC-11 v2.0 §10.4 if no activation changes mid-dwell). AC-16 requires that the written content matches what was shown in the modal; implementation must satisfy that constraint. Mark's engineering decision. Not a product scope question.
