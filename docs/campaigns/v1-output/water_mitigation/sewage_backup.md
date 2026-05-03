# Variant: Sewage backup

**Sub-type:** Water Mitigation (`water_mitigation`)
**Scenario:** Sewage backup (`sewage_backup`)
**Industry classification (author-facing only):** IICRC S500 Category 3 Water Damage
**Authoring hypothesis:** Variant assumes sewage backup customers respond to direct, matter-of-fact contamination framing that anchors urgency in operational scope (cleanup approach, materials decisions, claim documentation) rather than health language, with the contamination-is-source-AND-time principle activating delayed-onset awareness from Hour 12 onward and Hour 48 push centered on customer property and claim rather than operator economics.
**Cadence:** 6 steps over ~5 days (Hour 0, Hour 4, Hour 12, Hour 24, Hour 48, Day 5)
**Authored:** 2026-04-27
**Master prompt version:** v0.7
**SPEC-11 schema version:** v2.0.1

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Hour 0 | 0 (immediate on approval) | Deliver the proposal from the prior walkthrough; orient to what's attached; decision-oriented CTA. |
| 2 | Hour 4 | 4h | Operational specificity on what makes a sewage cleanup different from clean-water work. |
| 3 | Hour 12 | 8h | Address modal objection (insurance + scope clarity) via duty-to-mitigate angle. |
| 4 | Hour 24 | 12h | Tighten operational reality; materials decisions are now in play. |
| 5 | Hour 48 | 24h | Close the live window; customer-situation framing on property, materials, and claim. |
| 6 | Day 5 | 3d | Soft return; available if surfaces have started showing problems. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Sewage cleanup at {property_address_short}`

**Body:**

The proposal for the sewage cleanup at {property_address_short} is attached, based on what we walked through at the property. It covers the cleanup scope, the materials we expect to remove, the drying and sanitization plan, and the timeline we discussed.

Sewage backups have a different cleanup approach from a clean-water loss from the start. Porous materials that absorbed contaminated water, drywall, baseboards, carpet, padding, and similar, come out rather than dry in place. The proposal reflects what we expect to remove based on the walkthrough; if anything shifts once we're in there with the right tools, we'll keep you in the loop.

Take your time reviewing it. If you want to walk through any part of the proposal, give me a call or reply here. Happy to do it by phone or come back to the property if it helps. When you're ready to move forward, just let me know and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Sewage cleanup approach at {property_address_short}`

**Body:**

The reason a sewage cleanup runs longer and looks different than a clean-water job comes down to what has to be removed versus what can be saved. Anything porous that the water touched, drywall a few inches up the wall, padding under carpet, baseboards, contents that absorbed it, comes out and gets disposed of properly. Hard, non-porous surfaces stay and get cleaned and sanitized.

Once the demolition piece is done, the drying setup goes in much like a regular water job, equipment running for several days to bring the structure back to dry standard, and then we sanitize again before anyone closes things back up. Most sewage cleanups at this scope take a week to ten days end to end, sometimes longer when the contamination reached subfloor or framing.

If you want to walk through what's in or out of scope before deciding, easiest by phone. Give me a call when it works, or reply here.

---

## Step 3

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Insurance and the sewage cleanup at {property_address_short}`

**Body:**

The reason timing matters on a sewage job isn't sales pressure. Most homeowner policies have language requiring the policyholder to mitigate damage in a timely way once a loss happens. Sewage backups also have their own coverage path, often a separate endorsement or sublimit that's worth confirming with your carrier early, and waiting several days before starting cleanup gives the carrier room to question whether the additional damage to materials had to happen.

If you're paying out of pocket and trying to size the decision before committing, the same logic shows up differently. Materials sitting in contaminated water continue moving from the cleanup-and-salvage scope into a larger demo-and-replace scope. The proposal you're holding reflects what we saw earlier today; that picture changes the longer materials sit.

Happy to talk through any of this on the phone if it would help.

---

## Step 4

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`A day in on the sewage cleanup at {property_address_short}`

**Body:**

About a day past the loss now, the picture on a sewage job shifts in a specific way. Materials that absorbed contaminated water at hour zero are still in the same condition; what changes is how far the contaminated moisture has migrated into surrounding structure, framing, subfloor, the back side of cabinets, the underside of flooring. Each additional day expands the footprint of what comes out.

That matters for two practical reasons. The cleanup scope grows, and the documentation the adjuster will look at grows with it. Faster start keeps both contained. We've handled enough of these to know what to look for and how to scope it tight.

If you want to move forward, reply here or give me a call and we'll get a crew on the schedule. If there are questions you'd rather talk through live, that works too; easier by phone if that helps.

---

## Step 5

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`The window on the sewage cleanup at {property_address_short}`

**Body:**

About two days past the loss now, we're at the edge of the window where moving fast still meaningfully changes the outcome on this job. On a sewage backup specifically, the longer contaminated water sits, the further it moves into structure that wasn't initially affected, which means more demolition, more material replacement, and a larger reconstruction scope on the back end after cleanup is done.

For your claim, that progression is the part carriers scrutinize, what damage was the original event, and what damage was the result of delay. The cleaner the documentation around timely mitigation, the cleaner the claim conversation. We've handled this end of it on a lot of jobs and we know what the adjuster will be looking for.

If you want to move forward, reply here or give me a call and we'll get a crew on the schedule. If you have questions you'd rather talk through live, that works too; easier by phone if that helps.

---

## Step 6

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Following up on the sewage cleanup at {property_address_short}`

**Body:**

Several days on from the original backup, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.

The reason I'm reaching back out: sewage cleanups sometimes look settled at the surface and then show up later. A soft spot in the floor, a baseboard that's started to swell, a smell that wasn't there before, a stain bleeding through fresh paint, those are the kinds of things that surface when the contamination reached materials that weren't visibly affected at the time. If anything like that has come up at {property_address_short}, even if the original work was done by someone else, that conversation is still worth having.

If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Specific operational facts throughout: porous-vs-non-porous removal logic, week-to-ten-day timeline, contaminated-water migration into surrounding structure, what adjusters scrutinize on documentation, sewage-specific endorsement/sublimit awareness. Not generic vendor language. |
| R2 — Avoids marketing automation language | true | No banned openings ("circle back," "checking in," "following up on" as transitional opener), no "let me know if you have questions," no "hope this finds you well." Mid-cadence steps open on substance. Step 6 uses "Following up on" only in the subject line as soft-return signal, not as body opener. |
| R3 — Scenario-specific | true | Sewage-specific operational substance is load-bearing throughout: contamination cleanup approach (porous removal, demo first then dry then sanitize), week-to-ten-day timeline, sewage-specific insurance endorsements, contaminated water migration into structure, the specific failure modes that show up later (soft spots, swollen baseboards, stains bleeding through). The variant cannot be swapped for clean_water_flooding or pipe_burst without rewriting most paragraphs. |
| R4 — No industry jargon | true | No IICRC, S500, Category 3, OSHA, EPA, CIH, HEPA, PPE, "containment" (noun). Mitigation used once in Step 3 ("timely mitigation") in a regulatory-context phrase the customer would hear from their adjuster. No state licensing references. |
| R5 — Trust contract preserved | true | No health/biological/air-quality claims (operational scope progression only, no "contamination spreads," no health-risk language). No pipeline-management language ("close out the file," "decision needs to happen," "for our records," "no expectation either way," "if you've gone with another vendor"). No false urgency, no insurance outcome promises. Hour 48 push centers on customer property, materials, and claim integrity, not on operator economics. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented per the exception (review the proposal, ask questions, walk through it by phone or in person if helpful, let me know when ready). Steps 2-5 acknowledge questions and pull toward phone or in-person conversation rather than fully resolving via email. Step 6 offers presence without asking for closure. |

---

## Authoring artifact metadata

**Step count:** 6
**Total duration (days):** 5

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to what's attached including the cleanup scope and materials-removal logic specific to sewage; signal availability to walk through it; decision-oriented CTA (review, questions, ready-to-move-forward).
- Step 2: Add operational specificity on what makes a sewage cleanup structurally different from clean-water work, porous removal, demo-then-dry-then-sanitize sequence, week-to-ten-day timeline, so the customer understands what they're committing to.
- Step 3: Address the modal objection via duty-to-mitigate angle plus sewage-specific coverage awareness (separate endorsements, sublimits worth confirming with carrier), with parallel framing for self-pay customers about scope progression.
- Step 4: Tighten the operational case at the day-mark since the loss; the contaminated-water migration footprint is now expanding into surrounding structure; documentation grows with scope; signal the operator's experience scoping tight.
- Step 5: Close the live window with customer-situation framing only; what's happening to the property, the materials, and the claim documentation; available to move forward or talk live, no pressure for closure.
- Step 6: Soft return at Day 5; assume situation resolved one way or another; offer presence specifically calibrated to the failure modes that surface later in sewage cleanups (soft spots, swollen baseboards, stains bleeding, smell) even if the original work was done elsewhere.
