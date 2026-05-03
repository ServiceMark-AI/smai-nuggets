# Variant: Crawlspace mold

**Sub-type:** Mold Remediation (`mold_remediation`)
**Scenario:** Crawlspace mold (`crawlspace_mold`)
**Industry classification (author-facing only):** IICRC S520 Mold Remediation
**Authoring hypothesis:** Variant assumes crawlspace mold customers, who typically have not personally seen the mold and are operating on a referral from an HVAC tech, plumber, or inspector, respond to practical orientation about why crawlspaces commonly show mold and how the testing-and-protocol sequence works as normal regulated process, with steady presence through the Day 7 protocol-writing handoff being the load-bearing conversion factor.
**Cadence:** 5 steps over ~18 days
**Authored:** 2026-04-28
**Master prompt version:** v0.8
**SPEC-11 schema version:** v2.0.2

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Day 0 | 0 | Deliver the proposal from the prior walkthrough; orient the customer to the testing-and-protocol sequence as normal regulated process; set up the decision. |
| 2 | Day 3 | 3d | Clarify the testing-vs-remediation split and what each company does; reduce confusion about the sequence; keep the operator present as vendor of record. |
| 3 | Day 7 | 4d | Stay-hot through the protocol-writing window where deals most often die; signal readiness to act once the protocol is in hand. |
| 4 | Day 12 | 5d | Begin tone shift; acknowledge protocol delays are common; offer a hand without pressing. |
| 5 | Day 18 | 6d | Soft return; acknowledge several weeks have passed; offer a path back if anything has changed. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Crawlspace mold work at {{property_address_short}}`

**Body:**

The proposal for the crawlspace mold work at {{property_address_short}} is attached, based on what we walked through when we were out at the property.

Crawlspace mold is one of the more common things we get called on, and the sequence is a little different than most people expect. We're licensed in {{state}} to do the remediation side, but a licensed environmental consultant has to do the testing and write the protocol first; we then execute to that protocol. We work with consultants regularly and can connect you with one if you don't already have one lined up.

Take your time reviewing the proposal. If you want to walk through any part of it, give me a call or reply here. When you're ready to move forward on getting testing scheduled, let me know and we'll get the consultant in the loop.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Testing and remediation at {{property_address_short}}`

**Body:**

The testing-and-remediation split trips up most people on their first mold job, and crawlspace cases especially, because you're often working off something a plumber or HVAC tech told you rather than something you've seen yourself. Worth a quick clarification.

The environmental consultant comes out, takes samples in the crawlspace, sends them to a lab, and writes a protocol that specifies what has to be done. That part typically takes a few days from sample to written protocol. Then we come in and do the work the protocol describes. The two scopes are kept separate by design under state licensing, and that separation is the reason a protocol-driven job has clear boundaries on what's in scope.

If you want a referral to a consultant we work with regularly, I can send a few options. If you've already got one moving on it, that works too; we just need a copy of the protocol when it's written and we can be on the schedule.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Crawlspace protocol at {{property_address_short}}`

**Body:**

About a week in on the crawlspace at {{property_address_short}}, so depending on how the testing has moved, you're probably waiting on the protocol or have it in hand.

This is the spot in the process where we like to check in, because once the protocol is written we can get a crew on the schedule pretty quickly. Crawlspaces are a confined-space job, so we plan the work around access points, ventilation conditions, and what the protocol calls for on the framing and any insulation that has to come out. Most crawlspace remediations we do run two to four days of active work, depending on scope.

If the protocol's written, send it over and we'll line up a start date. If it's still in progress and you want me to follow up with the consultant directly to keep things moving, happy to do that.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The crawlspace timeline at {{property_address_short}}`

**Body:**

A couple of weeks on from when we first talked about the crawlspace at {{property_address_short}}, and protocol-writing sometimes takes longer than expected, especially if the consultant ran into unusual conditions or the lab turnaround stretched.

If you've got the protocol now and want to talk through scheduling, give me a call or reply here. If the testing or protocol is still in motion, that's not unusual; let me know where things stand and I can be useful or stay out of the way, whichever helps.

If something else has come up that's changed the picture on the crawlspace work, also good to know.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Checking on the crawlspace at {{property_address_short}}`

**Body:**

Several weeks on from the original conversation about the crawlspace at {{property_address_short}}, so things have likely either gotten handled or moved in another direction. Either of those is a fine outcome.

The reason I'm reaching back out: crawlspace situations can sit quietly for a while and then resurface, especially if the underlying moisture source wasn't fully addressed, or if the testing turned up something more involved than the original plumber or HVAC tech flagged. If anything's come up since we last talked, even if the original work was done by someone else, the conversation is still worth having.

If something does come up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | Operational specifics (testing-and-remediation split as regulated structure, sample-to-protocol turnaround, confined-space crawlspace work, two-to-four-day remediation duration, working with consultants regularly) signal experience without becoming technical. |
| R2 — Avoids marketing automation language | true | No banned openings; mid-cadence steps open on substance (testing-and-remediation split clarification, week-in protocol check-in, two-weeks-in acknowledgment, several-weeks-in soft return). No CRM template fill-in phrasing. |
| R3 — Scenario-specific | true | Crawlspace specifics are load-bearing throughout: customer hearing about it secondhand from plumber/HVAC tech, confined-space job planning, framing and insulation as protocol elements, moisture source as resurfacing risk. Variant cannot be swapped to visible_mold_growth or structural_mold without rewriting most prose. |
| R4 — No industry jargon | true | No IICRC, S520, TDLR, EPA, OSHA, or category language. Soft state-licensing allusion uses the permitted "we're licensed in {{state}}" form per R4 mold rule and v0.8 {{state}} merge field addition. "Remediation" used sparingly. |
| R5 — Trust contract preserved | true | No health claims anywhere (crawlspace-to-living-space air communication is operationally tempting and explicitly avoided). No pipeline-management language ("close out the file," "decision needs to happen," "let me know either way for our records" do not appear). No coverage promises. No automated-approval framing. Customer-situation framing throughout. |
| R6 — Pulls toward onsite | true | Step 1 CTA is decision-oriented (proposal already delivered from prior walkthrough). Mid- and late-cadence steps offer phone or in-person follow-up rather than trying to resolve protocol or scope questions in writing. Step 4 explicitly offers to follow up with the consultant directly rather than answering hypothetical timing questions. |

---

## Authoring artifact metadata

**Step count:** 5
**Total duration (days):** 18

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient the customer to the testing-and-protocol sequence as normal regulated process; set up the decision.
- Step 2: Clarify the testing-vs-remediation split and what each company does; reduce confusion about the sequence; keep the operator present as vendor of record.
- Step 3: Stay-hot through the protocol-writing window where deals most often die; signal readiness to act once the protocol is in hand.
- Step 4: Begin tone shift; acknowledge protocol delays are common; offer a hand without pressing.
- Step 5: Soft return; acknowledge several weeks have passed; offer a path back if anything has changed.
