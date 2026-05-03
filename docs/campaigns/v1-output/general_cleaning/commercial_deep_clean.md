# Variant: Commercial deep clean

**Sub-type:** General Cleaning (`general_cleaning`)
**Scenario:** Commercial deep clean (`commercial_deep_clean`)
**Industry classification (author-facing only):** Non-IICRC (general cleaning is unregulated)
**Authoring hypothesis:** Variant assumes commercial deep-clean customers convert on operational specificity about what a deep clean covers that janitorial does not, paired with explicit accommodation of business-timing constraints (off-hours, minimal disruption); the Day 4 push leans on the customer's own downstream date rather than any operator-pipeline framing, and the Day 6 step uses the tighter "before this slips" register because the cadence is too short for a full soft-return arc.
**Cadence:** 4 steps over 6 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 (immediate on approval) | Deliver the proposal from the prior walkthrough; confirm scope and the scheduling approach; signal availability for review by phone, reply, or in person; set up the customer's decision to authorize the work. |
| 2 | Day 2 | 2d | Add a useful angle on what a one-time deep clean actually covers that regular janitorial does not, and signal real scheduling flexibility around the customer's operating hours. |
| 3 | Day 4 | 2d | Direct push centered on the customer's own downstream date and the practical reality that crew slots tighten as the window closes; no operator-pipeline framing. |
| 4 | Day 6 | 2d | Tight final touch using "before this slips" register; acknowledges the tight conversion window without dwelling; offers a clean path back if the customer's situation has shifted. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Deep clean proposal for {{property_address_short}}`

**Body:**

The proposal for the deep clean at {{property_address_short}} is attached, based on the scope we walked through onsite. It covers the surfaces, areas, and finish standard we discussed, with the schedule built around your operating hours so the work happens with minimal disruption to the business.

Most jobs at this scope run a single window with a full crew, sometimes split across an evening and the following morning when the space needs to be back in operation early. If anything in the schedule needs to flex around tenants, staff, or a specific reopen time, that is normal and we can adjust.

Take whatever time you need to review. If you want to walk through any part of the scope or the schedule, give me a call or reply here. When you are ready to authorize the work, just let me know and we will lock in the crew.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Scope on the deep clean at {{property_address_short}}`

**Body:**

The reason a deep clean is its own scope, separate from regular janitorial, is that it gets to the surfaces and details janitorial passes by. Above hand-height surfaces, vent intakes and registers, equipment-adjacent zones, baseboards and door frames, restrooms taken to a hard reset rather than a daily wipe-down, floors stripped and refinished rather than buffed where the floor calls for it. The proposal already reflects what we walked through; this is just the framing for why the scope reads the way it does.

On the schedule side, we can run after hours, overnight, or across a weekend if any of those fit your operating reality better than a normal weekday window. If your usual janitorial team will be back in the space the day after, the deep clean leaves them on a clean baseline that holds longer.

Happy to walk through any of it on the phone if it would help.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Scheduling the deep clean at {{property_address_short}}`

**Body:**

A few days into the conversation now, and the practical question is when the work actually fits in your calendar. If you have a specific date the space needs to be back in normal operation, a tenant returning, an event, an inspection, a quarter close, that date is the one that drives our scheduling backwards from there.

Crew availability tightens as we get closer to the date you have in mind, especially if the work needs to happen on an evening, overnight, or weekend window. The earlier we lock in the slot, the easier it is to keep the work inside your preferred window rather than having to flex into hours that disrupt the business.

If you want to set a date, reply here or give me a call and we will get it on the schedule. If there are still questions on scope or timing you would rather work through live, that is easier by phone.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the deep clean at {{property_address_short}}`

**Body:**

Wanted to follow up on the deep clean at {{property_address_short}} before this slips off the radar in either direction. Six days in, things have either gotten handled, the timing has changed on your end, or the work is still on the list and just has not been scheduled yet. Any of those is a fine outcome.

If the work is still on the list, the proposal as scoped is still good and we can pick the schedule up wherever your calendar makes sense. If your situation has shifted, no follow-up needed from your side.

Either way, I am here if you want to talk through it.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Names operational specifics a working professional would (above hand-height surfaces, vent intakes, equipment-adjacent zones, floors stripped vs buffed, after-hours/overnight/weekend windows, leaving janitorial on a clean baseline); voice is grounded, not effusive. |
| R2 — Avoids marketing automation language | true | No banned phrases; mid-cadence Steps 2 and 3 open with substance (the scope distinction; the practical timing question); Step 4 opens with "Wanted to follow up... before this slips" which is the cadence document's prescribed tighter-than-soft-return register for general cleaning Day 6, not a generic "circling back" opener. |
| R3 — Scenario-specific | true | Commercial-specific operational anchors throughout (operating hours, tenants, staff, reopen time, weekday vs weekend windows, quarter close, inspection, the janitorial-vs-deep-clean distinction); not interchangeable with move_in_move_out, post_construction_cleanup, or odor_remediation. |
| R4 — No industry jargon | true | No IICRC, no S-numbers, no licensing references (correct for general_cleaning per master prompt R4); plain language throughout (deep clean, hard reset, stripped and refinished). |
| R5 — Trust contract preserved | true | No promises of automated approval, no false urgency, no specific insurance procedural advice; no pipeline-management language ("close out the file," "let me know either way," "no expectation either way" all absent); no health/biological/air-quality claims; Day 4 push centers on customer's downstream date, not operator pipeline economics; Step 4 acknowledges life happens without asking for a status update. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented (proposal already in hand from the prior walkthrough); mid-cadence steps acknowledge scope and scheduling questions without trying to fully resolve them in email and pull toward a phone call; no specific cost or timeline commitments that depend on factors only visible onsite. |

---

## Authoring artifact metadata

**Step count:** 4
**Total duration (days):** 6

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; confirm scope and the scheduling approach built around the customer's operating hours; signal availability for review by phone, reply, or in person; set up the decision to authorize the work.
- Step 2: Add a useful angle on what a one-time deep clean actually covers that regular janitorial does not (above hand-height surfaces, vent intakes, equipment-adjacent zones, floors stripped/refinished, restroom hard reset); signal real scheduling flexibility around operating hours.
- Step 3: Direct push centered on the customer's own downstream date (tenant return, event, inspection, quarter close) and the practical reality that crew slots in off-hours windows tighten as the window closes; no operator-pipeline framing.
- Step 4: Tighter-than-soft-return final touch using the "before this slips" register prescribed by the cadence document; acknowledges the tight conversion window without dwelling; offers a clean path back if the customer's situation has shifted.
