# Variant: Post-water mold discovered

**Sub-type:** Mold Remediation (`mold_remediation`)
**Scenario:** Post-water mold discovered (`post_water_mold_discovered`)
**Industry classification (author-facing only):** IICRC S520 Mold Remediation
**Authoring hypothesis:** Variant assumes customers who suspect mold after a prior water event respond to an investigative-but-non-blaming posture that treats their suspicion as plausible and routine, with the testing-and-protocol sequence framed as normal regulated process and Day 7 stay-hot presence carrying the load through the protocol-writing handoff.
**Cadence:** 5 steps over ~18 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal; orient the customer to the testing-and-protocol sequence as normal regulated process; establish investigative-but-not-alarmed presence. |
| 2 | Day 3 | 3d | Help the customer navigate the next step by clarifying what the consultant does and what we do. |
| 3 | Day 7 | 4d | Stay-hot through the protocol-writing window; signal we are ready to act the moment the protocol is in hand. |
| 4 | Day 12 | 5d | Begin tone shift; acknowledge the protocol-writing handoff often stalls; offer help without pressing. |
| 5 | Day 18 | 6d | Soft return; acknowledge the gap; leave a clean path back if the situation has not been handled. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Mold work at {{property_address_short}}`

**Body:**

The proposal for the mold work at {{property_address_short}} is attached, based on what we walked through at the property. It reflects what we found and what you described from the original water event, and it covers the scope we expect once a remediation protocol is in hand.

One thing worth knowing if it hasn't come up yet: in {{state}}, mold testing and mold remediation are done by separate companies. A licensed environmental consultant tests the affected areas and writes a protocol, which is the document that defines what the remediation work has to accomplish. We do the remediation to that protocol. We're licensed in {{state}} for this work, and we can connect you with a consultant we trust if you don't already have one. It's not a runaround, it's how the regulated process works.

Take your time with the proposal. If you have questions or want to walk through any part of it, give me a call or reply here. When you're ready to move forward on testing or to talk about timing, let me know and we'll get the next step lined up.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Testing and the mold work at {{property_address_short}}`

**Body:**

The piece that catches most people off guard on a job like this is the order of operations. The consultant tests, gets results back in two to four days in most cases, and writes a protocol that tells us exactly which materials come out, which surfaces get treated, and how the area gets sealed off during the work. Once that protocol is in hand, we can schedule and execute. Without it, we can't legally start the remediation in {{state}}.

What this means in practice is that the next two to three weeks usually break into pieces: testing scheduled, results back, protocol written, then the remediation work itself. If you want, I can connect you with a consultant we've worked with before, or you're welcome to find your own. Either way, we stay in the loop and pick up the work once the protocol is written.

If anything about the sequence is unclear or you want to walk through it on the phone, give me a call when it's convenient.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Protocol step at {{property_address_short}}`

**Body:**

About a week in now, you are likely either waiting on test results, waiting on the protocol to be written, or somewhere in that handoff. That window is where these jobs most often go quiet, not because anyone's doing anything wrong, but because a document moves between the customer, the consultant, and the remediation company, and it's easy for momentum to slip while you wait on it.

The reason this matters: the situation that prompted the original call hasn't changed. If something was missed during the prior water work, it's still there, and the materials around it are still doing what they were doing before. We're ready to act the moment the protocol lands. If you want help moving any piece of this along, whether that's nudging the consultant on protocol turnaround or walking through what the protocol is going to ask us to do once we have it, give me a call.

If you'd rather wait until you have the protocol in hand before talking again, that works too.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The mold work at {{property_address_short}}`

**Body:**

Wanted to make sure you have what you need to keep this moving. The protocol-writing handoff is where a lot of these jobs lose momentum, and the customer often ends up holding a document they don't fully understand and aren't sure what to do with next.

If that's where things have landed, I'm happy to walk through the protocol with you, talk through what the scope means in plain terms, and confirm what the work would look like and how long it would take. There's no obligation in any of that. If the situation has changed or you've gone in a different direction, that's a fine outcome too; the proposal stays good either way if you decide to come back to it.

If now is a good time to talk it through, give me a call when it's convenient.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the mold work at {{property_address_short}}`

**Body:**

It's been a few weeks since we walked through the property, and there's a good chance the situation has either been handled or moved in a different direction. Either of those is a fine outcome.

The reason I'm reaching back out: post-water mold cases sometimes look settled and then surface again later. A new musty smell in the same room, a soft spot in flooring or trim, a stain on a wall or ceiling that wasn't there before, those are the kinds of things that show up when the original water event left more behind than was caught the first time. If anything like that has come up at {{property_address_short}}, even if you've worked with another company in the meantime, that conversation is still worth having.

If something comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Voice carries operational specifics about the testing-protocol-remediation sequence, two-to-four-day testing turnaround, and the handoff dynamics that signal real experience. |
| R2 — Avoids marketing automation language | true | No banned phrases; mid-cadence steps open with substance rather than transitional follow-up phrasings. |
| R3 — Scenario-specific | true | The investigative posture, references to the prior water event, and the "something was missed the first time" framing are load-bearing across all five steps and would not fit visible_mold_growth, crawlspace_mold, or structural_mold without rewriting. |
| R4 — No industry jargon | true | No IICRC, S-numbers, TDLR, OSHA, or category language; "we're licensed in {{state}}" used as the soft licensing allusion permitted for mold variants. |
| R5 — Trust contract preserved | true | No health claims, no biological-growth claims, no air-quality framing; no pipeline-management language; no blame language toward the prior vendor; no guarantees on outcomes. |
| R6 — Pulls toward onsite | true | Step 1 is decision-oriented per the proposal-already-delivered rule; mid-cadence steps point toward phone or in-person conversation rather than resolving questions in writing. |

---

## Authoring artifact metadata

**Step count:** 5
**Total duration (days):** 18

**Per-step purposes:**

- Step 1: Deliver the proposal; orient the customer to the testing-and-protocol sequence as normal regulated process; establish investigative-but-not-alarmed presence with the soft licensing allusion in {{state}}.
- Step 2: Help the customer navigate the next step by clarifying the testing-protocol-remediation sequence and what each company does.
- Step 3: Stay-hot through the protocol-writing window; signal we are ready to act the moment the protocol is in hand; offer help moving the handoff along.
- Step 4: Begin tone shift; acknowledge the protocol-writing handoff often stalls customers; offer to walk through the protocol without pressing.
- Step 5: Soft return; acknowledge the elapsed time; leave a clean path back if symptoms have re-emerged or the situation hasn't actually been handled.
