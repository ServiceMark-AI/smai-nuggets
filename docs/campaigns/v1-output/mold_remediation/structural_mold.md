# Variant: Structural mold

**Sub-type:** Mold Remediation (`mold_remediation`)
**Scenario:** Structural mold (`structural_mold`)
**Industry classification (author-facing only):** IICRC S520 Mold Remediation
**Authoring hypothesis:** Variant assumes structural mold customers know the scope is large and need a calm, substantive voice that signals capability without guarantee, with the testing-and-protocol sequence framed as the load-bearing scope-definition step rather than bureaucratic obstacle, and with stay-hot presence through the Day 7 protocol-writing handoff being the conversion-critical moment.
**Cadence:** 5 steps over 18 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the walkthrough; orient the customer to the testing-and-protocol sequence as normal regulated process; set up a decision-oriented next step. |
| 2 | Day 3 | 3d | Help the customer navigate the next step by clarifying why the consultant's testing matters specifically when framing and sheathing are in play. |
| 3 | Day 7 | 4d | Stay visibly present through the protocol-writing handoff window where deals most often die; signal readiness to act once the protocol is in hand. |
| 4 | Day 12 | 5d | Begin tone shift; acknowledge the possibility of protocol delays or stalled momentum; offer a hand without pressing. |
| 5 | Day 18 | 6d | Full soft return; acknowledge that the situation may have resolved or been handled elsewhere; offer a path back if not. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Mold work at {{property_address_short}}`

**Body:**

The proposal for the mold work at {{property_address_short}} is attached, based on what we walked through at the property. It covers what we saw on the framing and sheathing side, the access and demolition work the scope implies, and the sequencing we discussed.

Structural mold scope is genuinely hard to pin down without testing, because what's visible on the surface is usually a fraction of what the testing finds once the consultant gets behind walls and into cavities. The proposal reflects what we expect based on the walkthrough, and we're licensed to do this work in {{state}}, but the protocol from the licensed environmental consultant is what actually defines the boundaries of the remediation scope.

Take your time reviewing it. If you have questions or want to walk through the scope live, give me a call or reply here. When you're ready to move forward on the consultant referral and getting testing scheduled, just let me know and we'll get it set up.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Testing the mold at {{property_address_short}}`

**Body:**

The reason the testing step matters more on a structural mold job than on a smaller surface scenario is that the consultant's protocol is what bounds the demolition. Without a written protocol, a remediation crew is either guessing at where to stop cutting or cutting wider than they need to. Neither outcome is what you want when framing and sheathing are involved.

Most homeowners aren't aware that in regulated states the assessment and the remediation are done by separate companies on purpose. The consultant tests, identifies the affected materials, and writes the protocol; we do the work to that protocol. It's the reason a structural mold job ends with documentation that holds up if it ever needs to.

If the consultant referral hasn't gone out yet or you're stuck on the testing logistics, let me know and I can help move that forward. If you'd rather walk through how the sequence will work on this specific job, give me a call when it's convenient.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Protocol stage at {{property_address_short}}`

**Body:**

If testing has happened or is in progress, you're now in the window where the consultant is writing the protocol. That document usually arrives within a few days of testing, and it's the piece that lets us schedule the remediation work and bring a crew in.

I wanted to make sure I haven't dropped off your radar during this stretch. Once the protocol is in hand, we're ready to move on it. If anything in the protocol is unclear when you receive it, or if the scope reads differently than what we walked through, that's a conversation we should have before scheduling, since the consultant sometimes identifies more affected material than was visible at the walkthrough.

If you want to talk through what to expect once the protocol arrives, give me a call when it's convenient.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The mold remediation at {{property_address_short}}`

**Body:**

A couple of weeks on from when we walked the property. The protocol-writing step on jobs at this scope sometimes runs longer than expected, especially if the consultant's lab turnaround was slow or if the testing surfaced more material than was visible at the original assessment.

If you've hit a snag somewhere in the sequence, on the consultant side, on the testing side, or on something else entirely, I'm happy to help untangle it if it would be useful. If the protocol is in hand and you're sorting through it, I can walk through what the scope and timeline look like once we're cleared to start.

If something has shifted on your end and the timing isn't right anymore, that's a fine outcome too. Either way, I wanted to make sure you have what you need to move this forward when you're ready.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the mold at {{property_address_short}}`

**Body:**

It's been a few weeks since we walked the property at {{property_address_short}}, so things have likely either gotten handled or moved in a different direction. Both are fine outcomes.

The reason I'm reaching back out: structural mold jobs that stall in the protocol-writing window sometimes sit longer than the homeowner intended, not because the situation resolved but because the paperwork lost momentum. If that's where you ended up, the path forward is still the same one we walked through, and we're still here to do the work whenever you're ready to pick it back up.

If something comes up on this or anything related, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Each step references operational specifics a competent professional would know: the surface-versus-actual-scope reality of structural mold, the consultant-bounds-the-demolition logic, the protocol-writing handoff window, the lab-turnaround variance, and the framing-and-sheathing scope language. |
| R2 — Avoids marketing automation language | true | No banned openers; mid-cadence steps open with substance (testing logic at Step 2, protocol-stage status at Step 3, time-progression shift at Step 4, soft-return acknowledgment at Step 5). No "circle back," "checking in," "touching base," "just wanted to," or similar constructions in any opener or closing. |
| R3 — Scenario-specific | true | Variant could not swap in another mold scenario without rewriting. Structural mold's specific reality, scope hard to assess without testing, framing and sheathing in play, the consultant's protocol bounding demolition, runs through every step and is load-bearing in Steps 1, 2, and 3. |
| R4 — No industry jargon | true | No IICRC, S520, TDLR, or regulatory acronyms. Soft licensing allusion uses the calibrated "we're licensed to do this work in {{state}}" form per the v0.8 merge-field update. No "PPE," "HEPA," "containment," or category language. "Remediation" used sparingly alongside plain-language alternatives like "the work" and "demolition." |
| R5 — Trust contract preserved | true | No health claims anywhere; the customer's anxiety is not named or amplified, and the structural framing keeps focus on materials, scope, and process. No false urgency, no coverage promises, no pipeline-management language ("close out," "for our records," "no expectation either way" all absent). Step 4's late-cadence push is customer-situation framing only. |
| R6 — Pulls toward onsite | true | Steps 2 through 5 acknowledge questions and pull toward live conversation rather than resolving in writing. Step 1 is the appropriate exception (proposal delivery from a prior walkthrough, decision-oriented CTA). No specific timeline, scope, or coverage commitments made via email. |

---

## Authoring artifact metadata

**Step count:** 5
**Total duration (days):** 18

**Per-step purposes:**

- Step 1: Deliver the proposal from the walkthrough; orient the customer to the testing-and-protocol sequence as normal regulated process; set up a decision-oriented next step.
- Step 2: Help the customer navigate the next step by clarifying why the consultant's testing matters specifically when framing and sheathing are in play.
- Step 3: Stay visibly present through the protocol-writing handoff window where deals most often die; signal readiness to act once the protocol is in hand.
- Step 4: Begin tone shift; acknowledge the possibility of protocol delays or stalled momentum; offer a hand without pressing.
- Step 5: Full soft return; acknowledge that the situation may have resolved or been handled elsewhere; offer a path back if not.
