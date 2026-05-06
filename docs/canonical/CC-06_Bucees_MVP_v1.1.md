# Buc-ee's MVP Definition v1.1

**Status:** Canonical
**Supersedes:** v1.0 (2026-02-22)
**Last updated:** 2026-04-29

*(Jeff-first, on-path to California)*

---

## What we are solving right now

Jeff has a follow-up problem, not a CRM problem. Leads sit. Proposals go out. Nobody follows up. We are building the shortest path to measurable improvement, with a product foundation that compounds into the full SMAI OS.

The pilot is not "the product." It is the first stop that proves:

1. We can reliably run follow-up for real jobs in the wild.
2. We can stop at the right time when a human needs to take over.
3. We can do this in a way that fits the customer's existing workflow and system of record.

Jeff's role has evolved during the wave that produced this v1.1. Jeff is now Founding Design Partner under the Stone Family Office Design Partnership (per CC-07 RestorAI Brief). Buc-ee's remains his paid pilot for the Conversion Coordinator agent. The pilot terms (CC-04 v2.0 §4) are 60 days at $250 per month per location, with conversion to the Conversion Coordinator standalone bridge offering at $500 per month per location until the Sales & Revenue Recovery Team ships, then conversion to Tier 1 ($2,000/mo/location) — at the Founding Operator lifetime-locked 35% discount where applicable.

## MVP success criteria (non-negotiable)

If these are not true, Jeff will not adopt and we will not earn the right to charge.

### 1) DASH-native threadability

- We extract the DASH job number from the user.
- We put the DASH job number at the start of the email subject line.
- We preserve a clean, consistent subject format so Jeff can track everything in DASH without thinking.

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
- Includes Needs Attention overlays and CTAs beyond Reply, specifically: Reply, Fix issue, Resume, Mark Won, Mark Lost (per SPEC-09 v1.x), and any required approval or missing-info prompts needed to proceed.
- This can be simple, but it cannot be invisible.

### 5) Basic credibility

- Attachments work.
- Salutation and signature are correct and consistent (originator identity per SPEC-07).
- Email quality is clean enough to not embarrass Jeff.

### 6) Template authoring complete for v1 scope (new in v1.1)

- v1 campaign templates are authored, reviewed, and activated for the **5 restoration sub-types covering 17 scenarios** authorized by Jeff Stone (governed by SPEC-12 v2.0.1 authoring methodology).
- Templates are activated per tenant in the SMAI admin portal (PRD-10).
- The Conversion Coordinator cannot run without an active approved template variant for the resolved (job type, scenario) pair. Without templates authored and activated, the agent has nothing to resolve.

### 7) Tenant Analytics dashboard live (new in v1.1)

- The tenant-facing Analytics surface is **in scope for Buc-ee's** (governed by PRD-07).
- MTD/YTD conversion-rate view per SPEC-05.
- Branch comparison view per SPEC-06.
- Analytics ties back to authorized template versions and append-only events; no fuzzy heuristics.

## What is in scope for Buc-ee's (Milestone 1)

This is the minimum set that proves the wedge and preserves the OS foundation.

### A) New Job flow

- Upload proposal (PDF).
- Parse and prefill: customer name, email, address, job name, job type/sub-type and scenario classification (the operator confirms the (job type, scenario) pair before submission).
- Parse and prefill: DASH job number (or require it if missing).
- Allow edits before launch.
- Governed by PRD-02 (New Job Intake) and SPEC-03 (job type / sub-type taxonomy).

### B) Campaign resolution and launch

- Resolve the active operator-approved campaign template for the job's (job type, scenario) pair from the tenant's activated template library.
- Substitute job-specific data into operator-approved content (cadence, timing, quiet hours, body content all derived from the approved template plus merge-field substitution).
- Operator approves per campaign on this job; campaign launches deterministically.
- No word-by-word editing in Buc-ee's.
- Governed by PRD-03 (Campaign Engine) and SPEC-11 v2.0 (templated architecture).

### C) Jobs list with real statuses

- Every job has a status that is legible from five feet away.
- Minimum statuses: In campaign, Customer replied, Campaign Paused, Delivery failed, plus Won and Lost outcome states.
- Jobs is the inventory and timeline, even if lightweight.
- Governed by PRD-05 (Jobs List) and SPEC-02 (originator filter).

### D) Needs Attention page

- Needs Attention exists as the home screen.
- It only shows jobs that require a human.
- Minimum triggers: reply detected, bounce or delivery issue, manual pause.
- Governed by PRD-04 (Needs Attention).

### E) Job detail page (lightweight)

- Show the proposal.
- Show key job fields including the resolved template version (so Jeff can see which approved template variant the campaign is running against).
- Show campaign state: what step it is on, what has been sent, what is next.
- If possible, show reply content when a reply happens — or at least tell the user that a reply exists in their inbox from the prospect.
- Governed by PRD-06 (Job Detail).

### F) Notifications

- When a reply happens, the job moves to Customer Replied.
- On Needs Attention (and in Job Detail), user has options to Resume Campaign, Stop Campaign, Mark Won, Mark Lost — based on the context of the prospect's response.

### G) Tenant Analytics dashboard (new in v1.1)

- MTD/YTD conversion rate (SPEC-05).
- Branch comparison view (SPEC-06).
- Reply rate, time-to-first-reply, delivery truth coverage, Needs Attention resolution rate.
- All metrics tie back to authorized template versions and append-only events.
- Governed by PRD-07 (Analytics).

### H) Settings (originator identity, signatures, OAuth)

- Per-originator Gmail signature retrieval and from-display-name handling per SPEC-07.
- Office location display per SPEC-08.
- Governed by PRD-08 (Settings).

### I) Gmail OAuth and OBO send (per PRD-09)

- One dedicated operational mailbox per location using `mail` subdomain.
- OBO OAuth token storage and reconnect flow.
- Send with originator identity in From-display name; reply-to to the operational mailbox.

## What is explicitly out of scope for Buc-ee's

This is the stuff that feels good to build but does not unlock paid usage yet.

- Campaign templates UI in the operator product (template authoring lives in the SMAI admin portal per PRD-10; operators do not author templates)
- Tone slider and persona controls beyond a single default
- Multi-location support and domain-based onboarding
- Full prompt playground UI inside the operator product
- Rich job stages beyond what is needed for the follow-up wedge
- Any deep "product OS" expansion that is not directly tied to running campaigns and triaging exceptions
- The first-time-per-pair approval shape (this is an Early v2 milestone; Buc-ee's ships with the per-campaign approval gate intact — see "Approval shape" below)
- Named agent identity in the operator UI ("Maya" or other agent names; the agent-as-staff visual reframe is post-Buc-ee's)
- Multi-agent team views (the second agent and beyond ship after Buc-ee's)
- Conversational chat interface to the agent (excluded by doctrine; CC-01 v1.5 §3)

*(Note: v1.0 listed "Analytics page, reply-rate dashboards, and performance graphs" as out of scope. v1.1 reverses this — tenant Analytics dashboard is now in scope per PRD-07, SPEC-05, SPEC-06.)*

## Approval shape (clarified in v1.1)

Buc-ee's ships with the **per-campaign approval gate** intact. The operator approves the resolved campaign for each job before launch. This is the same approval shape from v1.0; nothing changes for Buc-ee's.

The doctrinal direction beyond Buc-ee's is the first-time-per-pair approval shape (CC-01 v1.5 §17 and DA-12): the operator approves the playbook for each (job type, scenario) pair the first time that pair is used; subsequent jobs of the same pair execute the approved playbook automatically. This is an **Early v2 milestone**, not a Buc-ee's deliverable. The build pipeline must hold the per-campaign gate for Buc-ee's regardless of doctrinal direction.

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
- DASH job number extraction (from user's manual input or from proposal if it's present there) and subject line format
- Template resolution + merge-field substitution for the resolved (job type, scenario) pair
- Per-campaign approval to launch or regenerate plan
- Stop on reply, with Needs Attention overlays and CTAs for Fix delivery issue, Resume campaign, Stop campaign, Mark Won, Mark Lost
- Needs Attention triage
- Jobs inventory with legible statuses
- Lightweight job detail page (showing resolved template version)
- Originator identity, signatures, OAuth (per SPEC-07, PRD-08, PRD-09)
- **Tenant Analytics dashboard** with MTD/YTD conversion rate and branch comparison (per PRD-07, SPEC-05, SPEC-06)
- Attachments reliably included
- v1 campaign templates authored, reviewed, and activated for **5 restoration sub-types covering 17 scenarios** (per SPEC-12)
- SMAI admin portal operational for template management, tenant configuration, OBO operations (per PRD-10)

**Definition of done:**

- Jeff can run 10 real jobs through it in one week.
- He can track them in DASH because subject lines are correct.
- He sees replies and exceptions in one place.
- He sees Analytics with real conversion data.
- He says: this is already better than what my reps do.

**Pricing:** Conversion Coordinator pilot at $250/mo/location for 60 days, converting to the bridge offering at $500/mo/location until the Sales & Revenue Recovery Team ships. Founding Operator lifetime-locked 35% discount applies to USDS where the Founding Operator round mechanics (CC-07 §4) determine class assignment. CC-04 v2.0 governs full pricing.

### Milestone 2: MVP (repeatable for the next 3 to 5 customers)

**Goal:** Make this sellable and operable beyond Jeff.

**Adds:**

- Onboarding flow that sets company identity, default signature, quiet hours, default tone
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
- Multi-location, role permissions, and deeper integrations

**Definition of done:**

- SMAI is not just follow-up automation.
- It is the AI staffing layer for restoration revenue and back-office workflow.
- The Servpro / RestorAI motion has Founding Operators on Tier 2 and Tier 3 with multi-location proof.

## A simple alignment statement

We are not choosing between "ugly prototype" and "full product." We are choosing sequence.

Buc-ee's is the fastest shippable slice that:

- Produces real value for Jeff
- Fits his system of record (DASH)
- Preserves our OS foundation (Jobs, Needs Attention, Analytics)
- Runs against operator-approved templated content authored offline
- Creates paid momentum on the path to repeatable MVP and California
- Earns the right to a strategic acquirer narrative through proof, not a bigger story

If we hold that line, we move fast without building something we regret.

---

## What changed from v1.0 (drift correction summary)

This v1.1 is a surgical update, not a rewrite. The structure and most of the language are preserved from v1.0. The substantive changes:

**Architecture (templated, not runtime-generated):**

- v1.0 described campaign generation as runtime AI generation ("Generate cadence... Generate email copy for each touch"). v1.1 describes it as template resolution ("Resolve the active campaign template... Substitute job-specific data into operator-approved content"). The customer-visible behavior is similar; the underlying mechanism is fundamentally different. SPEC-11 v2.0 governs the templated architecture.

**Analytics (in scope, not out of scope):**

- v1.0 listed analytics as explicitly out of scope. v1.1 reverses this — the tenant Analytics dashboard ships with Buc-ee's per PRD-07, SPEC-05 (MTD/YTD conversion rate), and SPEC-06 (branch comparison view).

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
- **Version:** v1.1
- **Status:** Canonical
- **Supersedes:** v1.0 (2026-02-22)
- **Owner:** ServiceMark AI leadership team
- **Last updated:** 2026-04-29
- **Change summary:** Surgical updates to reflect canon refresh wave landing 2026-04-29. Templated architecture replaces runtime generation language. Analytics dashboard moved from out-of-scope to in-scope. v1 template authoring (5 sub-types, 17 scenarios) added as MVP success criterion. Approval shape clarified (per-campaign gate intact for Buc-ee's, first-time-per-pair as Early v2). Jeff's Stone Family Office Design Partnership role added. Pricing pointer to CC-04 v2.0 added. In-scope items anchored to current spec set (PRD-01 through PRD-10; SPEC-02, SPEC-03, SPEC-05, SPEC-06, SPEC-07, SPEC-08, SPEC-09, SPEC-11, SPEC-12). Out-of-scope list expanded with named-agent-identity, multi-agent team views, conversational chat exclusions. Milestone 2 and 3 updated to reflect templated architecture, agent fleet, and team-based pricing.
- **Triggers:** Per CP-02 v1.1 §12, this CC-06 update triggers review of: CP-01 v1.1 (current MVP slice section, already reflects v1.1 scope), active governed build briefs (verify alignment to current spec set), Current Priorities (verify Buc-ee's go-live tracking includes template authoring and analytics), product demo narratives (update to reflect templated architecture, analytics dashboard, and SMAI admin portal as separate surface).
