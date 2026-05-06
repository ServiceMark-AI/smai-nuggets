# SMAI Canonical Index v1.1

**Status:** Canonical
**Supersedes:** v1.0 (2026-03-16)
**Last updated:** 2026-04-29

---

## 1. Purpose

This document defines the source-of-truth hierarchy for ServiceMark AI. It exists to prevent source-of-truth confusion, support contradiction handling, and make impact propagation explicit when a canonical document changes.

The Canonical Index is a control-plane document, not a narrative memo. It tells the system and the team which documents are authoritative, what each one governs, what depends on it, and what must be reviewed when it changes. This is a required shell document in the SMAI Product Operating System.

## 2. Quick Reference Summary

**CI-01 — ServiceMark AI Platform Spine v1.5** (2026-04-29)
Status: Canonical
Domain owned: Product doctrine and platform truth
Primary role: Highest-order authority on what SMAI is, what it is not, and how the system must behave

**CI-02 — SMAI Context Pack v1.1** (2026-04-29)
Status: Canonical
Domain owned: Current-state operating context
Primary role: Concise source of truth for what is true now across wedge, ICP, MVP slice, priorities, and active tensions

**CI-03 — Canonical Strategy Memo v2.0** (2026-04-29 — pending Phase 3 ratification)
Status: Canonical
Domain owned: Strategic narrative
Primary role: Partner-style explanation of the business, sequence, and strategic logic

**CI-04 — Pricing & Packaging Brief v2.0** (2026-04-29 — pending Phase 3 ratification)
Status: Canonical
Domain owned: Commercial model
Primary role: Source of truth for packaging, pricing posture, pilot terms, team-based pricing structure, and pricing language

**CI-05 — Market & Sizing Brief v1.1** (2026-04-29 — pending Phase 3 ratification)
Status: Canonical
Domain owned: Market sizing and denominator logic
Primary role: Source of truth for TAM/SAM/SOM framing and denominator discipline, including restoration-first near-term denominator and 5-vertical long-arc denominator

**CI-06 — GTM Plan & Channel Strategy v2.0** (2026-04-29 — pending Phase 3 ratification)
Status: Canonical
Domain owned: Go-to-market and channels
Primary role: Source of truth for near-term GTM sequencing (Servpro/RestorAI primary, direct non-Servpro restoration parallel), channel rules, ICP operationalization, and sales motion

**CI-07 — Buc-ee's MVP Definition v1.1** (2026-04-29)
Status: Canonical
Domain owned: Near-term MVP scope and milestone sequence
Primary role: Source of truth for current MVP boundaries, out-of-scope rules, and milestone progression from Buc-ee's to repeatable MVP

**CI-08 — RestorAI Brief v1.0** (2026-04-29) — *new*
Status: Canonical
Domain owned: RestorAI subsidiary commercial structure and Servpro channel motion
Primary role: Source of truth for RestorAI entity structure, capitalization (Founding Operator round, SAFE classes), Stone Family Office Design Partnership, exit thesis and timing optionality, sales motion, and SMAI/RestorAI relationship

**CI-09 — SMAI Product Operating System: Implementation Plan v1**
Status: Canonical
Domain owned: Product OS build method
Primary role: Source of truth for how the Product Operating System should be structured, built, and maintained

*Note on numbering:* CI-08 is the new RestorAI Brief; the prior CI-08 (Product OS Implementation Plan) is renumbered to CI-09. The renumbering preserves the original document; only the index ID changes. Decision Ledger entry DL-XXX records the renumbering.

## 3. Canonical Document Rules

A document may be in one of four states:

- **Canonical.** Authoritative current-state source of truth for a defined domain. Downstream documents must align to it.
- **Supporting.** Useful, current, and referenceable, but not the top authority for the domain it discusses.
- **Working.** In-progress material, notes, briefs, or drafts that may inform decisions but do not set truth until promoted.
- **Archived / superseded.** No longer authoritative. May be retained for history, rationale, or comparison only.

## 4. Core Hierarchy Rule

If two documents appear to conflict, resolve in this order:

1. The most recent canonical document that directly governs the topic
2. The more domain-specific canonical document
3. The broader canonical narrative document
4. Supporting documents
5. Working documents or notes

The Canonical Index does not replace judgment, but it does define the default precedence path.

## 5. Current Canonical Set

### A. Platform / Product Doctrine

**CI-01 — ServiceMark AI Platform Spine v1.5** (2026-04-29)
Status: Canonical
Role: Highest-order product doctrine and platform truth
Governs: Central thesis, product identity, trust contract (including the "approval-first per content pattern" doctrinal direction), system primitives, execution boundaries, UX boundaries, doctrine atoms (DA-01 through DA-35), near-term unlock logic, platform scaling logic, agent-as-staff frame, restoration-first sequencing
Why canonical: This is the deepest statement of what SMAI is, what it refuses to be, how the system works, and what architectural boundaries cannot be violated. It is the top authority on product doctrine.

### B. Operating Snapshot / Current-State Control Context

**CI-02 — SMAI Context Pack v1.1** (2026-04-29)
Status: Canonical
Role: Concise current-state operating context for Cowork and OS workflows
Governs: Current wedge truth (proposal follow-through agent for restoration, leased per location), current ICP (Servpro franchise operators primary, non-Servpro restoration parallel), current MVP slice, commercial stance (team-based pricing model with cumulative team-purchase rule), channel sequence, proof gates, current build priorities, tool role model, open tensions
Why canonical: This is the compact "what is true now" document for daily operating use. It is authoritative for current-state interpretation unless overridden by a more specific canonical domain document.

### C. Company / Strategy Narrative

**CI-03 — Canonical Strategy Memo v2.0** (2026-04-29)
Status: Canonical
Role: Partner-style strategic narrative
Governs: Strategy framing, why-now logic, who we serve now versus later, operating model posture, channel sequencing, proof-gate narrative, near-term execution priorities
Why canonical: This is the top narrative memo for strategic explanation, but where it conflicts with newer domain-specific canonical documents, those newer documents govern.

### D. Commercial / Pricing

**CI-04 — Pricing & Packaging Brief v2.0** (2026-04-29)
Status: Canonical
Role: Top authority for commercial packaging and pricing posture
Governs: Team-based pricing structure (three ratcheted tiers at $2,000 / $3,825 / $6,950 per location per month), cumulative team-purchase rule, Conversion Coordinator bridge offering, Founding Operator pricing (35% lifetime discount), field tool add-on pricing, Activated Plan definition, pilot terms, internal rate card vs external tiers, managed scope rules, pricing risks
Why canonical: This is the specific authority for how SMAI charges and what pricing language is allowed. It overrides broader narrative documents on pricing details.

### E. Market / Denominator Logic

**CI-05 — Market & Sizing Brief v1.1** (2026-04-29)
Status: Canonical
Role: Top authority for TAM/SAM/SOM framing and denominator discipline
Governs: Market definition, spine verticals (preserved as long-arc denominator), restoration-first near-term denominator (Servpro franchise locations + non-Servpro restoration), nonemployer ring logic, SOM assumptions, validation requirements
Why canonical: This is the authority for investor-safe and operator-safe market sizing logic and denominator discipline.

### F. GTM / Channels

**CI-06 — GTM Plan & Channel Strategy v2.0** (2026-04-29)
Status: Canonical
Role: Top authority for near-term go-to-market sequencing and channel rules
Governs: ICP operationalization (Servpro franchise operators primary, non-Servpro restoration parallel), disqualifiers, channel commitments (Servpro/RestorAI primary motion via Bryan Stone, direct non-Servpro restoration parallel motion, all other channels deferred), sales motion, Founding Operator round dynamics, pilot-to-rollout playbook, GTM risks, proof artifacts, gating milestones
Why canonical: This is the specific authority for how SMAI goes to market in the next 6 to 12 months. The RestorAI motion is governed jointly with CI-08.

### G. Near-Term Product Slice / Milestone Sequence

**CI-07 — Buc-ee's MVP Definition v1.1** (2026-04-29)
Status: Canonical
Role: Top authority for near-term MVP sequencing and scope boundaries
Governs: Buc-ee's scope, explicit out-of-scope list, current demo truth, milestone ladder from Buc-ee's to MVP to California
Why canonical: This is the most specific authority for current near-term product-slice truth and sequencing discipline. Note: Buc-ee's ships with the per-campaign approval gate intact; first-time-per-pair approval shape is an Early v2 milestone, not a Buc-ee's deliverable. v1.1 updates capture analytics in-scope, templated architecture, and v1 template authoring (5 sub-types, 17 scenarios) as success criterion.

### H. RestorAI Subsidiary

**CI-08 — RestorAI Brief v1.0** (2026-04-29) — *new*
Status: Canonical
Role: Top authority for RestorAI entity structure and Servpro channel commercial motion
Governs: RestorAI subsidiary structure (Delaware C-corp, SMAI 80%, Stone Family Office 10% combined, RestorAI option pool 10%), IP licensing between SMAI and RestorAI, Founding Operator round structure (three SAFE classes totaling $1M, 16-18 seats), Stone Family Office Design Partnership terms (Jeff and Bryan vesting, roles, compensation), exit window framing (acceleration scenario ~Y1.5 + planning case Y3 + Series A bridge contingency), sales motion (Bryan Stone-led with founder support), competitive landscape responses, multi-vertical platform preservation
Why canonical: RestorAI is the entity through which the primary near-term GTM motion runs. CI-08 governs the structural and commercial decisions specific to that entity. It is downstream of CI-01 (doctrine), CI-02 (current-state truth), CI-04 (pricing), and CI-06 (GTM); it is upstream of partner agreements, SAFE drafting, and Stone Family Office operating agreements.

### I. Product Operating System / Build Method

**CI-09 — SMAI Product Operating System: Implementation Plan v1**
Status: Canonical
Role: Top authority for how the Product Operating System itself should be built and used
Governs: Shell documents, build order, core skills, recurring loops, automation-ready design principles, role model for Claude, ChatGPT, and Perplexity, later-phase intelligence layers
Why canonical: This governs the Product Operating System build process, not SMAI market or product truth itself. It is canonical for internal operating method.

## 6. Dependency Map

### Foundational Doctrine Layer

- CI-01 Platform Spine
- CI-02 Context Pack

These should be interpreted first for any high-stakes artifact.

### Domain-Specific Canonical Layer

- CI-04 Pricing & Packaging Brief
- CI-05 Market & Sizing Brief
- CI-06 GTM Plan & Channel Strategy
- CI-07 Buc-ee's MVP Definition
- CI-08 RestorAI Brief
- CI-03 Canonical Strategy Memo

These derive from, and must remain consistent with, the Platform Spine and Context Pack. CI-08 RestorAI Brief sits in this layer because RestorAI commercial structure is a domain-specific canonical commitment, not a narrative interpretation.

### OS Control-Plane Layer

- CI-09 Product Operating System: Implementation Plan
- Canonical Index (this document)
- Decision Ledger
- Working Notes
- Current Priorities
- Open Questions
- Change Log

These govern how the system operates, reviews drift, and routes updates.

## 7. Override Logic by Topic

**Product identity / what SMAI is**
Primary: CI-01 Platform Spine
Secondary: CI-02 Context Pack
Tertiary: CI-03 Canonical Strategy Memo

**What SMAI refuses to be / guardrails**
Primary: CI-01 Platform Spine
Secondary: CI-02 Context Pack
Tertiary: CI-03 Canonical Strategy Memo

**Current wedge / current product truth**
Primary: CI-02 Context Pack
Secondary: CI-07 Buc-ee's MVP Definition
Tertiary: CI-01 Platform Spine

**Near-term MVP scope / current implementation specifics**
Primary: CI-07 Buc-ee's MVP Definition
Secondary: CI-02 Context Pack
Tertiary: CI-01 Platform Spine

**Pricing / packaging / pilot terms / Activated Plan definition / team structure / Founding Operator pricing**
Primary: CI-04 Pricing & Packaging Brief
Secondary: CI-08 RestorAI Brief (for RestorAI-specific pricing details such as Founding Operator discount mechanics)
Tertiary: CI-02 Context Pack

**ICP / channel sequence / disqualifiers / sales motion**
Primary: CI-06 GTM Plan & Channel Strategy
Secondary: CI-08 RestorAI Brief (for Servpro-specific channel mechanics)
Tertiary: CI-02 Context Pack

**RestorAI entity structure / capitalization / Stone Family Office terms / exit thesis**
Primary: CI-08 RestorAI Brief
Secondary: CI-04 Pricing & Packaging Brief (for tier pricing referenced by CI-08)
Tertiary: CI-06 GTM Plan & Channel Strategy

**TAM / SAM / SOM / denominator logic**
Primary: CI-05 Market & Sizing Brief
Secondary: CI-03 Canonical Strategy Memo
Tertiary: CI-02 Context Pack

**Trust contract / approval shape / templated architecture / agent-as-staff frame**
Primary: CI-01 Platform Spine (especially DA-12, DA-33, DA-34)
Secondary: CI-02 Context Pack
Tertiary: SPEC-11 (template architecture spec, governs implementation)

**Product OS shell docs / skills / loops / build order**
Primary: CI-09 Product Operating System: Implementation Plan
Secondary: CI-02 Context Pack

## 8. Current Supporting Set

These are current and useful, but not top authority over a major domain unless explicitly promoted later:

- Proof Pack templates or artifact schemas not yet separately locked as standalone canonical documents
- PRDs (PRD-01 through PRD-10) — implementation specs, governed by CI-01 and CI-07 doctrine
- SPECs (SPEC-01 through SPEC-12) — implementation specs, governed by CI-01 doctrine
- RestorAI Pro Forma v2.10 — financial model; supports CI-08 but is not itself canonical
- RestorAI deck v3 (https://restorai-pitch.lovable.app) — investor artifact derived from CI-08; supports CI-08 but is not itself canonical
- Build briefs
- Implementation summaries
- Meeting notes and transcripts
- Workshop notes
- Architecture notes below the spine level
- Partner-specific operating documents
- Customer-specific pilot documents
- Research inputs used to produce the canonical documents

Some of these may later deserve promotion to canonical if they become reusable operating assets.

## 9. Current Working-State Documents

These should remain non-canonical unless promoted:

- Decision Ledger
- Working Notes
- Current Priorities
- Open Questions
- Change Log
- Draft governed build briefs
- Exploratory notes
- Idea dumps
- Partner call synthesis

These are essential operating documents, but they do not set truth on their own.

## 10. Current Archived / Superseded Set

- CC-01 Platform Spine v1.4 (2026-03-16) — superseded by v1.5 (2026-04-29)
- CP-01 Context Pack v1.0 (2026-03-16) — superseded by v1.1 (2026-04-29)
- CC-02 Canonical Strategy Memo v1.0 (2026-02-22) — superseded by v2.0 (2026-04-29)
- CC-03 Market & Sizing Brief v1.0 (2026-02-17) — superseded by v1.1 (2026-04-29)
- CC-04 Pricing & Packaging Brief v1.0 (2026-02-19) — superseded by v2.0 (2026-04-29)
- CC-05 GTM Plan & Channel Strategy v1.0 (2026-02-20) — superseded by v2.0 (2026-04-29)
- CC-06 Buc-ee's MVP Definition v1.0 (2026-02-22) — superseded by v1.1 (2026-04-29)
- SPEC-11 v1.0 (runtime AI generation architecture) — superseded by SPEC-11 v2.0 (templated architecture)
- Lovable-era specs 1-17 — archived, superseded by current PRD/SPEC set

Archive rule:

- Retain for rationale and history
- Never cite as current truth
- Reference only to explain evolution or decisions

## 11. Watched Documents for Integrity Review

The watched set:

- CI-01 Platform Spine
- CI-02 Context Pack
- CI-03 Canonical Strategy Memo
- CI-04 Pricing & Packaging Brief
- CI-05 Market & Sizing Brief
- CI-06 GTM Plan & Channel Strategy
- CI-07 Buc-ee's MVP Definition
- CI-08 RestorAI Brief
- Canonical Index

These are the documents whose changes should trigger contradiction checks and downstream review proposals.

## 12. Impact Propagation Rules

### If CI-01 Platform Spine changes

Review:

- CI-02 Context Pack
- CI-03 Canonical Strategy Memo
- CI-04 Pricing & Packaging Brief
- CI-05 Market & Sizing Brief
- CI-06 GTM Plan & Channel Strategy
- CI-07 Buc-ee's MVP Definition
- CI-08 RestorAI Brief
- Canonical Index

Reason: The Platform Spine governs doctrine, system boundaries, and what SMAI is.

### If CI-02 Context Pack changes

Review:

- Canonical Index
- Current Priorities
- Open Questions
- Relevant build briefs
- Any active strategic memo or product artifact in flight

Reason: It is the current-state operating snapshot.

### If CI-04 Pricing & Packaging Brief changes

Review:

- CI-02 Context Pack commercial stance section
- CI-03 Canonical Strategy Memo offer architecture
- CI-06 GTM Plan & Channel Strategy pilot language
- CI-08 RestorAI Brief pricing and Founding Operator discount sections
- RestorAI Pro Forma model (downstream)
- RestorAI deck pricing slides (downstream)
- Customer-facing pricing artifacts

### If CI-06 GTM Plan & Channel Strategy changes

Review:

- CI-02 Context Pack channel sequencing
- CI-03 Canonical Strategy Memo channel strategy
- CI-08 RestorAI Brief sales motion section
- Sales one-pagers and pilot language
- Current Priorities

### If CI-05 Market & Sizing Brief changes

Review:

- CI-03 Canonical Strategy Memo market sizing section
- CI-08 RestorAI Brief (for restoration-specific denominator)
- Investor-facing materials including RestorAI deck Slide 12
- Any financial model assumptions document tied to denominator logic

### If CI-07 Buc-ee's MVP Definition changes

Review:

- CI-02 Context Pack current MVP slice
- Active governed build briefs
- Current Priorities
- Product demo narratives

### If CI-08 RestorAI Brief changes

Review:

- CI-02 Context Pack §7 commercial stance and §8 channel sequencing
- CI-04 Pricing & Packaging Brief Founding Operator section
- CI-06 GTM Plan & Channel Strategy Servpro channel section
- RestorAI Pro Forma model
- RestorAI deck (especially Slides 1, 11, 12, 14, 16, 17, 19)
- SAFE document templates
- Stone Family Office operating agreement (when drafted)

### If CI-09 Product Operating System: Implementation Plan changes

Review:

- Canonical Index
- Shell document templates
- Orchestrator instructions
- Recurring review prompts

---

## Document Control

- **Document name:** SMAI Canonical Index
- **Document ID:** CP-02
- **Version:** v1.1
- **Status:** Canonical
- **Supersedes:** v1.0 (2026-03-16)
- **Owner:** ServiceMark AI leadership team
- **Last updated:** 2026-04-29
- **Change summary:** Added CI-08 RestorAI Brief as new canonical document; renumbered prior CI-08 (Product OS Implementation Plan) to CI-09; updated all version references to current canonical set (CC-01 v1.5, CP-01 v1.1, CC-02 v2.0, CC-03 v1.1, CC-04 v2.0, CC-05 v2.0, CC-06 v1.1); added override logic and propagation rules for CI-08; added templated architecture / approval shape / agent-as-staff override topic; expanded archived set to record superseded versions including CC-06 v1.0
- **Next review trigger:** Any new canonical document added to the set; any version bump to a watched document; any change in the override logic that affects how contradictions are resolved
