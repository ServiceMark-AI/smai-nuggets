# Variant: Appliance failure

**Sub-type:** Water Mitigation (`water_mitigation`)
**Scenario:** Appliance failure (`appliance_failure`)
**Industry classification (author-facing only):** IICRC S500 Category 1 or 2 Water Damage (depends on appliance and source)
**Authoring hypothesis:** Variant assumes appliance-failure customers respond to operational specificity about how appliance water actually moves (under cabinets, into toe-kick, through subfloor) plus matter-of-fact framing that does not reinforce self-blame, with the duty-to-mitigate lever activating at Hour 12 paired with the appliance-failure-as-covered-cause-of-loss reassurance.
**Cadence:** 6 steps over ~5 days
**Authored:** 2026-04-27
**Master prompt version:** v0.7
**SPEC-11 schema version:** v2.0.1

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Hour 0 | 0 | Deliver proposal from prior walkthrough; orient to attached scope; decision-oriented CTA in matter-of-fact register. |
| 2 | Hour 4 | 4h | Add operational specificity on how appliance-failure water moves and what equipment does, without amplifying self-blame. |
| 3 | Hour 12 | 8h | Address modal insurance objection; activate duty-to-mitigate lever; reassure on appliance-failure as covered cause of loss. |
| 4 | Hour 24 | 12h | Tighten operational case at day-mark since loss; customer-situation framing on materials and salvageable scope. |
| 5 | Hour 48 | 24h | Close the live conversion window; duty-to-mitigate direct in customer-situation terms (floor, cabinets, walls, claim). |
| 6 | Day 5 | 3d | Soft return; offer help if delayed-onset issues have surfaced; no push, no pipeline-closure ask. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Water cleanup at {{property_address_short}}`

**Body:**

The proposal for the water cleanup at {{property_address_short}} is attached, based on what we walked through at the property. It covers the drying scope, the equipment plan, and the timeline we discussed.

Appliance failures usually push more water into more places than people expect; supply lines run continuously until the valve gets shut, and the water tends to travel under cabinets and into adjacent rooms before it shows on the surface. The proposal reflects what we saw and what we expect once equipment is reading actual moisture levels. For most jobs at this scope, the equipment runs 3-5 days, sometimes longer when there's hardwood, dense materials with heavy absorption, or building systems where moisture has migrated further than it looks.

Take your time reviewing it. If you want to walk through any part of the proposal, give me a call or reply here, by phone or in person, whatever works. When you're ready to move forward, just let me know and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Drying timeline at {{property_address_short}}`

**Body:**

Most of the drying work happens passively once the equipment is set. Air movers shift the air across wet surfaces, dehumidifiers pull the moisture out of the air, and meters track where things are across the cabinets, subfloor, and adjacent walls. Quiet for the homeowner most of the time, just a hum.

With appliance-failure water, the spots that take the longest are usually the ones you can't see from the kitchen or laundry room itself. Water runs along the path of least resistance, which on most floors means under cabinets, into the toe-kick space, and out into adjacent rooms or down through the subfloor. The proposal accounts for that based on what we saw, and the meters will tell us if anything is wetter than it looked.

If you have questions about how the equipment works or what to expect day-to-day while it's running, easiest to talk through on the phone.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Insurance and the water cleanup at {{property_address_short}}`

**Body:**

The reason timing matters on water jobs isn't sales pressure, it's the policy language about timely mitigation. Once a loss happens, the policyholder is responsible for starting the drying process promptly, and waiting several days gives the carrier room to argue the loss got bigger than it had to.

The good news on appliance-failure losses: sudden water release from an appliance is almost always a covered cause of loss under a standard homeowner policy, distinct from gradual leaks that often get pushed back on. Mitigation and rebuild are also typically separate line items on the claim, which is worth knowing if the adjuster conversation is still ahead.

If you're paying out of pocket, the same timing logic applies differently: materials that are still wet sit in the range where drying with equipment is the answer, and waiting shifts the work to a different scope. Happy to walk through any of it on the phone if it would help.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`A day in on the water at {{property_address_short}}`

**Body:**

About a day past the loss now, and the drying picture starts to change. Materials that were on the edge of salvageable when we walked through can move past that point quickly once they've been wet long enough.

With appliance-failure water, the spots that drive the timeline are usually the ones you can't see, under cabinets, in the toe-kick, in any subfloor with a path for the water to spread. The difference between starting drying today and starting drying in three days shows up most clearly there: what can be saved versus what has to come out.

If anything about the proposal needs a second look, or you want to talk through the scope, give me a call or reply here. We can get a crew on the schedule once you give the go-ahead.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The window on water cleanup at {{property_address_short}}`

**Body:**

About two days past the loss now, and we're at the edge of the window where moving fast still meaningfully changes the outcome on this job. Materials that have been sitting wet for two days are mostly past the point where drying with equipment alone can save them. The scope shifts from drying to replacement, which means more of the floor, more of the cabinets, and more of the wall comes out; on the insurance side, the carrier has more room to question whether the additional damage had to happen.

If you want to move forward, reply here or give me a call and we'll get a crew on the schedule. If you have questions you'd rather talk through live, that works too, easier by phone if that helps.

---

## Step 6

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the water cleanup at {{property_address_short}}`

**Body:**

Several days on from the original loss now, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.

The reason I'm reaching back out: appliance-failure water sometimes looks settled at the surface and then shows up later. A soft spot in the floor, a cabinet door that won't close right anymore, a stain on a ceiling below, a smell that wasn't there before, those are the kinds of things that surface when materials weren't fully dried out. If anything like that has come up at {{property_address_short}}, even if the original work was done by someone else, that conversation is worth having.

If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Operational specifics throughout: toe-kick, subfloor pathing, supply-line runtime until valve shut-off, air movers and dehumidifiers and meters by function not name, 3-5 day equipment runtime with the hardwood and dense-materials exception, mitigation/rebuild as separate claim line items, delayed-onset signals (cabinet door not closing, ceiling stain, soft spot, smell). |
| R2 — Avoids marketing automation language | true | No banned mid-cadence openings (no "circling back," "checking in," "following up on" as a transitional opener); Steps 2-5 open with substance (equipment behavior, policy language, day-mark since loss, edge of the window); Step 6 opens with the elapsed-time acknowledgment, not a follow-up tag. |
| R3 — Scenario-specific | true | Appliance-failure load-bearing across the variant: water travel paths under cabinets and into toe-kick, supply-line runtime, sudden-release vs. gradual-leak coverage distinction, kitchen/laundry room context, delayed-onset signals specific to appliance scenarios (cabinet door not closing). Cannot be swapped to sewage_backup or storm_related_flooding without rewriting. |
| R4 — No industry jargon | true | No IICRC, no S500, no "Category 1/2," no "PPE," no "HEPA," no licensing references. "Mitigation" used sparingly; "drying" and "cleanup" carry most of the work. |
| R5 — Trust contract preserved | true | No health/biological/air-quality claims; no pipeline-management language ("close out the file," "decision needs to happen," "where things stand" all absent); Hour 48 push is in customer-situation terms (floor, cabinets, walls, claim integrity), not operator-pipeline terms ("the number," "the math"); insurance content stays at general process awareness, no specific adjuster-tactic advice. Voice anchor compliance: matter-of-fact register, no language that reinforces self-blame about the appliance failure. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented per the prior-walkthrough rule; mid-cadence steps offer phone/in-person/reply paths and explicitly do not try to fully resolve insurance or scope questions in writing; Step 6 offers a return path without resolving anything via email. |

---

## Authoring artifact metadata

**Step count:** 6
**Total duration (days):** 5

**Per-step purposes:**

- Step 1: Deliver the attached proposal from the prior walkthrough; briefly orient to scope and equipment plan; decision-oriented CTA in matter-of-fact register that does not reinforce self-blame about the appliance.
- Step 2: Add operational specificity on equipment function and on how appliance-failure water travels through cabinetry, toe-kick, and subfloor; signal expertise without amplifying self-blame.
- Step 3: Address the modal insurance objection; activate the duty-to-mitigate lever in policy-language terms; reassure on appliance-failure sudden-release as a covered cause of loss distinct from gradual leaks; offer parallel paying-out-of-pocket logic.
- Step 4: Tighten the operational case at the day-mark since the loss; customer-situation framing on what shifts from drying-with-equipment to needing replacement, focused on the appliance-typical impact zones.
- Step 5: Close the live conversion window with the strongest customer-situation framing; what's at stake is the customer's floor, cabinets, walls, and claim integrity, not operator-pipeline economics.
- Step 6: Soft return at Day 5; acknowledge that the customer has likely moved on or solved it; offer help only if delayed-onset appliance-water issues have surfaced; no push, no pipeline-closure ask.
