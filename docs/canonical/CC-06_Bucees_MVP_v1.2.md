# Buc-ee's MVP Definition v1.2

**Status:** Canonical
**Supersedes:** v1.1 (2026-04-29)
**Last updated:** 2026-05-08

*(Jeff-first, on-path to California)*

---

## What we are solving right now

Jeff has a follow-up problem, not a CRM problem. Leads sit. Proposals go out. Nobody follows up. We are building the shortest path to measurable improvement, with a product foundation that compounds into the full SMAI OS.

The pilot is not "the product." It is the first stop that proves:

1. We can reliably run follow-up for real jobs in the wild.
2. We can stop at the right time when a human needs to take over.
3. We can do this in a way that fits the customer's existing workflow and system of record.

Jeff's role has evolved during the wave that produced this v1.1. Jeff is now Founding Design Partner under the Stone Family Office Design Partnership (per CC-07 RestorAI Brief). Buc-ee's remains his paid pilot for the Conversion Coordinator agent. The pilot terms (CC-04 v2.0 §4) are 60 days at $250 per month per location, with conversion to the Conversion Coordinator standalone bridge offering at $500 per month per location until the Sales & Revenue Recovery Team ships, then conversion to Tier 1 ($2,000/mo/location) at the Founding Operator lifetime-locked 35% discount where applicable.

## Wedge vs. Foundation

Buc-ee's MVP scope is a deliberate choice, not a Jeff-specific wishlist. The success criteria below split into two categories:

**Wedge (criteria #1 through #4):** What Jeff actually feels. Proposal in, follow-up running, stopping on reply, Needs Attention triage. If these don't work for 10 real jobs in week one, the pilot fails. These are the items the team must defend if anything has to slip.

**Foundation (criteria #5 through #7):** What the next 3 to 5 customers need before we can sell to them. Originator identity and email quality, template authoring at v1 scope, tenant Analytics dashboard, Account configuration data readiness. Cuttable for a Jeff-only pilot, in scope here because Buc-ee's is the proof point for the foundation, not just for Jeff.

This distinction matters because it answers the question that comes up every time prioritization gets tense: *what would we cut if we had to?* The wedge does not get cut. The foundation gets sequenced. The strategic posture (CC-01, CC-02, CC-07, CP-01 §6) is to build the foundation now because we will not get another clean window to do it.

## The complete MVP build set

Buc-ee's MVP is every PRD and SPEC currently in the canonical project, with one exception: the **Admin Portal frontend** (governed by PRD-10 v1.3.1) ships post-Jeff, pre-tenant-#2. The Admin Portal *backend* is required for go-live.

No PRD or SPEC in the project is speculative or post-MVP scope. Every artifact in `smai-specs/prd/` and `smai-specs/specs/` was written or revised inside the v1.3/v1.4 cycle that produced the current canonical schema, and every one of them is required for Buc-ee's go-live. SPEC-08 v1.0 and SPEC-09 v1.2.1 are bug fixes shipping with MVP, not features (per §J). PRD-10 v1.3.1 ships partially (backend in, frontend out, per §K). Everything else ships in full.

The complete in-scope build set:

- **PRDs (10):** PRD-01 v1.4.1, PRD-02 v1.5, PRD-03 v1.4.1, PRD-04 v1.2.1, PRD-05 v1.4, PRD-06 v1.3.1, PRD-07 v1.2, PRD-08 v1.2, PRD-09 v1.3.1, PRD-10 v1.3.1 (backend only).
- **SPECs (9):** SPEC-02 v1.0, SPEC-03 v1.3.3, SPEC-05 v1.0, SPEC-06 v1.0, SPEC-07 v1.4, SPEC-08 v1.0, SPEC-09 v1.2.1, SPEC-11 v2.0.2, SPEC-12 v2.0.1.

This means the question *"is X in MVP scope?"* has a simple answer: if X is governed by a PRD or SPEC currently in the project, X is in MVP scope. If not, X is post-MVP.

## MVP success criteria (non-negotiable)

If these are not true, Jeff will not adopt and we will not earn the right to charge.

### 1) DASH-native threadability

- We extract the DASH job number from the user.
- We put the DASH job number at the start of the email subject line.
- We preserve a clean, consistent subject format so Jeff can track everything in DASH without thinking.
- The Job Number requirement is governed by an Account-level config flag (`job_reference_required`) per PRD-02 v1.5 §5 and PRD-10 v1.3.1 §7.5. Jeff's Account has this flag set to `true`; future Accounts may have it set to `false` without code change.

### 2) Proposal in, follow-up running

- Upload proposal.
- Extract key fields and prefill the job shell.
- Resolve the active campaign template for the job's (job type, scenario) pair from the operator-approved template library.
- Substitute job-specific data into operator-approved content; present the resolved plan for operator review.
- Operator approves per campaign on this job; campaign executes deterministically.

*(See "What changed from v1.0" below for the template-resolution architecture context.)*

### 3) Stop correctly

- If the customer replies, we pause the campaign.
- If delivery fails or something breaks, we stop and raise a flag.
- No weird half-states. The system either runs or asks for help.

### 4) Human-in-the-loop command center

- There is a single place Jeff and his team of estimators can look to answer: what is running, what needs me, what happened.
- Includes Needs Attention overlays and CTAs beyond Reply, specifically: Reply, Fix issue, Resume, Mark Won, Mark Lost (per SPEC-09 v1.2.1), and any required approval or missing-info prompts needed to proceed.
- This can be simple, but it cannot be invisible.

### 5) Basic credibility (Account and Location configuration data ready)

- Attachments work.
- Salutation and signature are correct and consistent (originator identity per SPEC-07 v1.4).
- Email quality is clean enough to not embarrass Jeff.
- **Account-level configuration is populated:** company logo (`logo_url`) and company name (`company_name`) on the Accounts record. Without these, signature composition fails per SPEC-07 v1.4 §9.
- **Location-level configuration is populated for all three Servpro locations** (NE Dallas, Boise, Reno): `display_name`, full address, `phone_number`, and the location must be flipped to `is_active = true`. Activation is blocked until every signature-bearing field is populated, per PRD-10 v1.3.1 §7.
- All three data layers (Users, Locations, Accounts) must be complete for any campaign email to render. See §K Account and Location configuration below.

### 6) Template authoring complete for v1 scope

- v1 campaign templates are authored, reviewed, and activated for the **5 restoration sub-types covering 17 scenarios** authorized by Jeff Stone (governed by SPEC-12 v2.0.1 authoring methodology).
- Templates are activated per Account in the SMAI admin portal (PRD-10 v1.3.1).
- The Conversion Coordinator cannot run without an active approved template variant for the resolved (job type, scenario) pair. Without templates authored and activated, the agent has nothing to resolve.

### 7) Tenant Analytics dashboard live

- The tenant-facing Analytics surface is **in scope for Buc-ee's** (governed by PRD-07 v1.2).
- MTD/YTD conversion-rate view per SPEC-05 v1.0.
- Branch comparison view per SPEC-06 v1.0.
- Analytics ties back to authorized template versions and append-only events; no fuzzy heuristics.
- Per Wave 6D (PRD-07 §1A, SPEC-05 §1A, SPEC-06 §1A): backend ships raw query results from `jobs` and `messages` tables; frontend handles period filtering, MTD/YTD computation, chart bucketing, and per-location aggregation client-side. Operator-facing behavior is unchanged regardless of where computation runs. The eventual contract for backend computation (when reporting tables or a data warehouse are introduced) is documented inline in those specs.

## What is in scope for Buc-ee's (Milestone 1)

This is the minimum set that proves the wedge and preserves the OS foundation.

### A) New Job flow

- Upload proposal (PDF).
- Parse and prefill: customer name, email, address, job name, job type/sub-type and scenario classification (the operator confirms the (job type, scenario) pair before submission).
- Parse and prefill: DASH job number (or require it if the Account `job_reference_required` flag is `true`, which it is for Jeff).
- Allow edits before launch.
- Governed by PRD-02 v1.5 (New Job Intake) and SPEC-03 v1.3.3 (job type / sub-type / scenario taxonomy).

### B) Campaign resolution and launch

- Resolve the active operator-approved campaign template for the job's (job type, scenario) pair from the Account's activated template library.
- Substitute job-specific data into operator-approved content (cadence, timing, quiet hours, body content all derived from the approved template plus merge-field substitution).
- Operator approves per campaign on this job; campaign launches deterministically.
- No word-by-word editing in Buc-ee's.
- Governed by PRD-03 v1.4.1 (Campaign Engine) and SPEC-11 v2.0.2 (templated architecture).

### C) Jobs list with real statuses

- Every job has a status that is legible from five feet away.
- Minimum statuses: In campaign, Customer replied, Campaign Paused, Delivery failed, plus Won and Lost outcome states.
- Jobs is the inventory and timeline, even if lightweight.
- Governed by PRD-05 v1.4 (Jobs List) and SPEC-02 v1.0 (originator filter).

### D) Needs Attention page

- Needs Attention exists as the home screen.
- It only shows jobs that require a human.
- Minimum triggers: reply detected, bounce or delivery issue, manual pause.
- Governed by PRD-04 v1.2.1 (Needs Attention).

### E) Job detail page (lightweight)

- Show the proposal.
- Show key job fields including the resolved template version (so Jeff can see which approved template variant the campaign is running against).
- Show campaign state: what step it is on, what has been sent, what is next.
- If possible, show reply content when a reply happens, or at least tell the user that a reply exists in their inbox from the prospect.
- Governed by PRD-06 v1.3.1 (Job Detail).

### F) Notifications

- When a reply happens, the job moves to Customer Replied.
- On Needs Attention (and in Job Detail), user has options to Resume Campaign, Stop Campaign, Mark Won, Mark Lost based on the context of the prospect's response.

### G) Tenant Analytics dashboard

- MTD/YTD conversion rate (SPEC-05 v1.0).
- Branch comparison view (SPEC-06 v1.0).
- Reply rate, time-to-first-reply, delivery truth coverage, Needs Attention resolution rate.
- All metrics tie back to authorized template versions and append-only events.
- Governed by PRD-07 v1.2 (Analytics).
- Build contract: backend ships raw query results; frontend handles period filtering, MTD/YTD computation, and aggregation client-side per Wave 6D architecture decision.

### H) Settings (originator identity, signatures, OAuth)

- Per-originator user fields required by SPEC-07 v1.4 signature composition: `first_name`, `last_name`, `title`, `cell_phone`, single-Location assignment for Originators per PRD-08 v1.2.
- Office location display per SPEC-08 v1.0 (display name priority fix).
- Governed by PRD-08 v1.2 (Settings).

### I) Gmail OAuth and OBO send (per PRD-09 v1.3.1)

- One dedicated operational mailbox per location using `mail` subdomain.
- OBO OAuth token storage and reconnect flow.
- Send with originator identity in From-display name; reply-to to the operational mailbox.

### J) Bug fixes shipping with MVP

- SPEC-08 v1.0 (Office Location display bug) and SPEC-09 v1.2.1 (Mark Won/Lost CTA visibility) are bug fixes surfaced in the April 6 Jeff walkthrough. Not features in their own right, but the build cannot ship clean without them.

### K) Account and Location configuration (Admin Portal backend)

This is the configuration layer that makes everything else work.

- **Admin Portal backend ships complete for Buc-ee's go-live.** Endpoints, validation, audit logging, and schema for the Account record (logo, company name) and Location records (per-location signature-bearing fields) per PRD-10 v1.3.1.
- **Admin Portal frontend does not ship for Buc-ee's go-live.** SMAI staff configure Jeff's three Servpro locations (NE Dallas, Boise, Reno) and Account-level fields via direct API calls, scripts, or controlled DB writes against the Admin Portal backend. This is the explicit posture in PRD-10 v1.3.1 §0.
- **The Admin Portal frontend ships before tenant #2 onboarding begins.** Configuring Jeff via direct DB writes is acceptable for one Account. It is not a scalable onboarding path. The frontend is post-Jeff, pre-tenant-#2.
- **Account-level Job Type and Scenario activation** is configured via the same backend per SPEC-03 v1.3.3 §10. Jeff's Account is activated for the 5 sub-types covering 17 scenarios authored under SPEC-12 v2.0.1.
- **Account-level template variant activation** per SPEC-11 v2.0.2 §11.2 (two-step atomic).

## What is explicitly out of scope for Buc-ee's

This is the stuff that feels good to build but does not unlock paid usage yet.

- **Admin Portal frontend** (backend yes, frontend no per §K above; frontend ships before tenant #2)
- Campaign templates UI in the operator product (template authoring lives in the SMAI admin portal per PRD-10 v1.3.1; operators do not author templates)
- Tone slider and persona controls beyond a single default
- Multi-Location support and domain-based onboarding beyond the three Servpro locations
- Full prompt playground UI inside the operator product
- Rich job stages beyond what is needed for the follow-up wedge
- Any deep "product OS" expansion that is not directly tied to running campaigns and triaging exceptions
- The first-time-per-pair approval shape (this is an Early v2 milestone; Buc-ee's ships with the per-campaign approval gate intact, see "Approval shape" below)
- Named agent identity in the operator UI ("Maya" or other agent names; the agent-as-staff visual reframe is post-Buc-ee's)
- Multi-agent team views (the second agent and beyond ship after Buc-ee's)
- Conversational chat interface to the agent (excluded by doctrine; CC-01 v1.5.1 §3)

## Approval shape (unchanged)

Buc-ee's ships with the **per-campaign approval gate** intact. The operator approves the resolved campaign for each job before launch. This is the same approval shape from v1.0 and v1.1; nothing changes for Buc-ee's.

The doctrinal direction beyond Buc-ee's is the first-time-per-pair approval shape (CC-01 v1.5.1 §17 and DA-12): the operator approves the playbook for each (job type, scenario) pair the first time that pair is used; subsequent jobs of the same pair execute the approved playbook automatically. This is an **Early v2 milestone**, not a Buc-ee's deliverable. The build pipeline must hold the per-campaign gate for Buc-ee's regardless of doctrinal direction.

The non-negotiable across both shapes: every customer-facing message resolves to operator-approved content. Operator authority over what gets sent is absolute.

## What Buc-ee's should feel like in a demo

Jeff should see four things in five minutes:

1. **Upload proposal**, it parses all info it can into the job shell, including job type / sub-type and scenario classification.
2. **The user inputs the DASH number** (required field in job shell, not pullable from proposal); the active template variant resolves for the (job type, scenario) pair; the subject line is correct; the operator reviews and approves; the campaign launches.
3. **The campaign runs without babysitting** against the operator-approved templated content.
4. **When a reply happens**, everything stops and it lands in Needs Attention with the reply ready to act on.
5. **Bonus (Analytics):** Jeff opens the Analytics dashboard and sees MTD/YTD conversion rate plus branch-level comparison.

If those things work, we are earning the right to charge and iterate.

## Milestone Ladder: Buc-ee's → MVP → California

### Milestone 1: Buc-ee's (paid alpha with Jeff / USDS)

**Goal:** Prove wedge, earn revenue, collect real feedback.

**What we ship:**

- New Job upload and parse with editable fields, including (job type, scenario) classification
- DASH job number extraction (governed by Account-level `job_reference_required` flag) and subject line format
- Template resolution + merge-field substitution for the resolved (job type, scenario) pair
- Per-campaign approval to launch or regenerate plan
- Stop on reply, with Needs Attention overlays and CTAs for Fix delivery issue, Resume campaign, Stop campaign, Mark Won, Mark Lost
- Needs Attention triage
- Jobs inventory with legible statuses
- Lightweight job detail page (showing resolved template version)
- Originator identity, signatures, OAuth (per SPEC-07 v1.4, PRD-08 v1.2, PRD-09 v1.3.1)
- **Tenant Analytics dashboard** with MTD/YTD conversion rate and branch comparison (per PRD-07 v1.2, SPEC-05 v1.0, SPEC-06 v1.0)
- Attachments reliably included
- v1 campaign templates authored, reviewed, and activated for **5 restoration sub-types covering 17 scenarios** (per SPEC-12 v2.0.1)
- **SMAI Admin Portal backend** operational for Account and Location configuration, template management, and OBO operations (per PRD-10 v1.3.1). Frontend deferred to pre-tenant-#2.
- **Account and Location configuration data populated** for Jeff's three Servpro locations via direct API/script/DB writes by SMAI staff

**Definition of done (priority-ordered):**

1. Jeff can run 10 real jobs through it in one week. *(Wedge)*
2. He can track them in DASH because subject lines are correct. *(Wedge)*
3. He sees replies and exceptions in one place. *(Wedge)*
4. He says: this is already better than what my reps do. *(Wedge)*
5. He sees Analytics with real conversion data. *(Foundation; the recruiting asset under CC-07)*

If something has to slip, it slips from the bottom. The first four are non-negotiable. The fifth is the foundation deliverable that proves the platform thesis to Jeff and to the operators he is recruiting under the Stone Family Office Design Partnership.

**Pricing:** Conversion Coordinator pilot at $250/mo/location for 60 days, converting to the bridge offering at $500/mo/location until the Sales & Revenue Recovery Team ships. Founding Operator lifetime-locked 35% discount applies to USDS where the Founding Operator round mechanics (CC-07 §4) determine class assignment. CC-04 v2.0 governs full pricing.

### Milestone 2: MVP (repeatable for the next 3 to 5 customers)

**Goal:** Make this sellable and operable beyond Jeff.

**Adds:**

- **Admin Portal frontend complete** (Account configuration UI, Location CRUD UI, template variant activation UI, audit log viewer)
- Onboarding flow that sets Account identity, default signature, quiet hours, default tone
- Better campaign plan review UI (still not word-level editing; resolved-template review)
- Basic campaign timeline visualization and per-job progress indicator
- Exception handling upgrades: bounces, wrong email, duplicate jobs, wrong job type
- Expanded template library coverage (additional sub-types and scenarios beyond the 5/17 v1 scope)
- Stronger structured extraction fields stored once per job
- The first-time-per-pair approval shape (Early v2): operator approves the playbook for each (job type, scenario) pair on first use; subsequent jobs auto-resolve and execute against the approved playbook
- Named agent identity in the operator UI (the agent-as-staff visual reframe; the Conversion Coordinator becomes a named, identifiable agent)

**Definition of done:**

- We can onboard a new customer in under an hour.
- The system runs without constant founder babysitting.
- We can charge meaningful tier-based pricing (Tier 1 at $2,000/mo/location standard, with Founding Operator discount where applicable) with confidence.

### Milestone 3: California (Lovable target state)

**Goal:** Full SMAI OS experience with the agent fleet, compounding intelligence, and the multi-agent team frame.

**Adds:**

- Sales & Revenue Recovery Team complete (Conversion Coordinator + Review/Reputation Manager + Collections Coordinator + Referral/Partnership Coordinator)
- Intake & Customer Communication Team available (Tier 2)
- Operations & Back Office Functions Team available (Tier 3)
- Multi-agent team views and performance-review surfaces
- Field tool add-ons live (Voice Job Intake, Estimate Optimization Engine)
- Rich Needs Attention workflows across stages and across agents
- Full job lifecycle OS beyond follow-up
- Context packs and (job type, scenario) rule sets enforced reliably
- Internal prompt tooling and template authoring iteration workflow (admin portal expansion)
- Multi-Location, role permissions, and deeper integrations

**Definition of done:**

- SMAI is not just follow-up automation.
- It is the AI staffing layer for restoration revenue and back-office workflow.
- The Servpro / RestorAI motion has Founding Operators on Tier 2 and Tier 3 with multi-Location proof.

## A simple alignment statement

We are not choosing between "ugly prototype" and "full product." We are choosing sequence.

Buc-ee's is the fastest shippable slice that:

- Produces real value for Jeff
- Fits his system of record (DASH)
- Preserves our OS foundation (Jobs, Needs Attention, Analytics, Account/Location config)
- Runs against operator-approved templated content authored offline
- Creates paid momentum on the path to repeatable MVP and California
- Earns the right to a strategic acquirer narrative through proof, not a bigger story

If we hold that line, we move fast without building something we regret.

---

## What changed from v1.1 (drift correction summary)

This v1.2 is a surgical update, not a rewrite. The structure and most of the language are preserved from v1.1. The substantive changes:

**Wedge vs. Foundation framing (new):**

- Added an explicit section distinguishing wedge criteria (#1 through #4, what Jeff feels) from foundation criteria (#5 through #7, what the next 3 to 5 customers need). Definition of done is now priority-ordered. This makes the strategic posture legible inside the document and answers the de-scope question without requiring a separate conversation.

**Complete MVP build set (new):**

- Added a section after Wedge vs. Foundation that states the equation directly: Buc-ee's MVP is every PRD and SPEC currently in the canonical project, with the Admin Portal frontend as the one exception (backend in, frontend out). Lists the complete in-scope build set with version anchors. Provides a simple decision rule for future scope questions: if X is governed by a PRD or SPEC in the project, X is in MVP. v1.1 implied this through the §A through §I anchoring; v1.2 makes it explicit so a reader does not have to reconstruct the equation from section headers.

**Admin Portal frontend deferral (new):**

- Per PRD-10 v1.3.1 §0, the Admin Portal frontend is **not** a Buc-ee's go-live gate. SMAI staff configure Jeff's tenant via direct API/script/DB writes against the Admin Portal backend. The frontend ships before tenant #2 onboarding begins. v1.1 was silent on this distinction; v1.2 makes it explicit in §K and in the out-of-scope list.

**Account and Location configuration data readiness (added to criterion #5 and new §K):**

- v1.1 success criterion #5 covered originator identity and email quality. v1.2 expands it to include the Account-level (logo, company name) and Location-level (display name, address, phone) data that signature composition depends on per SPEC-07 v1.4. New §K Account and Location configuration documents the Admin Portal backend layer that makes this work and the manual-configuration posture for Jeff's three Servpro locations.

**Wave 6D Analytics architecture noted (criterion #7 and §G):**

- Per Wave 6D (PRD-07 v1.2 §1A, SPEC-05 v1.0 §1A, SPEC-06 v1.0 §1A): backend ships raw query results, frontend handles MTD/YTD computation, period filtering, chart bucketing, and aggregation client-side. Operator-facing behavior unchanged. The build contract is materially different and worth surfacing in CC-06.

**Account-level Job Number config flag (criterion #1):**

- Per PRD-02 v1.5 §5 and PRD-10 v1.3.1 §7.5, the DASH job number requirement is governed by an Account-level `job_reference_required` flag. Jeff's Account has it set to `true`. v1.1 framed this as a universal MVP requirement; v1.2 names the flag and the per-Account scope.

**Bug fixes called out (new §J):**

- SPEC-08 (Office Location display bug) and SPEC-09 (Mark Won/Lost CTA visibility) are bug fixes shipping with MVP, not features. New §J names this distinction so the team does not mistake fix-to-ship-clean for feature-build.

**Terminology lock applied (DL-040):**

- Per CC-01 v1.5.1 terminology lock, "tenant" and "Account" refer to the same entity. v1.2 prose uses "Account" consistently in new content and sweeps body-text references where they appeared in v1.1. SQL/schema column names like `tenant_id` are preserved as physical-layer references.

**Spec and PRD version anchors refreshed throughout:**

- PRD-01 v1.4.1, PRD-02 v1.5, PRD-03 v1.4.1, PRD-04 v1.2.1, PRD-05 v1.4, PRD-06 v1.3.1, PRD-07 v1.2, PRD-08 v1.2, PRD-09 v1.3.1, PRD-10 v1.3.1.
- SPEC-02 v1.0, SPEC-03 v1.3.3, SPEC-05 v1.0, SPEC-06 v1.0, SPEC-07 v1.4, SPEC-08 v1.0, SPEC-09 v1.2.1, SPEC-11 v2.0.2, SPEC-12 v2.0.1.
- CC-01 reference updated to v1.5.1.

---

## What changed from v1.0 (preserved from v1.1 for audit trail)

**Architecture (templated, not runtime-generated):**

- v1.0 described campaign generation as runtime AI generation ("Generate cadence, generate email copy for each touch"). v1.1 describes it as template resolution ("Resolve the active campaign template, substitute job-specific data into operator-approved content"). The customer-visible behavior is similar; the underlying mechanism is fundamentally different. SPEC-11 v2.0 governs the templated architecture.

**Analytics (in scope, not out of scope):**

- v1.0 listed analytics as explicitly out of scope. v1.1 reverses this. The tenant Analytics dashboard ships with Buc-ee's per PRD-07, SPEC-05 (MTD/YTD conversion rate), and SPEC-06 (branch comparison view).

**Template authoring as prerequisite (new MVP success criterion #6):**

- v1 campaign templates for the 5 restoration sub-types covering 17 scenarios authorized by Jeff are a hard prerequisite. Without templates authored and activated, the Conversion Coordinator has nothing to resolve. SPEC-12 governs the authoring methodology.

**Approval shape (clarified):**

- Buc-ee's holds the per-campaign approval gate intact. The first-time-per-pair approval shape is an Early v2 milestone, not a Buc-ee's deliverable. CC-01 v1.5 §17 governs the doctrinal direction.

**Jeff's role (Stone Family Office Design Partnership):**

- v1.0 framed Jeff as paid alpha customer. v1.1 adds that Jeff is now Founding Design Partner under the Stone Family Office Design Partnership (CC-07). Buc-ee's remains his paid pilot.

**Pricing pointer (added):**

- v1.0 was silent on pricing. v1.1 references the Conversion Coordinator pilot at $250/mo/location for 60 days, the bridge offering at $500/mo/location, and Tier 1 standard pricing of $2,000/mo/location. CC-04 v2.0 governs full pricing.

**Spec set anchors (added):**

- v1.1 anchors each in-scope item to the governing PRD or SPEC. PRDs: PRD-01 through PRD-10. SPECs present in the current set: SPEC-02, SPEC-03, SPEC-05, SPEC-06, SPEC-07, SPEC-08, SPEC-09, SPEC-11, SPEC-12. SPEC-01 and SPEC-04 were retired during the canon refresh wave; SPEC-10 was an inadvertent gap in the numbering scheme and was never authored. v1.0 was authored before most of the present specs existed.

**Settings, OAuth, originator identity (added):**

- v1.0 did not call out Settings, OAuth, or originator identity as in-scope items because the relevant specs (SPEC-07, PRD-08, PRD-09) hadn't been written yet. v1.1 adds them as in-scope deliverables.

**Out-of-scope clarifications (added):**

- v1.1 explicitly excludes the first-time-per-pair approval shape, named agent identity in the UI, multi-agent team views, and conversational chat interface. These are post-Buc-ee's deliverables governed by Milestone 2 and 3 plus the agent platform architecture (forthcoming).

---

## Document Control

- **Document name:** Buc-ee's MVP Definition
- **Document ID:** CC-06
- **Version:** v1.2
- **Status:** Canonical
- **Supersedes:** v1.1 (2026-04-29), v1.0 (2026-02-22)
- **Owner:** ServiceMark AI leadership team
- **Last updated:** 2026-05-08
- **Change summary:** Surgical updates reflecting the v1.3/v1.4 cycle landings post-2026-04-29. Adds Wedge vs. Foundation framing as a new section. Adds Complete MVP Build Set section that names every in-scope PRD and SPEC with version anchors and identifies the Admin Portal frontend as the only exception. Adds Admin Portal frontend deferral as explicit MVP scope posture (backend yes, frontend post-Jeff pre-tenant-#2). Expands criterion #5 to cover Account and Location configuration data readiness with new §K documenting the Admin Portal backend layer. Adds Wave 6D Analytics build contract (backend raw, frontend computed) to criterion #7 and §G. Names the Account-level `job_reference_required` flag in criterion #1. Adds new §J calling out SPEC-08 and SPEC-09 as bug fixes shipping with MVP. Applies CC-01 v1.5.1 terminology lock (Tenant ≡ Account; "Account" used in new prose). Refreshes all PRD and SPEC version anchors throughout. Definition of done for Milestone 1 is now priority-ordered (wedge criteria first, foundation last). All other v1.1 content preserved including the v1.0 → v1.1 audit trail.
- **Triggers:** Per CP-02 v1.1 §12, this CC-06 update triggers review of: CP-01 v1.1 (current MVP slice section, must mirror v1.2 framing including Wedge vs. Foundation distinction and Admin Portal frontend deferral); active governed build briefs (verify alignment to current spec set versions); Current Priorities (verify Buc-ee's go-live tracking includes Account/Location config data readiness and Admin Portal backend completeness); product demo narratives (update to reflect Wave 6D Analytics architecture and Admin Portal backend posture); Decision Ledger (new entries for Admin Portal frontend deferral as MVP scope decision, Wave 6D Analytics architecture, Wedge vs. Foundation framing as canonical scope discipline).
