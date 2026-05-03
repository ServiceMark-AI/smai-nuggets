# Variant: Trauma / crime scene

**Sub-type:** Environmental / Trauma (`trauma_biohazard`)
**Scenario:** Trauma / crime scene (`trauma_crime_scene`)
**Industry classification (author-facing only):** IICRC S540 Trauma and Crime Scene Cleanup; OSHA Bloodborne Pathogens Standard 29 CFR 1910.1030
**Authoring hypothesis:** Variant assumes trauma scene customers (typically a remaining family member, landlord, or property manager handling an aftermath they did not cause) respond to steady, quiet capability and discretion signals more than to operational specificity or empathy framing, with the load-bearing conversion factors being speed-to-onsite and the assurance that the operator has handled situations like this before.
**Cadence:** 3 steps over ~12 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; establish quiet capability; set up decision path without urgency. |
| 2 | Day 5 | 5d | Follow up without pressure; add useful operational clarity (every job is different, customer presence not required, honest insurance posture); pull toward onsite without push. |
| 3 | Day 12 | 7d | Soft return calibrated to trauma context; acknowledge customer may have moved forward elsewhere or lacked bandwidth; offer path back without re-engagement push. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Cleanup work at {property_address_short}`

**Body:**

The proposal for the cleanup work at {property_address_short} is attached, based on what we walked through when we were there. Every job in this category is a little different, and the scope reflects what we actually saw rather than a standard package.

What I can tell you is that we've handled a lot of these. Unmarked vehicles, no signage, in and out as quickly as the work allows. Once access is arranged, you don't need to be there while the crew is working unless you want to be. Most jobs in this category we can start within 24 to 48 hours of approval.

Take whatever time you need to review the proposal. When you're ready to move forward, or if there are questions you'd rather talk through live, give me a call.

---

## Step 2

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`Next steps for the cleanup at {property_address_short}`

**Body:**

A few things often come up at this stage that are worth saying directly. Every trauma scene job is different, and what looks like a small scope from the outside sometimes isn't, and the other way around. Real assessment happens when we're there with the crew, which is also when we get you a firm timeline.

On the practical side: you don't need to be onsite while we work, only present long enough to arrange access. On insurance, coverage varies. If there is coverage, we can work directly with the carrier and bill them. If there isn't, the work is straightforward to handle as a direct engagement.

If you'd rather walk through any of this on the phone, give me a call when it's convenient. When you're ready to move forward, just let me know and we'll get on the schedule.

---

## Step 3

**Subject (post-prefix; engine prepends `[{job_number}]` at send time):**

`If we can still help at {property_address_short}`

**Body:**

A couple of weeks on from when we first came out, my guess is this has either been handled or moved in a different direction, and either of those is a fine outcome.

The reason I'm reaching back out: situations like this sometimes get partially addressed and then a piece resurfaces later, or the original plan falls through and the family is back to figuring out who to call. If anything along those lines has come up at {property_address_short}, the offer still stands and the proposal is still good.

If something's changed and we can help, give me a call.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Specifics that signal experience without performance: unmarked vehicles, no signage, work without customer presence, 24-48 hour onsite window, real-assessment-happens-onsite framing. |
| R2 — Avoids marketing automation language | true | No banned openings; no "circle back," "checking back in," or "following up on" as a body opener; Step 2 opens on substance ("A few things often come up at this stage"); Step 3 opens with the time-elapsed acknowledgment, not a transitional phrase. |
| R3 — Scenario-specific | true | Scenario load-bearing throughout: discretion signals, customer-not-present framing, honest insurance posture for self-pay reality, every-job-is-different framing, and the soft-return acknowledgment that families sometimes have a piece resurface, all specific to trauma scene work and not swappable with another sub-type. |
| R4 — No industry jargon | true | No IICRC, S540, OSHA, CFR, PPE, biohazard, or bloodborne references in customer prose. No licensing allusion of any kind, per the trauma_biohazard explicit prohibition. |
| R5 — Trust contract preserved | true | No automated-approval claims, no false urgency, no insurance outcome promises, no health/safety/biohazard claims, no pipeline-management language. Customer-situation framing throughout; no operator-pipeline framing. Coverage stated as honest reality without prediction. |
| R6 — Pulls toward onsite | true | Step 1 is decision-oriented (proposal already delivered from prior walkthrough); Steps 2 and 3 acknowledge that real scope, real timeline, and real answers happen in person without trying to resolve specifics in writing. |

---

## Authoring artifact metadata

**Step count:** 3
**Total duration (days):** 12

**Per-step purposes:**

- Step 1: Deliver the proposal that came out of the prior walkthrough; establish quiet capability and discretion as experience signals; set up a decision-oriented path forward without urgency.
- Step 2: Follow up without pressure; add useful operational clarity on customer presence, scope variability, and coverage; pull toward onsite for real assessment without pushing on timing.
- Step 3: Soft return calibrated to trauma context; acknowledge the customer may have moved forward or lost bandwidth; offer a path back if their situation requires it; no re-engagement push.
