# Variant: Post-water deep clean

**Sub-type:** Structural Cleaning (`structural_cleaning`)
**Scenario:** Post-water deep clean (`post_water_deep_clean`)
**Industry classification (author-facing only):** IICRC S700-adjacent (cleaning standards apply)
**Authoring hypothesis:** Variant assumes post-water deep clean customers respond to operational specificity about water-residue behavior and the cleaning-versus-replacement window as the primary push lever (parallel role to soot acidity in post-fire variants), with restrained insurance posture and Day 6 push-timing activation, all anchored to the matter-of-fact voice that distinguishes this scenario from the more acute post-fire opening.
**Cadence:** 5 steps over ~14 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; orient the customer to what post-water deep cleaning is and why timing matters; decision-oriented CTA. |
| 2 | Day 3 | 3d | Address the modal objection; explain why deep cleaning after a water event is a distinct scope from regular cleaning and why some materials have a window. |
| 3 | Day 6 | 3d | Push-timing voice activates; about a week post water event, surface residues bonding and materials shifting from cleanable toward replacement is the operational case for moving. |
| 4 | Day 10 | 4d | Push intensifies; tone holds; reinforce expertise and weekly-volume signal; customer-situation framing on scope drift. |
| 5 | Day 14 | 4d | Soft return; significant time has passed; offer a path back if the cleaning piece was missed or the situation evolved. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Cleanup proposal for {property_address_short}`

**Body:**

The proposal for the deep cleaning work at {property_address_short} is attached, based on what we walked through at the property. It covers the cleaning scope, the surfaces and materials involved, and the timeline we discussed.

This work sits between standard mitigation and full restoration. The water event is past; what's left is cleaning what was affected so it can be returned to condition rather than replaced. Surface deposits and residues from a water event do tend to bond more firmly the longer they sit, which is the main reason moving sooner than later is worth thinking about.

If you have questions or want to walk through any part of the proposal, give me a call or reply here. When you're ready to move forward, let me know and we'll get on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`What the cleanup at {property_address_short} covers`

**Body:**

The thing that makes deep cleaning after a water event different from regular cleaning is what's actually on the surfaces. Water carries minerals, fine sediment, and whatever was suspended in it onto every material it touched, and that residue dries in place. Standard cleaning either misses it or smears it around; the chemistry and method in the proposal are calibrated to lift that material off without damaging the finish underneath.

Some of what's in scope responds well to cleaning if it's handled within the next week or so. Materials that absorbed water during the event, particularly the lower trim and the lower portion of any wall surfaces in the affected area, will progressively shift toward needing replacement if they sit long enough. That's the reason the cleaning timing matters even though the water itself is no longer active.

If you want to walk through what's in or out of scope, easiest to do that on the phone.

---

## Step 3

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Timing on the cleanup at {property_address_short}`

**Body:**

About a week past the water event now, we're at the point where the cleaning decision starts having different consequences depending on which way it goes. Surface residues that lift cleanly within the first week or two become noticeably more difficult to remove the longer they sit. The materials that absorbed water during the event, the lower trim and the lower portion of the wall surfaces in particular, are the ones with a real window: every additional week shifts more of that material from cleanable into needing replacement, and once that line is crossed it does not come back.

The case for moving on the cleaning scope at this point is operational, not sales pressure. Some of what's in the scope can be cleaned and held in place; if it sits much longer, it shifts onto a replacement list and the work changes shape. We've handled enough of these to know how the decision tends to land, and the customers who move within the cleaning window almost always come out ahead of the customers who let it sit.

If you want to move forward, reply here or give me a call and we'll get on the schedule. If you have questions you'd rather talk through live, that works too.

---

## Step 4

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`The cleanup work at {property_address_short}`

**Body:**

Roughly two weeks past the water event, the materials situation is what it is. The items that were marginal at week one have either been cleaned by now or are sitting in a state where cleaning may no longer return them to condition. That's not a sales argument; it's how surface residues and absorbed moisture behave over time.

There's still real value in moving on the cleaning scope now rather than later. The longer it sits, the more the work drifts from cleaning toward replacement, which is a different scope and a different conversation with the carrier. We handle post-water cleaning every week; the method is calibrated for exactly this kind of situation, and once we have your go-ahead, getting on the schedule is straightforward.

If you have questions or want to walk through where things stand, easiest by phone. When you're ready, reply here or call and we'll get a crew on it.

---

## Step 5

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Following up on the cleanup at {property_address_short}`

**Body:**

A couple of weeks on from the original water event now, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.

The reason I'm reaching back out: post-water cleaning sometimes looks settled at the surface and then surfaces a different problem later. Lingering staining on a baseboard, a soft area in flooring that didn't seem affected at first, a smell that wasn't there before, those are the kinds of things that show up when the cleaning piece wasn't fully addressed. If anything like that has come up at {property_address_short}, even if the original work was done by someone else, that conversation is still worth having.

If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Operational specifics throughout: residue behavior, absorbed-moisture progression, scope drift toward replacement, calibrated chemistry, weekly volume signal. Steady, grounded voice across all 5 steps. |
| R2 — Avoids marketing automation language | true | No banned phrases used. Mid-cadence steps (2-5) open with substance, not transitional follow-up phrasings. No "circling back," "checking in," "just touching base," "hope this finds you well." |
| R3 — Scenario-specific | true | The post-water deep clean scope is load-bearing throughout. Soot acidity (the post_fire lever) is not invoked. Instead the water-residue-and-absorbed-moisture reality drives the operational case. Step 5 references baseboard staining, soft flooring, residual smell as scenario-specific aftermath signals. Could not swap in post_fire_soot_smoke without rewriting. |
| R4 — No industry jargon | true | No IICRC, S700, S500, Category, OSHA, EPA, ALE, PPE, HEPA, CIH, or state licensing references in customer prose. No regulatory acronyms. Plain language used throughout: "cleaning," "deep cleaning," "scope," "the carrier." |
| R5 — Trust contract preserved | true | No automated-approval language, no false urgency, no AI-generated framing, no specific insurance procedural advice (carrier reference at Step 4 is general process awareness only), no health/biological/air-quality claims, no pipeline-management language. Customer-situation framing throughout: scope drift, materials, claim implications — never proposal economics or operator pipeline. |
| R6 — Pulls toward onsite | true | Steps 2-5 do not attempt to fully resolve coverage, scope details, or timeline questions; instead they pull toward phone or in-person. Step 1 carries the proposal per R6 exception (decision-oriented CTA, not site-visit-oriented). |

---

## Authoring artifact metadata

**Step count:** 5
**Total duration (days):** 14

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to what post-water deep cleaning is and briefly introduce the timing reality without leaning on it as a push; decision-oriented CTA.
- Step 2: Address the modal objection by explaining why deep cleaning after a water event is a distinct scope from regular cleaning, what makes it operationally different, and why certain materials have a finite cleaning window.
- Step 3: Push-timing voice activates per the Day 6 cadence rule. About a week post water event, surface residues bonding and materials shifting from cleanable toward replacement is the operational case for moving. Customer-situation framing throughout.
- Step 4: Push intensifies, tone holds. Reinforce expertise (weekly volume, calibrated method) and the operational case for moving without escalating into desperation. Acknowledge the customer may not have committed yet, without demanding status.
- Step 5: Soft return per the Day 14 long-cadence framing. Acknowledge significant time has passed, offer a low-pressure path back if the cleaning piece was missed or the situation evolved, do not ask for closure.
