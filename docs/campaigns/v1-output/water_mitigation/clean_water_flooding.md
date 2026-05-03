# Variant: Clean water flooding

**Sub-type:** Water Mitigation (`water_mitigation`)
**Scenario:** Clean water flooding (`clean_water_flooding`)
**Industry classification (author-facing only):** IICRC S500 Category 1 Water Damage
**Authoring hypothesis:** Variant assumes clean-water flooding customers in the active 48-hour conversion window respond to operational specificity (drying timeline, equipment behavior, what the first day actually looks like) more than to empathy framing, with duty-to-mitigate education activating at Hour 12 and customer-situation framing carrying the Hour 48 push.
**Cadence:** 6 steps over ~5 days
**Authored:** 2026-04-27
**Master prompt version:** v0.7 (skill references v0.4; v0.7 is the live authoritative version in the project)
**SPEC-11 schema version:** v2.0.1

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Hour 0 | 0 | Deliver the proposal from the prior walkthrough; orient customer to what is attached; set decision-oriented next step. |
| 2 | Hour 4 | 4h | Add operational specificity on what the equipment actually does once running; signal that most of the work is passive. |
| 3 | Hour 12 | 8h | Address the modal insurance objection through the duty-to-mitigate angle; explain why timing is contractual, not sales pressure. |
| 4 | Hour 24 | 12h | Tighten the operational case as a day passes since the loss; describe how materials behave differently after sitting wet for 24 hours. |
| 5 | Hour 48 | 24h | Close the live window with customer-situation framing; describe what is happening to the property and the claim, not the proposal economics. |
| 6 | Day 5 | 3d | Soft return; assume customer has moved on or solved it; offer a path back if anything settled-looking has shifted. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Water cleanup at {{property_address_short}}`

**Body:**
The proposal for the water cleanup at {{property_address_short}} is attached, based on what we walked through at the property. It covers the drying scope, the equipment plan, and the timeline we discussed.
For most clean-water jobs at this scope, equipment runs 3 to 5 days, sometimes longer when there is hardwood, other dense materials with heavy absorption, or building systems where moisture has migrated further than it looks. The proposal reflects what we expect based on the walkthrough. If anything shifts once equipment is in and reading actual moisture levels, we will keep you in the loop.
Take the time you need to review it. If you have questions or want to walk through any part of the proposal, give me a call or reply here. Happy to do it by phone or in person if it helps. When you are ready to move forward, just let me know and we will get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Drying timeline at {{property_address_short}}`

**Body:**
Most of the work on a water job happens passively once equipment is in and running. Air movers and dehumidifiers do the heavy lifting; the technician visits are mostly to read moisture levels, confirm materials are tracking toward dry, and adjust placement when readings show pockets that are not moving.
What that means in practice: the disruption is real for the first day or so when equipment goes in, and then it settles. Furniture is moved, some baseboards or drywall sections may need to come out so air can reach what is wet behind them, and the equipment runs continuously. Daily visits to check readings are short. The total active disruption is much less than the calendar duration of the drying period.
If you want to walk through what the work would actually look like at {{property_address_short}}, easiest by phone. I can also answer anything by reply email if that works better.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Insurance and the water cleanup at {{property_address_short}}`

**Body:**
The reason timing matters on water jobs is not sales pressure. Most homeowner policies have language requiring the policyholder to mitigate damage in a timely way once a loss happens. Waiting several days to start drying gives the carrier room to argue the loss got bigger than it had to, which can create real coverage problems on the claim side.
If you are paying out of pocket and trying to size the decision before committing, the same logic applies in a different way. Materials that are wet now are still in the range where drying with equipment is the answer. Materials that have been sitting since the loss happened will continue shifting toward needing replacement, which is a different scope and a different conversation.
Happy to talk through any of this on the phone if it would help. Insurance specifics get easier to answer once we are onsite and can see what we are actually dealing with.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`A day in on the water at {{property_address_short}}`

**Body:**
About a day past the loss now, the drying picture changes. Water that has been sitting for 24 hours behaves differently than water that has been sitting for 4 hours. Wicking has had time to move moisture into materials it was not in initially, which is why subfloors, lower wall cavities, and the underside of cabinets get checked even when the surface looks dry.
The equipment plan in the proposal accounts for this. The reason crews show up with more equipment than the visible damage suggests is because moisture is reliably further along than it looks at this stage. None of this is a problem if equipment goes in soon. It becomes a problem when materials sit through another day or two and the scope shifts from drying to replacement.
If you want to move forward or have questions about anything in the proposal, reply here or give me a call. If something has changed on your side that we should know about, say so and we will adjust.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The window on water cleanup at {{property_address_short}}`

**Body:**
About two days past the loss now, we are at the edge of the window where moving fast still meaningfully changes the outcome on this job. Materials that have been sitting wet for two days are mostly past the point where drying with equipment alone can save them. The work shifts from drying intact materials to opening up walls, pulling flooring, and replacing what is no longer salvageable.
Two pieces of that matter for you. The job becomes a larger one, which means more disruption at {{property_address_short}} and more time before things are back to normal. On the insurance side, carriers have more room to question whether the additional damage had to happen, which can affect what gets covered on the claim.
If you want to move forward, reply here or give me a call and we will get a crew on the schedule. If you have questions you would rather talk through live, that works too. Easier by phone if that helps.

---

## Step 6

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the water cleanup at {{property_address_short}}`

**Body:**
Several days on from the original loss, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.
The reason I am reaching back out: clean-water losses sometimes look settled at the surface and then show up later. A soft spot in the floor, a cupping board, a stain on a ceiling below, a smell that was not there before, those are the kinds of things that surface when materials were not fully dried out. If anything like that has come up at {{property_address_short}}, even if the original work was done by someone else, that conversation is still worth having.
If something comes up, I am here. Reply or call whenever it works.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Specifics throughout: 3 to 5 day equipment runs, moisture wicking into subfloors and cabinets, drying versus replacement scope distinction, clean-water-loss late-tail symptoms (cupping boards, stains on ceilings below). No marketer-voice generalities. |
| R2 — Avoids marketing automation language | true | No banned phrases. Mid-cadence emails open with substance (passive equipment work at Step 2, duty-to-mitigate at Step 3, a-day-in operational shift at Step 4, two-days-in window framing at Step 5). |
| R3 — Scenario-specific | true | Clean-water specifics carry the prose: drying-with-equipment as the answer when materials are wet now, dense-material absorption as a known timing factor, late-tail late-discovery symptoms specific to clean water in Step 6. The variant would not work for sewage backup or storm-related flooding without rewriting. |
| R4 — No industry jargon | true | No IICRC, S500, Category 1, PPE, HEPA, mitigation as a noun used heavily, or contractor-license references. "Drying" and "cleanup" used in plain language. No state-licensing references (water mitigation default behavior). |
| R5 — Trust contract preserved | true | No automated-approval language, no false urgency, no insurance-coverage promises, no health/biological/air-quality claims, no pipeline-management language ("close out the file," "no expectation either way," "decision needs to happen"). Step 5 push is customer-situation framed (property, materials, claim), not operator-pipeline framed (proposal economics). Time references anchor to the loss event, not the campaign cadence. |
| R6 — Pulls toward onsite | true | Step 3 explicitly says "Insurance specifics get easier to answer once we are onsite." Steps 2, 3, 4, and 5 offer phone or in-person options without trying to fully resolve scope or coverage by email. Step 1 is the proposal-delivery exception per the master prompt. |

---

## Authoring artifact metadata

**Step count:** 6
**Total duration (days):** 5

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient customer to what is attached; set decision-oriented next step (review, ask questions, authorize when ready).
- Step 2: Add operational specificity on equipment behavior and disruption profile so the customer understands what they would actually be committing to.
- Step 3: Address the modal insurance objection through the duty-to-mitigate angle; frame timing as contractual obligation, not sales pressure.
- Step 4: Tighten the operational case as a day passes since the loss; describe how materials behave differently after 24 hours of wicking.
- Step 5: Close the live window with customer-situation framing on what is happening to the property and the claim as materials shift from salvageable to replaceable.
- Step 6: Soft return; assume customer moved on; offer a path back if late-discovery symptoms have surfaced.
