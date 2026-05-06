# Canonical Strategy Memo

**Version:** v2.0
**Status:** Canonical
**Supersedes:** v1.0 (2026-02-22)
**Last updated:** 2026-04-29

---

## 1) Why we exist and what is at stake

Most bid-based operators lose work after the proposal is sent, not because the work is uncompetitive, but because follow-through breaks under load. The failure mode is familiar: proposals go out, teams get busy, inboxes get messy, deliverability is unclear, and nobody can say with confidence what is stalled, what delivered, what got a reply, and what needs action.

SMAI exists to make that window reliable and legible. We started there because it is the most acute, most provable operating pain in the businesses we serve. But the deeper problem is broader. In service businesses, the back office runs on humans the company cannot find or retain in sufficient numbers, doing repetitive coordination work in the margins of the day, with no system holding the line when reality intervenes. A franchise doing $2M to $4M annually runs a back office that costs $175K to $275K per year for 2 to 3 people covering 15 to 20 functions, and at full strength would cost $787K. Most franchises cannot afford that, so they run understaffed, lose deals, and leave gaps that could be closed with the right staff in place.

SMAI builds and leases AI agents to fill those gaps. The first agent — the Conversion Coordinator — handles proposal follow-through. The next four agents fill out the Sales & Revenue Recovery Team. The agents that follow extend into intake, customer communication, and full back office. Each agent runs against operator-approved playbooks. Each agent reports its work into surfaces the operator already uses. Each agent stops the moment reality intervenes.

We are not selling software. We are staffing the back office.

## 2) What SMAI is and what we refuse to become

SMAI builds and leases AI agents to field service operators, starting with restoration. The agents are organized into three teams that map to the operator's revenue and back-office functions: Sales & Revenue Recovery, Intake & Customer Communication, and Operations & Back Office Functions. Customers lease teams, not seats; tiers are cumulative (Tier 2 requires Tier 1, Tier 3 requires both); the Conversion Coordinator is offered as a standalone bridge agent during the Buc-ee's window.

For the next 6 to 12 months, the active GTM scope is restoration only. The Servpro franchise channel via the RestorAI subsidiary is the primary go-to-market motion. Direct non-Servpro restoration is the parallel motion on the same product. The four other spine verticals (Roofing, HVAC, Plumbing, Electrical) and channels beyond Servpro and direct-restoration are deferred to post-Gate C — preserved as long-arc opportunity, not present-tense scope.

What SMAI refuses to become is part of the product contract, not branding language. We will not build a campaigns UI in MVP and early v1. We will not allow unapproved customer-facing send. We will not author content at runtime; campaign content is templated and pre-approved offline. We will not expose a conversational chat interface to agents. We will not allow in-flight rewriting or cadence changes after the playbook is approved. We will not commit to bespoke per-customer agents or per-customer code paths. Packaging, pricing, and channels must reinforce these boundaries.

## 3) The trust contract and why it remains the wedge

The wedge is a hard separation between intelligence and execution. SMAI authors campaign templates offline as inspectable, versioned playbooks. The operator approves the playbook before any agent runs against it. Deterministic services execute the approved playbook at runtime, substituting job-specific data into operator-approved content. Stop conditions behave like an operating system, not a marketing tool.

Four elements define the contract:

- **Approval-first, with zero unapproved customer-facing send.** Every customer-facing message resolves to operator-approved content. In Buc-ee's MVP, approval happens per campaign on each job. In Early v2, approval happens per (job type, scenario) pair the first time that pair is used; subsequent jobs of the same pair execute the approved playbook automatically. The unit of approval evolves; operator authority over what gets sent to their customer does not.
- **Deterministic execution after approval in MVP and early v1.** No AI rewriting at runtime. No cadence changes mid-campaign.
- **Immediate stop conditions on reply, bounce, or operator pause.** First-class interrupts. The operator can pause a single job, a scenario, or an entire agent at any time.
- **Append-only proof tied to the job record so every claim is traceable.**

The trust contract is also what makes SMAI different from DIY automation, what keeps attribution non-political, and what determines whether any later platform expansion is legitimate. If a later workflow step or a new agent cannot preserve the same approval-first, deterministic, append-only discipline where required, it does not belong in the product yet.

CC-01 Platform Spine v1.5 governs the full doctrine, including the doctrine atoms (DA-01 through DA-35) that govern over the body of any canonical document.

## 4) Who we serve now and who we will serve later

For the next 6 to 12 months, the primary ICP is Servpro franchise operators sold through the RestorAI motion. Owners, COOs, GMs, and operations leaders at Servpro franchise ownership groups, typically multi-location, with shared operating standards (DASH job records, IICRC training, brand voice). The parallel ICP is non-Servpro restoration operators (independent restoration companies and operators in other restoration franchise networks) buying the same agent product on the same architecture, potentially with different SOPs configured at the tenant level.

The 5-vertical spine ICP (Restoration, Roofing, HVAC, Plumbing, Electrical) remains the long-arc ICP and is the basis for the long-arc 5-vertical SAM. Active GTM does not pursue the four non-restoration verticals in this window. They are not abandoned; they are sequenced behind restoration proof.

Beyond the spine, SMAI's broader universe includes bid-based construction contractors, specialty project trades, commercial services sold by bid, professional services with proposal-driven closes, and B2B quoting workflows. These sit in the TAM universe but are not counted in near-term SAM or SOM until the promotion rule is met: proposal parsing reliability, context pack sufficiency, stop-condition correctness, and tenant-level SOP configuration proven without bespoke per-customer agent code.

## 5) Market sizing: two denominators, one discipline

CC-03 v1.1 establishes a two-denominator structure: a near-term restoration-only denominator that governs active GTM, and a long-arc 5-vertical spine SAM that governs the platform thesis.

**Near-term active denominator (restoration only):**

- Servpro franchise locations (~1,800-2,000 in the U.S.)
- Non-Servpro restoration operators (independents plus operators in other restoration franchise networks)
- Restoration Employer SAM Core: ~5,000-15,000 establishments
- Restoration Wedge-Ready Nonemployer Ring: 2,638 / 6,442 / 12,795
- Restoration SAM Total: ~7,600 / ~16,400 / ~27,800

**Long-arc denominator (5-vertical spine, preserved):**

- Employer SAM Core: 43,385 / 88,646 / 153,921
- Wedge-Ready Nonemployer Ring: 14,656 / 33,335 / 67,059
- Total Combined SAM: 58,041 / 121,981 / 220,980

The near-term restoration-only denominator is what governs RestorAI's commercial trajectory and the strategic acquirer narrative (CC-08 RestorAI Brief). The long-arc 5-vertical denominator is what SMAI continues with after a RestorAI exit, and what governs the platform thesis when non-restoration verticals are activated post-Gate C.

The data backbone (CBP 2023 employer establishments, NES 2023 nonemployer counts where available, QCEW cross-check) is preserved from CC-03 v1.0. v1.1 narrows active scope, not analytical foundation.

## 6) The offer architecture: leased agents, team pricing, the Activated Plan as proof

We package and price SMAI as leased AI employees organized into three ratcheted teams. The customer is not buying email automation or seats. They are buying staffed back-office functions.

**Three customer-facing tiers (cumulative purchase required):**

- Tier 1: Revenue Recovery — $2,000/mo/location (4 roles)
- Tier 2: Front Office — $3,825/mo/location (8 roles, requires Tier 1)
- Tier 3: Full Back Office — $6,950/mo/location (14 roles, requires Tier 1+2)

**Field tool add-ons** (orthogonal to tier when each ships): Voice Job Intake at $800/mo/location, Estimate Optimization Engine at $1,000/mo/location.

**Bridge offering during build-out** (Buc-ee's window only, retires when Sales & Revenue Recovery Team ships): Conversion Coordinator standalone at $500/mo/location.

**Founding Operator pricing** (RestorAI Founding Operator round only): 35% lifetime-locked discount off standard tier pricing.

The deck headline anchors the value proposition: a fully-loaded human equivalent across all 14 roles costs $787,050 per location per year. RestorAI Tier 3 (Full Back Office) is $83,400 per location per year. Implied savings: $703,650 per location per year. The substitute stack is anchored against human-cost displacement, not against substitute-software cost.

The Activated Plan is preserved as the internal billing-equivalent throughput unit (the cost-to-serve anchor and the proof anchor) but is no longer the customer-facing billing unit. CC-04 v2.0 governs the full pricing card, the cumulative team-purchase rule, the Founding Operator discount, and the cost-to-serve model.

The pilot offer remains 60 days at $250 per month per location for the Conversion Coordinator bridge offering, with up to 120 Activated Plans per month per location, no overages during the pilot, and conversion at the end of 60 days based on success criteria and Activated Plan throughput. We do not promise booking outcomes. We measure reply capture and time to first reply versus baseline, and we use the proof spine to keep the conversation grounded.

## 7) The operating model: managed without becoming a services company

Managed is not an excuse for bespoke work. Managed means governed template authoring (offline, by SMAI, governed by SPEC-12), tenant configuration in the admin portal (governed by PRD-10), deliverability monitoring, stop monitoring, triage for delivery failures and edge cases inside the defined workflow, and an ops review cadence that reduces interrupts and stabilizes throughput. The operator product surface remains tight: Jobs, Needs Attention, Analytics. Template authoring, tenant configuration, agent activation, and OBO operations live in the SMAI admin portal — a separate surface that operators do not see.

We keep margin and repeatability by refusing services creep: no custom workflows, no campaign building, no copywriting outside governed templates, no custom integrations beyond Gmail OAuth in MVP and early v1, and no per-tenant bespoke agent code paths.

Operationally, the binding constraint is not onboarding minutes. The binding constraints are correctness under load, stop-condition integrity, and weekly managed time per location. The pricing memo (CC-04 v2.0 §5) models steady-state weekly time per Tier 1 location at 1.0 to 2.0 hours, with a clear capacity model and explicit failure modes that would break margin. As Tier 2 and Tier 3 ship, managed time per location scales proportionally; the team-tier pricing structure absorbs that scaling, not per-Activated-Plan overages charged to the customer.

## 8) Go-to-market strategy: founder-led, Bryan-led, no sales-heavy company

We will not build a sales-heavy company. The first motion is founder-led plus Bryan-Stone-led for the Servpro channel. CC-05 v2.0 governs the GTM plan; CC-08 RestorAI Brief governs the Stone Family Office Design Partnership.

Direct founder-led selling for non-Servpro restoration is the parallel Proof Factory motion. Bryan Stone's franchise-network-led motion for Servpro is the primary motion. Together they harden stop conditions, validator preflight, the proof spine, and the operating cadence under real proposal load. They also produce the proof artifacts that make every other motion possible.

The sales motion is intentionally short and operational: qualify against the 10 disqualifiers, walk the deck and Proof Pack, run a tightly scoped pilot at $250/mo/loc for 60 days on the Conversion Coordinator bridge offering, convert based on success criteria and Activated Plan throughput. For Servpro Founding Operators, the SAFE signature and pilot agreement run in parallel; the Founding Operator becomes both an investor and a paying customer at lifetime-locked Founding Operator pricing.

## 9) Channel strategy and sequencing

For the next 6 to 12 months:

- **Channel A (Servpro / RestorAI):** Primary motion. Bryan Stone-led with founder support. Founding Operator round mechanics (CC-08) overlay this channel.
- **Channel B (Direct non-Servpro restoration):** Parallel motion. Founder-led. Validates same-product-different-SOPs assumption and preserves restoration optionality outside the Servpro context.
- **Channel C (Restoration consolidators):** Prepare now, activate later. Belfor, Cotton, ServiceMaster Restore corporate, PuroClean corporate. Pursuit gated until Gate A and Gate C are met and at least 10 paid restoration locations show zero stop-condition failures.
- **Channel D (Deferred):** MSPs, franchisor-outside-Servpro, marketplaces, non-restoration spine verticals. Not active in this window.

The first version of this memo (v1.0) listed MSPs as a near-term referral channel. v2.0 defers MSPs entirely for the restoration window. Reason: MSP recruitment and enablement consume founder time, and the Servpro/RestorAI motion is denser, faster, and produces a strategic acquirer narrative that MSP referrals do not. MSPs may re-enter as a channel post-Gate C if non-restoration verticals are activated.

The original v1.0 channel framing of "franchisors as upside only" is reframed in v2.0: the Servpro franchise channel is now the primary motion, not upside. This is the core strategic shift between v1.0 and v2.0.

## 10) RestorAI: subsidiary structure, exit window, and multi-vertical preservation

CC-08 RestorAI Brief is the canonical document for RestorAI structure. Brief summary for strategic narrative purposes:

RestorAI is a Delaware C-corp wholly-controlled subsidiary of ServiceMark AI. SMAI holds 80% pre-SAFE equity. The Stone Family Office (Jeff and Bryan Stone) holds 5% each direct, with 4-year/1-year-cliff vesting. A 10% RestorAI option pool is reserved. RestorAI operates under an arm's-length perpetual license from SMAI for the restoration vertical and the Servpro franchise channel and adjacent restoration operators.

The Founding Operator round is $1M total across 16-18 Founding Operators, structured as three SAFE classes (Class A "Founding Partner" at $100K/$10M cap, Class B "Founding Operator" at $75K/$11M cap, Class C "Founding Member" at $25K/$12M cap), all with 20% discount. Founding Operators receive 35% lifetime-locked subscription discount on whichever tier they buy.

The exit window framing (CC-08 §6 and deck Slide 14) is "we choose if or when we sell" — one continuous timeline with two visible exit points. The acceleration scenario (~Y1.5 at $5M ARR, ~$175M strategic exit) and the planning case (Y3 at $25-32M ARR, $760-960M strategic exit) are both within the window. Series A is a bridge available if no strategic move by Year 2, not the primary plan.

The structural commitment that matters for the company-level strategic narrative: **a RestorAI exit sells the restoration license and the restoration-vertical entity. SMAI retains all platform IP and continues independently in non-restoration verticals.** Founder economics flow through SMAI's ownership of RestorAI, not through direct RestorAI grants. A successful RestorAI exit returns capital to founders without ending the SMAI platform.

This is the disciplined version of the multi-vertical thesis. Restoration earns an outsized exit on a compressed timeline; SMAI retains the long-arc 5-vertical opportunity. The two-denominator structure of CC-03 v1.1 is the market-sizing companion to this commercial structure.

## 11) Proof, gates, and instrumentation

Proof is not a slide. It is a one-page artifact that makes SMAI sellable, auditable, and repeatable. Proof Pack v1 is the template and ties plan governance, delivery truth, stop correctness, Needs Attention, outcomes (reply capture and time-to-first-reply), template variant resolution, and evidence pointers back to proof events.

The gates remain explicit:

- **Gate A (Trust Boundary Proven):** zero stop-condition failures across the first cohort, delivery truth coverage at or above 98%, plus required build of stop-condition audit and hard pause mechanisms.
- **Gate B (Value Proven):** hit 2 of 3 pilot success criteria with repeatability and standardize Proof Pack generation.
- **Gate C (Repeatability Proven):** onboarding time and weekly managed load land inside cost-to-serve bands without bespoke exceptions, plus partner enablement and enforcement readiness.

Proof gates govern channel activation. Restoration consolidator pursuit is gated until Gate A and at least 10 paid restoration locations show zero stop-condition failures. Servpro corporate or Blackstone outreach is gated until Gate C and multi-location proof across at least 5 Servpro Founding Operators. Non-restoration vertical activation is gated until Gate C in restoration plus a strategic decision to expand verticals.

## 12) Near-term unlocks the architecture already supports

The MVP is intentionally narrow, but the architecture is not fragile. Once a team trusts follow-through, they immediately want the same discipline in adjacent moments: fewer handoffs, fewer missed replies, fewer places where a job can drift into ambiguity. The near-term unlocks are credible because they extend what already exists: job as the unit of truth, an operator-approved playbook as a versioned durable artifact, deterministic execution, explicit interrupts, and an append-only event record.

Each new agent on the platform is a phase-owning unit that extends the spine without violating it. The Sales & Revenue Recovery Team (Review/Reputation Manager, Collections Coordinator, Referral/Partnership Coordinator, plus the live Conversion Coordinator) ships in the next 90 days to 12 months. The Intake & Customer Communication Team ships next. The Operations & Back Office Functions Team follows in the 6-12 month window. Field tool add-ons (Voice Job Intake, Estimate Optimization Engine) attach orthogonally to any tier when each ships.

The agent platform architecture document (forthcoming) will govern how agents share state, surfaces, and governance without producing a Frankenstein product. The agent-as-staff frame anchors the operator's mental model: the operator hires the agent (subscribes to the team), trains it (approves the playbook), watches it work (Jobs, Needs Attention, Analytics), and can pause it at any time. There is no conversational chat interface to agents. Operator interactions with agents are structured.

None of these unlocks change the trust contract or introduce autonomous outbound behavior.

## 13) Near-term execution plan and decisions required

The next 8 to 12 weeks are about turning assumptions into facts and hardening repeatability. The immediate decisions:

- Founding Operator round target close date (working target: 6 months Base case; calibrated to July Servpro convention)
- Bryan Stone compensation structure (equity-only, equity + commission, equity + retainer, or full-time conversion path) — blocks Channel A scaling
- License fee structure between SMAI and RestorAI (working frame: percentage of RestorAI ARR; pending counsel)
- Cumulative team-purchase rule durability (track rejection rate over first 6 months)
- First Founding Operator commitment (Class A target identification and outreach sequencing)
- v1 campaign template authoring for the 5 restoration sub-types covering 17 scenarios authorized by Jeff Stone (governed by SPEC-12)
- Buc-ee's MVP go-live (Conversion Coordinator at USDS)

The specific unknowns we must validate are measurable: eligible job percent, approval friction during the per-campaign-gate window, stop-condition correctness, template variant resolution accuracy, Founding Operator commitment rate, weekly managed time per location, same-product-different-SOPs assumption durability across Servpro and non-Servpro restoration tenants. Many remain medium or low confidence today. The plan is designed to tighten them quickly with pilot telemetry and proof artifacts, not to argue about them.

## Closing

SMAI wins by building the AI staffing layer for restoration, then earning the right to extend across the broader 5-vertical spine. The wedge is a governed trust contract: operator-approved playbooks authored offline, deterministic execution at runtime, first-class interrupts, and append-only proof tied to the job. The active near-term scope is restoration only, sold primarily through the Servpro franchise channel via RestorAI. The 5-vertical long-arc denominator is preserved. RestorAI is structured for a strategic exit on a compressed timeline; SMAI retains platform IP and the long-arc opportunity.

The market is large enough to build a serious business. The advantage comes from doing the hard thing early: staying correct under load, proving it with telemetry, narrowing scope to earn the right to widen it, and scaling only when proof and repeatability are real.

---

## Document Control

- **Document name:** Canonical Strategy Memo
- **Document ID:** CC-02
- **Version:** v2.0
- **Status:** Canonical
- **Supersedes:** v1.0 (2026-02-22)
- **Owner:** ServiceMark AI leadership team
- **Last updated:** 2026-04-29
- **Change summary:** Coherence pass over CP-01 v1.1, CC-01 v1.5, CC-03 v1.1, CC-04 v2.0, CC-05 v2.0, and CC-08 v1.0. AI staffing positioning landed throughout. Three-tier ratcheted team-based pricing structure integrated. Restoration-first GTM scope and two-denominator market structure landed. RestorAI subsidiary structure summarized with pointer to CC-08. Multi-vertical preservation thesis articulated. Approval shape direction (per-campaign in Buc-ee's, per-pair in Early v2) integrated with operator-authority-remains-absolute framing. Agent-as-staff frame integrated. Channel strategy reframed (Servpro/RestorAI primary, direct non-Servpro restoration parallel, all other channels deferred or gated). Decisions-required list refreshed against Phase 3 canon refresh.
- **Triggers:** Per CP-02 §12, this CC-02 update propagates to investor-facing strategic narratives and any partner-style strategic explanation derived from this memo. CC-02 is the strategic narrative; it restates positions established in the more specific canonical documents. If a contradiction is detected between this memo and CC-01, CC-03, CC-04, CC-05, or CC-08, the more specific document governs and this memo is updated to match.
