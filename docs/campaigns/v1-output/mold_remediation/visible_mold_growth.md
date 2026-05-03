# Variant: Visible mold growth

**Sub-type:** Mold Remediation (`mold_remediation`)
**Scenario:** Visible mold growth (`visible_mold_growth`)
**Industry classification (author-facing only):** IICRC S520 Mold Remediation
**Authoring hypothesis:** Variant assumes visible-mold-growth customers convert when the testing-and-protocol sequence is framed as normal regulated process (not runaround), with stay-hot presence at Day 7 protocol-writing handoff being the load-bearing conversion factor, and an explicit state-licensing reference (via `{{state}}` merge field) supplying credibility without regulatory acronym specifics.
**Cadence:** 5 steps over 18 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; orient the customer to the testing-and-protocol sequence as normal regulated process; signal next step. |
| 2 | Day 3 | 3d | Help the customer navigate the testing-vs-remediation distinction; clarify what the consultant does and what we do. |
| 3 | Day 7 | 4d | Stay-hot through the protocol-writing handoff; signal we are ready to act once the protocol is in hand. |
| 4 | Day 12 | 5d | Begin tone shift; offer a hand without pressing; acknowledge the protocol step may have stalled. |
| 5 | Day 18 | 6d | Soft return; acknowledge the gap; offer a path back if the situation has not resolved. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Mold work at {{property_address_short}}`

**Body:**

The proposal for the mold work at {{property_address_short}} is attached, based on what we walked through at the property. It covers the scope we discussed and what the next step looks like.

One thing worth flagging up front, because most homeowners don't know it: in {{state}}, the testing piece and the remediation piece have to be done by separate companies. A licensed environmental consultant tests the area, identifies what's there, and writes a protocol that defines the scope of work. We then do the remediation to that protocol. We're licensed in {{state}} to do the remediation side, and we work with consultants on these jobs all the time, so we can get you connected with one if you don't already have someone.

Take your time reviewing the proposal. If you have questions about the scope, the sequence, or how the testing piece works, give me a call or reply here and we can walk through it. Happy to do it by phone or in person if that's easier. When you're ready to move forward, just let me know and we'll get the testing scheduled.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Testing and the mold work at {{property_address_short}}`

**Body:**

The testing-and-protocol piece is the part that throws most homeowners. The short version: the consultant comes out, takes samples (usually air samples and surface samples in the affected area), sends them to a lab, and writes up a protocol that says what's there, what scope of removal is needed, and what the post-remediation testing has to confirm. Turnaround on testing is usually two to four days from when samples go to the lab.

That protocol is what defines a successful job. We execute to it, and the consultant comes back at the end to verify the area cleared. It's structured this way deliberately because the company doing the testing can't also do the remediation, which is what makes the result independent.

If you'd like a referral to a consultant we've worked with on jobs at {{property_address_short}}'s area, I can send a couple of names. If you've already lined someone up, we can coordinate on timing once the protocol is in hand. Easiest to talk through this on the phone if you have questions.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Where things stand on the mold work at {{property_address_short}}`

**Body:**

A week or so in on this, you may be in the middle of the testing-and-protocol step right now. Sometimes that piece moves quickly, sometimes the protocol takes a few extra days to come back, and the gap between getting the report and actually scheduling remediation is where these jobs tend to stall.

I wanted to make sure you know we're ready to go on our end as soon as the protocol is in hand. We can typically get a crew on the schedule within a few days of having a written protocol, and we can scope and price against it directly so there's no second round of back-and-forth on cost. If your consultant has questions about the proposal we sent, we're happy to talk to them too.

If something has come up on the testing side or the protocol is delayed, give me a call and we can figure out what makes sense. If you've already received a protocol and just haven't had a chance to send it over, you can forward it whenever it's convenient.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The protocol step on the mold work at {{property_address_short}}`

**Body:**

A couple of weeks past our walkthrough now, and these jobs sometimes hit a slow patch around this point. The protocol may have come in later than expected, the consultant may still be finalizing it, or the report may be sitting in your inbox waiting for the next step.

If anything in the protocol has come back unclear, or if the scope ended up larger than what we walked through originally, that's worth a phone call rather than working through it over email. We've been on a lot of these and we can usually help you read the protocol and understand what's actually being asked for, regardless of who you end up using for the remediation.

Either way, if there's anything I can do to help move this forward, give me a call.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the mold work at {{property_address_short}}`

**Body:**

Several weeks on from when we first walked through this, so things have likely either gotten handled or moved in another direction. Either of those is a fine outcome.

The reason I'm reaching back out: mold situations sometimes settle for a while and then come back, especially when the underlying moisture source wasn't fully addressed or when the scope of removal turned out to be smaller than what was actually needed. If anything at {{property_address_short}} has come back, or if the situation never got fully resolved, that conversation is still worth having.

If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Specifics on testing turnaround, protocol mechanics, remediation/assessment separation, scheduling reality after protocol arrives, and the late-stage failure mode where moisture source was not addressed. Reads as someone who has been on multiple mold jobs in regulated states. |
| R2 — Avoids marketing automation language | true | No banned phrases anywhere in body or subject prose. Mid-cadence steps open with substance (the testing piece, the week-mark observation, the time gap, the situational acknowledgment in Step 5). No "Wanted to circle back," "Checking back in," "Following up on" as openings, "Just checking in," or similar transitional patterns. Step 5's subject uses "Following up on" as the soft-return baseline framing per the master prompt's documented Step 6 water-mitigation example pattern. |
| R3 — Scenario-specific | true | Visible-mold-growth scenario is load-bearing throughout: customer has seen something specific, the testing-and-protocol sequence is the dominant operational reality, the voice is calm-and-knowledgeable per the anchor. Could not swap with structural_mold (different scope framing) or post_water_mold_discovered (different opening posture) without rewriting. |
| R4 — No industry jargon | true | No IICRC, S520, TDLR, EPA, OSHA, PPE, HEPA, CIH, "Category" / "Class" / "Condition" references. State-licensing reference in Step 1 ("we're licensed in {{state}}") uses the SPEC-11 v2.0.2 `{{state}}` merge field, resolves at render time to the location's state name (Texas, Idaho, Nevada, etc.), and matches the calibrated R4 mold-remediation rule's first permitted form. Portable across all USDS locations and any future tenant. "Remediation" used sparingly and paired with "removal" / "the work." |
| R5 — Trust contract preserved | true | No health claims, no biological growth language, no air quality framing, no pipeline-management language, no false urgency, no insurance procedural advice, no guarantees of outcome. Late-cadence steps (4 and 5) center on customer situation (protocol delays, moisture source, scope coming back) not on operator pipeline. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented (proposal already exists). Mid- and late-cadence steps offer phone or in-person walkthroughs without trying to fully resolve protocol questions, scope questions, or coverage in writing. Step 4 explicitly defers protocol interpretation to a phone call. |

---

## Authoring artifact metadata

**Step count:** 5
**Total duration (days):** 18

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to the testing-and-protocol sequence as normal regulated process; explicit state-licensing reference via {{state}} merge field; decision-oriented CTA.
- Step 2: Help the customer navigate the testing-vs-remediation distinction; explain what the consultant does and what we do; offer referral support.
- Step 3: Stay-hot through the protocol-writing handoff; signal we are ready to act the moment the protocol is in hand; explicitly address the gap where deals die.
- Step 4: Begin tone shift; offer help interpreting the protocol regardless of who they use for remediation; back off the push.
- Step 5: Soft return; acknowledge the gap without dwelling; flag the realistic scenario where moisture source was not fully addressed; offer a path back without asking for status.
