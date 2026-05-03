# Variant: Post-fire soot and smoke

**Sub-type:** Structural Cleaning (`structural_cleaning`)
**Scenario:** Post-fire soot and smoke (`post_fire_soot_smoke`)
**Industry classification (author-facing only):** IICRC S700 Fire and Smoke Damage Restoration
**Authoring hypothesis:** Variant assumes post-fire customers respond to soot-acidity operational reality (every day of delay damages materials further; standard cleaning makes it worse) more than to empathy or capability framing, with push-timing voice activating at Day 6 and rebuild capability deferred until cleaning scope is signed.
**Cadence:** 5 steps over 14 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the walkthrough. Orient the customer to the cleaning scope and briefly introduce soot acidity without leaning on it as a push lever. |
| 2 | Day 3 | 3d | Address the modal objection. Hold the line on cleaning scope first; surface the cleaning-chemistry signal as needed. |
| 3 | Day 6 | 3d | Activate push-timing voice. Soot has been sitting nearly a week; damage is ongoing. Direct, not pleading. |
| 4 | Day 10 | 4d | Push intensifies; tone holds steady. Reinforce expertise without chasing. |
| 5 | Day 14 | 4d | Soft return. Acknowledge the customer has likely moved or stalled; offer a path back. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Fire cleanup at {property_address_short}`

**Body:**

The proposal for the fire cleanup at {property_address_short} is attached. The scope and pricing reflect what we walked through together at the property, and it covers the cleaning work needed to handle the soot and smoke residue across the affected areas.

One thing worth knowing as you review it: soot is acidic, and it does more damage to surfaces and materials the longer it sits. That is part of why we want to move once you are ready, not as sales pressure but as the operational reality of how these jobs work. The proposal is built around getting in and getting the cleaning handled before that damage compounds.

Take whatever time you need to review the numbers. If you want to walk through any part of it on the phone, or have me come back out to look at anything we did not cover, just say the word. When you are ready to move forward, reply here or give me a call and we will get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`The cleaning scope at {property_address_short}`

**Body:**

A question that comes up on most fire jobs is whether you can handle the cleaning yourself with regular cleaning products, or whether the soot is something a normal cleaning service can deal with. The honest answer is no on both counts, and the reason is technical. Standard cleaning products do not neutralize soot; they tend to set it deeper into the surface and make the damage worse. We use cleaning chemistry that is formulated specifically to neutralize soot rather than smear it around. That is one of the reasons fire cleanup is its own scope of work and not something a regular cleaner can do well.

The other question that usually comes up is the rebuild side, drywall and paint and getting the structure back to where it was before the fire. The short answer is yes, we handle all of that. The longer answer is that the cleaning has to come first as its own scope, and getting that signed and started is the right next step. Once cleaning is moving, we can talk through what reconstruction looks like.

If you want to walk through any of this live, easier by phone. Otherwise reply here and let me know what questions you have.

---

## Step 3

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Moving on the fire cleanup at {property_address_short}`

**Body:**

About a week on from the fire now, and this is the point in the timeline where the soot-acidity issue stops being a footnote and starts being the main thing. Surfaces and materials that have been sitting under soot for this long are taking real damage every day, and the parts of the structure that could have been cleaned and saved a week ago start moving into a category where they need to be replaced instead. That changes the scope of the job and the size of the claim, and it does not change in your favor.

I want to be direct with you here, not pushy. We need to get started on the cleaning at {property_address_short}. The longer this waits, the more damage builds up under the soot, and that damage is the kind that is hard to reverse once it has set in. We have done a lot of these jobs and we know how to move quickly without making the day harder than it already is.

If you are ready to move forward, reply here or call and we will get the crew scheduled. If something is holding you up, the cleanup we discussed, the insurance side, anything else, the easiest way to work through it is on the phone.

---

## Step 4

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`The fire cleanup window at {property_address_short}`

**Body:**

Ten days past the fire and the picture is the same as it was at Day 6, just more of it. The soot has had another four days to work into the surfaces, and the materials that could have been cleaned a week ago are getting closer to the line where cleaning is no longer the right answer. On the insurance side, carriers tend to look harder at scope that grew because the cleaning was not done in time, and that is the kind of conversation nobody wants to have in the middle of a claim.

We do a lot of fire cleanup and we are good at it. The cleaning chemistry we use is built for this; the crews have been on enough of these jobs to know how to move through the work without missing things; and we can get started quickly once you give us the go-ahead. The question at this point is not whether the cleanup needs to happen. It is whether it happens with us this week, or whether more days go by while you are still deciding.

If you have questions you would rather walk through live, give me a call when it works for you. If you are ready to move forward, reply here and we will get a crew on the schedule.

---

## Step 5

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Following up on the fire cleanup at {property_address_short}`

**Body:**

Two weeks on from the fire now, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome, and I am not writing to push.

The reason I am reaching back out: fire cleanup jobs sometimes look settled and then surface again. The original vendor's scope did not cover everything, the cleaning got partway done and stopped, the smoke smell did not come out the way it was supposed to, or what looked clean at the surface is showing problems underneath. If anything like that has come up at {property_address_short}, even if the original work was done by someone else, that conversation is still worth having and we are happy to come look.

If something comes up, I am here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Voice grounds in operational specifics: soot acidity, cleaning chemistry that neutralizes vs. smears, the cleaning-then-rebuild sequence, carrier scrutiny on preventable scope. Steady throughout, not hurried, no marketer language. |
| R2 — Avoids marketing automation language | true | No banned openings. Mid-cadence steps open with substance (the technical reality of the question, the time-progression, the scope-vs-window framing). No "circling back," "checking in," or "just wanted to." |
| R3 — Scenario-specific | true | Soot acidity, cleaning chemistry that neutralizes, the cleaning-vs-rebuild sequencing, fire-damage materials behavior, and "since the fire" time anchoring are all load-bearing. The variant could not be swapped to mold or water without rewriting the substance of every step. |
| R4 — No industry jargon | true | No IICRC, S700, OSHA, EPA, category language, PPE, HEPA, containment, or licensing references. Customer-facing vocabulary is "soot," "smoke residue," "fire cleanup," "cleaning chemistry," "rebuild." |
| R5 — Trust contract preserved | true | No automated-approval claims, no false urgency, no insurance procedural advice, no AI/automation tells. No pipeline-management language ("close out the file," "decision needs to happen," "for our records"). No health, biological, or air-quality claims; the operational case is built on damage to materials and surfaces. Late-cadence push (Steps 3 and 4) frames in customer-situation terms (your structure, your materials, your claim) not pipeline terms. |
| R6 — Pulls toward onsite | true | Step 1 is decision-oriented (proposal already from prior walkthrough). Steps 2-4 acknowledge questions but route procedural detail (insurance specifics, scope walk-throughs) to a phone call or in-person conversation. Step 5 offers in-person follow-up if the original work has surfaced problems. |

---

## Authoring artifact metadata

**Step count:** 5
**Total duration (days):** 14

**Per-step purposes:**

- Step 1: Deliver the proposal from the walkthrough. Orient the customer to the cleaning scope and briefly introduce soot acidity as operational fact, not push lever.
- Step 2: Address the modal objection. Handle the cleaning-products question with the cleaning-chemistry signal, and hold Part A before Part B on the rebuild ask.
- Step 3: Activate push-timing voice. Soot has been sitting nearly a week; the case for moving is now centered on damage to materials and claim scope.
- Step 4: Push intensifies; tone holds steady. Reinforce expertise (chemistry, crew experience, fire-job volume) without chasing.
- Step 5: Soft return. Acknowledge significant time has passed; offer a path back if the original cleanup has surfaced problems or did not get fully handled.
