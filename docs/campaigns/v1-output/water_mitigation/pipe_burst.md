# Variant: Pipe burst

**Sub-type:** Water Mitigation (`water_mitigation`)
**Scenario:** Pipe burst (`pipe_burst`)
**Industry classification (author-facing only):** IICRC S500 Category 1 Water Damage (typical; may shift category with time)
**Authoring hypothesis:** Variant assumes pipe burst customers are operating in a stabilized-but-shaken emotional state after shutting off the supply themselves, that the strongest mid-cadence lever is duty-to-mitigate paired with the operational fact that pipe burst is the cleanest insurance scenario in water damage, and that customer-situation framing about materials shifting from drying to replacement carries the Hour 48 push without operator-pipeline language.
**Cadence:** 6 steps over ~5 days (active conversion window through Hour 48, optional soft return at Day 5)
**Authored:** 2026-04-27
**Master prompt version:** v0.7 (file labeled v0.4 per skill invocation; actual content version v0.7)
**SPEC-11 schema version:** v2.0.1

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Hour 0 | 0 (immediate on approval) | Deliver the proposal that came out of the onsite walkthrough; orient the customer to scope, drying plan, and timeline; signal the path to a decision. |
| 2 | Hour 4 | 4h | Add operational specificity about how drying actually works for a pipe burst; what equipment does over the first few days; what the customer should expect to see. |
| 3 | Hour 12 | 8h | Address the modal objection on a pipe burst job (insurance coverage and the duty-to-mitigate reality); explain why pipe burst is treated as the cleanest claim type and why timing still matters. |
| 4 | Hour 24 | 12h | Tighten the operational case at the day-mark since the loss; materials that were salvageable yesterday behave differently today; pull the conversation back to deciding. |
| 5 | Hour 48 | 24h | Close the live conversion window with directness; center the push on what's happening to the customer's property, materials, and claim, not on the proposal economics. |
| 6 | Day 5 (optional) | ~3d | Soft return; acknowledge that several days have passed and the situation has likely either resolved or moved another direction; offer a path back if anything settled-looking has surfaced. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Water cleanup at {{property_address_short}}`

**Body:**The proposal for the water cleanup at {{property_address_short}} is attached, based on what we walked through at the property. It covers the drying scope, the equipment plan, and the timeline we discussed.For most pipe burst jobs at this scope, the equipment runs 3 to 5 days, sometimes longer when there's hardwood, dense materials with heavy absorption, or building systems where the water migrated further than it looked at first. The proposal reflects what we expect to see based on the walkthrough; once equipment is reading actual moisture levels, we'll keep you in the loop on anything that shifts.Take your time reviewing it. If you have questions or want to walk through any part of the proposal, give me a call or reply here. Happy to do it by phone or in person if it helps. When you're ready to move forward, let me know and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Drying timeline at {{property_address_short}}`

**Body:**Most of the actual drying work happens passively once the equipment is in place. Air movers and dehumidifiers run continuously for several days, pulling moisture out of materials and dropping humidity in the affected spaces. The crew comes back to take readings, adjust placement, and pull equipment as rooms dry down. You don't need to be home for any of that beyond the initial setup.The first 24 hours are the most active on our side: setup, demo of any unsalvageable materials, getting baseline moisture readings written down. After that the work is mostly equipment running and us checking in.If you want to walk through what the first day actually looks like, give me a call. Often easier to talk through than to read.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Insurance and the water cleanup at {{property_address_short}}`

**Body:**Pipe burst is the cleanest claim type in water damage. Sudden and accidental discharge from internal plumbing is the scenario most homeowner policies are written to cover, and adjusters generally work mitigation invoices through without much friction.The piece worth knowing is that most policies have language requiring the policyholder to mitigate the damage in a timely way once a loss happens. Waiting several days to start drying gives the carrier room to argue the loss got bigger than it had to, which can create real coverage problems on the claim side. Showing that mitigation started promptly is the cleanest way to keep the claim straightforward.If you're paying out of pocket or trying to size the decision before committing, the same logic applies in a different way. Materials that are wet now are still in the range where drying with equipment is the answer; materials that have been sitting since last night will continue shifting toward needing replacement, which is a different scope. Happy to talk through any of this on the phone if it would help.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`A day in on the water at {{property_address_short}}`

**Body:**About a day past the loss now, the drying picture changes. Materials that were within range of drying with equipment yesterday are right at the edge of that range today. Subfloors and the lower few inches of drywall are the usual tells; once those have been wet for a full day, the call between dry-in-place and remove-and-replace gets harder to make from the surface.What the proposal covered was the scope we expected based on what we saw at the walkthrough. If we get equipment running today, that scope holds for most of the affected materials. If we're still here tomorrow having this conversation, the proposal likely shifts toward more replacement and less drying, and the cleanup runs longer.If anything has come up on your side that's slowing the decision, walk me through it. Easier to address questions live than over email. Reply here or give me a call when it's convenient.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The window on water cleanup at {{property_address_short}}`

**Body:**About two days past the loss now, we're at the edge of the window where moving fast still meaningfully changes the outcome on this job. Materials that have been sitting wet for two days are mostly past the point where drying with equipment alone can save them. The work shifts toward removing and replacing what didn't dry, your floors and walls take more damage that's harder to undo, and on the insurance side, carriers have more room to question whether the additional damage had to happen.If you want to move forward, reply here or give me a call and we'll get a crew on the schedule. If you have questions you'd rather talk through live, give me a call when it's convenient and we'll work through them together.

---

## Step 6

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the water cleanup at {{property_address_short}}`

**Body:**Several days on from the original loss, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.The reason I'm reaching back out: pipe burst losses sometimes look settled at the surface and then surface problems later. A soft spot in the floor, a board that started cupping, a stain on a ceiling below, a smell that wasn't there before. Those are the kinds of things that show up when materials weren't fully dried out, and they often turn into a larger conversation with the carrier than the original loss would have been. If anything like that has come up at {{property_address_short}}, even if the original work was done by someone else, that conversation is still worth having.If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Specific operational facts throughout (3-5 day equipment runs, dense materials with heavy absorption, subfloors and lower drywall as the day-mark tells, dry-in-place vs remove-and-replace, passive drying mechanics); no marketer-grade abstractions; voice reads as someone who has been on enough pipe burst jobs to know what changes between Hour 4 and Hour 48. |
| R2 — Avoids marketing automation language | true | No banned openings; mid-cadence steps open on substance (drying mechanics, claim-type framing, day-mark operational shift, soft-return acknowledgment); no "circling back," "checking in," "hope this finds you well," "just touching base," or any variant. |
| R3 — Scenario-specific | true | Pipe burst is load-bearing in the prose: voice signals stabilization once supply is off, Step 3 names pipe burst as the cleanest claim type (an accurate scenario-specific operational fact that does not hold for gradual leak, storm flooding, or sewage), Step 6 names pipe burst late-discovery patterns (cupping boards, ceiling stains below, soft floors). Could not be swapped to another water sub-scenario without rewriting. |
| R4 — No industry jargon | true | No S500, no Category language, no IICRC, no PPE, no HEPA, no licensing references; "mitigation" used sparingly and substituted with "drying" or "cleanup" where natural; "remediation" not used. |
| R5 — Trust contract preserved | true | No promises of coverage outcomes, no timeline guarantees that depend on factors outside operator control, no specific insurance procedural advice (general process awareness only on duty-to-mitigate), no health or biological or air-quality claims anywhere, no pipeline-management language ("close out the file," "decision needs to happen," "let me know either way," "no expectation either way" all absent), no false urgency, late-cadence push framed in customer-situation terms (materials, claim, property), not in operator-pipeline terms (proposal value, the math, the number). |
| R6 — Pulls toward onsite | true | Step 1 is decision-oriented per exception (proposal already exists from prior walkthrough); Steps 2 through 5 each pull toward a phone conversation rather than trying to fully resolve the modal question via email; Step 6 stays available without resolving anything. No step quotes a specific number, predicts a coverage outcome, or commits to a timeline that depends on factors only visible onsite. |

---

## Authoring artifact metadata

- **Step count:** 6
- **Total duration (days):** 5
- **Per-step purposes:**
  - Step 1: Deliver the proposal that came out of the onsite walkthrough; orient the customer to scope, drying plan, and timeline; signal the path to a decision without re-proposing a site visit.
  - Step 2: Add operational specificity about how drying actually works on a pipe burst; what the equipment does over the first few days; what the customer should expect to see and not see.
  - Step 3: Address the modal objection on a pipe burst job (insurance coverage and the duty-to-mitigate reality); explain why pipe burst is treated as the cleanest claim type and why timing still matters even when coverage is straightforward.
  - Step 4: Tighten the operational case at the day-mark since the loss; materials that were salvageable yesterday behave differently today; pull the conversation back to deciding without becoming pushy.
  - Step 5: Close the live conversion window with directness; center the push on what's happening to the customer's property, materials, and claim, not on the proposal economics or operator-pipeline framing.
  - Step 6: Soft return at Day 5; acknowledge that several days have passed and the situation has likely either resolved or moved in a different direction; offer a path back if anything settled-looking has surfaced; step away gracefully without demanding a status update.
