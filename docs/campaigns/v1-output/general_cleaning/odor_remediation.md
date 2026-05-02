# Variant: Odor remediation

**Sub-type:** General Cleaning (`general_cleaning`)
**Scenario:** Odor remediation (`odor_remediation`)
**Industry classification (author-facing only):** Non-IICRC primary (may invoke S540 for trauma-adjacent or S700 for smoke odor)
**Authoring hypothesis:** Variant assumes odor remediation customers convert on the strength of investigative competence (source-then-air sequence framed as the actual workflow, not deodorizing) more than on price or speed alone, with the Day 4 push leaning on the customer's own timing constraint rather than any operational urgency lever.
**Cadence:** 4 steps over 6 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; orient the customer to what's attached and signal availability to walk through it. |
| 2 | Day 2 | 2d | Add a useful angle on the source-then-air sequence so the customer understands what they're actually paying for. |
| 3 | Day 4 | 2d | Push step anchored to the customer's own timing window; direct about getting on the schedule without becoming pleading. |
| 4 | Day 6 | 2d | Tighter final touch before the window closes; "wanted to follow up before this slips," not full soft return. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Odor work at {property_address_short}`

**Body:**

The proposal for the odor work at {property_address_short} is attached, based on what we walked through at the property. It covers what we'd do to track down the source and what the air treatment looks like once that part is handled.

The reason we work in that order matters for what you're paying for. Most odor problems don't get solved by treating the air alone. If the source is still in the space, even a well-deodorized room is going to start smelling again within a few days. So the proposal reflects both halves: find and remove what's causing it, then treat what's left in the air.

Take your time reviewing it. If you have questions or want to talk through any part of the scope, give me a call or reply here. When you're ready to get on the schedule, just let me know.

---

## Step 2

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Source-then-air at {property_address_short}`

**Body:**

The thing that makes odor work different from regular cleaning is that the smell is almost always a symptom, not the problem itself. Something is producing it. Animal in a wall cavity, residue on materials from something that burned, biological contamination on a surface, smoke that's bonded into porous finishes. The job is figuring out which one and where, then handling that, and then dealing with what's still in the air after.

That's what the scope in the proposal reflects. Some of it we can identify before crews start; some of it only becomes clear once we're in the space with the right equipment. If anything shifts once we're working, we'll let you know what we're seeing.

If you want to walk through any of the scoping questions before you decide, easiest to do that on the phone.

---

## Step 3

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Scheduling the odor work at {property_address_short}`

**Body:**

A few days into reviewing this now, so a quick note on timing. The window where odor problems tend to stay manageable is the one we're in right now. The longer the source sits, the more it works its way into materials that are harder to deal with after the fact. Carpet, drywall, upholstery, and anything porous holds onto it.

That's the reason for getting a crew in sooner rather than later, not pressure on our end. If your situation has a downstream date driving it (someone moving in, a property going on the market, a tenant returning, a business reopening), that's the lever that matters most for scheduling.

If you want to move forward, reply here or give me a call and we'll get a crew on the schedule. If you have questions you'd rather talk through live, that works too.

---

## Step 4

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Following up on the odor work at {property_address_short}`

**Body:**

Wanted to follow up before this slips. The window where odor work makes the biggest difference is fairly short, and at this point either the source is still in the space or you've handled it elsewhere. Both of those are fine outcomes.

The reason I'm reaching back: if the source is still there, the proposal as scoped still applies and we can get a crew on the schedule. If your situation has changed, no follow-up needed from your side.

If something comes up, give me a call or reply here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Source-then-air framing, specific material absorption references (carpet, drywall, upholstery, porous finishes), and the "smell is a symptom not the problem" framing read as operator domain knowledge rather than vendor copy. |
| R2 — Avoids marketing automation language | true | No banned phrases. Step 4 opens with "Wanted to follow up before this slips" which matches the cadence document's prescribed Day 6 framing for general cleaning, distinct from banned "wanted to follow up" transitional opening. |
| R3 — Scenario-specific | true | The variant cannot be swapped to commercial_deep_clean or post_construction without rewriting; source-then-air sequence and the symptom-vs-source framing are load-bearing in every step. |
| R4 — No industry jargon | true | No IICRC, no S540, no S700, no VOC abbreviation in customer prose, no licensing references, no "remediation" overuse (used once in subject framing, "odor work" elsewhere). |
| R5 — Trust contract preserved | true | No health claims (no respiratory effects, no air quality consequences, no exposure framing), no pipeline-management language, no operator-pipeline framing in late-cadence push, customer-situation framing throughout (their property, their materials, their timing). |
| R6 — Pulls toward onsite | true | Step 1 is decision-oriented per the prior-walkthrough framing; mid-steps acknowledge that some scope only becomes clear onsite ("some of it only becomes clear once we're in the space"); no email tries to fully resolve scope or quote specific outcomes. |

---

## Authoring artifact metadata

**Step count:** 4
**Total duration (days):** 6

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to what's attached and signal availability to walk through it.
- Step 2: Add a useful angle on the source-then-air sequence so the customer understands what they're actually paying for.
- Step 3: Push step anchored to the customer's own timing window; direct about getting on the schedule without becoming pleading.
- Step 4: Tighter final touch before the window closes; "wanted to follow up before this slips," not full soft return.
