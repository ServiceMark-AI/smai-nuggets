# SPEC-09: Mark Won and Mark Lost, Primary CTA Visibility on Job Detail

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Mark Won and Mark Lost, Primary CTA Visibility on Job Detail |
| Spec ID | SPEC-09 |
| Version | 1.2.1 |
| Status | Ready for build |
| Date | 2026-04-23 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | April 8 design review; UX hierarchy assessment; v1.3 cycle verification pass 2026-04-22 |
| Related docs | PRD-06 v1.3.1 Job Detail Screen & Sub-Flows; PRD-05 v1.4 Jobs List; PRD-04 v1.2.1 Needs Attention; PRD-01 v1.4.1 Job Record (canonical `pipeline_stage` and `status_overlay`; `cta_type` computed at query time); PRD-03 v1.4.1 Campaign Engine (stop conditions on Mark Won / Mark Lost); PRD-02 v1.5 New Job Intake (collapsed flow; no Draft or Awaiting Estimate states); CC-06 Buc-ee's MVP Definition; Global Navigation & Routing Final MVP Spec |

**Revision note (v1.1):** Verification pass against the v1.3 cycle (SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, PRD-01 v1.4, PRD-02 v1.5, PRD-03 v1.4, PRD-04 v1.2, PRD-05 v1.3, PRD-06 v1.3, PRD-07 v1.2, PRD-10 v1.2). Surgical scope: only changes driven by the v1.3 cycle. No behavioral changes; availability logic, modals, sticky footer, and slices are all unchanged in intent.

1. **Eliminated states removed from availability matrix and edge cases.** Per PRD-01 v1.4 and PRD-02 v1.5 collapsed intake flow, no job record exists in `draft` or `awaiting_estimate` pipeline stages. Every job in the database has `pipeline_stage = 'in_campaign'` or a terminal `won` / `lost` state. §7 availability matrix rewritten to reflect the canonical pipeline stages and status overlays. §11 and §12 edge cases and UX-visible behavior tables cleaned of Draft references.

2. **Terminology aligned to canonical pipeline_stage and status_overlay model.** Per PRD-01 v1.4 §10, the display states SPEC-09 v1.0 called "job status" (In Campaign, Paused, Reply Needed, Delivery Issue) are now surfaced as `pipeline_stage = 'in_campaign'` with a `status_overlay` modifier (`paused`, `customer_waiting`, `delivery_issue`). §7 availability matrix rewritten to use this model. Outcome action availability logic is unchanged; the underlying data reference is clarified.

3. **Stale PRD references corrected.** §0 related docs, §4 source constraint rows, and inline prose references to "PRD-07 Job Status Architecture & CTA Rules" were stale (PRD-07 v1.2 is Analytics; canonical CTA governance now lives in PRD-01 v1.4 and PRD-04 v1.2). Stop-condition governance reference corrected from "PRD-07" to "PRD-03 v1.4." No behavioral change.

Material section changes in v1.1: §0 (meta and related docs), §2 (primary CTA examples aligned to canonical enum), §4 (source constraint rows updated), §7 (availability matrix rewritten), §11 (Draft edge case rows removed), §12 (UX-visible behavior tables cleaned).

**Revision note (v1.2, 2026-04-22):** Two corrections. (1) B-01 terminology fix: four occurrences of `campaign_hold` replaced with `paused`, aligning to PRD-01 v1.4 §6 canonical `status_overlay` enum. PRD-01, PRD-03, PRD-04, PRD-05, and PRD-06 all use `paused`; SPEC-09 v1.1 was the sole outlier. Affected: v1.1 revision note point 2 (historical reference), §7 canonical state model prose, §7 availability matrix row 2, §14 acceptance criterion prose. No behavioral change; the overlay semantics are unchanged. (2) M-04 Path B loss reason write target: §9 now specifies that the loss reason selected in the Mark Lost modal is written to `job_proposal_history.event_payload` as JSON on the `job_marked_lost` event (no new column on `job_proposals`). Matches append-only audit discipline. Closes the data contract gap where v1.1 defined the modal UI but no write target for the selected reason. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 B-01, M-04).

**Patch note (v1.2.1, 2026-04-23):** B2P-01 column-name correction. The v1.2 fix above named `job_proposal_history.event_payload` as the loss-reason write target. PRD-01 v1.4.1 §12 canonical `job_proposal_history` schema has no `event_payload` column; the event-specific JSON payload column is named `metadata` (used correctly by PRD-05 §11.4 for `job_issue_flagged`). §9 "Loss reason write target" rewritten to use `metadata`. JSON key names (`loss_reason`, `loss_notes`) inside the payload are unchanged; only the column name is corrected. No behavioral change. Ref: CONSISTENCY-REVIEW-2026-04-23 B2P-01.

**Patch note (2026-04-23, H2P-01 sweep):** Cross-doc version-reference sweep applied as part of the same Wave 6 cycle. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1`, `PRD-03 v1.4` → `PRD-03 v1.4.1`, `PRD-04 v1.2` → `PRD-04 v1.2.1`, `PRD-05 v1.3` → `PRD-05 v1.4`, `PRD-06 v1.3` → `PRD-06 v1.3.1`. Includes the §0 Related docs cell at line 18, the §4 source constraint rows, §7 canonical state model prose, and §13 inline references. Audit-trail revision-note text preserved byte-exact. The v1.2.1 column-name correction above (B2P-01) is the substantive change; this sweep is pointer-hygiene only and does not affect the v1.2.1 versioning. Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01.

---

## 1. What This Is in Plain English

The most consequential actions an originator can take on a job are recording that they won it or that they lost it. These happen constantly, every time a customer calls to accept the proposal, or tells the originator it is not going to happen. Right now, both actions are buried in the three-dot overflow menu at the top right of the Job Detail screen, alongside Flag Issue and Delete Job.

Hiding Mark Won and Mark Lost in an overflow menu is the wrong hierarchy. An operator in a truck, on a phone, who just got a verbal yes from a customer, should not have to remember that there is a three-dot menu, tap it open, scan a list of four mixed-importance items, and then confirm their selection. The friction is invisible in testing and real in the field.

This spec moves Mark Won and Mark Lost out of the three-dot menu and onto the Job Detail screen as always-visible secondary CTAs. They sit below the primary CTA (whatever the status-driven action is: Open in Gmail, Resume Campaign, Fix Delivery Issue, per the canonical CTA enum in PRD-04 v1.2.1) without competing with it. The three-dot menu retains Flag Issue and Delete Job only, the two actions that are genuinely administrative or destructive and belong in an overflow control.

The spec covers all three form factors: desktop, tablet, and mobile. The treatment differs slightly by form factor to match the interaction model and available screen real estate on each.

---

## 2. What Builders Must Not Misunderstand

1. **Mark Won and Mark Lost are secondary CTAs, not primary.** The Job Detail screen already has a governing UX principle: always show exactly one primary next step. Mark Won and Mark Lost do not replace or compete with the status-driven primary CTA (per the canonical CTA enum in PRD-04 v1.2.1: `open_in_gmail`, `fix_delivery_issue`, `resume_campaign`, `view_job`). They are always-visible secondary actions that sit beneath the primary CTA zone, clearly styled as secondary (outline or text-weight, not filled/teal).

2. **The existing confirmation modals are preserved exactly.** Mark Won already shows a confirmation dialog: "This job will be marked as won. All automated follow-ups will stop and the job will be removed from active campaigns." Mark Lost shows a confirmation with required loss reason and optional notes. Both modals are correct and must not be changed. This spec changes how the operator gets to those modals, not what the modals say or do.

3. **Availability is status-dependent.** Mark Won and Mark Lost are available on active-state jobs only. They are not shown, not grayed out, not shown, on jobs that are already Won or Lost. The exact availability matrix is in Section 7.

4. **The three-dot menu is not removed.** It is reduced. After this spec, the three-dot menu contains only Flag Issue and Delete Job. The edit pencil icon remains in the header. The header control zone does not otherwise change.

5. **On mobile, the outcome actions live in a sticky footer bar.** Mobile Job Detail is a single-column scroll. Putting outcome buttons mid-page creates a hunting problem, they disappear as the operator scrolls through contact info, proposal, and activity log. A sticky footer keeps them reachable at all times without scrolling back up. This is a mobile-specific treatment and is not applied to desktop or tablet.

6. **The outcome actions must never appear to be the same weight as Delete Job.** Delete Job is destructive and irreversible. Mark Won and Mark Lost are operational and reversible (a won job can be reopened or corrected). Visual weight, placement, and confirmation friction must reflect this distinction. Mixing them in the same overflow control was the original problem this spec fixes.

7. **This spec is frontend-only.** The backend logic for Mark Won and Mark Lost already exists and is correct, the confirmation modals, the status transitions, the stop-condition enforcement, and the activity log entries. Nothing in the backend changes. This is a visibility and hierarchy change only.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Corrects a UX hierarchy error identified during the April 8 design review. Mark Won and Mark Lost are the most frequent consequential actions in the product and must be immediately visible on Job Detail without any tap to reveal them. The fix is motivated by real-world usage patterns: Jeff's originators are in the field, often on mobile, often acting quickly on a verbal customer response. Friction on this action loses data.

**What this covers:**
- Removing Mark Won and Mark Lost from the three-dot overflow menu
- Adding Mark Won and Mark Lost as visible secondary CTAs on the Job Detail screen
- Desktop layout: inline secondary button row below the primary CTA zone
- Tablet layout: inline secondary button row, adapted for tablet viewport
- Mobile layout: sticky footer bar with Mark Won and Mark Lost always visible
- Status-dependent availability, which job states show or hide the outcome actions
- Trimming the three-dot menu to Flag Issue and Delete Job only
- Preserving the existing confirmation modals exactly as built

**What this does not cover:**
- Any change to the Mark Won confirmation modal
- Any change to the Mark Lost confirmation modal (including the loss reason options)
- Any change to the backend status transition logic
- Any change to the activity log entries generated by Mark Won or Mark Lost
- Any change to how Won and Lost jobs display on the Jobs List
- Adding outcome actions to the Jobs List card or Needs Attention card
- Any change to the edit pencil icon behavior
- Flag Issue behavior or modal
- Delete Job behavior or confirmation

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| "Always show the operator exactly one primary next step. Never show two CTAs that conflict." | PRD-06 v1.3.1 Job Detail Screen, Section 10 UX Principles |
| The status-driven CTA is the governing primary action. `cta_type` is computed at query time from `pipeline_stage` + `status_overlay`; canonical enum values are `open_in_gmail`, `fix_delivery_issue`, `resume_campaign`, `view_job`. | PRD-01 v1.4.1 §8 and §10; PRD-04 v1.2.1 (canonical CTA enum) |
| Stop conditions are enforced when Mark Won or Mark Lost is confirmed. All automated follow-ups stop. Campaign exits. | Platform Spine v1.4; PRD-03 v1.4.1 (closure path) |
| Append-only proof. The Mark Won / Mark Lost event is written to `job_proposal_history`. This behavior is unchanged. | Platform Spine v1.4; PRD-01 v1.4.1 §12 |
| Mobile responsive layout: sidebar collapses to a collapsible drawer. No bottom tab bar in MVP. | Global Navigation & Routing Final MVP Spec, Section 8 |
| The three-dot menu currently contains: Mark Won, Mark Lost, Flag Issue, Delete Job. | UI audit April 8 |
| Mark Won confirmation modal language: "This job will be marked as won. All automated follow-ups will stop and the job will be removed from active campaigns." | UI audit April 8 |
| Mark Lost confirmation modal: required loss reason radio (6 options) + optional notes field. | UI audit April 8 |
| The edit pencil icon is correctly placed in the header and is unchanged by this spec. | UI audit April 8 |
| No job record exists in a `draft` or `awaiting_estimate` pipeline stage. Every job is either in `in_campaign` (with optional `status_overlay` modifier) or in terminal `won` / `lost` state. | PRD-01 v1.4.1; PRD-02 v1.5 (collapsed intake flow) |

---

## 5. Actors and Objects

**Actors:**
- **Originator**, the primary user of Job Detail on mobile and desktop. Most likely to act on Mark Won after a phone call from a customer.
- **Admin**, also has access to Job Detail and to outcome actions. Same treatment as Originator.
- **System**, executes the status transition, stops the campaign, and writes the audit event. Unchanged by this spec.

**Objects:**
- **Primary CTA zone**, the status-driven action button that currently governs the top of the Job Detail action area. Unchanged by this spec.
- **Outcome action row**, the new secondary CTA area introduced by this spec, containing Mark Won and Mark Lost.
- **Three-dot menu**, the overflow control, trimmed to Flag Issue and Delete Job only.
- **Sticky footer bar (mobile only)**, a fixed-position bar at the bottom of the mobile viewport containing the Mark Won and Mark Lost buttons.
- **Mark Won confirmation modal**, existing, unchanged.
- **Mark Lost confirmation modal**, existing, unchanged.

---

## 6. Workflow Overview

**Existing workflow (being replaced):**
1. Originator receives verbal yes from customer. Opens Job Detail.
2. Taps three-dot menu at top right.
3. Scans four options: Mark Won, Mark Lost, Flag Issue, Delete Job.
4. Taps Mark Won.
5. Confirms in modal.

**New workflow:**
1. Originator receives verbal yes from customer. Opens Job Detail.
2. Sees Mark Won button immediately, no tap to reveal.
3. Taps Mark Won.
4. Confirms in modal.

The cognitive load reduction is at step 2. The originator does not need to remember where the action lives. It is in plain sight.

---

## 7. Status-Dependent Availability

Mark Won and Mark Lost are outcome actions. They are only available when there is an active outcome to record. They must not appear on jobs that are already in a terminal state.

Canonical state model per PRD-01 v1.4.1 §8 and §10: every job has a `pipeline_stage` (`in_campaign`, `won`, or `lost`) and, when `in_campaign`, an optional `status_overlay` modifier (`paused`, `customer_waiting`, `delivery_issue`, or none). Outcome actions are available on every active job (`pipeline_stage = 'in_campaign'`), regardless of which `status_overlay` is applied. Outcome actions are not available on terminal jobs.

| `pipeline_stage` | `status_overlay` | Operator-facing display | Mark Won shown | Mark Lost shown | Rationale |
|------------------|-----------------|-------------------------|----------------|-----------------|-----------|
| `in_campaign` | none | In Campaign | Yes | Yes | Active job; customer may accept or decline |
| `in_campaign` | `paused` | Paused | Yes | Yes | Active job; originator may have been in contact |
| `in_campaign` | `customer_waiting` | Reply Needed | Yes | Yes | Customer replied; outcome likely imminent |
| `in_campaign` | `delivery_issue` | Delivery Issue | Yes | Yes | Active job; outcome can still be recorded regardless of delivery state |
| `won` | n/a | Won | No | No | Already terminal; no outcome to record |
| `lost` | n/a | Lost | No | No | Already terminal; no outcome to record |

**When outcome actions are not shown (`won`, `lost`):** The outcome action row is not rendered at all. No grayed-out buttons, no placeholder space. The layout collapses cleanly.

**Note on eliminated states:** Prior versions of this spec listed `Draft` and `Awaiting Estimate` as job statuses. Per PRD-01 v1.4.1 and PRD-02 v1.5 collapsed intake flow, these states do not exist in the launch build. Every job in the database has `pipeline_stage = 'in_campaign'` at the moment of creation (via the atomic Approve and Begin Campaign write at intake) or a terminal `won` / `lost` state reached by Mark Won or Mark Lost. No rendering or availability logic is needed for states that cannot exist.

---

## 8. Detailed Behavior by Form Factor

### 8.1 Desktop (viewport width ≥ 1024px)

**Current header zone:**
```
[Back to Jobs]
[Customer Name]                           [✏ edit]  [⋮ menu]
[Job type • Description • $Value]
[Status badge] · Created X days ago
```

**New action zone, below the What's Happening card, above the Contact card:**

The outcome action row is added as a dedicated section between the What's Happening card and the Contact information card. This placement is deliberate: it appears after the operator has read the current campaign status (What's Happening) and before they scroll into the detail content. It is the first interactive zone below the status summary.

```
┌─────────────────────────────────────────┐
│  What's Happening                        │
│  Campaign is active.                     │
│  Step 4 sent Apr 8. Next: Step 5 Apr 12. │
└─────────────────────────────────────────┘

┌──────────────────┐  ┌──────────────────┐
│   ✓  Mark Won    │  │   ✗  Mark Lost   │
└──────────────────┘  └──────────────────┘

┌─────────────────────────────────────────┐
│  Contact                                 │
│  EMAIL ...                               │
└─────────────────────────────────────────┘
```

**Button styling:**
- Both buttons are equal-width, side by side, filling the content column width with a standard gap between them.
- Style: outlined / ghost, not filled, not teal. They must read as secondary to whatever the primary status-driven CTA is on the screen. Border is the existing neutral border color used in the product's secondary button style.
- Mark Won: checkmark icon (✓) + "Mark Won" label. No color emphasis in the default state.
- Mark Lost: X icon (✗) + "Mark Lost" label. No color emphasis in the default state, do not use red or destructive color on the default state of this button. It is an operational action, not a destructive one.
- Font weight and size: same as other secondary actions on the page.
- Minimum height: 44px to ensure comfortable tap target even on desktop trackpad or touch-enabled laptop.

**Three-dot menu (trimmed):**
After this spec, the three-dot menu contains exactly:
```
⚑  Flag Issue
🗑  Delete Job
```
Mark Won and Mark Lost are removed from this menu entirely.

**Confirmation modals:** Triggered exactly as before. No changes to modal content, layout, or behavior.

### 8.2 Tablet (viewport width 768px-1023px)

The tablet layout mirrors the desktop treatment with one adjustment: the two buttons stack vertically rather than sitting side by side if the content column is narrow enough that side-by-side buttons would be cramped (below approximately 480px content column width). At tablet widths where the content column is comfortable (above approximately 480px), the side-by-side layout is preserved.

**Stacked layout (narrow content column):**
```
┌─────────────────────────────────────────┐
│  ✓  Mark Won                             │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│  ✗  Mark Lost                            │
└─────────────────────────────────────────┘
```

**Side-by-side layout (wider content column):**
Same as desktop, equal-width buttons in a row.

**Placement:** Same as desktop, between the What's Happening card and the Contact card.

**Styling:** Identical to desktop. Outlined, secondary weight, 44px minimum height.

**Three-dot menu:** Same as desktop, trimmed to Flag Issue and Delete Job only.

**Interaction model:** Tablet may be touch or pointer. The 44px minimum height handles both. No swipe gestures introduced.

### 8.3 Mobile (viewport width < 768px)

Mobile is where the current three-dot menu placement fails most severely. An originator parking in front of a job site, holding a phone with one hand, should be able to tap Mark Won without hunting for it. The mobile treatment addresses this with a sticky footer.

**Sticky footer bar:**

A fixed-position bar anchors to the bottom of the mobile viewport, always visible regardless of scroll position. It contains Mark Won and Mark Lost side by side.

```
Viewport bottom:
┌─────────────────────────────────────────┐
│  [ ✓ Mark Won ]    [ ✗ Mark Lost ]      │
└─────────────────────────────────────────┘
```

**Sticky footer specifications:**
- Fixed position: bottom: 0, left: 0, right: 0.
- Background: matches the app's card/surface background (white or near-white). A subtle top border or shadow separates it from the scrollable content.
- Height: 64px minimum. Buttons fill the bar horizontally with equal width and a standard gap.
- Safe area: on devices with a home indicator (iPhone notch-era devices), the bar respects the safe area inset (`env(safe-area-inset-bottom)`) so buttons are not obscured.
- The scrollable content area has bottom padding equal to the sticky footer height so the footer does not permanently obscure the bottom of the Activity log.

**Button styling in sticky footer:**
- Both buttons are outlined / ghost style, consistent with the secondary styling on desktop and tablet.
- Mark Won: ✓ icon + "Mark Won" label.
- Mark Lost: ✗ icon + "Mark Lost" label.
- Font size: appropriate for mobile touch (minimum 16px label text).
- Touch target: full button height of the footer (64px minimum), full half-width of the bar. This is a generous target for a stressed or hurried user.

**Status-dependent behavior on mobile:**
When the job is in a terminal state (`pipeline_stage = 'won'` or `'lost'`), the sticky footer is not rendered. The content area does not have the bottom padding. The layout behaves as if the footer does not exist.

**No outcome action row in the page body on mobile:**
On mobile, the outcome actions live exclusively in the sticky footer. They are not also placed in the page body between the What's Happening card and the Contact card. Duplicating them would be confusing and would consume vertical space in an already compact layout.

**Three-dot menu on mobile (trimmed):**
Same as desktop and tablet, reduced to Flag Issue and Delete Job only. The three-dot icon remains in the header.

**Interaction with other sticky elements:**
In the current mobile layout, there is no other sticky footer. If a future spec adds a sticky footer element, the two must be coordinated. For this spec, assume no conflict.

---

## 9. Confirmation Modal Behavior (Unchanged)

The following is preserved exactly. It is documented here for completeness so the frontend agent does not inadvertently change it.

**Mark Won confirmation:**
```
Mark Job as Won?

This job will be marked as won. All automated follow-ups
will stop and the job will be removed from active campaigns.

[Cancel]    [Mark Won]
```
- Modal is triggered by tapping the Mark Won button on any form factor.
- "Mark Won" button in the modal is teal/filled, this is the confirmation CTA, not the trigger button.
- "Cancel" dismisses the modal. No state change occurs.

**Mark Lost confirmation:**
```
Mark Job as Lost?

This job will be marked as lost. All automated follow-ups
will stop and the job will be removed from active campaigns.

Loss Reason *
○ Price too high
○ Went with a competitor
○ Insurance issue
○ No response from customer
○ Timing / scheduling conflict
○ Other

Notes (optional)
[Add any additional context...]

[Cancel]    [Mark Lost]
```
- Loss Reason is required. "Mark Lost" button in the modal is disabled until a reason is selected.
- "Cancel" dismisses the modal. No state change occurs.
- Both modals appear as center-screen overlays on desktop and tablet, and as bottom sheets on mobile (consistent with the existing Fix Issue slider pattern observed in the Needs Attention screen).

**On mobile, bottom sheet vs. center modal:**
The Mark Won confirmation on mobile is a center modal (it is simple, one confirmation sentence and two buttons). The Mark Lost confirmation on mobile is a bottom sheet because the loss reason radio list and notes field make it tall enough to benefit from the bottom-anchored pattern that is more natural for mobile scrolling. This mirrors the delivery issue slider pattern already in the product.

**Loss reason write target (v1.2 addition):**
When Mark Lost is confirmed, the selected loss reason value is written to `job_proposal_history.metadata` as a JSON field on the `job_marked_lost` event. No new column on `job_proposals`. This matches the append-only audit discipline already used for other job-scoped events per PRD-01 v1.4.1 §9 (and the same `metadata` column used by PRD-05 §11.4 for `job_issue_flagged`). The six canonical loss reason values (`price_too_high`, `went_with_competitor`, `insurance_issue`, `no_response_from_customer`, `timing_scheduling_conflict`, `other`) are written as a string under the key `loss_reason`. The optional notes field, if populated, is written under the key `loss_notes`. Analytics queries that need to break down lost jobs by reason read from the history event metadata. If Analytics later surfaces a dedicated per-reason tile, the field can be promoted to a column on `job_proposals` at that time; it is not required for v1.

Note: `cause_of_loss` on the `jobs` record (if present in the canonical schema) captures the incident cause at intake (for example burst pipe, kitchen fire) and is unrelated to the sales outcome loss reason captured here.

---

## 10. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| Mark Won and Mark Lost are never shown in the three-dot menu after this spec | Removed from overflow. Not re-added under any condition. |
| Three-dot menu contains exactly: Flag Issue, Delete Job | No other items. |
| Outcome actions are secondary, not primary | They are outlined/ghost style. They do not compete visually with the status-driven primary CTA. |
| Outcome actions are hidden (not grayed) on terminal jobs (`pipeline_stage = 'won'` or `'lost'`) | When not available, the buttons are not rendered. No disabled state shown. Layout collapses cleanly. |
| Mobile outcome actions are in the sticky footer only | Not duplicated in the page body. Content area has bottom padding equal to footer height. |
| Sticky footer respects safe area inset on notched devices | `env(safe-area-inset-bottom)` applied. |
| Confirmation modals are unchanged | Content, behavior, and layout of both modals are preserved exactly. |
| Mark Lost modal on mobile renders as a bottom sheet | Consistent with existing bottom-anchored interaction patterns on mobile. |
| Mark Won modal on mobile renders as a center modal | Simple enough to not require a bottom sheet. |
| 44px minimum touch target height on all form factors | Desktop, tablet, and mobile. Non-negotiable for field usability. |
| No outcome actions on job cards (Jobs List or Needs Attention) | Confirmed out of scope. Actions belong on Job Detail only. |
| Backend is unchanged | Status transitions, stop conditions, activity log entries, all unchanged. This is a frontend-only spec. |

---

## 11. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| Originator taps Mark Won mid-scroll on mobile | Sticky footer is always visible regardless of scroll position. Tap is always reachable. Modal opens. |
| Originator taps Mark Won, then taps Cancel in the modal | Modal dismisses. Job state is unchanged. Buttons return to their normal visible state. |
| Job transitions from In Campaign to Won while the operator has the detail screen open | On next data refresh, the outcome action row (desktop/tablet) or sticky footer (mobile) disappears. Job status updates to Won. No error. |
| Originator taps Mark Won on a job that is already Won (race condition, two users) | Backend rejects the transition (job is already in terminal state). Frontend shows an error state and refreshes the job detail to reflect current status. |
| Tablet viewport is at the exact breakpoint (768px) | Apply mobile treatment at < 768px, tablet treatment at ≥ 768px. The breakpoint is inclusive of 768px on the tablet side. |
| Very long job detail page on mobile (many activity log entries) | Sticky footer remains fixed. Bottom padding on the content area ensures the last activity log entry is scrollable into view above the footer. No content is permanently obscured. |
| Keyboard open on mobile (originator typing in a field) | Sticky footer may be pushed up by the keyboard or temporarily hidden, depending on the browser's viewport behavior. This is acceptable and consistent with standard mobile web behavior. Do not attempt to compensate for keyboard position. |
| Won job opened on mobile | Sticky footer is not rendered. No bottom padding added to content area. Layout is normal. |
| Lost job opened on mobile | Same as Won. Sticky footer not rendered. |

---

## 12. UX-Visible Behavior by Form Factor

### Desktop, active-state job

| Element | Visible |
|---------|---------|
| Header | Unchanged: Customer Name, edit pencil, three-dot menu |
| Three-dot menu | Flag Issue, Delete Job only |
| What's Happening card | Unchanged |
| Outcome action row | Mark Won (outlined, ✓ icon) and Mark Lost (outlined, ✗ icon), side by side, full column width |
| Contact card | Unchanged, directly below outcome row |
| Everything below | Unchanged |

### Desktop, terminal-state job (Won or Lost)

| Element | Visible |
|---------|---------|
| Outcome action row | Not rendered. Contact card appears directly below What's Happening card. |
| Three-dot menu | Flag Issue, Delete Job only (unchanged) |

### Tablet, active-state job, wide content column

| Element | Visible |
|---------|---------|
| Outcome action row | Same as desktop, side-by-side buttons |

### Tablet, active-state job, narrow content column

| Element | Visible |
|---------|---------|
| Outcome action row | Stacked, Mark Won full width, Mark Lost full width below it |

### Mobile, active-state job

| Element | Visible |
|---------|---------|
| Sticky footer | Fixed at viewport bottom, Mark Won (left half) and Mark Lost (right half) |
| Content area | Scrollable, with bottom padding equal to sticky footer height |
| Outcome action row in page body | Not rendered |
| Three-dot menu | Flag Issue, Delete Job only |

### Mobile, terminal-state job (Won or Lost)

| Element | Visible |
|---------|---------|
| Sticky footer | Not rendered |
| Content area | No bottom padding. Full-height scroll. |

---

## 13. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Removing Mark Won and Mark Lost from the three-dot menu | Frontend |
| Rendering the outcome action row on desktop and tablet | Frontend |
| Rendering the sticky footer on mobile | Frontend |
| Status-dependent show/hide logic for outcome actions | Frontend (reads job status from existing API response) |
| Applying safe area inset to sticky footer | Frontend |
| Adding bottom padding to content area when sticky footer is active | Frontend |
| Triggering the existing Mark Won / Mark Lost confirmation modals | Frontend, same trigger as before, new entry point |
| Rendering Mark Lost modal as bottom sheet on mobile | Frontend |
| All backend transitions, stop conditions, and audit events | smai-backend / FM Comms (Mark), unchanged |

---

## 14. Implementation Slices

### Slice A, Three-dot menu trim
**Purpose:** Remove Mark Won and Mark Lost from the overflow menu.
**Components touched:** Three-dot menu component on Job Detail header.
**Key behavior:** Menu renders Flag Issue and Delete Job only. Mark Won and Mark Lost are removed. No other menu behavior changes.
**Dependencies:** None. Can be built immediately.
**Excluded:** New button placement. Mobile footer.

### Slice B, Desktop and tablet outcome action row
**Purpose:** Add the visible outcome action row between What's Happening and Contact on desktop and tablet.
**Components touched:** Job Detail page layout; new outcome action row component.
**Key behavior:** Renders Mark Won and Mark Lost as outlined secondary buttons. Side by side on desktop and wide tablet. Stacked on narrow tablet. Hidden on terminal-state jobs (`pipeline_stage = 'won'` or `'lost'`). Tapping either triggers the existing confirmation modal. 44px minimum height.
**Dependencies:** Slice A complete (so the actions are not duplicated in both the menu and the row simultaneously).
**Excluded:** Mobile sticky footer. Modal changes.

### Slice C, Mobile sticky footer
**Purpose:** Add the always-visible sticky footer for outcome actions on mobile.
**Components touched:** Job Detail mobile layout; new sticky footer component.
**Key behavior:** Fixed at viewport bottom. Mark Won left, Mark Lost right, equal width. 64px minimum height. Safe area inset respected. Content area bottom padding added. Hidden on terminal-state jobs (`pipeline_stage = 'won'` or `'lost'`). Tapping triggers existing confirmation modals (Mark Won = center modal, Mark Lost = bottom sheet).
**Dependencies:** Slice A complete.
**Excluded:** Desktop and tablet row. Modal changes.

### Slice D, Mark Lost bottom sheet on mobile
**Purpose:** Render the Mark Lost confirmation as a bottom sheet on mobile rather than a center modal.
**Components touched:** Mark Lost confirmation modal component, mobile variant.
**Key behavior:** On mobile viewport (< 768px), the Mark Lost confirmation renders anchored to the bottom of the screen, slides up, is scrollable if content is tall. Loss reason list and notes field are fully accessible. Behavior on tap-outside and swipe-down to dismiss follows the existing pattern used by the Fix Issue slider in Needs Attention. On desktop and tablet, the existing center modal is unchanged.
**Dependencies:** Slice C complete.
**Excluded:** Mark Won modal (center modal on all form factors).

---

## 15. Acceptance Criteria

**Given** any active-state job (`pipeline_stage = 'in_campaign'`, any `status_overlay`: none, paused, customer_waiting, or delivery_issue) on desktop,
**When** an Originator opens the Job Detail screen,
**Then** Mark Won and Mark Lost buttons are visible between the What's Happening card and the Contact card without any tap to reveal them. They are outlined/ghost style and clearly secondary to any primary status CTA on the page.

**Given** the three-dot menu on Job Detail after this spec is implemented,
**When** an Originator opens it,
**Then** the menu contains exactly two items: Flag Issue and Delete Job. Mark Won and Mark Lost are not present.

**Given** a Won or Lost job on desktop,
**When** the Job Detail screen renders,
**Then** the outcome action row is not present. No grayed-out buttons, no placeholder space. The Contact card appears directly below the What's Happening card.

**Given** any active-state job on mobile,
**When** the Job Detail screen renders,
**Then** a sticky footer is fixed at the bottom of the viewport containing Mark Won (left) and Mark Lost (right) at all times, regardless of scroll position. The scrollable content has bottom padding so the Activity log is fully accessible above the footer.

**Given** a Won or Lost job on mobile,
**When** the Job Detail screen renders,
**Then** the sticky footer is not present. The content area has no bottom padding.

**Given** an Originator on mobile who taps Mark Won in the sticky footer,
**When** the confirmation modal opens,
**Then** it appears as a center modal with the existing confirmation language and Cancel / Mark Won buttons. The job transitions to Won on confirmation. The sticky footer disappears after the transition.

**Given** an Originator on mobile who taps Mark Lost in the sticky footer,
**When** the confirmation bottom sheet opens,
**Then** it slides up from the bottom of the screen, shows the existing loss reason radio options and optional notes field, and the Mark Lost confirm button remains disabled until a reason is selected.

**Given** a tablet at 768px viewport width with an active-state job,
**When** the Job Detail renders,
**Then** the tablet treatment (outcome action row, no sticky footer) is applied. The breakpoint is inclusive of 768px on the tablet side.

**Given** a mobile device with a home indicator (safe area inset),
**When** the sticky footer renders,
**Then** the buttons are not obscured by the home indicator. The footer respects `env(safe-area-inset-bottom)`.

**Given** any form factor where the outcome action buttons are visible,
**When** a designer measures the touch targets,
**Then** the minimum tap target height is 44px for desktop and tablet buttons and 64px for mobile sticky footer buttons.

**Given** the Mark Won button is tapped and the confirmation modal is dismissed with Cancel,
**When** the operator returns to the Job Detail screen,
**Then** the job status is unchanged. The outcome action buttons remain visible. No error state is shown.

---

## 16. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Breakpoint for tablet stacked vs. side-by-side layout | Engineering decision | Spec states approximately 480px content column width as the stacking threshold. Frontend agent adjusts based on the actual content column width at various tablet viewport sizes. The goal is that the buttons never appear cramped. |
| Mark Won modal on mobile as center vs. bottom sheet | Confirmed decision | Mark Won is a center modal on all form factors. It is simple enough (one sentence + two buttons) that a bottom sheet adds complexity without benefit. Mark Lost is a bottom sheet on mobile due to its height (radio list + notes field). |
| Interaction of sticky footer with future sticky elements | Engineering decision | If a future spec adds another sticky element to mobile Job Detail, the two must be coordinated at that time. For this spec, assume no conflict exists. |
| Content area bottom padding calculation | Engineering decision | Bottom padding should equal the sticky footer height including the safe area inset. Frontend agent calculates this dynamically using the rendered footer height rather than a hardcoded value, to handle varying device safe area sizes. |
| Mark Lost bottom sheet swipe-to-dismiss | Engineering decision | Whether the bottom sheet can be dismissed by swiping down (vs. Cancel only) follows the existing pattern used by the Fix Issue slider in Needs Attention. Frontend agent matches that behavior for consistency. |
| Existing Mark Won / Mark Lost trigger code | Assumption | The confirmation modal trigger code currently lives in the three-dot menu handler. Slices B and C wire new entry points to the same trigger. The modal code itself does not change. Frontend agent confirms the modal trigger is factored into a reusable function before building Slices B and C. If not, it must be refactored first. |

---

## 17. Out of Scope

- Any change to the Mark Won confirmation modal content or behavior
- Any change to the Mark Lost confirmation modal content, loss reason options, or behavior
- Any change to backend status transition logic or stop condition enforcement
- Any change to the activity log entry generated by Mark Won or Mark Lost
- Outcome actions on the Jobs List card
- Outcome actions on the Needs Attention card
- Swipe gestures on job cards for mobile (deferred to future iteration)
- Any change to the edit pencil icon or its behavior
- Flag Issue behavior or modal
- Delete Job behavior or confirmation
- Any change to Won or Lost job display in the Jobs List
- A "Reopen" action for Won or Lost jobs (future scope)
