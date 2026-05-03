# Variant: Post-construction cleanup

**Sub-type:** General Cleaning (`general_cleaning`)
**Scenario:** Post-construction cleanup (`post_construction_cleanup`)
**Industry classification (author-facing only):** Non-IICRC (general cleaning is unregulated)
**Authoring hypothesis:** Variant assumes post-construction cleanup customers convert on the gap between contractor-grade cleaning and occupy-ready cleaning, with the customer's own downstream date (move-in, listing, occupancy) as the only meaningful push lever, and the cadence ending tight at Day 6 rather than running a long-tail soft return.
**Cadence:** 4 steps over ~6 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; orient the customer to what's attached; signal availability and a clear path to authorize when ready. |
| 2 | Day 2 | 2d | Add a useful angle on what occupy-ready cleaning actually involves; clarify what's in scope versus what a contractor's cleanup typically leaves behind; offer to walk through scope by phone. |
| 3 | Day 4 | 2d | Push step centered on the customer's downstream date; the window for getting cleaned and ready is closing; signal scheduling reality without becoming pleading. |
| 4 | Day 6 | 2d | Tighter late-step touch; "wanted to follow up before this slips"; acknowledge the window is closing and offer one clean path forward. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Post-construction cleanup at {{property_address_short}}`

**Body:**

The proposal for the post-construction cleanup at {{property_address_short}} is attached, based on what we walked through at the property. It covers the cleaning scope, the crew plan, and the timeline we discussed.

Most jobs at this scope take 1-2 days with a full crew, depending on square footage and how much of the fine work (adhesive residue on glass, paint mist on hardware, fine dust in HVAC returns and on top of cabinetry) needs attention. The proposal reflects what we expect to see based on the walkthrough; if anything looks different once we're back onsite running the work, we'll keep you in the loop.

Take your time reviewing it. If you have questions or want to walk through any part of the scope, give me a call or reply here. Happy to do it by phone or in person if it helps. When you're ready to move forward, just let me know and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Scope and timing on the cleanup at {{property_address_short}}`

**Body:**

Most of what makes the difference between a broom-swept handover and an occupy-ready space is the detail clean. Adhesive residue on glass, paint mist on hardware, drywall dust that settles into HVAC returns and stays there, fine grit on top of trim and cabinet runs. Those are the things that show up after a contractor finishes and that a regular cleaning service usually doesn't handle.

The proposal covers all of that based on the scope we walked through. If your move-in or listing date has shifted, or if you want to walk through what's in or out of scope before deciding, easiest to do that on the phone.

When you're ready to move forward, reply here or give me a call and we'll get a crew on the schedule.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Schedule for the cleanup at {{property_address_short}}`

**Body:**

The window for getting the property cleaned and ready ahead of your downstream date is starting to tighten. A full-crew job at this scope is 1-2 days of work, but we also need lead time to slot it on the schedule, and the further out you push, the more we're working around other jobs already booked.

If your move-in, listing, or occupancy date is still where it was when we walked the property, locking in scheduling now is the cleanest way to keep that date intact. If the date has shifted, that's worth a quick conversation; we can talk through what schedule still works on our side.

Reply here or give me a call and we'll get this booked. Happy to talk it through live if that's easier.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the cleanup at {{property_address_short}}`

**Body:**

Wanted to follow up before this slips. The cleanup at {{property_address_short}} has been sitting open for about a week now, and depending on where your move-in or listing date has landed, the window for getting a crew in ahead of it is either close or already past.

If the timing is still workable on your end, we can still make it happen; reply or call and we'll find a slot. If you've already handled it another way or the situation has changed, that's fine too.

Either way, I'm here if anything comes up.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | References specific operational details (adhesive residue on glass, paint mist on hardware, drywall dust in HVAC returns, fine grit on top of trim and cabinet runs); 1-2 day crew duration framed as operator reality, not marketing. |
| R2 — Avoids marketing automation language | true | No banned phrases. Step 4 opens with "Wanted to follow up before this slips" which is the explicit late-step pattern called out in the cadence document for general cleaning Day 6, not a banned mid-cadence opening; mid-cadence Steps 2 and 3 open on substance. |
| R3 — Scenario-specific | true | Post-construction-specific operational details throughout (contractor-finish-versus-occupy-ready gap, fine dust in HVAC returns, adhesive residue, paint mist on hardware, downstream date framing tied to move-in/listing/occupancy); not swappable with commercial_deep_clean or move_in_move_out without losing substance. |
| R4 — No industry jargon | true | No IICRC, no S-numbers, no regulatory citations; general cleaning is non-IICRC and no licensing allusion is permitted in this sub-type, none used. |
| R5 — Trust contract preserved | true | No automation language, no false urgency, no health/biological/air-quality claims, no pipeline-management framing ("close out the file," "decision needs to happen," etc. all absent); push framing in Step 3 centers on customer's own downstream date and property condition, not on operator economics; Step 4 offers a path back without demanding status update. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented per Step 1 exception; mid-cadence Steps 2 and 3 pull toward phone or in-person walkthrough rather than resolving scope or schedule via email; Step 4 offers reply or call without trying to close the deal in writing. No specific quotes, no committed dates, no guaranteed schedule outcomes. |

---

## Authoring artifact metadata

**Step count:** 4
**Total duration (days):** 6

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to what's attached; signal availability and a clear path to authorize when ready.
- Step 2: Add a useful angle on what occupy-ready cleaning actually involves; clarify what's in scope versus what a contractor's cleanup typically leaves behind; offer to walk through scope by phone.
- Step 3: Push step centered on the customer's downstream date; the window for getting cleaned and ready is closing; signal scheduling reality without becoming pleading.
- Step 4: Tighter late-step touch; "wanted to follow up before this slips"; acknowledge the window is closing and offer one clean path forward.
