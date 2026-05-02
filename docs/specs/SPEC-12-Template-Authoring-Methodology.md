# SPEC-12: Template Authoring Methodology

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Template Authoring Methodology |
| Spec ID | SPEC-12 |
| Version | 2.0.1 |
| Status | Ready for use |
| Date | 2026-04-27 |
| Product owner | Kyle |
| Authoring leads | Kyle, Ethan |
| Domain expert | Jeff Stone (pilot customer; Servpro VP, NE Dallas / Boise / Reno) |
| Source | Conversation 2026-04-25/26 (Kyle / Claude) on pilot bar and methodology rebase; Jeff feedback round 2026-04-25/26 (v1 authoring scope reduction); CC-06 Buc-ee's MVP Definition v1.0; SPEC-12 v1.0 (superseded); SPEC-11 v2.0.1; SPEC-03 v1.3.2; CC-01 Platform Spine v1.4 |
| Related docs | SPEC-11 v2.0.1 (Campaign Template Architecture); SPEC-03 v1.3.2 (Job Type and Scenario taxonomy); PRD-10 v1.3 (SMAI Admin Portal); CC-01 ServiceMark AI Platform Spine v1.4; CC-06 Buc-ee's MVP Definition v1.0 |

**Revision note (v2.0):** Full replacement of SPEC-12 v1.0. The v1.0 methodology was over-engineered for the actual quality bar required by the Buc-ee's pilot and the SMAI wedge thesis. v2.0 rebases the methodology around the operational reality: the wedge is automated follow-through that runs reliably; content quality is a supporting feature that improves through live-data iteration rather than through pre-launch perfection. The v2.0 methodology produces variants that read as researched and scenario-specific, ship in days not weeks, and improve on a defined post-launch iteration cadence. SPEC-12 v1.0 is superseded and archived; references in other documents to SPEC-12 v1.0 should be updated to v2.0.

Material differences from v1.0:

- Pipeline reduced from eight stages to five
- Rubric reduced from ten criteria to five, structured as a self-check rather than a binary pass-fail grid
- Jeff interview pattern replaced with asynchronous brief review plus a single 30-minute correction call
- Constitutional rewrite loop, persona reaction stage, and variety sampling stage removed (none were load-bearing for the actual bar)
- Iteration commitment added as a load-bearing section with concrete trigger conditions and review cadence
- Master authoring prompt referenced as the primary execution artifact, not a per-stage prompt chain

**Revision note (v2.0.1):** Three surgical edits, no methodology changes. All grounded in the Jeff feedback round 2026-04-25/26 and the SPEC-03 v1.3.2 patch.

1. **§11.1 effort estimate variant count update.** v2.0 was scoped to author all 33 v1 master scenarios. Per Jeff's 2026-04-25/26 feedback round, v1 authoring scope is reduced to 17 variants for Jeff's tenant — the master list itself is unchanged, but per-tenant activation scope determines which variants get authored for v1. The §11.1 effort table is updated to reflect 17 variants. The math behind the estimate is otherwise unchanged.

2. **§1 plain English variant count update.** The opening section's reference to "all 33 v1 variants" is updated to "all 17 v1 variants for Jeff's tenant" with a parenthetical note that the master list itself contains 33 scenarios. This is editorial alignment with §11.1 and SPEC-03 v1.3.2 §7.2; no methodology change.

3. **§6.1 rubric criterion R6 added: Subject line discipline.** Master prompt v0.4 enforces subject line discipline at authoring time, including the engine-managed `[{job_number}]` prefix per PRD-03 v1.4.1 §7.3. SPEC-12 v2.0's §6.1 rubric did not include subject line guidance, leaving an audit gap between authoring-time enforcement and methodology-level quality gate. R6 closes that gap. The criterion is binary like the other R1-R5 checks.

4. **§4 source truth update for variant count.** "The 33 v1 (`job_type`, `scenario_key`) pairs are defined by SPEC-03 v1.3.2 §7.2" updated to acknowledge that the master list contains 33 entries but per-tenant authoring scope is governed by activation. Jeff's tenant scope is 17. The locked constraint reflects this distinction.

5. **§0 related docs version refresh.** SPEC-03 v1.3.1 → v1.3.2; SPEC-11 v2.0 → v2.0.1; PRD-10 v1.2 → v1.3.

Patch note (2026-04-27): SPEC-12 v2.0.1 reflects v1 authoring scope reduction per Jeff feedback round, plus subject line rubric closure for the master prompt v0.4 enforcement gap. No methodology change. Ref: Jeff feedback 2026-04-25/26; master prompt v0.4 audit; SPEC-03 v1.3.2 patch wave.

---

## 1. What This Is in Plain English

SPEC-11 v2.0.1 specifies an engine that resolves a campaign template at intake time and renders emails by substituting merge fields. SPEC-12 specifies the methodology that produces those templates.

The methodology is built around a clear-eyed read of what actually drives conversion lift in restoration follow-up: the existence of follow-up at all is the largest driver, and content that reads as researched and scenario-specific captures most of the remaining lift. World-class operator voice produces additional lift, but that lift is small compared to the first two and is best earned through live-data iteration rather than pre-launch authoring effort.

The v2.0 methodology has five stages. The first three stages run once per sub-type and produce shared inputs for all scenarios within that sub-type. The last two stages run once per (`job_type`, `scenario_key`) pair to produce one variant. The methodology is designed to author all 17 v1 variants for Jeff's tenant in roughly two weeks of elapsed time, with Jeff requiring 1-1.5 hours total of synchronous time across the entire authoring run. (The master scenario list contains 33 entries per SPEC-03 v1.3.2 §7.2; per-tenant activation scope determines which scenarios require authored variants. v1 authoring is scoped to Jeff's tenant activation only.)

The methodology relies on three sources of leverage: (a) pre-built sub-type briefs that Jeff reviews asynchronously and corrects in a single short call, (b) a master authoring prompt that encodes this spec and produces variants when given a brief plus Jeff's correction notes plus a scenario, (c) a human finalization pass at speaking pace before any variant ships. None of these is sufficient alone. The methodology is structured so each compensates for the others' weaknesses.

The methodology is also designed to be honest about what is hard and what isn't. Authoring restoration follow-up content that doesn't sound like generic marketing automation is moderately hard. Authoring it at scenario-level granularity is a little harder. Authoring it in a way that holds up after 90 days of live data and reveals which sub-types need deeper work is the actual hard part, and that's what the iteration loop in §10 exists for.

---

## 2. What Authors Must Not Misunderstand

1. **The bar is "researched-looking and scenario-specific," not "world-class operator voice."** v1 variants must read as if a competent professional who took the time to understand the situation wrote them. They do not have to read as if a 20-year veteran operator wrote them. The latter bar is the v2 hardening target, earned through live-data iteration.

2. **Templates are authored offline. The engine does not generate at runtime.** Per SPEC-11 v2.0.1. AI authoring work happens in this pipeline and produces template content that is committed and activated. There is no AI in the campaign engine's generation path.

3. **The master authoring prompt is the load-bearing artifact, not the rubric.** v1.0 treated the rubric as the gate. v2.0 treats the master prompt as the gate: a strong prompt produces variants that pass the rubric on first pass most of the time, and the human finalization step catches the rest. Authors who feel tempted to bolt on additional rubric checks should improve the prompt instead.

4. **Jeff is the domain expert, not the validator.** Jeff's input is primary source material that drives drafting. He reviews briefs asynchronously and corrects them in a 30-minute call. He does not approve final variants. Treating him as a final validator produces drafts that are already drifting from his operational reality and need rework.

5. **No industry jargon in customer-facing prose.** Per Jeff's 2026-04-21 guidance and SPEC-11 v2.0.1 §2 point 8. IICRC, OSHA, EPA, S500, S520, "Category 1/2/3 water," "Class A/B/C asbestos," and similar terms appear in author-facing scenario metadata only. They never appear in a rendered email body. The master prompt enforces this; the human finalizer is the backstop.

6. **Hypothesis-first authoring is enforced by the SPEC-11 v2.0.1 schema.** Per §7.1 of that spec, the `authoring_hypothesis` field on the template variant record is required. The master prompt produces a hypothesis statement as part of its output for each variant. Authors confirm or revise the hypothesis at human finalization.

7. **The iteration loop is non-negotiable.** Per §10. The v2.0 bar is calibrated to ship fast and improve on data. If the iteration loop does not run, v2.0 is the wrong methodology and SPEC-12 should revert to a v1.0-style upfront-rigor approach. Authors and product owners must commit to the §10 iteration cadence at adoption time, not after pilot launch.

8. **Master list scope and per-tenant authoring scope are distinct.** SPEC-03 v1.3.2 §10.1 establishes that scenarios in the master list have no requirement for an active template variant until they are activated for some tenant. Authoring is gated on tenant activation, not master list presence. v1 authoring is scoped to Jeff's 17 activated scenarios. The remaining 16 master list scenarios do not require authored variants until they are activated for some tenant.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
The standing methodology for producing campaign template variants that satisfy the SPEC-11 v2.0.1 contract, calibrated to the Buc-ee's pilot bar (researched-looking, scenario-specific, ship fast, improve on live data).

**What this covers:**

- The five-stage authoring pipeline from sub-type brief to activation-ready variant
- The asynchronous Jeff review pattern with a single 30-minute correction call
- The short rubric used as a self-check at the master prompt and human finalization steps
- The master authoring prompt as the primary execution artifact
- The legal review path for regulated-content scenarios
- The iteration loop with concrete triggers, cadence, and re-authoring methodology
- Authoring artifact storage and handoff
- Effort and cadence expectations for the v1 authoring run

**What this does not cover:**

- The template data model or render contract (SPEC-11 v2.0.1 owns)
- The (Job Type, Scenario) taxonomy itself (SPEC-03 v1.3.2 owns)
- The activation operation or admin portal UI (SPEC-11 v2.0.1 §11.2 and PRD-10 v1.3)
- The campaign engine or send lifecycle (PRD-03 v1.4.1)
- Specific template content for any (Job Type, Scenario) pair (those are deliverables produced by this methodology, not spec content)
- Internationalization (English-only in v1)
- Per-tenant template variation (templates are global per SPEC-11 v2.0.1 §10.3)
- Analytics interpretation for the iteration loop (PRD-07 v1.2 covers the data; this spec covers what to do with it)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Templated architecture; no AI in the engine's generation path. | SPEC-11 v2.0.1 |
| One active variant per (`job_type`, `scenario_key`) pair globally. | SPEC-11 v2.0.1 §10.3 |
| Variants are global; no per-tenant or per-location variation in v1. | SPEC-11 v2.0.1 §10.3 |
| Master scenario list contains 33 entries per SPEC-03 v1.3.2 §7.2. v1 authoring scope is governed by per-tenant activation, not master list count. Jeff's tenant activates 17 scenarios; v1 authoring scope is 17 variants. The remaining 16 master list scenarios do not require authored variants until activated for some tenant. | SPEC-03 v1.3.2; Jeff feedback 2026-04-25/26 |
| `authoring_hypothesis` is required on every activated variant. | SPEC-11 v2.0.1 §7.1 |
| No industry jargon in customer-facing prose. | Jeff 2026-04-21; SPEC-11 v2.0.1 §2 point 8 |
| Subject line discipline: `subject_template` does not contain the `[{job_number}]` prefix (engine-managed at send time per PRD-03 v1.4.1 §7.3); subject lines carry a scenario-specific anchor recognizable in two words. | PRD-03 v1.4.1 §7.3; CC-06 (DASH-native threadability MVP-non-negotiable); master prompt v0.4 |
| Trust contract preservation in all variant prose. | CC-01 Platform Spine v1.4 |
| Approval-first; no unapproved outbound. | CC-01 Platform Spine v1.4 |
| Legal review required for Trauma / Biohazard sub-type and any biohazard scenario within other sub-types. | §8 |

---

## 5. Actors and Objects

**Actors:**

- **Authoring lead** — Kyle or Ethan. Owns the brief drafting, prompt execution, and human finalization. One authoring lead per authoring run; not split mid-run.
- **Domain expert** — Jeff. Reviews briefs asynchronously, corrects them in a 30-minute call.
- **Legal reviewer** — outside counsel for §8 scenarios. Engaged once, retains scope for v1.
- **Iteration owner** — Kyle. Runs the §10 loop on the defined cadence, decides which sub-types get re-authored.

**Objects:**

- **Sub-type brief** — a one-page document per sub-type capturing customer profile, common objections, emotional register, deliberation timing, and applicable industry standards (author-facing only). Drafted by the authoring lead from web research and product priors. Reviewed by Jeff asynchronously, corrected in the 30-minute call.
- **Jeff correction notes** — captured in the 30-minute call. Bullet-point list per sub-type covering what Jeff corrected, what he added, and any verbatim phrases he used that should be embedded in the master prompt context.
- **Master authoring prompt** — the standing prompt that takes (sub-type brief + Jeff correction notes + scenario) as input and produces a variant payload as output. Versioned. v0 lives outside `smai-specs/`; promoted to a Claude Code skill once stable.
- **Variant payload** — a SPEC-11 v2.0.1-compliant template variant record. Output of the master prompt, refined by human finalization, activated through the admin portal per PRD-10 v1.3 §9B.
- **Authoring artifacts** — per-variant bundle preserved for audit and v2 hardening: sub-type brief, Jeff correction notes, master prompt input, master prompt output, human finalization diff, legal review record (if applicable). Stored at `smai-specs/templates/source-material/<sub_type>/<scenario_key>/v1/`.

---

## 6. The Quality Rubric

The v2.0 rubric is a six-criterion self-check applied at two gates: inside the master prompt (the prompt instructs Claude to evaluate its own output against the rubric and revise once before returning) and at human finalization (the finalizer reads the variant against the rubric at speaking pace).

The rubric is not a binary pass-fail grid. It is the standard the master prompt encodes and the finalizer applies. A variant that is borderline on a criterion gets revised in place rather than rejected.

### 6.1 Rubric criteria

| # | Criterion | What it means in practice |
|---|-----------|---------------------------|
| R1 | Sounds like someone who knows the work | The voice reads as a competent professional who has done this kind of job before. Not a marketing copywriter. Not a chatbot. Not necessarily a 20-year veteran, but someone who has been on enough of these jobs to know what matters. |
| R2 | Avoids marketing automation language | No "circling back," "just touching base," "wanted to follow up on," "here's a friendly reminder," "don't hesitate to reach out," "let me know if you have any questions," and similar phrases that pattern-match to standard sales-followup automation. |
| R3 | Scenario-specific | The email refers to specifics of the scenario in a way that signals the sender understood what kind of job this is. A water mitigation email after a sewage backup reads differently than one after a clean water supply line break. Generic per-sub-type prose fails this criterion. |
| R4 | No industry jargon | No IICRC, OSHA, EPA, S500, S520, "Category 1/2/3 water," "Class A/B/C asbestos," etc. The master prompt has the full block list; the human finalizer is the backstop. |
| R5 | Trust contract preserved | No promises of automated approval, no "AI scheduling" language, no claims that imply the email is anything other than a follow-up from the originator's company. No false urgency. No overpromising on outcomes, timelines, or insurance coverage. |
| R6 | Subject line discipline | Every step's `subject_template` contains a scenario-specific anchor recognizable in two words. No `subject_template` includes the `[{job_number}]` prefix manually — the engine prepends it at send time when a job number exists per PRD-03 v1.4.1 §7.3 and omits it when none exists. Subject lines across steps in a variant feel consistent enough to belong to the same Gmail thread. Only `{property_address_short}` is permitted as a merge field in subjects. |

### 6.2 Rubric application

The rubric is applied per email per variant. A 4-step variant has 24 rubric checks (6 criteria × 4 emails). The master prompt is instructed to self-evaluate against all 24 and revise any failures before returning. The human finalizer reads the variant against the same rubric and edits in place where needed.

Failures the finalizer can't fix in a few minutes of editing are signal that the master prompt is producing weak output for that scenario, not signal that the variant should ship as-is. The finalizer escalates persistent failures to the iteration owner for prompt refinement.

### 6.3 Rubric evolution

The rubric is versioned with the spec. SPEC-12 v2.0.1 carries the rubric above. Future SPEC-12 revisions may add, remove, or modify criteria as the methodology matures. Rubric changes are applied to new variants authored after the revision; previously activated variants are not retroactively re-evaluated.

---

## 7. The Authoring Pipeline

The pipeline runs in two phases. Stages 1-3 run once per sub-type and produce shared inputs for all scenarios within that sub-type. Stages 4-5 run once per (`job_type`, `scenario_key`) pair to produce one variant.

The first time a sub-type is authored, all five stages run for every scenario within it. Subsequent variants for an existing pair (per the §10 iteration loop) re-run stages 4-5 only; the brief and correction notes from the first cycle remain valid unless Jeff's operational reality has changed.

### 7.1 Stage 1: Sub-type brief draft

**Run once per sub-type. Authored by the authoring lead before the Jeff session.**

**Input:** SPEC-03 v1.3.2 §7.2 scenario list for the sub-type; web research on customer dynamics, industry standards, and common objections; product priors from prior conversations with Jeff.

**Output:** A one-page brief covering:

- **Customer profile** — who hires for this sub-type, in what state of mind, with what immediate concerns. Specific enough to be wrong in interesting ways. "Homeowner, stressed" is not specific enough. "Homeowner who came home to find their basement flooded, has called insurance, is waiting on adjuster scheduling, comparing two or three vendors who all sound similar" is.
- **Common objections** — what makes customers hesitate after receiving a proposal. Drawn from web research and prior Jeff conversations.
- **Emotional register** — what tone fits (urgent vs sympathetic vs technical vs reassuring).
- **Insurance context** — how insurance typically interacts with this sub-type, including timing patterns that affect customer urgency.
- **Deliberation timeline** — how long customers typically take to decide.
- **Industry-standard references** — which standards govern (author-facing only; never in customer prose).
- **Scenario list** — the scenarios within the sub-type from SPEC-03 v1.3.2 §7.2, with one-line descriptions to prime Jeff's review.

**Gate:** Authoring lead reads the brief and asks: "If Jeff reads this, will he correct it in interesting ways or rebuild it from scratch?" If the answer is rebuild, the brief is too thin and needs another pass before going to Jeff.

### 7.2 Stage 2: Jeff async review

**Run once per sub-type. Owned by Jeff. Synchronous time required: zero.**

**Input:** All seven sub-type briefs (from stage 1) sent to Jeff at once for asynchronous review.

**Output:** Jeff's markup — corrections, additions, and any verbatim phrases he writes in the margins of the briefs.

**Gate:** Jeff confirms he has reviewed all seven briefs and is ready for the correction call. If Jeff has not had time to review meaningfully, the correction call is rescheduled, not held. A correction call without prior review collapses to an unstructured interview, which defeats the purpose.

### 7.3 Stage 3: Jeff correction call

**Run once per sub-type set (all seven sub-types in one call). Owned by authoring lead. Jeff time required: 30-60 minutes.**

**Input:** Jeff's marked-up briefs.

**Output:** Per-sub-type Jeff correction notes capturing:

- Customer profile corrections (what Jeff said is wrong about the original profile, what he added)
- Objections he sees that the brief missed
- Tone corrections
- Verbatim phrases Jeff used during the call. These are gold and must be captured exactly. "I just say 'the longer mold sits, the more it spreads, and once it's in the framing it's a different conversation'" is the kind of sentence that, embedded in the master prompt context, shifts the AI output meaningfully toward operator voice.
- Anything Jeff said that the authoring lead found surprising

**Gate:** Authoring lead reads correction notes back to Jeff at the end of the call and confirms accuracy. Notes are then locked.

### 7.4 Stage 4: Master prompt execution

**Run once per (`job_type`, `scenario_key`) pair. Owned by authoring lead. Time per pair: a few minutes.**

**Input:** Sub-type brief, Jeff correction notes, scenario record from SPEC-03 v1.3.2 §7.2 (including `industry_classification` author-facing metadata).

**Output:** A SPEC-11 v2.0.1-compliant variant payload including all step records, merge field references, and a populated `authoring_hypothesis`. The master prompt is instructed to self-evaluate against the §6 rubric and revise once before returning.

**Gate:** Variant payload validates against the SPEC-11 v2.0.1 schema. Rubric self-check pass is captured in the prompt output.

### 7.5 Stage 5: Human finalization

**Run once per variant. Owned by authoring lead (Kyle or Ethan). Time per variant: 5-15 minutes at speaking pace.**

**Input:** Variant payload from stage 4.

**Output:** Activation-ready variant payload after human edit pass.

**The finalizer:**

- Reads each email at speaking pace
- Edits anything that sounds like AI
- Edits anything Jeff would never say (cross-referenced against correction notes)
- Verifies no jargon block list violations
- Verifies trust contract preservation
- Verifies subject line discipline per R6 (no `[{job_number}]` prefix manually included; scenario-specific anchor present; consistent across steps)
- Confirms or revises the `authoring_hypothesis`
- Captures a finalization diff for the authoring artifact bundle

**Gate:** Finalizer reads the variant once more end-to-end and signs off. If the variant required substantial structural editing (more than light copy fixes), this is signal that the master prompt is weak for that scenario and the prompt is refined before the next run.

---

## 8. Legal Review Path

Legal review is required for all variants in the **Trauma / Biohazard** sub-type and for any scenario in any sub-type where the operational work involves blood, bodily fluids, or other biohazard exposure (e.g., a trauma scene cleanup or a contamination event that involves regulated materials).

**Engagement pattern:**

- Outside counsel is engaged once before the v1 authoring run. Counsel reviews the methodology and the master prompt for general posture.
- Counsel then reviews the variant payloads for §8-triggering scenarios in batch, not one at a time.
- Counsel sign-off is captured in the authoring artifact bundle.

**What counsel reviews for:**

- Misrepresentation risk (claims of certification, capability, or outcome)
- Regulatory disclosure adequacy
- Liability exposure in language around contamination, exposure, or remediation outcomes
- State-specific compliance issues for the markets where Jeff operates (Texas, Idaho, Nevada)

Variants that fail legal review return to stage 4 with counsel's specific objections as additional input to the master prompt. They cannot be activated until counsel signs off.

---

## 9. The Master Authoring Prompt

The master prompt is the load-bearing execution artifact for v2.0. It encodes this spec into a form that Claude (or another sufficiently capable model) executes against per scenario.

The prompt is a separate artifact from this spec. It lives outside `smai-specs/` in v0 form and is promoted to a Claude Code skill at `/mnt/skills/user/smai-template-author/SKILL.md` once it has been used to author at least 10 variants successfully.

**Prompt structure (specified here, drafted separately):**

- System context: SPEC-11 v2.0.1 output contract, SPEC-12 v2.0.1 rubric, jargon block list, trust contract constraints, subject line discipline rules including the engine-managed prefix per PRD-03 v1.4.1 §7.3
- Per-run inputs: sub-type brief, Jeff correction notes, scenario record
- Output instruction: variant payload conforming to SPEC-11 v2.0.1 schema, with self-evaluated rubric pass and populated `authoring_hypothesis`
- Self-check: prompt instructs Claude to evaluate its own output against §6 rubric and revise once before returning

**Prompt versioning:** v0.1 is the initial draft. Version increments when (a) the rubric changes, (b) the SPEC-11 schema changes, (c) the iteration loop reveals systematic weaknesses in prompt output that warrant a refinement, (d) downstream PRD/SPEC changes affect authoring rules (e.g., PRD-03 §7.3 subject line prefix logic).

**Prompt authority:** The prompt is authoritative for execution but subordinate to this spec for design. Conflicts between prompt behavior and SPEC-12 are resolved by amending the prompt, not by amending this spec.

---

## 10. Iteration Loop

The iteration loop is the load-bearing element that earns the v2.0 bar. Without it, v2.0 ships permanently mediocre content. With it, v2.0 ships fast-then-improving content that converges on world-class on real signal rather than pre-launch effort.

### 10.1 Iteration triggers

A sub-type's variants are re-authored when any of these triggers fire:

| Trigger | Threshold | Source |
|---------|-----------|--------|
| Reply rate below floor | <15% reply rate over 30 days, after at least 30 jobs across the sub-type | PRD-07 analytics |
| Conversion rate below floor | <5% conversion to a meeting after 30 days, after at least 30 jobs across the sub-type | PRD-07 analytics |
| Jeff flags a variant | Any time Jeff identifies a specific variant as embarrassing or wrong | Jeff feedback |
| Customer complaint | Any complaint that references variant prose specifically | Operator escalation |
| Scenario volume crosses 100 jobs | Sub-type has accumulated 100+ jobs in production | PRD-07 analytics |

The 30-day window starts at first send, not at variant activation. A variant must have been sending for at least 30 days before any reply or conversion threshold can fire.

### 10.2 Iteration cadence

- **30-day post-launch review:** Iteration owner, authoring lead, and Jeff review per-sub-type analytics and identify any sub-types that triggered §10.1.
- **90-day deeper review:** Same group reviews scenario-level performance within sub-types. By this point, scenario-level signal is meaningful.
- **Quarterly thereafter:** Standing review cadence until either (a) all sub-types have stable conversion at acceptable thresholds, or (b) the iteration loop is formally retired in favor of a new methodology.

The 30-day and 90-day reviews are calendar-blocked at pilot adoption time, not scheduled later. This is the discipline that distinguishes v2.0 from a hand-wave.

### 10.3 Re-authoring methodology

When a sub-type triggers re-authoring, the v1 authoring artifacts (brief, Jeff correction notes, prompt output, finalization diff) plus the live data signal feed back into a deeper authoring cycle.

**Re-authoring runs all five v2.0 stages with two additions:**

1. **Stage 1 (brief)** is updated with insights from the live data: which customer profile assumptions held and which didn't, which objections actually surface in replies, which prose patterns landed and which didn't.
2. **Stage 3 (Jeff correction)** is replaced with a deeper Jeff conversation focused specifically on the underperforming variants: what does he think went wrong, what would he say differently. This is closer in depth to the SPEC-12 v1.0 interview pattern than the v2.0 async-plus-30-min pattern.

Re-authored variants ship through the same activation flow per SPEC-11 v2.0.1 §11.3. The prior variant is retained in the variant store for comparison and audit.

### 10.4 What re-authoring does not do

- It does not produce world-class operator voice automatically. It produces incrementally better operator voice. Multiple iteration cycles may be needed for any given sub-type to reach a quality plateau.
- It does not retroactively re-evaluate variants that were performing acceptably. The loop targets specific weaknesses, not blanket re-authoring.
- It does not move SPEC-12 to a higher upfront-rigor methodology. The methodology stays lean; quality compounds through iteration, not through pipeline expansion.

---

## 11. Effort and Cadence Expectations

### 11.1 v1 authoring run (17 variants for Jeff's tenant)

| Stage | Effort | Owner |
|-------|--------|-------|
| Brief drafting (5 sub-types active in v1) | 4-7 hours | Authoring lead |
| Jeff async review | 1-2 hours of Jeff's time, asynchronous | Jeff |
| Jeff correction call | 30-60 minutes (live), plus 1-2 hours of authoring lead time to capture and structure notes | Authoring lead + Jeff |
| Master prompt execution (17 pairs) | 1-2 hours total | Authoring lead |
| Human finalization (17 variants) | 2-4 hours total | Kyle + Ethan |
| Legal review (Trauma / Biohazard plus any biohazard scenarios) | 2-4 hours of counsel time, plus authoring lead coordination | Counsel + authoring lead |

**Total elapsed time from spec adoption to all variants live: 5-8 working days, gated primarily by Jeff's review turnaround and counsel availability.**

Note on scope: Jeff's tenant activates 17 of the 33 master scenarios per SPEC-03 v1.3.2 §7.2 and PRD-10 v1.3 §12.6. The remaining 16 master scenarios do not require authored variants in v1; they are authored at the time their first activating tenant is onboarded. The authoring run scope is governed by Jeff's activation, not the master list.

### 11.2 Iteration cycle (per sub-type)

| Stage | Effort |
|-------|--------|
| Live data review | 1-2 hours |
| Brief update | 1-2 hours |
| Deeper Jeff conversation | 60-90 minutes |
| Master prompt re-execution and finalization | 2-4 hours per affected sub-type |

**Total elapsed time per iteration cycle: 3-5 working days per sub-type undergoing re-authoring.**

---

## 12. Authoring Artifact Storage

All authoring artifacts are stored at `smai-specs/templates/source-material/<sub_type>/<scenario_key>/v1/` for v1 authoring run, and `<scenario_key>/v2/`, `v3/` etc. for subsequent iteration cycles.

**Per-scenario artifact bundle:**

- `brief.md` — sub-type brief (shared across all scenarios within sub-type via symlink or reference)
- `jeff-correction-notes.md` — sub-type correction notes (shared across all scenarios within sub-type)
- `prompt-input.md` — exact input passed to master prompt
- `prompt-output.json` — exact output from master prompt, including self-evaluated rubric
- `finalization-diff.md` — human edits captured between prompt output and activation-ready variant
- `legal-review.md` — counsel sign-off record (only for §8-triggering scenarios)
- `variant-payload.json` — final activation-ready variant per SPEC-11 v2.0.1 schema

The bundle is preserved for audit, iteration analysis, and v2 hardening reference. It is never deleted; superseded versions are retained in their original directories.

---

## 13. Acceptance Criteria for the Methodology

These criteria are not for individual variants (rubric covers that). These are for the methodology itself: when SPEC-12 v2.0.1 is functioning as designed.

**Given** an authoring lead picking up SPEC-12 v2.0.1 for the first time,
**When** they read sections 1-11,
**Then** they can execute a sub-type's worth of variants without requiring synchronous guidance from Kyle or Ethan, producing activation-ready variants that pass the rubric.

**Given** any variant that has reached activation-ready state,
**When** the variant's authoring artifacts are inspected,
**Then** all of the following are present: sub-type brief, Jeff correction notes, master prompt input and output, finalization diff, legal review record (if applicable), activation-ready variant payload.

**Given** any activated variant,
**When** the SPEC-11 v2.0.1 template store is queried for that variant,
**Then** the `authoring_hypothesis` field is populated with non-empty content describing what the variant is testing or attempting to achieve.

**Given** any rendered email body produced from any variant authored under SPEC-12 v2.0.1,
**When** the body is inspected,
**Then** it contains no IICRC, OSHA, EPA, or other industry-standard classifications, and reads as a competent professional who understands the work rather than as marketing automation.

**Given** any variant authored under SPEC-12 v2.0.1,
**When** every step's `subject_template` field is inspected,
**Then** none of them contain the `[{job_number}]` prefix manually (engine-managed at send time per PRD-03 v1.4.1 §7.3); each subject line contains a scenario-specific anchor recognizable in two words; subject lines across steps in the variant feel consistent enough to belong to the same Gmail thread.

**Given** a Trauma / Biohazard scenario or a biohazard scenario in any sub-type,
**When** the variant is activated,
**Then** a legal review record exists in the authoring artifacts and is referenced in the activation audit trail per SPEC-11 v2.0.1 §11.

**Given** the 30-day post-launch review,
**When** any sub-type has triggered an iteration condition per §10.1,
**Then** a re-authoring cycle is scheduled within two weeks of the review.

**Given** the 90-day post-launch review,
**When** scenario-level analytics are inspected,
**Then** every scenario's reply and conversion metrics are documented in a per-scenario performance log, and any underperforming scenarios are flagged for re-authoring.

---

## 14. Failure Modes and Recovery

| Failure mode | Cause | Recovery |
|--------------|-------|----------|
| Jeff doesn't have time to review briefs before the call | Briefs sent too late, or Jeff's calendar tightened | Reschedule call. Do not run an unstructured call without prior review. |
| Jeff reviews but his corrections are vague | Briefs were too thin or too generic to react to specifically | Authoring lead revises briefs to be more specific (more wrong in interesting ways) and re-sends. Better to delay than to capture vague signal. |
| Master prompt produces variants that fail the rubric self-check repeatedly | Prompt is weak for that sub-type, or the brief plus correction notes are insufficient context | Iteration owner refines the prompt. If the issue is context, deeper Jeff conversation may be needed for that sub-type. |
| Human finalizer is making structural edits, not light copy edits | Master prompt is producing structurally weak variants | Pause the run. Refine the prompt before continuing. Structural editing at finalization defeats the §11 effort estimates. |
| Subject line discipline failures recurring across variants | Master prompt is not enforcing R6 correctly, or PRD-03 §7.3 prefix logic is being misunderstood | Iteration owner reviews master prompt's subject line section against PRD-03 §7.3. Common failure: prompt allowing `[{job_number}]` in `subject_template`. Refine prompt and re-run affected variants. |
| Legal review returns "no" | Variant has a regulatory or liability issue | Variant returns to stage 4 with counsel's specific objections as additional prompt input. |
| Live reply data shows a sub-type performing well below floor | Variants are actually weaker than the v1 bar suggested, or scenario taxonomy is wrong | §10 iteration loop fires. Either re-author the sub-type or escalate to a SPEC-03 review if scenario boundaries are the actual issue. |
| 30-day review is missed or skipped | Iteration loop discipline breaking down | Iteration owner is accountable. Skipped reviews are escalated to product owner (Kyle) within one week. |

---

## 15. Open Questions and Implementation Decisions

| Topic | Status | Notes |
|-------|--------|-------|
| Master prompt versioning storage | Open | Recommendation: prompt v0 lives as a Markdown artifact in the SMAI Product OS project. Once promoted to a Claude Code skill, lives at `/mnt/skills/user/smai-template-author/SKILL.md` with version frontmatter. Confirm with Kyle. |
| Legal counsel selection | Open | SPEC-12 v1.0 §15 carried this open question. Still open. Recommendation: engage counsel before v1 authoring run begins, not after. Owner: Kyle. |
| Iteration owner accountability | Open | The §10 loop names Kyle as iteration owner. If Kyle's bandwidth becomes a constraint post-pilot, ownership transfers to whoever owns SMAI's content quality function. Confirm with Kyle. |
| Per-tenant variation when v2 customers onboard | Out of scope for v1 | Templates are global per SPEC-11 v2.0.1. When SMAI onboards customers other than Jeff, the question of whether a variant authored with Jeff's input fits another customer's operational reality will arise. SPEC-12 v2.0.1 assumes single-customer authoring; multi-customer methodology is a future revision. |
| Authoring scope expansion to remaining 16 master scenarios | Open | The 16 master scenarios not activated for Jeff's tenant in v1 are authored when their first activating tenant is onboarded. The exact methodology mirrors §7 (run all five stages). Whether the brief/correction-notes inputs for those scenarios benefit from Jeff's existing input depends on whether the new tenant's operational reality is similar enough; decided per-onboarding. |
| Rubric evolution based on iteration data | Open | If the iteration loop reveals that the §6.1 rubric is missing a criterion that consistently differentiates winning from losing variants, the rubric is updated in a SPEC-12 v2.x patch. Trigger: 90-day review. |
| Authoring tool drift | Open | Master prompt is currently designed for Claude. If model capabilities, pricing, or limits change materially, re-evaluate. SPEC-12 v2.0.1 is written assuming the current tool reality. |

---

## 16. Out of Scope

- The template data model, render contract, or activation operation (covered by SPEC-11 v2.0.1)
- The (Job Type, Scenario) taxonomy (covered by SPEC-03 v1.3.2)
- The campaign engine or send lifecycle (covered by PRD-03 v1.4.1)
- The admin portal UI for activation (covered by PRD-10 v1.3)
- Internationalization of templates (English-only in v1)
- Per-tenant template variation (templates are global per SPEC-11 v2.0.1)
- Replacement of the human finalization stage with AI-only finalization
- Replacement of legal review with AI-only review for regulated content
- Per-customer template customization for customers other than Jeff in v1
- Any A/B testing framework (single-active-variant per pair per SPEC-11 v2.0.1)
- Specific template content for any (Job Type, Scenario) pair (those are deliverables of this methodology, not spec content)
- Operator-facing surfacing of authoring artifacts or hypotheses
- Generic per-sub-type templates that don't carry scenario-level specificity (the scenario-level distinction is the entire point)
