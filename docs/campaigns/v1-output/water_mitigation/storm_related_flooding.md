# Variant: Storm-related flooding

**Sub-type:** Water Mitigation (`water_mitigation`)
**Scenario:** Storm-related flooding (`storm_related_flooding`)
**Industry classification (author-facing only):** IICRC S500 Category 3 Water Damage (typical for rising water)
**Authoring hypothesis:** Variant assumes storm-flooding customers receiving multiple unsolicited proposals respond to local-presence proof and scope-clarity-onsite framing more than to duty-to-mitigate pressure, because rising-water coverage exclusions make insurance posture uncertain and the differentiator from storm-chasing competitors is the operator's year-round local operation.
**Cadence:** 6 steps over 5 days
**Authored:** 2026-04-27
**Master prompt version:** v0.7
**SPEC-11 schema version:** v2.0.1

---

## Cadence overview

| Step | Timing | Delay from prior | Purpose |
|---|---|---|---|
| 1 | Hour 0 | 0 | Deliver the proposal from the prior walkthrough; orient customer to what's attached; signal local presence. |
| 2 | Hour 4 | 4h | Add operational specificity on what storm-water cleanup actually looks like and why the source matters for scope. |
| 3 | Hour 12 | 8h | Address the modal storm objection: how to compare the multiple proposals the customer is likely holding. |
| 4 | Hour 24 | 12h | Tighten operational case; a day past the loss, materials are in the timeline that determines salvageable-vs-not. |
| 5 | Hour 48 | 24h | Close the live window with customer-situation framing on materials and claim posture. |
| 6 | Day 5 | 3d | Soft return; acknowledge several days have passed; make the "local, not storm circuit" point one more time. |

---

## Step 1

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Storm water cleanup at {{property_address_short}}`

**Body:**

The proposal for the storm water cleanup at {{property_address_short}} is attached, based on what we walked through at the property. It covers the extraction, the drying scope, the equipment plan, and the timeline we discussed.

A note on context: storm events bring a lot of out-of-area companies into the neighborhood for a few weeks, then they're gone. We're local, we work this area year-round, and the proposal reflects what we'd quote on any similar job whether or not a storm had come through. If anything in the scope is unclear or you want to walk through any part of it, give me a call or reply here. Happy to talk through it by phone, or if you'd rather sit with the proposal in front of us together at the property, that works too.

When you're ready to move forward, just let me know and we'll get a crew on the schedule.

---

## Step 2

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Drying scope for the storm water at {{property_address_short}}`

**Body:**

A practical note on what storm-water cleanup actually involves once a crew is onsite. The first day is extraction and demo of materials that won't dry back: typically wet drywall to a cut-line above the water mark, baseboards, and any saturated insulation. Then equipment goes in: air movers and dehumidifiers running continuously, with moisture readings checked each day so we know when materials are actually dry versus just feeling dry on the surface.

Most storm-water jobs at this scope run 4-6 days of equipment time, sometimes longer when there's hardwood, dense materials with heavy absorption, or the water reached subfloors and wall cavities. The proposal reflects what we expect to see based on the walkthrough; if the equipment readings tell us something different once it's running, we'll adjust and keep you in the loop.

If you want to talk through any of the scope or the timeline, easiest by phone.

---

## Step 3

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Comparing the storm water proposals at {{property_address_short}}`

**Body:**

After a storm event, most homeowners we work with are holding two or three proposals from different companies. A useful frame for comparing them: what does each proposal include for extraction, what's the demo scope (which materials get removed and to what cut-line), how many days of equipment time, and what's the documentation plan for the carrier if you're filing a claim.

Storm flooding sits in a different insurance category than a pipe burst or appliance failure, and rising-water coverage varies a lot by policy. We can't tell you what your carrier will or won't cover, but we can tell you that proposals built without a clear demo scope and without daily moisture documentation tend to create problems on the claim side regardless of how the policy reads. The walkthrough we did is the basis for the scope in the attached proposal, and the documentation plan is built in.

If you have questions about how this proposal compares to others you're looking at, give me a call. That's a faster conversation by phone than email.

---

## Step 4

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`A day past the storm water at {{property_address_short}}`

**Body:**

About a day past the loss now, the drying picture changes. Materials that were wet at intake are still in the range where extraction and equipment can handle them. Materials that have been sitting since the storm came through are starting to shift toward the line where drying alone stops being the answer and replacement enters the conversation.

For storm-source water specifically, the contamination question gets larger the longer water sits regardless of how clean it looked when it came in. That changes the demo scope, the personal-protective approach for the crew, and the documentation the carrier will look at if you do file. None of that is solved by waiting another day to see how it looks.

If you'd like to move forward, reply here or give me a call and we'll get a crew on the schedule. If you have questions you'd rather talk through live, easier by phone.

---

## Step 5

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`The window on the storm water at {{property_address_short}}`

**Body:**

About two days past the loss now, we're at the edge of the window where moving fast still meaningfully changes the outcome on this job. Materials that have been sitting wet for two days are mostly past the point where drying with equipment alone can save them. The job becomes a larger one; floors and walls take damage that's harder to reverse, and on the claim side, there's more room for the carrier to question whether the additional damage had to happen.

If you've already moved forward with another company, that's fine. If you're still working through the decision, the proposal at {{property_address_short}} reflects the scope we walked through and we can have a crew onsite within 24 hours of approval.

If you want to move forward, reply here or call and we'll get on the schedule. If you'd rather talk through any of it live, easier by phone.

---

## Step 6

**Subject (post-prefix; engine prepends `[{{job_number}}]` at send time):**

`Following up on the storm water at {{property_address_short}}`

**Body:**

Several days on from the storm now, so things have likely either gotten handled or moved in a different direction. Either of those is a fine outcome.

The reason I'm reaching back out: storm-source water sometimes looks settled at the surface and then shows up later. A soft spot in the floor, a cupping board, a stain on a ceiling below, a smell that wasn't there before, those are the kinds of things that surface when materials weren't fully dried out. If anything like that has come up at {{property_address_short}}, even if the original work was done by someone else, that conversation is still worth having.

We're local and we work this area whether or not a storm has come through, so if something turns up weeks or months from now, we're still around. If anything comes up, I'm here.

---

## Self-evaluated rubric

| Criterion | Pass | Notes |
|---|---|---|
| R1 — Sounds like someone who knows the work | true | References cut-lines above water marks, daily moisture documentation, demo scope for storm-source contamination, and 4-6 day equipment runs with crew procedure changes for contaminated source. |
| R2 — Avoids marketing automation language | true | No banned openings; mid-cadence steps open with substance (operational fact, comparison angle, time progression, customer-situation reference); no "circle back," "checking in," or "just wanted to" anywhere. |
| R3 — Scenario-specific | true | Storm-circuit-vs-local framing in Steps 1, 3, and 6; rising-water coverage uncertainty in Step 3; multi-proposal comparison framing in Step 3 specific to post-storm neighborhood dynamics; could not be swapped for clean_water_flooding without rewriting. |
| R4 — No industry jargon | true | No IICRC, S500, Category 3, EPA, or licensing references in customer prose. "Cleanup," "extraction," "demo," "drying," and "moisture readings" used in plain language; carrier and claim used naturally. |
| R5 — Trust contract preserved | true | No coverage promises (Step 3 explicitly says "we can't tell you what your carrier will or won't cover"); no health or contamination-spreading claims (Step 4 references contamination shifting demo scope and PPE, not health); no pipeline-management language; no operator-pipeline framing in Step 5 (centers on customer's materials and claim, not on proposal value). |
| R6 — Pulls toward onsite | true | Mid-cadence steps signal availability by phone or in-person review without trying to fully resolve insurance, scope detail, or competitor comparison via email; scope adjustments framed as crew-onsite work, not email-resolved. |

---

## Authoring artifact metadata

**Step count:** 6
**Total duration (days):** 5

**Per-step purposes:**

- Step 1: Deliver the proposal from the prior walkthrough; orient customer to what's attached; differentiate from out-of-area storm-chasing competitors via local presence; decision-oriented CTA.
- Step 2: Add operational specificity on extraction, demo scope, equipment time, and moisture documentation so customer understands what they're committing to.
- Step 3: Address the modal storm objection (multiple competing proposals); offer a comparison frame; acknowledge rising-water coverage uncertainty without promising any outcome.
- Step 4: Tighten operational case at 24 hours past loss; describe how storm-source contamination dynamics change with elapsed time; customer-situation framing on demo scope and claim documentation.
- Step 5: Close the live window with customer-situation framing on materials, property, and claim posture; not pleading; offer a clean path forward or off.
- Step 6: Soft return at Day 5; explicitly assume customer has moved on or solved the problem; reinforce local-not-storm-circuit positioning so the relationship survives even if this job did not.
