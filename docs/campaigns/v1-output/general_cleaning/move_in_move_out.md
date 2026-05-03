# Variant: Move-in / move-out

**Sub-type:** General Cleaning (`general_cleaning`)
**Scenario:** Move-in / move-out (`move_in_move_out`)
**Industry classification (author-facing only):** Non-IICRC (general cleaning is unregulated)
**Authoring hypothesis:** Variant assumes move-in / move-out customers are operating against a hard transition date and convert on logistical confidence (timing, scope clarity, fit-for-purpose) rather than warmth or capability claims; the lever across the cadence is the customer's own downstream date, not any operator-side urgency.
**Cadence:** 4 steps over ~6 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; orient the customer to scope and timing; signal that the operator can move on the customer's transition window. |
| 2 | Day 2 | 2d | Add a useful angle on what makes a move-in / move-out clean different from a regular cleaning service, and signal scheduling availability against the customer's date. |
| 3 | Day 4 | 2d | Direct push centered on the customer's own downstream date; the conversion window is closing and scheduling needs to lock in. |
| 4 | Day 6 | 2d | Final touch; tighter than a long-cadence soft return; "before this slips" framing without dwelling. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Move-out clean at {{property_address_short}}`

**Body:**

The proposal for the move-in / move-out clean at {{property_address_short}} is attached, based on the walkthrough we did at the property. It covers the rooms in scope, what we're handling that a regular cleaning service typically wouldn't, and the timing we discussed against your transition date.

Most jobs at this scope take a full day with a crew, sometimes a day and a half if the prior occupant left more behind than usual or if specific surfaces need extra attention. The proposal reflects what we saw at the walkthrough; if anything looks different once we're back in the space with the cleaning crew, we'll keep you in the loop before any scope adjusts.

Take your time reviewing it. If you have questions or want to walk through any part of it, give me a call or reply here. When you're ready to move forward, just let me know your preferred date and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Scheduling the clean at {{property_address_short}}`

**Body:**

A move-in / move-out clean is a different scope than a recurring cleaning service, and that's usually the part that takes some explaining. We're handling the things that get left behind when the previous tenant or owner moves out: residue inside cabinets and drawers, the build-up around appliances that doesn't come off with a regular wipe, baseboards and trim, the bathrooms at a level a new occupant won't have to redo. Most maid services aren't set up for this kind of pass.

On scheduling: we typically have a 1-2 day lead time for a job at this scope, longer if your date falls on a weekend or close to a holiday. If your move-in or hand-off date is locked, working backward from that gives us the cleanest scheduling target.

If it would help to talk through scheduling on the phone, give me a call when it's convenient.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Locking in the date at {{property_address_short}}`

**Body:**

The window where we can still hit your transition date without compressing the work is starting to tighten. When a move-in / move-out clean gets compressed, the parts that get skipped are the ones that show up later: inside cabinets, behind appliances, the bathroom detail. Those are the things a new occupant or a prospective buyer notices first.

If your date is still where you walked us through it being, the cleanest path now is to lock in scheduling so the crew has the right amount of time on the property. If the date has shifted, that's fine, just let me know what the new target looks like and we'll work backward from there.

When you're ready to move forward, reply here or give me a call and we'll get the date on the schedule.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the clean at {{property_address_short}}`

**Body:**

Wanted to reach out before this slips. If your transition date has come and gone, or if you ended up handling the cleaning a different way, that's a fine outcome.

The reason I'm checking in: move-in / move-out cleans sometimes get half-done by a regular cleaning crew or skipped entirely, and the gap shows up later when the new occupant is already in the space. If anything has come up at {{property_address_short}}, even after the move, we can still come do the work.

If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Concrete operational specifics (1-day crew time, 1-2 day lead, the specific things a regular cleaning crew skips) signal someone who has been on these jobs. |
| R2 — Avoids marketing automation language | true | No banned constructions; mid-cadence steps open with substance, not transitional follow-up phrasing; Step 4's "wanted to reach out before this slips" is the cadence-document-prescribed tighter close, not banned circle-back language. |
| R3 — Scenario-specific | true | Move-in / move-out specifics are load-bearing throughout: prior-occupant residue, transition date logic, the cabinets/appliances/bathroom detail, the "shows up later when occupant is already in the space" frame. Could not swap this for post-construction or commercial deep clean without rewriting. |
| R4 — No industry jargon | true | No IICRC, no S-numbers, no licensing references; general cleaning is non-IICRC and the variant respects that. |
| R5 — Trust contract preserved | true | No health claims, no insurance promises, no false urgency, no pipeline-management language ("close out the file," "where things stand," "either way for our records," etc.); Step 3's push centers on customer's own date, not on operator economics; Step 4 offers a path back without demanding status. |
| R6 — Pulls toward onsite | true | Variant does not try to fully answer scope-detail questions in email; Step 1 is decision-oriented per the carries-attachment rule; mid- and late-cadence steps point toward phone or scheduling, not toward email-resolved scope. |

---

## Authoring artifact metadata

**Step count:** 4
**Total duration (days):** 6

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to scope and timing; signal that the operator can move on the customer's transition window.
- Step 2: Add a useful angle on what makes a move-in / move-out clean different from a regular cleaning service, and signal scheduling availability against the customer's date.
- Step 3: Direct push centered on the customer's own downstream date; the conversion window is closing and scheduling needs to lock in.
- Step 4: Final touch; tighter than a long-cadence soft return; "before this slips" framing without dwelling.
