# Pricing and Packaging Brief

**Version:** v2.0
**Status:** Canonical
**Supersedes:** v1.0 (2026-02-19)
**Last updated:** 2026-04-29

**Scope:** Next 6 to 12 months (Buc-ee's MVP through early v1; aligned with restoration-first GTM window)
**Wedge:** Proposal-to-response reliability, delivered as the Conversion Coordinator agent
**Positioning anchor:** AI staffing for restoration. Not software, not seats, not message volume. The customer leases AI employees that follow operator-approved playbooks, organized into teams that map to the operator's revenue and back-office functions.

---

## Executive summary

SMAI prices like a team, not like software. The customer is leasing AI employees organized into three ratcheted teams. Pricing is anchored to the cost savings the agent team delivers versus the human roles it replaces, not to seat counts or message volumes. The billing throughput unit for any agent is the Activated Plan: an operator-approved, preflight-validated, successfully-executed unit of work with append-only proof recorded.

This v2.0 supersedes the v1.0 per-location-subscription-plus-Activated-Plan model. The Activated Plan throughput discipline is preserved as the internal cost-to-serve and proof anchor; the customer-facing commercial unit is the team at the location level, with the Conversion Coordinator offered as a standalone bridge agent during Sales & Revenue Recovery Team build-out.

**Three customer-facing tiers** (cumulative purchase required):

- **Tier 1: Revenue Recovery** — $2,000/mo/location (4 roles)
- **Tier 2: Front Office** — $3,825/mo/location (8 roles, requires Tier 1)
- **Tier 3: Full Back Office** — $6,950/mo/location (14 roles, requires Tier 1+2)

**Field tool add-ons** (orthogonal to tier, when each ships):

- Voice Job Intake/Scoping: $800/mo/location
- Estimate Optimization Engine: $1,000/mo/location

**Bridge offering** (Buc-ee's window only, retires when Sales & Revenue Recovery Team ships):

- Conversion Coordinator standalone: $500/mo/location

**Founding Operator pricing** (RestorAI Founding Operator round only):

- 35% lifetime-locked discount off standard tier pricing on whichever tier the Founding Operator buys

CC-08 RestorAI Brief governs the Founding Operator round structure and Stone Family Office Design Partnership terms. This brief governs the pricing card that any RestorAI tenant or direct SMAI tenant pays.

---

## 1. What we are selling and what we refuse to sell

### What customers are actually buying

Leased AI employees organized into teams that map to the operator's revenue and back-office functions. Each agent owns a phase of the workflow, runs against operator-approved playbooks, and reports its work into surfaces the operator already uses (Jobs, Needs Attention, Analytics).

The Conversion Coordinator (live now) handles the proposal-to-response window:

- Proposal in, job shell formed, playbook resolved against the (job type, scenario) pair, operator approves, execution runs deterministically against operator-approved templated content
- Reply, bounce, or operator pause halts immediately and becomes a surfaced job state
- Needs Attention is the control plane, not a dashboard
- Every meaningful action emits an append-only event so attribution is defensible, non-political, and renewal-safe

Additional agents in Tier 1 (Review/Reputation Manager, Collections Coordinator, Referral/Partnership Coordinator), Tier 2, and Tier 3 extend the same discipline into adjacent moments. The agent platform architecture is shared across all agents; what differs across agents is phase ownership and operator-approved playbooks.

### What we refuse to become and what packaging must prevent

- Not CRM, not marketing automation, not a campaign builder
- Not a per-seat tool (seats imply tooling; SMAI sells leased agents)
- Not a per-message platform (volume pricing pulls SMAI into the email-tool bucket)
- No Campaigns UI in MVP and early v1
- No unapproved customer-facing send (every send is governed by operator-approved content)
- No autonomous content authoring at runtime; campaign content is templated and pre-approved
- No in-flight rewriting or cadence changes in MVP and early v1
- No conversational chat interface to agents
- No bespoke per-customer agents or per-customer code paths

This is why seat-based pricing is structurally wrong for SMAI, and why per-message pricing is structurally wrong. SMAI is a governed staffing layer where value correlates to phase coverage and reliability, not user count or message count.

---

## 2. The team-based pricing structure (cumulative ratcheted tiers)

### Three teams, organized by workflow phase

**Sales & Revenue Recovery Team** — the proposal-to-response and revenue-recapture phase

- Conversion Coordinator (live now) — proposal follow-through
- Review / Reputation Manager (next 90 days) — review solicitation after completed jobs
- Collections Coordinator (next 90 days) — aging AR follow-up
- Referral / Partnership Coordinator (6-12 months) — referral and partnership follow-through

**Intake & Customer Communication Team** — the inbound-to-active-job phase

- Job Record / Intake Coordinator (next 90 days) — clean job records from any inbound source
- Receptionist / Call Handler Agent (next 90 days) — 24/7 call answering and intake creation
- Customer Status Coordinator (next 90 days) — proactive status updates during active jobs
- Customer Service / Account Rep (6-12 months) — relationship management and account-level coordination

**Operations & Back Office Functions Team** — the operations and back-office phase

- Dispatch / Scheduling Agent (6-12 months)
- Accounting Clerk Agent (6-12 months)
- Insurance / Claims Coordinator (6-12 months)
- Recruiting Coordinator (6-12 months)
- Training / Certification Coordinator (6-12 months)
- Marketing Coordinator (6-12 months)

### Cumulative team-purchase rule (commercial commitment)

- A customer may enter at any tier; most enter at Tier 1.
- A customer **cannot** buy a higher tier without owning the lower ones (Tier 2 requires Tier 1; Tier 3 requires Tier 1 + Tier 2).
- Tiers are not unbundled into individual agents (no à la carte single-role purchase as a standard SKU).
- Once a tier is generally available, the team is the smallest commercial unit a customer can buy at that level.

### Customer-facing tier pricing

| Tier | Roles | Monthly per location | Annual per location (10% off) |
|---|---|---|---|
| Tier 1: Revenue Recovery | 4 | $2,000 | $21,600 |
| Tier 2: Front Office (Tier 1 + Team 2) | 8 | $3,825 | $41,310 |
| Tier 3: Full Back Office (all 14 roles) | 14 | $6,950 | $75,060 |

Annual is 10% off list, billed annually. Monthly is the default for MVP and early v1; annual offered when pilot success criteria are met and the customer wants commitment pricing.

### Field tool add-ons (orthogonal to tier)

| Add-on | Monthly per location | Ship target |
|---|---|---|
| Voice Job Intake / Scoping | $800 | Q4 2026 |
| Estimate Optimization Engine | $1,000 | Q1 2027, proof-gated |

Field tools attach to any tier when each ships. They are tools used by humans (estimators), not autonomous agents. Operator may attach one, both, or neither.

### Bridge offering (Buc-ee's window only)

The Conversion Coordinator is offered as a standalone agent at **$500 per month per location** until the Sales & Revenue Recovery Team is fully shipped (M4 in the financial model). After M4, the standalone offering retires; new customers buy Tier 1. Existing customers on the bridge offering convert per terms set at conversion time.

USDS (Jeff Stone's Servpro ownership group) is the reference benchmark customer for the bridge offering at this price point.

### Founding Operator pricing (RestorAI Founding Operator round only)

Every RestorAI Founding Operator receives a **lifetime-locked discount of 35% off standard tier pricing** on whichever tier they buy. The 35% lock is base case (30% Conservative, 40% Aggressive in the financial model).

Resulting Founding Operator prices:

- Tier 1 Founding Operator: $1,300/mo/location (lifetime-locked)
- Tier 2 Founding Operator: $2,486/mo/location (lifetime-locked)
- Tier 3 Founding Operator: $4,518/mo/location (lifetime-locked)

5-year savings framing per RestorAI deck Slide 17:

- Class A Founding Operator at 5 locations: ~$135K saved + equity upside
- Class B Founding Operator at 3 locations: ~$80K saved + equity upside
- Class C Founding Operator at 1 location: ~$27K saved + equity upside

Founding Operator economics are governed jointly with CC-08 RestorAI Brief.

---

## 3. The Activated Plan as the internal throughput and proof unit

The Activated Plan remains the internal billing-equivalent throughput metric for any agent in the team. It is preserved as:

- The cost-to-serve anchor (token cost, deliverability cost, ops review time all scale with Activated Plans)
- The proof anchor (every Activated Plan ties to operator-approved content and an append-only event chain)
- The pilot success metric for Conversion Coordinator-level proof

### Activated Plan definition (Conversion Coordinator)

A job-specific plan that is:

1. Resolved from an operator-approved campaign template for the job's (job type, scenario) pair
2. Passes preflight validation
3. Successfully sends and delivers the first email with append-only proof recorded

### Preflight validation requirements

- Recipient address present and syntactically valid
- Proposal attached or key terms present without invention
- No forbidden commitments (dates, pricing, guarantees, availability)
- Stop conditions armed (reply, bounce, pause)
- Plan version locked (template version + job version both pinned, no silent edits)
- Approved template variant exists for the resolved (job type, scenario) pair

### Why team pricing rather than per-Activated-Plan pricing

Per-Activated-Plan pricing implies a per-message product, which is the bucket SMAI refuses to be in. Team pricing aligns with the staffing positioning, simplifies the customer-facing pricing card, and matches the cost-displacement narrative ("$787K of human roles for $83K/year"). The Activated Plan is the internal proof and cost-to-serve unit, not the customer-facing billing unit.

### Activated Plan capacity per tier (planning assumption)

- Tier 1: ~120 Activated Plans per location per month (Conversion Coordinator dominant; modest Review/Collections volume)
- Tier 2: capacity scales with intake volume; currently a planning band, validated through Tier 2 pilots
- Tier 3: capacity scales with full-workflow volume; currently a planning band

If a tenant produces materially higher Activated Plan volume than the planning band, we evaluate whether the cost-to-serve model holds and whether a multi-location discount or volume agreement is appropriate. We do not bill per-Activated-Plan overages to the customer; we manage capacity at the team-pricing level.

---

## 4. Pilot offer and conversion path (Conversion Coordinator bridge offering)

### Pilot offer (60 days)

- **Price:** $250 per month per location for 60 days
- **Reference frame:** Conversion Coordinator standalone bridge price is $500/mo/location flat
- **Included:** Up to 120 Activated Plans per month per location, no overages during pilot
- **Scope:** proposal ingestion, template-resolved campaign execution, plan approval, deterministic follow-through, stop on reply, event log, Needs Attention, Analytics dashboard, weekly ops review

### Success criteria (must hit 2 of 3)

1. At least 85% of eligible jobs (proposal plus valid email) get an Activated Plan within 24 hours of proposal upload
2. Delivery truth coverage: at least 98% of sends have a clear state (delivered, bounced, replied) with actionable interrupts
3. Measured lift: defensible improvement in either reply rate or time to first reply versus baseline (baseline captured in the first 2 weeks)

### Conversion trigger

Conversion happens at the end of the 60-day pilot. The customer either:

- Stays on the Conversion Coordinator bridge offering at $500/mo/location until the Sales & Revenue Recovery Team ships (then converts to Tier 1)
- Or converts directly to Tier 1 if the Sales & Revenue Recovery Team has already shipped at conversion time

If success criteria are missed due to customer-side operational behavior, pricing still converts but requires a process change (an assigned approval owner with SLA) or we exit.

---

## 5. Why the team prices are defensible

### Where the prices sit relative to substitutes

The deck anchor: a fully-loaded human equivalent across all 14 roles costs $787,050 per location per year. RestorAI Tier 3 at $83,400 per location per year displaces that cost at roughly 89% savings. Tier 1 and Tier 2 deliver proportional savings against the comparable human roles.

The substitute stack falls into five buckets, and team pricing is anchored against the human-cost displacement, not against the substitute software cost:

1. **FSM ops systems (ServiceTitan, Jobber)** — designed for job ops, not back-office staffing. Customers keep these; RestorAI staffs the back office that interacts with them.
2. **DIY automation and CRM (HubSpot, Salesforce)** — toolkits the customer must operate. Anti-fit. Customers may keep them as systems of record; RestorAI is the staffing layer that operates on top.
3. **Managed marketing retainers** — top-of-funnel demand. Different problem.
4. **Answering and lead capture (Hatch, Breezy)** — operate at intake only and invite freelancing through configurability. Receptionist Agent (Tier 2) replaces these directly.
5. **Comms and reputation (Podium, Birdeye)** — point solutions for one phase. Review Manager (Tier 1) replaces these directly.

The anchor for "is the price reasonable" is not "what does the substitute software cost" but "what would a human team in these roles cost." That is the staffing positioning carrying its weight.

### Cost-to-serve and margin logic

This subsection explains why team pricing can work operationally if we keep the managed scope tight and repeatable. All numbers are planning assumptions with ranges, not claims.

**What is included in team pricing (managed):**

- Governed template authoring (offline, by SMAI; templates are activated per tenant)
- Tenant configuration and admin portal operations
- Deliverability setup and monitoring
- Triage support for delivery failures and reply-routing edge cases within the defined workflow
- Weekly ops review focused on interrupts, stuck states, and throughput stability
- Validator tightening based on observed failure modes (delivered as shared product improvement, amortized across tenants, not bespoke per customer)

**Core cost drivers per location (planning assumptions):**

1. Onboarding and governance setup (one-time): 2 to 5 hours per location
2. Deliverability setup and monitoring: 1 to 2 hours setup + 15-30 min/week ongoing
3. Weekly ops review: 30-45 min/week per location
4. Triage time: 15-45 min/week per location
5. Token cost (variable, scales with tier): Tier 1 ~$200/mo/loc, Tier 2 ~$400/mo/loc, Tier 3 ~$700/mo/loc (Base case)
6. Third-party services (telephony, transcription, voice synthesis): scales when Tier 2+ ships, ~$30/mo per active customer Base case
7. Validator tightening: shared improvement work, amortized across customers

**Steady-state weekly time per Tier 1 location: 1.0 to 2.0 hours.** If one CS operator has 25 to 30 focused hours per week available for managed work, capacity per operator is roughly 15-20 locations Base case (best case 25-30, worst case 10-12). Tier 2 and Tier 3 increase managed time per location proportionally; the pricing model accommodates this through team-tier pricing rather than per-Activated-Plan overages.

**What would cause margin failure at team pricing:**

- Bespoke workflows creep in and every customer needs special rules and exceptions
- Customer-side approval discipline is weak and creates repeated triage loops
- Deliverability is chronically broken and requires ongoing intervention
- The system becomes noisy and generates too many interrupts or unclear ownership
- Per-tenant template authoring creep (instead of activating from the master template library)
- Token costs scale faster than the variable assumption due to volume spikes or model-cost changes

The pricing model is built to avoid all of these. Activated Plans require preflight validation, the system executes deterministically after approval, stop conditions are first-class, and template authoring is governed by SPEC-12 (centralized, not per-tenant bespoke). Weekly ops review is meant to eliminate recurring interrupt patterns, not to run the customer's business for them.

---

## 6. What counts as managed service versus product

### Managed (included in tier pricing)

- Governed template library activation per tenant (template authoring is offline by SMAI, governed by SPEC-12)
- Deliverability configuration and monitoring
- Triage support for delivery failures and reply-routing edge cases within the defined workflow
- Weekly ops review focused on interrupt reduction and throughput stability
- Tenant SOP configuration in the admin portal

### Product (included in tier pricing)

- Operator product surface: Jobs, Needs Attention, Analytics
- Proposal upload to job shell
- Plan resolution from operator-approved templates, operator approval, deterministic execution
- Immediate stop conditions and event fabric
- Proof-grade analytics grounded in approved template versions and recorded events
- Admin portal access for tenant administrators (governed by PRD-10)

### What is not included in tier pricing

- Custom workflows beyond the master template library
- Custom integrations beyond Gmail OAuth in MVP and early v1
- Per-tenant copywriting outside governed templates
- Multi-brand legal review of customer-facing prose
- SMS sends (not in MVP and early v1)
- Bespoke agent SOPs not derivable from the standard template library

---

## 7. Pricing expansion for future modules

This section is forward-looking. It defines when a price lift is justified under the same governed contract. It does not commit to new modules, timelines, or prices.

### Price lift rule

We do not raise team prices because we ship more features inside an existing tier. We raise team prices only when:

- A new agent ships and the team it belongs to gains substantive coverage, evaluated against the team's pricing reference (human-equivalent cost)
- A new tier ships (already planned: the three tiers are the current commercial structure; Tier 4 not currently planned)
- Field tool add-on pricing adjusts based on observed value (Voice Job Intake $800/mo/loc and Estimate Optimization $1,000/mo/loc are working list prices subject to validation)

Team prices are not raised because Conversion Coordinator gets a new feature; they are raised when the team itself expands or a new tier becomes the standard. Founding Operators are insulated from team-price increases via the lifetime-locked 35% discount.

### Tier expansion table (hypotheses only, to be validated)

| Module | What it changes in the lifecycle | What it measurably improves | Pricing implication | Readiness gate |
|---|---|---|---|---|
| Voice Job Intake field tool | Reduces friction in creating a complete job record before plan creation | Higher Activated Plan coverage, faster time to activation, fewer interrupts caused by missing fields, stronger proof completeness | Add-on at $800/mo/location, not a tier raise | Demonstrate that it increases eligible job completeness and improves time to activation without increasing activation failure rate |
| Estimate Optimization Engine field tool | Improves proposal completeness and consistency before follow-through begins | Higher Activated Plan coverage, fewer interrupts tied to missing terms, stronger proof | Add-on at $1,000/mo/location, not a tier raise | Demonstrate that generated proposals meet preflight constraints, reduce forbidden commitment risk, and reduce interrupt volume without increasing disputes; deck claims 15% uplift on average job value, $600K additional recognized revenue at 500 jobs × $8K average |
| Tier 4 (hypothetical, not currently planned) | Would extend the agent fleet beyond the current 14 roles into a new workflow phase | TBD | New tier, not a base raise | Would require demonstrated repeatability of Tier 3 across multiple operators and a new phase that genuinely does not fit within the current three teams |

### Recommendation for the next 6 to 12 months

Do not raise base tier prices in the next 6 to 12 months. Treat new agents as filling out their team rather than triggering a price increase. Treat field tools as add-ons priced separately. If a module cannot be measured against the human-cost displacement narrative or the Activated Plan coverage and proof-strength metrics, it is not a pricing lever.

---

## 8. What must be true for this pricing to hold (next 6 to 12 months)

- The staffing positioning is legible to the buyer (they think "AI employee" not "software")
- The cumulative team-purchase rule does not block customers from getting in (most customers enter at Tier 1)
- The Conversion Coordinator at $500/mo/location bridge offering produces demonstrable conversion-rate signal during the Buc-ee's window
- The Sales & Revenue Recovery Team ships within ~M4 so the bridge offering can retire and new customers buy Tier 1
- Approval does not become a bottleneck (most eligible jobs activated within 24 hours under the per-campaign approval gate; first-time-per-pair approval shape ships in Early v2 to remove residual friction)
- Delivery truth instrumentation is credible
- Managed posture stays narrow and repeatable (no drift into bespoke workflows per customer or vertical)
- SMAI remains legible as a leased agent fleet, not perceived as software, because the surfaces stay job-centric and interrupt-centric

---

## 9. Risks and mitigations (top 7)

1. **Buyers bucket SMAI as marketing software and push back on price.** Mitigation: keep every surface and contract term anchored to staffing positioning, agents, operator-approved playbooks, and human-cost displacement. Never sell campaigns or seats.
2. **Cumulative team-purchase rule rejected by some operators who want only Tier 3.** Mitigation: hold the rule firm in v2.0 and track rejection rate as an open tension (CP-01 §12). The rule prevents cherry-picking and protects the cost-displacement narrative; if rejection rate becomes material, revisit in CC-04 v3.
3. **Operator approval becomes slow and reduces effectiveness during the Buc-ee's per-campaign-gate window.** Mitigation: one-click approval, explicit approval ownership in the pilot, weekly ops review measures time to activation. First-time-per-pair approval shape (Early v2) is the structural fix.
4. **Token cost scales faster than the variable assumption.** Mitigation: variable token cost assumptions per tier are tracked monthly; if material drift, revisit pricing or tier scope.
5. **Managed load exceeds capacity as customers grow beyond ~40-60 active locations.** Mitigation: planned CS hire in Year 2 per the financial model Headcount tab; track managed time per location in weekly ops review.
6. **Bridge offering at $500/mo/location creates anchoring problem when Tier 1 ships at $2,000.** Mitigation: the bridge is explicitly framed as transitional during build-out; Founding Operators are protected via the lifetime-locked discount; standard customers see Tier 1 at $2,000 from the start.
7. **Founding Operator 35% lifetime lock is too generous and erodes margin at scale.** Mitigation: 35% is base case in the model; Conservative is 30%, Aggressive is 40%; final % subject to RestorAI Founding Operator round dynamics and Stone Family Office negotiation. Lifetime-lock applies only to the 16-18 Founding Operator seats, not to standard customers.

---

## 10. Pricing language and contract anchors

### What customers see on the pricing page (RestorAI deck Slide 11)

> *"Your digital back office. Priced like a team, not like software. Standard pricing. Multi-location and Founding Operator rates on later slides."*

Three teams listed with team totals. Each agent within the team labeled with ship status (LIVE NOW, NEXT 90 DAYS, 6-12 MONTHS) and per-role rate. Team totals: $2,000 / $1,825 / $3,125 (incremental subtotals). Cumulative tier prices: $2,000 / $3,825 / $6,950.

### What the contract specifies

- Team subscription per location per month, billed monthly (or annual at 10% off)
- Activated Plan throughput included in team subscription (no per-Activated-Plan overages charged to customer)
- Approval-first per content pattern; trust contract preserved (CC-01 v1.5 §17)
- Stop conditions enforced; SMAI may pause sending if a tenant's preflight fail rate or stop-condition correctness drops below contract thresholds
- Mailbox access required (Gmail OAuth in MVP and early v1)
- Approval owner and inbox owner named in writing
- No outcome guarantees tied to bookings or close rates
- Termination terms: standard 30-day notice; pilot conversion terms specified separately

### Internal rate card (governs cost-to-serve and transfer pricing, not customer-facing pricing)

The full per-role rate card is governed by the RestorAI Pro Forma v2.10 Roles & Bundles tab and matches RestorAI deck Slide 11 exactly. It is the internal source of truth for transfer pricing between SMAI and RestorAI, financial modeling, and cost-to-serve analysis. It is not exposed as a customer-facing pricing menu. À la carte single-role purchase is not a standard SKU.

---

## 11. Open questions

- License fee structure between SMAI and RestorAI (working frame: percentage of RestorAI ARR; specifics pending counsel)
- Multi-location volume discount logic (currently flat per-location pricing; tiered discount may be needed for 5+ location operators)
- Whether the cumulative team-purchase rule holds against real customer demand patterns over the first 6 months
- Final Founding Operator % discount (working: 35% base case; final subject to round dynamics)
- Pricing for Tier 2 and Tier 3 when those tiers ship in production (current $3,825 and $6,950 are working list prices anchored to the deck; subject to validation through actual Tier 2 and Tier 3 customer signal)
- Whether SMAI direct-sales tenants (non-RestorAI restoration operators) receive the same Founding Operator pricing or a separate "Direct Founding" tier
- Sales commission structure for non-founder sales motion (deferred until standard sales hires)

---

## Document Control

- **Document name:** Pricing & Packaging Brief
- **Document ID:** CC-04
- **Version:** v2.0
- **Status:** Canonical
- **Supersedes:** v1.0 (2026-02-19)
- **Owner:** ServiceMark AI leadership team
- **Last updated:** 2026-04-29
- **Change summary:** Replaces per-location-subscription-plus-Activated-Plan model with team-based ratcheted tier pricing. Three tiers (Revenue Recovery / Front Office / Full Back Office) at $2,000 / $3,825 / $6,950 per location per month. Cumulative team-purchase rule. Conversion Coordinator standalone bridge offering at $500/mo/location during Buc-ee's window. Field tool add-ons priced orthogonally. Founding Operator 35% lifetime-locked discount. Activated Plan preserved as internal throughput and proof unit, no longer the customer-facing billing unit. Pilot terms updated to reference the bridge offering. Cost-to-serve model expanded to reflect templated architecture and tier scaling. Substitute stack reframed against human-cost displacement rather than substitute-software cost.
- **Triggers:** Per CP-02 §12, this CC-04 update triggers review of CP-01 (commercial stance section), CC-02 (offer architecture section), CC-05 (pricing language and pilot section), CC-08 (Founding Operator pricing references), RestorAI Pro Forma model (cost-to-serve assumptions), RestorAI deck Slide 11 (pricing card), and customer-facing pricing artifacts.
