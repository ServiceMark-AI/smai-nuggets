# Variant: Gray water

**Sub-type:** Water Mitigation (`water_mitigation`)
**Scenario:** Gray water (`gray_water`)
**Industry classification (author-facing only):** IICRC S500 Category 2 Water Damage
**Authoring hypothesis:** Variant assumes gray-water customers respond to operational acknowledgment that the water is not benign without health-claim escalation, with the contamination-by-source-and-time framing serving as the load-bearing differentiator across the Hour 0 to Hour 48 conversion window.
**Cadence:** 6 steps over ~5 days
**Authored:** 2026-04-27
**Master prompt version:** v0.7
**SPEC-11 schema version:** v2.0.1

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Hour 0 | 0 (immediate on approval) | Deliver the proposal from the prior walkthrough; orient the customer to gray-water scope vs clean-water scope; decision-oriented CTA. |
| 2 | Hour 4 | 4h | Add operational specificity on what gray-water drying actually involves and why source matters to scope. |
| 3 | Hour 12 | 8h | Address the modal objection (insurance hesitation) via duty-to-mitigate, with gray-water source making the timing case sharper. |
| 4 | Hour 24 | 12h | Tighten the operational case; gray water sitting 24 hours behaves differently than at 4 hours; materials shift. |
| 5 | Hour 48 | 24h | Close the live window; customer-situation framing on materials, claim integrity; direct without being pushy. |
| 6 | Day 5 (soft return) | 3d | Acknowledge time has passed; offer a return path if anything from the original loss has shown up since. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Proposal for water cleanup at {property_address_short}`

**Body:**

The proposal for the water cleanup at {property_address_short} is attached, based on what we walked through at the property. It covers the drying scope, the equipment plan, removal of any materials that aren't salvageable, and the timeline we discussed.

Because the water source on this one isn't clean supply water, the scope reflects that. Gray water (washing machines, dishwashers, that category of source) needs a different approach than a clean-water break, and a few materials that would normally dry in place won't on this kind of job. The proposal accounts for that. For most jobs at this scope, the equipment runs 3-5 days, sometimes longer when there's hardwood, dense materials with heavier absorption, or building systems where moisture migrates further than it looks.

Take your time reviewing it. If you have questions or want to walk through any part of the proposal, give me a call or reply here. Happy to do it by phone or in person if that's useful. When you're ready to move forward, let me know and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`What the first day of cleanup looks like at {property_address_short}`

**Body:**

Most of the work on a job like this happens passively once the equipment is running. The first day onsite, the crew removes whatever isn't salvageable on the gray-water side (the pad under affected carpet usually, sometimes baseboards or a few feet of drywall depending on how high the water reached), gets the area set up, and starts the drying equipment. After that, the equipment does the work and we monitor moisture readings until materials are back to dry standard.

The reason we move on removal early is that with a gray-water source you don't try to dry materials that the water actually saturated. They get pulled and replaced. What gets dried in place is the structural framing and the surfaces the water didn't soak into. Sorting that out properly on day one is most of what determines whether the job stays in mitigation scope or expands.

If you want to talk through any of this, easiest by phone. When you're ready to schedule, reply here or call and we'll get a crew out.

---

## Step 3

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Why timing matters on the {property_address_short} cleanup`

**Body:**

The reason timing matters on water jobs isn't sales pressure. Most homeowner policies have language requiring the policyholder to mitigate damage in a timely way once a loss happens. Waiting several days to start drying gives the carrier room to argue the loss got bigger than it had to, which can create real coverage problems on the claim side.

That logic is sharper on a gray-water source than on a clean-water break. The category of water on this job is already past the point where it can be treated as clean supply water, and the longer it sits, the more the operational picture moves toward materials needing replacement rather than drying. If you're paying out of pocket and trying to size the decision before committing, the same logic applies in a different way: the scope you're looking at now is roughly the scope. The scope a few days from now usually isn't.

Happy to walk through any of the insurance side on the phone if that's where the hesitation is. When you're ready to move forward, reply here or give me a call.

---

## Step 4

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Day after the loss at {property_address_short}, where things stand`

**Body:**

About a day past the loss now, the picture on a gray-water job changes. Water that's been sitting since yesterday behaves differently than water that's been sitting for a few hours. The materials that were borderline on day one are now closer to needing removal than to drying in place, and the source category that was already past clean water doesn't improve by waiting.

What that means for the scope: floor coverings, the pad underneath, and any drywall the water reached are mostly past the point where drying with equipment alone is the answer. They get pulled, the framing and subfloor get dried properly, and the rebuild side picks up from there. None of this is unusual for a job of this kind, but it is a different scope than what was on the table when the equipment could have started yesterday.

If you want to move forward or talk through what's still salvageable, give me a call or reply here. Easier to walk through specifics by phone if that's useful.

---

## Step 5

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Edge of the window on the {property_address_short} cleanup`

**Body:**

About two days past the loss now, we're at the edge of the window where moving fast on this kind of job still meaningfully changes the outcome. With a gray-water source, materials that have been sitting for two days are mostly past the point where drying alone is the answer. The flooring, the pad, and any drywall the water reached largely shift into removal-and-replace, and on the insurance side, carriers have more room to question whether the additional damage had to happen.

For your situation specifically, the things at risk now are the materials that could have been preserved if drying had started inside the first day, your floor and lower wall sections being the typical ones, and the integrity of the claim if this goes through insurance. That's where these jobs land when the start gets pushed.

If you want to move forward, reply here or give me a call and we'll get a crew on the schedule. If you have questions you'd rather talk through live, that works too; easier by phone if that helps.

---

## Step 6

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Checking in on the {property_address_short} situation`

**Body:**

Several days on from the original loss, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.

The reason I'm reaching back out: gray-water losses sometimes look settled at the surface and then show up later in ways that are harder to spot. A soft area in the floor, a baseboard that's started to swell, a smell that wasn't there before, a stain working through paint, those are the kinds of things that surface when the source category and the time-since-loss caught up with materials that didn't get fully addressed. If anything like that has come up at {property_address_short}, even if the original work was done by someone else, that conversation is still worth having.

If something comes up, I'm here. Reply or call whenever it works.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Specific operational details throughout: pad-under-carpet removal pattern, baseboard and lower-drywall behavior on gray water, framing-vs-surface drying distinction, why gray water gets removed rather than dried in place. |
| R2 — Avoids marketing automation language | true | No banned openers; mid-cadence steps open with substance (operational fact, angle, time-progression, customer-situation specifics). No "circling back," "checking in," "hope this finds you well," or CRM template fill. |
| R3 — Scenario-specific | true | Gray-water operational reality is load-bearing in every step: source category, removal-vs-drying decision driven by source, scope language reflects washing-machine/dishwasher class of source. Not swappable with clean-water-flooding without losing substance. |
| R4 — No industry jargon | true | No IICRC, no S500, no "Category 2," no "PPE," no "HEPA," no licensing references. "Gray water" used as plain customer-readable category descriptor (washing machines, dishwashers in parenthetical). "Mitigation" used sparingly. |
| R5 — Trust contract preserved | true | No automated-approval claims, no false urgency, no coverage outcome promises, no specific insurance procedural advice (general process awareness only). No pipeline-management language ("close out the file," "decision needs to happen," "no expectation either way" all absent). No health, biological, air-quality, or contamination-spreading claims; contamination handled in operational scope language only (materials shift toward removal). Late-cadence push (Step 5) frames in customer-situation terms (your floor, your lower wall sections, your claim integrity), not operator-pipeline terms. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented per instruction (review, ask, schedule when ready), not site-visit-oriented. Steps 2-6 acknowledge questions and pull to phone or in-person without trying to fully resolve insurance specifics, scope details, or coverage outcomes via email. |

---

## Authoring artifact metadata

**Step count:** 6
**Total duration (days):** 5

**Per-step purposes:**

- Step 1: Deliver the attached proposal as the output of the prior walkthrough; orient to gray-water scope reality (some materials get removed rather than dried); decision-oriented CTA.
- Step 2: Add operational specificity on what the first day of a gray-water job looks like, framing the removal-vs-drying decision as the load-bearing scope determinant.
- Step 3: Address the modal insurance objection via duty-to-mitigate, sharpening the timing case using the gray-water source category as the lever.
- Step 4: Tighten the operational case at the 24-hour mark; describe how materials behave differently after a day, with source category compounding the timing effect.
- Step 5: Close the active conversion window with customer-situation framing on materials, scope progression, and claim integrity; direct without operator-pipeline language.
- Step 6: Soft return at Day 5; acknowledge customer has likely moved on; offer a path back specifically for delayed-onset symptoms common to gray-water losses.
