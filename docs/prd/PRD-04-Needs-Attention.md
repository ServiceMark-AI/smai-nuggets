# PRD-04: Needs Attention
**Version:** 1.2.1  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:**
- Lovable FE audit (Phase 1, locked)
- Session State v6.0
- CC-06 (Buc-ee's MVP Definition)
- Spec 6 (Job Status Model and CTA Engine) [legacy out-of-repo reference; superseded by PRD-01 v1.4.1 §6 and §7]
- Spec 7 (Job Status Architecture and CTA Rules — Paused exclusion overridden, see §4) [legacy out-of-repo reference; superseded by PRD-01 v1.4.1 §7, with the Paused-overlay surfacing override governed by this PRD §4]
- Spec 10 (Notifications and Alerting) [legacy out-of-repo reference; no canonical in-repo successor; notifications/alerting is post-MVP and does not govern the launch build]
- Spec 2 (Multi-Tenancy) [legacy out-of-repo reference; superseded by PRD-08 v1.2 (role and location model) and PRD-10 v1.2 (admin portal tenant management)]
- Spec 13 (Global Navigation and Routing) [legacy out-of-repo reference; no canonical in-repo successor in the active spec set; treat as deferred platform-shell concern, does not govern the launch build]
- PRD-01 v1.4.1 (Job Record)
- PRD-02 v1.5 (New Job Intake)
- PRD-03 v1.4.1 (Campaign Engine)
- PRD-05 v1.4 (Jobs List)
- PRD-06 v1.3.1 (Job Detail)
- PRD-08 v1.2 (Settings — role-based location model)
- SPEC-11 v2.0 (Campaign Template Architecture)
- Save State 2026-04-21 (Pending Approval elimination, templated architecture, no draft / awaiting_estimate stages)
**Related PRDs and specs:** PRD-01 v1.4.1, PRD-02 v1.5, PRD-03 v1.4.1, PRD-05 v1.4, PRD-06 v1.3.1, PRD-08 v1.2; SPEC-03 v1.3, SPEC-11 v2.0  
**Revision note (v1.1):** Updated location scope sections (§1, §4, §11, §12, §17 AC-11) to reflect PRD-08 v1.2's single-location-Originator / multi-location-Admin model. Replaced "single-location user / multi-location user" phrasing with "Originator / Admin" throughout. §11.3 scope enforcement rewritten to reference `users.location_id` and `users.role` directly rather than the deprecated `user_location_access` table (being cleaned up per PRD-08 v1.2 OQ-10). No behavioral changes to Needs Attention surfacing, sort, or card rendering.  
**Revision note (v1.2):** Two related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what PRD-01 v1.4, PRD-02 v1.5, PRD-03 v1.4, PRD-06 v1.3, and PRD-05 v1.3 drive transitively. Nothing else.

1. **Surfaced CTA set reduced from five to three.** Per PRD-01 v1.4 (canonical CTA enum) and PRD-02 v1.5 (PDF-only intake; no `draft` or `awaiting_estimate` pipeline stages exist). Removed `attach_estimate` and `complete_job_setup` from the §5 surfacing logic table, the §6 sort priority table, the §7.1 triage text and CTA button tables, the §7.1 engagement fact rules referencing `pipeline_stage = awaiting_estimate` and `pipeline_stage = draft`, the §8 status badge list (Awaiting Estimate, Draft), the §15 API response shape, and the §17 ACs. Renamed `respond_now` to `open_in_gmail` throughout per PRD-06 v1.3 §11.1 and PRD-05 v1.3 §9.2 (Customer Waiting CTA is "Open in Gmail" — operator replies natively in Gmail; Respond Now modal does not exist). Updated §7.1 CTA button table accordingly. The screen now surfaces three CTA categories: Customer Waiting (`open_in_gmail`), Delivery Issue (`fix_delivery_issue`), and Paused (`resume_campaign`).

2. **Schema reference cleanup.** Per PRD-01 v1.4 §12 consolidation, all event reads/writes land in `job_proposal_history`. Replaced `event_logs` references throughout (§9.1, §9.3, §15, §16 Slice A) with `job_proposal_history`. Removed `voice_intake_started` and `voice_intake_completed` from the §9.1 excluded events list (voice intake deferred per PRD-02 v1.2; events do not exist in canonical enum). Replaced `campaign_started` with `campaign_approved` in the §9.1 Handled by SMAI feed event list (PRD-01 v1.4 canonical enum has `campaign_approved`, not `campaign_started`). Updated §9.3 query field name from `occurred_at` to `change_date` per PRD-01 v1.4 §12 schema (history rows use `change_date`).

Material section changes in v1.2: header, §2 (builders points 1 and 4 wording cleanup), §3 (sub-flow scope cleanup), §4 (locked constraints updated; legacy badge values removed), §5 (surfacing logic table reduced), §6 (sort table reduced), §7.1 (engagement fact rules and triage text and CTA button tables reduced; respond_now renamed), §7.1 inline-action prose (Respond Now references removed), §8 (status badge list trimmed), §9 (Handled by SMAI feed event list updated; data source aligned to job_proposal_history), §15 (API response shape updated), §16 (Slice A dependency aligned), §17 (AC-01, AC-04, AC-06 rewritten; AC-18 status surface list updated), §19 (out of scope cleanup).

**Revision note (v1.2.1, 2026-04-22):** Six surgical corrections; no behavioral change. (1) B-03: §13.2 inline-CTA parenthetical rewritten to strike deleted Respond Now / Attach Estimate CTAs; the only remaining sub-flow is Fix Delivery Issue. §14 system-boundary table: the Respond Now / Fix Issue / Attach Estimate combined row replaced with a dedicated Fix Delivery Issue sub-flow row plus a new Open in Gmail external redirect row; the Complete Job Setup navigation row was deleted entirely. Completes the v1.2 deletion propagation. (2) B-01-adjacent: "Paused (Campaign Hold)" clarifying parentheticals removed from the §5 surfacing table (line 112) and the §8 status badge table (line 238). Badge text is "Paused" (unchanged). The `campaign_hold` enum value no longer exists per the parallel SPEC-09 v1.2 B-01 fix aligning to PRD-01 §6's canonical `paused` overlay. (3) H-07: §6 CTA priority table now carries a footnote pointing to PRD-01 v1.4.1 §7 as the canonical full `cta_type` ladder; PRD-04 is a subset (non-surfacing values excluded). (4) H-08: §19 Out of Scope adds "Originator filter (SPEC-02, PRD-05 only — does not affect Needs Attention)" per SPEC-02 scope boundary. (5) L-04: Source truth line reformatted from a 200-character semicolon-delimited string onto a bulleted list for scan-ability. (6) L-06: "Customer Waiting" renamed to "Reply Needed" across 12 operator-facing sites (badge text, sort priority table, status badge colors line, card-type list, AC prose, real-time update description, out-of-scope prose). Lovable FE is the ground truth per governing principle; screenshot confirmed badge text renders "reply needed" (CSS-lowercase) with CTA "Open in Gmail." The `status_overlay = customer_waiting` enum value is unchanged. Only operator-visible UI strings updated; the two v1.2 revision-note historical references retain "Customer Waiting" as audit of the prior label. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 B-01, B-03, H-07, H-08, L-04, L-06).

**Patch note (2026-04-23):** Two changes; no behavioral change. (1) H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1`, `PRD-03 v1.4` → `PRD-03 v1.4.1`, `PRD-05 v1.3` → `PRD-05 v1.4`, `PRD-06 v1.3` → `PRD-06 v1.3.1`. Audit-trail revision-note text preserved byte-exact. (2) M2P-08 L-01 legacy annotations applied to §0 source-truth bullets: Specs 6, 7, 10, 2, 13 each annotated as out-of-repo references with their canonical in-repo successor (or noted as deferred / no-successor where applicable). Matches the L-01 treatment PRD-01 v1.4.1 received on 2026-04-22. No version bump on PRD-04 (sweep + annotation are pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01, M2P-08.

**Patch note (2026-04-23, M2P-06 sub-flow naming):** §13.2 "CTA action failure" sub-flow row rewritten from the singular-vague `Sub-flow failure` to `Fix Delivery Issue sub-flow failure`, with explicit citation to PRD-06 §11.2 and a parenthetical noting that Fix Delivery Issue is the only sub-flow opened from Needs Attention after Respond Now and Attach Estimate were removed in v1.2. Closes the H-03 carry-forward where the v1.2.1 fix corrected the Resume Campaign half but left the sub-flow half ambiguous. No behavioral change. Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-06.

**Patch note (2026-04-23, M2P-07 color convention):** Status badge color descriptors normalized to canonical name + hex pairs per PRD-05 §10. (1) §4 locked-constraint row (line 113) rewritten: `Reply Needed = red, Delivery Issue = red, Paused = orange, In Campaign = teal` → name + hex pairs `Reply Needed = Coral / #F56B4B, Delivery Issue = Red / #E53935, Paused = Amber / #F5A623, In Campaign = Teal / #00B3B3` with a `Color name + hex pairs are canonical per PRD-05 §10` note appended. (2) §8 Status Badge Colors table rebuilt with four columns: `Operator-facing status | Color name | Color hex | Style | Badge text`. All six rows show name + hex (Reply Needed = Coral / #F56B4B, Delivery Issue = Red / #E53935, Paused = Amber / #F5A623, In Campaign = Teal / #00B3B3, Won = Green / #27AE60, Lost = Gray / #9CA3AF). The `Style` column (default `solid`, Lost = `outline`) preserves the de-emphasis cue the prior `Gray outline` text expressed; the explanatory paragraph below the table specifies that for solid badges the color hex fills the background and text is white, while for outline badges the background is transparent, the color hex is the border, and text uses the same hex as the border. The name + hex format keeps the docs human-readable while pinning exact values; iterations earlier in this patch cycle that briefly tried hex-only were superseded. Closes the cross-doc naming drift the review flagged where PRD-04, PRD-05, and PRD-06 used three different conventions for the same badges, and closes the M2P-07 follow-up gap (outline-vs-fill for Lost). No behavioral change. Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-07.

---

## 1. What This Is in Plain English

Needs Attention is the home screen. It is the first thing an operator sees after login and the screen they return to when they need to know what requires human action right now.

It has one job: show every job that is blocked, interrupted, or incomplete — and show them in the order the operator should handle them. Nothing else appears here. Jobs that are running normally are invisible on this screen by design. The operator should be able to glance at Needs Attention and know immediately whether anything needs them, and if so, what to do.

Every card on this screen has one CTA. The CTA is derived from the job's `cta_type` field via the shared CTA engine. The sort order mirrors the CTA priority ladder. The highest-stakes interrupts (customer replies, delivery failures) always appear at the top.

Below the actionable job cards, there is a secondary section: "Handled by SMAI." This is a read-only feed of automation events from the current day — sends, campaign steps completed, replies detected. It confirms to the operator that the system is working. It is informational only. No CTAs, no action required.

The screen is location-scoped. What appears depends on the user's role. Originators see jobs at their assigned location. Admins see jobs at a single selected location or all locations in the account, depending on the location switcher.

---

## 2. What Builders Must Not Misunderstand

1. **Paused jobs appear on Needs Attention.** Spec 7 excluded Paused from Needs Attention, but CC-06 explicitly includes Resume as a Needs Attention CTA, and Spec 6's CTA list includes Resume Campaign. CC-06 governs. Paused jobs with `cta_type = resume_campaign` appear in Needs Attention. See Section 4 for the full conflict resolution.

2. **In Campaign jobs do not appear.** A job running a campaign normally — `pipeline_stage = in_campaign`, `status_overlay = null` — has `cta_type = view_job`. View Job is not an action CTA. These jobs are invisible on Needs Attention. They appear on the Jobs list instead.

3. **Won and Lost jobs never appear on Needs Attention.** They are terminal. `cta_type = view_job`. They are not surfaced here under any condition.

4. **The sort order is CTA priority order, not recency.** A Reply Needed job from three days ago ranks above a Paused job from five minutes ago. Sort is driven by `cta_type` priority, with recency as the tiebreaker within the same priority tier.

5. **The CTA on each card must match the CTA engine exactly.** Needs Attention reads `jobs.cta_type` from the API. It does not recompute the CTA client-side. If the CTA engine is wrong, every surface is wrong simultaneously — which is the point. Fix it at the source.

6. **The "Handled by SMAI" feed is read-only and day-scoped.** It shows automation events from `job_proposal_history` for the current calendar day, scoped to the active location. It does not show historical days. It has no CTAs. It does not affect any job state.

7. **The empty state is meaningful.** When no jobs need attention, the screen does not show a blank page. It shows a specific message confirming that everything is under control. This is a trust signal — the operator needs to know the screen is working, not broken.

8. **Access-scope filtering is enforced by the backend.** The frontend passes the active `location_id` (or account-level scope for All Locations) as a query parameter. The backend applies the access-scope filter server-side: for Originators, results are restricted to `users.location_id`; for Admins, to the selected location or all locations in the account. The frontend must not filter jobs by `location_id` or `account_id` in the browser — access scope is untrusted in untrusted code. Eligibility filtering within the access-scoped result (e.g., filtering by `cta_type` to drive what renders on Needs Attention) may run in the frontend or the backend; that is an implementation choice.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- Which jobs appear on Needs Attention and which do not
- The eligibility rules (surfacing logic) derived from `cta_type`
- Sort order within the list
- Card anatomy: every element shown on each job card
- Status badge colors
- Engagement fact and triage text rendering rules
- The CTA button per card type
- The "Handled by SMAI" feed: what appears, where it lives, what it shows
- Empty state behavior
- Location scope enforcement
- The screen route and navigation behavior
- Error states

**This PRD does not cover:**
- The Jobs list (PRD-05 v1.4)
- Job Detail screen (PRD-06 v1.3.1)
- The Open in Gmail behavior on Reply Needed cards (PRD-06 v1.3.1 §11.1)
- The Fix Issue slide-out sub-flow (PRD-06 v1.3.1 §11.2)
- SMS notifications triggered by Needs Attention events (Spec 10)
- Analytics screen (Analytics PRD)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| Needs Attention is the home screen and default post-login destination. | Session State v6.0, Spec 13 |
| Route: `/home` (Originator, implicit single-location) or `/:locationId/home` (Admin, explicit location selection). | Session State v6.0, Spec 13; PRD-08 v1.2 |
| Paused jobs appear on Needs Attention with Resume Campaign CTA. | CC-06 governs over Spec 7. Spec 6 consistent with CC-06. Conflict resolved here. |
| In Campaign jobs with no overlay do not appear. `cta_type = view_job` is not a Needs Attention CTA. | Spec 6, Spec 7 (consistent on this point) |
| Won and Lost jobs never appear. | PRD-01 v1.4.1, Spec 6 |
| Sort order is CTA priority order, not recency. Recency is tiebreaker within same tier. | Spec 6 CTA priority ladder |
| The CTA on each card is read from `jobs.cta_type`. Not recomputed client-side. | PRD-01 v1.4.1, Spec 7 engineering requirements |
| Status badge colors are canonical: Reply Needed = Coral / `#F56B4B`, Delivery Issue = Red / `#E53935`, Paused = Amber / `#F5A623`, In Campaign = Teal / `#00B3B3`. Color name + hex pairs are canonical per PRD-05 §10. | Spec 12 |
| Surfaced CTA values per PRD-01 v1.4.1 §7: `open_in_gmail` (Reply Needed), `fix_delivery_issue` (Delivery Issue), `resume_campaign` (Paused). `attach_estimate` and `complete_job_setup` are removed; `pipeline_stage = awaiting_estimate` and `pipeline_stage = draft` do not exist in the launch build per PRD-02 v1.5. `respond_now` was renamed to `open_in_gmail`. | PRD-01 v1.4.1 §7; PRD-02 v1.5; PRD-06 v1.3.1 §11.1 |
| "Handled by SMAI" feed lives at the bottom of Needs Attention. Day-scoped. Read-only. | Spec 10 |
| Access-scope filtering (by `account_id` and `location_id`) enforced server-side. Eligibility filtering (by `cta_type`) may run server-side or client-side per implementation choice. | Spec 2, Spec 13; this PRD §2 point 8 |
| Empty state shown when no jobs qualify. Not a blank screen. | Lovable FE audit |
| All event reads/writes use the consolidated `job_proposal_history` table per PRD-01 v1.4.1 §12. The `event_logs` table is deprecated. | PRD-01 v1.4.1 §12, DL-026, DL-027 |

**Spec 7 conflict on Paused jobs — resolved:**

Spec 7, Section 7 states: "Jobs in Campaign, Paused, Won, and Lost do not appear" on Needs Attention. This directly conflicts with Spec 6, Section 6, which lists Resume Campaign as a Needs Attention CTA, and with CC-06, which explicitly includes "Resume" as a Needs Attention trigger. CC-06 is the governing product definition for Buc-ee's and postdates both Spec 6 and Spec 7. Paused jobs with `cta_type = resume_campaign` appear on Needs Attention. Spec 7's exclusion of Paused is overridden. All builds and tests must treat Paused as a Needs Attention-eligible status.

---

## 5. Surfacing Logic: Which Jobs Appear

A job appears on Needs Attention if and only if its `cta_type` is one of the following:

| `cta_type` | Operator-facing status | Appears on Needs Attention |
|---|---|---|
| `open_in_gmail` | Reply Needed | **Yes** |
| `fix_delivery_issue` | Delivery Issue | **Yes** |
| `resume_campaign` | Paused | **Yes** |
| `view_job` | In Campaign, Won, Lost | **No** |

This is the complete and final list. No other logic gates inclusion. If `cta_type` is one of the three eligible values, the job is on the screen. If it is `view_job`, it is not.

Note: Prior versions surfaced five CTA values including `respond_now`, `attach_estimate`, and `complete_job_setup`. Removed in v1.2. `respond_now` was renamed to `open_in_gmail` per PRD-06 v1.3.1 §11.1 (operators reply natively in Gmail; no in-app compose). `attach_estimate` and `complete_job_setup` corresponded to `pipeline_stage = awaiting_estimate` and `pipeline_stage = draft`, neither of which exists in the launch build per PRD-02 v1.5 (PDF-only intake; jobs are written directly into `in_campaign` on Approve and Begin Campaign).

The backend query is:

```sql
SELECT jobs.*, job_contacts.*
FROM jobs
JOIN job_contacts ON job_contacts.job_id = jobs.id
WHERE jobs.account_id = :account_id
  AND jobs.location_id IN (:permitted_location_ids)
  AND jobs.cta_type IN ('open_in_gmail', 'fix_delivery_issue', 'resume_campaign')
ORDER BY
  CASE jobs.cta_type
    WHEN 'open_in_gmail' THEN 1
    WHEN 'fix_delivery_issue' THEN 2
    WHEN 'resume_campaign' THEN 3
  END ASC,
  jobs.updated_at DESC
```

For "All Locations" scope, `:permitted_location_ids` expands to all locations the user has access to under the account.

---

## 6. Sort Order

Jobs are sorted by CTA priority first, then by recency within the same tier.

**Primary sort: CTA priority (ascending)**

| Priority | `cta_type` | Operator-facing |
|---|---|---|
| 1 | `open_in_gmail` | Reply Needed |
| 2 | `fix_delivery_issue` | Delivery Issue |
| 3 | `resume_campaign` | Paused |

Note: This table lists only the three `cta_type` values that surface on Needs Attention. The full `cta_type` enum and priority ladder (including `view_job` and any other non-surfacing values) is canonical in PRD-01 v1.4.1 §7. PRD-04 is a subset. If the two differ, PRD-01 governs.

**Secondary sort: recency (descending)**

Within the same `cta_type` tier, jobs are sorted by `jobs.updated_at` descending — most recently updated first. This means a customer reply that just arrived appears above an older customer reply.

The sort is computed server-side and returned in order. The frontend renders the list as received. No client-side re-sorting.

---

## 7. Card Anatomy

Every job card on Needs Attention renders the same structural elements. Specific content varies by status. Each card is tappable — tapping anywhere on the card navigates to the Job Detail screen for that job.

### 7.1 Card elements (top to bottom)

**Row 1: Status badge + job name + job value**

- **Status badge** — left-aligned. Color and label per the canonical status badge system (Section 8).
- **Job name** — `jobs.job_name`. If null, render `{job_type_display_label} + " — " + jobs.address_line1` where `job_type_display_label` is the human-readable label for `jobs.job_type` per SPEC-03 v1.3 §7.1 and §8 casing rules (not the raw enum string). Truncate at 60 characters with ellipsis.
- **Job value** — right-aligned. Renders `jobs.job_value_estimate` formatted as currency (e.g., "$4,200"). If null, render nothing (no placeholder, no zero).

**Row 2: Customer name + time since last activity**

- **Customer name** — `job_contacts.customer_name`. If null, render "Unknown Customer" in muted gray.
- **Time since last activity** — right-aligned. Derived from `jobs.updated_at`. Format: "2h ago", "1d ago", "3d ago". Do not show exact timestamps on the card.

**Row 3: Engagement fact**

A single line of plain text stating the most recent meaningful event for this job. This is the fact-first line. It must be specific and true — never generic.

Rules for rendering the engagement fact (evaluated in priority order, first match wins):

| Condition | Engagement fact text |
|---|---|
| `status_overlay = customer_waiting` | "Customer replied {time ago}" — e.g., "Customer replied 2h ago" |
| `status_overlay = delivery_issue` | "Email delivery failed {time ago}" — e.g., "Email delivery failed 8h ago" |
| Most recent `messages` row is outbound and `status = sent` | "Follow-up #{step_order} sent {time ago}" — e.g., "Follow-up #2 sent 4h ago" |
| `status_overlay = paused` | "Campaign paused {time ago}" — e.g., "Campaign paused 1d ago" |
| No messages and no overlay | "Job created {time ago}" |

The time reference in the engagement fact derives from the relevant event timestamp in `job_proposal_history` or `messages.sent_at`. It is not `jobs.updated_at`.

Note: Prior versions carried `pipeline_stage = awaiting_estimate` and `pipeline_stage = draft` engagement-fact rules. Removed in v1.2 — these pipeline stages do not exist in the launch build per PRD-02 v1.5.

**Row 4: Triage text**

A single sentence that gives meaning to the fact on Row 3. This is the meaning-second line. It must be contextually appropriate to the status and tell the operator what is at stake.

| `cta_type` | Triage text |
|---|---|
| `open_in_gmail` | "This customer is warm — respond before they go cold." |
| `fix_delivery_issue` | "Your follow-up isn't reaching this customer. Fix their email to resume." |
| `resume_campaign` | "Your campaign is on hold. Resume when ready." |

Triage text is static per `cta_type`. It does not vary based on job age or engagement history in the launch build.

Note: Prior versions included triage text rows for `respond_now`, `attach_estimate`, and `complete_job_setup`. `respond_now` is renamed to `open_in_gmail` in v1.2; `attach_estimate` and `complete_job_setup` are removed (corresponding pipeline stages do not exist).

**Row 5: CTA button**

A single tappable button, right-aligned. Label and action per the CTA type:

| `cta_type` | Button label | Tap behavior |
|---|---|---|
| `open_in_gmail` | Open in Gmail | Opens the Gmail thread directly in the operator's Gmail (PRD-06 v1.3.1 §11.1). The operator composes and sends the reply natively in Gmail; SMAI does not provide a compose interface. |
| `fix_delivery_issue` | Fix Delivery Issue | Opens the Fix Issue slide-out (PRD-06 v1.3.1 §11.2) in context |
| `resume_campaign` | Resume Campaign | Triggers resume campaign action inline; no modal |

**Resume Campaign inline action:** Tapping Resume Campaign on a card does not navigate away from Needs Attention. It sends the resume request to smai-backend (per PRD-03 v1.4.1 §13.2), and on success, the card disappears from the Needs Attention list. The job's `status_overlay` is cleared, `cta_type` updates to `view_job`, and the card is removed from the list. A brief toast appears: "Campaign resumed." If the resume call fails, the card remains and a toast appears: "Couldn't resume — try again." No navigation occurs on either success or failure.

**Open in Gmail:** Tapping Open in Gmail exits SMAI and opens the Gmail thread in the operator's Gmail. The card remains visible on the Needs Attention list until SMAI detects the operator's reply via Gmail Pub/Sub (per PRD-06 v1.3.1 §11.1). When the reply is detected, the backend clears `status_overlay = customer_waiting`, sets `cta_type = view_job`, and writes `job_proposal_history` rows for `status_overlay_changed` and `operator_replied`. On the next page load or realtime update, the card disappears from the Needs Attention list.

**Fix Delivery Issue:** Opens the Fix Issue slide-out defined in PRD-06 v1.3.1. The card remains visible in the background while the slide-out is open. On successful completion, the card is removed from the Needs Attention list and the count updates.

Note: Prior versions defined Respond Now and Attach Estimate / Complete Job Setup CTAs. All removed in v1.2 — see §5 surfacing logic for rationale.

---

## 8. Status Badge Colors

These are canonical. Every surface that shows a status badge must use these colors. No deviations.

| Operator-facing status | Color name | Color hex | Style | Badge text |
|---|---|---|---|---|
| Reply Needed | Coral | `#F56B4B` | solid | Reply Needed |
| Delivery Issue | Red | `#E53935` | solid | Delivery Issue |
| Paused | Amber | `#F5A623` | solid | Paused |
| In Campaign | Teal | `#00B3B3` | solid | In Campaign |
| Won | Green | `#27AE60` | solid | Won |
| Lost | Gray | `#9CA3AF` | outline | Lost |

Names, hex codes, and style values are canonical per PRD-05 §10. The `Color hex` column's rendering role depends on `Style`: for **solid** badges the hex fills the background and text is white (`#FFFFFF`); for **outline** badges (Lost only) the background is transparent, the hex is the border, and text uses the same hex as the border. Lost is intentionally outline-only to de-emphasize a terminal state with no follow-up; all other badges are solid fill. Use the name + hex pair (e.g., `Coral / #F56B4B`) when referencing badge colors in prose; both are pinned to the same row in PRD-05 §10.

On Needs Attention specifically, only the first three badge types appear (Reply Needed, Delivery Issue, Paused). In Campaign, Won, and Lost are never rendered on this screen.

Note: Prior versions included Awaiting Estimate (Blue) and Draft (Gray) badges. Removed in v1.2 — these statuses do not exist in the launch build per PRD-02 v1.5.

---

## 9. "Handled by SMAI" Feed

This section lives below all actionable job cards. It is separated from the cards by a section divider with the label "Handled by SMAI."

### 9.1 What it shows

A chronological list of automation events that occurred today for the active location scope. "Today" means the current calendar day in the operator's local timezone.

Events displayed (in reverse chronological order, most recent first):

| Event type (from `job_proposal_history`) | Display text |
|---|---|
| `campaign_step_sent` | "Follow-up #{step_order} sent to {customer_first_name} — {job_name}" |
| `campaign_approved` | "Campaign started for {customer_first_name} — {job_name}" |
| `campaign_completed` | "Campaign completed for {customer_first_name} — {job_name}" |
| `customer_replied` | "Reply received from {customer_first_name} — {job_name}" |
| `delivery_issue_detected` | "Delivery issue detected for {customer_first_name} — {job_name}" |
| `delivery_issue_resolved` | "Delivery issue resolved for {customer_first_name} — {job_name}" |
| `campaign_paused` | "Campaign paused for {customer_first_name} — {job_name}" |
| `campaign_resumed` | "Campaign resumed for {customer_first_name} — {job_name}" |

Events not displayed in this feed: `job_created`, `job_marked_won`, `job_marked_lost`, `operator_replied`, `job_fields_updated`, `job_issue_flagged`, `status_overlay_changed`, `pipeline_stage_changed`, `campaign_step_dropped`, `job_needs_attention_flagged`, `estimate_attached`. These are job-level events that belong in the Job Detail activity timeline (PRD-06 v1.3.1 §10.1), not the Needs Attention automation feed.

Note: Prior versions referenced `campaign_started` for the campaign-start event. Renamed in v1.2 to `campaign_approved` per the canonical event enum in PRD-01 v1.4.1 §12 — under the collapsed intake flow (PRD-02 v1.5 §8.4), `campaign_approved` is the event that fires when the campaign begins. Display text "Campaign started for ..." is preserved in the operator-facing copy. Excluded events `voice_intake_started` and `voice_intake_completed` removed from the prior excluded list — voice intake is deferred per PRD-02 v1.2 and these event values are not in the canonical enum.

### 9.2 Rendering rules

- Maximum 50 events displayed. If more than 50 events occurred today, show the 50 most recent and render a muted footnote: "Showing most recent 50 automation events."
- Each event row shows: event text (left), time (right, formatted as "2h ago" or "10:32 AM").
- No CTAs. No interactive elements. Tapping an event row does nothing.
- If zero automation events occurred today, do not render the "Handled by SMAI" section at all. The section header and divider are also hidden.
- The feed does not auto-refresh. It reflects the state at page load. Pull-to-refresh (mobile) or a manual refresh reloads the feed.

### 9.3 Data source

Query `job_proposal_history` where:
- `account_id = :account_id` (joined via `jobs` on `job_id`)
- `change_date >= start of current calendar day (operator local timezone)`
- `event_type IN ('campaign_step_sent', 'campaign_approved', 'campaign_completed', 'customer_replied', 'delivery_issue_detected', 'delivery_issue_resolved', 'campaign_paused', 'campaign_resumed')`
- Job's `location_id IN (:permitted_location_ids)` — join to `jobs` on `job_id`

Order by `change_date DESC`. Limit 50.

Note: Prior versions referenced `event_logs` table with `primary_context_type`, `primary_context_id`, and `occurred_at` fields. Replaced in v1.2 with `job_proposal_history` (`job_id`, `change_date`) per PRD-01 v1.4.1 §12 schema consolidation.

---

## 10. Empty States

### 10.1 No jobs needing attention

When the surfacing query returns zero results:

**Heading:** "You're all caught up"  
**Body text:** "No jobs need your attention right now. SMAI is running your campaigns in the background."  
**Visual:** A simple checkmark or calm icon (per Lovable design). No illustration required — keep it minimal.

The "Handled by SMAI" feed still renders below if there are automation events today. The empty state replaces only the actionable cards section.

### 10.2 No jobs needing attention and no automation events today

When both the card list and the feed are empty (e.g., account just onboarded, no jobs yet):

**Heading:** "Welcome to Needs Attention"  
**Body text:** "This is your command center. When a customer replies or a campaign needs help, it shows up here."  
**CTA:** A "+ New Job" button that opens the New Job modal (PRD-02).

### 10.3 First job ever (special onboarding case)

If the account has zero jobs total (no draft, no active, nothing), the empty state includes the onboarding prompt and the New Job CTA. This is the only time a CTA appears in the Needs Attention empty state.

---

## 11. Location Scope

### 11.1 Originator

Originators are single-location by design (PRD-08 v1.2). The screen loads scoped to the user's assigned location automatically (from `users.location_id`). No location switcher is shown. The page title or a muted label reads: "Needs Attention — {Location Name}". No UI exists for the user to change scope.

### 11.2 Admin

Admins have implicit access to all active locations in the account (`users.location_id` is null; `users.role = 'admin'`). The location switcher in the sidebar and profile slide-out is visible and active. The selected location determines the scope of the Needs Attention query. Switching locations reloads the entire screen with the new location's data.

Selecting "All Locations" expands the query to include every active location in the account. The page label reads: "Needs Attention — All Locations."

### 11.3 Scope enforcement

The backend enforces access scope server-side against the user's role and assigned location:
- For an Originator (`users.role = 'user'`): the backend returns only jobs where `location_id = users.location_id`. Any request for a different `location_id` returns 403.
- For an Admin (`users.role = 'admin'`): the backend returns jobs for any active location in the user's `account_id`. A specific `location_id` filter may be applied per the location switcher; "All Locations" returns every active location in the account. A request for a `location_id` outside the account returns 403.

The frontend cannot bypass this by filtering a broader result set client-side. Access-scope enforcement is server-side and non-negotiable per §2 point 8 and §4 source truth. A 403 response renders an access error state.

Eligibility filtering — determining which of the access-scoped jobs render on Needs Attention based on `cta_type` — is not an access-scope concern and may run server-side (via a dedicated endpoint or query parameter) or client-side (by filtering the shared jobs response). The choice is an implementation decision for the engineering team. What is not permitted: returning jobs outside the access scope under the assumption that the client will filter them out.

---

## 12. Screen Route and Navigation

**Route:** `/home` (Originator, implicit single-location) or `/:locationId/home` (Admin, explicit location selection).

**Default post-login destination:** After successful authentication, all users land on `/home` or `/:locationId/home` for their active location. This is non-negotiable. No other screen is the default landing page.

**Nav item:** "Needs Attention" is the first item in the sidebar navigation and the first tab in the mobile bottom nav. It is always highlighted when the current route is `/home` or `/:locationId/home`.

**Nav badge:** The Needs Attention nav item shows a numeric badge indicating the count of jobs currently on the screen (i.e., the count of jobs with an eligible `cta_type`). The badge updates in real time as jobs move on and off the list. If zero, no badge is shown (not "0"). The badge count is derived from the same query that populates the screen — not a separate count query.

**Real-time updates:** When a new job_needs_attention_flagged event fires for the active location, the Needs Attention screen updates without requiring a full page reload. The implementation mechanism (polling, websocket, or server-sent events) is an engineering-design decision. The product requirement is that a new Reply Needed or Delivery Issue job appears on the screen within 30 seconds of the event firing. The nav badge updates at the same time.

**Tapping a card:** Navigates to `/jobs/:jobId` or `/:locationId/jobs/:jobId`. Browser back returns to the Needs Attention screen.

**Mobile (390px):** The screen renders as a single-column card list. The "Handled by SMAI" feed renders below the cards. The bottom nav shows the Needs Attention tab (first tab) with the same badge logic.

---

## 13. Error States

### 13.1 Page load failure

If the backend query fails on page load:

Display an inline error banner at the top of the screen:  
"Couldn't load your jobs. Check your connection and refresh."  
A "Refresh" button reloads the page. The nav badge clears or shows a dash during error state.

### 13.2 CTA action failure

For inline CTA actions (Resume Campaign, and the sub-flow opened by Fix Delivery Issue):

- **Resume Campaign failure:** Toast: "Couldn't resume — try again." Card remains. No navigation.
- **Fix Delivery Issue sub-flow failure:** Handled within the Fix Delivery Issue slide-out per PRD-06 §11.2. The Needs Attention screen is not responsible for sub-flow error states. (Fix Delivery Issue is the only sub-flow opened from Needs Attention; Respond Now and Attach Estimate were removed in v1.2.)

### 13.3 Real-time update failure

If the real-time update mechanism fails silently, the screen shows stale data. No error is surfaced to the operator. Engineering must implement a fallback — at minimum, a periodic silent refresh (e.g., every 60 seconds) to re-query the list even if real-time push is unavailable.

---

## 14. System Boundaries

| Responsibility | Owner |
|---|---|
| Surfacing query (jobs eligible for Needs Attention) | smai-backend |
| Sort order (CTA priority + recency) | smai-backend (returned in order) |
| "Handled by SMAI" feed query | smai-backend |
| Location scope validation | smai-backend |
| Real-time event push (job_needs_attention_flagged) | smai-backend → frontend (mechanism TBD by engineering) |
| Nav badge count | smai-frontend (derived from surfacing query result count) |
| Card rendering (badge, job name, value, customer name, engagement fact, triage text, CTA) | smai-frontend |
| Engagement fact timestamp resolution | smai-frontend (derived from `job_proposal_history` or `messages` timestamps returned in API response) |
| Resume Campaign inline action | smai-frontend → smai-backend API |
| Fix Delivery Issue sub-flow launch | smai-frontend (sub-flow defined in PRD-06) |
| Open in Gmail external redirect | smai-frontend |
| Empty state rendering | smai-frontend |

The frontend does not recompute `cta_type` or sort order. It renders what the backend returns.

---

## 15. API Response Shape

The Needs Attention endpoint must return sufficient data to render every card element without additional fetches. This means a single endpoint call per page load returns:

For each job in the list:
- `job.id`
- `job.job_name`
- `job.job_type`
- `job.address_line1`
- `job.job_value_estimate`
- `job.cta_type`
- `job.pipeline_stage`
- `job.status_overlay`
- `job.updated_at`
- `job_contacts.customer_name`
- `job_contacts.customer_email`
- Most recent relevant `job_proposal_history` row: `event_type`, `change_date` (for engagement fact rendering)
- Most recent outbound message: `step_order`, `sent_at` (for "Follow-up #N sent" engagement fact)

For the "Handled by SMAI" feed:
- Up to 50 `job_proposal_history` rows with `event_type`, `change_date`, and enough job context (`job_name`, `customer_name`) to render the display text per §9.1.

All data returned in a single response. No waterfall fetches for individual cards.

Note: Prior versions referenced `event_logs` rows with `occurred_at` and `primary_context_id` join semantics. Replaced in v1.2 with `job_proposal_history` (`change_date`, `job_id`) per PRD-01 v1.4.1 §12 schema consolidation.

---

## 16. Implementation Slices

### Slice A: Surfacing query and API endpoint
Implement the Needs Attention backend query with the exact eligibility filter (`cta_type IN ('open_in_gmail', 'fix_delivery_issue', 'resume_campaign')`) and sort order (CTA priority + recency). Implement the "Handled by SMAI" feed query against `job_proposal_history` per §9.3. Return both in a single API response with all card-rendering fields per §15.

Dependencies: PRD-01 v1.4.1 (job record with `cta_type` stored and current per the canonical CTA enum; `job_proposal_history` schema and event semantics), PRD-03 v1.4.1 (events written to `job_proposal_history`).  
Excludes: Real-time updates, frontend rendering.

### Slice B: Card list rendering
Implement the card layout for all three card types (Reply Needed, Delivery Issue, Paused). Render status badge, job name, job value, customer name, time since last activity, engagement fact, triage text, and CTA button per the specs in §7. Implement card tap navigation to Job Detail.

Dependencies: Slice A.  
Excludes: Sub-flow modals (PRD-06 v1.3.1), real-time updates.

### Slice C: Inline Resume Campaign action
Implement the Resume Campaign inline tap: send resume request, on success remove card and show toast, on failure show error toast and keep card. No navigation.

Dependencies: Slice B. PRD-03 v1.4.1 §13.2 (Resume logic — smai-backend endpoint).  
Excludes: Other CTA sub-flows.

### Slice D: "Handled by SMAI" feed
Render the feed below the card list per the rules in §9. Implement the 50-event limit and the "no events today" hide behavior. Source events from `job_proposal_history` per §9.3.

Dependencies: Slice B.  
Excludes: Real-time feed updates (feed reflects state at page load only).

### Slice E: Empty states
Implement all three empty state variants (Section 10): all caught up, no events yet, first-time user with New Job CTA.

Dependencies: Slices B, D.

### Slice F: Location scope, nav badge, and real-time updates
Implement location scope switching and the backend scope enforcement. Implement the nav badge derived from the card count. Implement real-time updates (mechanism to be decided by engineering) with a 30-second latency requirement for new Needs Attention events. Implement the 60-second polling fallback.

Dependencies: Slices A, B. Spec 2 (multi-tenancy).

### Slice G: Error states and mobile
Implement page load failure error banner with Refresh. Implement mobile layout (390px single-column). Confirm bottom nav badge behavior matches desktop.

Dependencies: Slices B, F.

---

## 17. Acceptance Criteria

**AC-01: Surfacing — eligible jobs appear**
Given jobs with `cta_type` of `open_in_gmail`, `fix_delivery_issue`, and `resume_campaign` in the active location, when the operator loads Needs Attention, then all three jobs appear in the list.

**AC-02: Surfacing — ineligible jobs do not appear**
Given a job with `cta_type = view_job` (In Campaign, Won, or Lost), when the operator loads Needs Attention, then that job does not appear anywhere on the screen, including the feed.

**AC-03: Paused jobs appear**
Given a job with `status_overlay = paused` and `cta_type = resume_campaign`, when the operator loads Needs Attention, then that job appears in the card list with the Resume Campaign CTA.

**AC-04: Sort order — CTA priority**
Given one Reply Needed job and one Paused job both present in the list, when the screen renders, then the Reply Needed job appears above the Paused job regardless of which was updated more recently.

**AC-05: Sort order — recency tiebreaker**
Given two Reply Needed jobs, one updated 10 minutes ago and one updated 2 hours ago, when the screen renders, then the job updated 10 minutes ago appears first.

**AC-06: Card CTA correctness**
Given a job with `cta_type = open_in_gmail`, when the card renders, then the CTA button label is "Open in Gmail" and tapping it opens the Gmail thread directly in the operator's Gmail (per PRD-06 v1.3.1 §11.1). No in-app compose surface is shown.

**AC-07: Resume Campaign inline**
Given a job with `cta_type = resume_campaign`, when the operator taps Resume Campaign on the card, then the resume request is sent to the backend, on success the card disappears from the list and a "Campaign resumed" toast appears, and no navigation occurs.

**AC-08: Engagement fact — customer reply**
Given a job with `status_overlay = customer_waiting` where the reply occurred 2 hours ago, when the card renders, then the engagement fact reads "Customer replied 2h ago."

**AC-09: Engagement fact — follow-up sent**
Given a job in campaign where the most recent outbound message was step 2 sent 4 hours ago, when the card renders, then the engagement fact reads "Follow-up #2 sent 4h ago."

**AC-10: "Handled by SMAI" feed — today only**
Given three campaign_step_sent events: two from today and one from yesterday, when the feed renders, then only the two from today appear. The one from yesterday is absent.

**AC-11: "Handled by SMAI" feed — hidden when empty**
Given no automation events have occurred today, when the screen loads, then the "Handled by SMAI" section header, divider, and feed are not rendered.

**AC-12: Empty state — all caught up**
Given the surfacing query returns zero eligible jobs but automation events exist today, when the screen renders, then the heading "You're all caught up" and body text appear where the cards would be, and the "Handled by SMAI" feed renders below as normal.

**AC-13: Empty state — first-time user**
Given an account with zero jobs created, when the screen renders, then the "Welcome to Needs Attention" heading appears with the New Job CTA button.

**AC-14: Nav badge count**
Given 3 jobs on the Needs Attention list, when the screen renders, then the Needs Attention nav item shows a badge reading "3".

**AC-15: Nav badge absent when empty**
Given zero eligible jobs, when the screen renders, then no badge appears on the Needs Attention nav item. A "0" badge must not be shown.

**AC-16: Location scope enforcement**
Given an Admin with access to Location A and Location B, when Location A is active in the location switcher, then only jobs belonging to Location A appear in the card list and feed. Jobs from Location B are absent.

**AC-17: Real-time update**
Given a job that transitions to `status_overlay = customer_waiting` while the operator is viewing Needs Attention, when the transition occurs, then the job appears on the Needs Attention screen within 30 seconds without requiring a manual page refresh.

**AC-18: CTA matches across surfaces**
Given a job with `cta_type = fix_delivery_issue`, when the operator views that job on Needs Attention, Jobs list, and Job Detail simultaneously, then the CTA button label "Fix Delivery Issue" appears consistently on all three surfaces.

**AC-19: Removed CTA values do not appear**
Given any job in the system, when Needs Attention loads under any location scope, then no card displays a "Respond Now," "Attach Estimate," or "Complete Job Setup" CTA button. No card displays an "Awaiting Estimate" or "Draft" status badge. No `cta_type` value of `respond_now`, `attach_estimate`, or `complete_job_setup` is present in any card data, and no `pipeline_stage` value of `awaiting_estimate` or `draft` exists on any job (per PRD-02 v1.5).

---

## 18. Open Questions and Implementation Decisions

**OQ-01: Real-time update mechanism**
The product requirement (AC-17) is that new Needs Attention events appear within 30 seconds. The implementation — polling, websocket, or server-sent events — is an engineering-design decision. Engineering should confirm the mechanism before Slice F is built. The 60-second polling fallback is a minimum backstop regardless of which mechanism is chosen.

**OQ-02: Engagement fact timestamp source precision**
The engagement fact timestamps ("Customer replied 2h ago", "Follow-up #2 sent 4h ago") require event-level timestamps from `job_proposal_history` or `messages.sent_at`, not `jobs.updated_at`. The API response must include the relevant event timestamp per card (§15). Engineering should confirm whether this is returned as part of the jobs query join or as a separate field in the API response.

**OQ-03: Nav badge real-time sync**
The nav badge must update at the same time as the card list. If the real-time update mechanism updates the card list, it must also update the badge count. Engineering should confirm the badge is derived from the live query result count — not a separate count endpoint — to ensure they stay in sync.

---

## 19. Out of Scope

- Jobs list screen (PRD-05 v1.4)
- Job Detail screen and all sub-flows (PRD-06 v1.3.1)
- Open in Gmail behavior on Reply Needed cards (PRD-06 v1.3.1 §11.1)
- Fix Issue slide-out (PRD-06 v1.3.1 §11.2)
- Campaign Ready surface at intake (PRD-02 v1.5 §8.4)
- SMS notification layer (Spec 10)
- Analytics screen (Analytics PRD)
- Filters or search on Needs Attention (this screen has no filters — it shows all eligible jobs)
- Originator filter (SPEC-02, PRD-05 only — does not affect Needs Attention)
- Pagination (low job volume in launch; full list renders without pagination)
- Multi-day automation event history in the "Handled by SMAI" feed (today only in MVP)
- Admin portal (separate codebase, post-MVP)
