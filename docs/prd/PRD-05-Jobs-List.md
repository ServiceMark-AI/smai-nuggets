# PRD-05: Jobs List
**Version:** 1.4  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked); Session State v6.0; Spec 6 (Job Status Model and CTA Engine) [legacy out-of-repo reference; superseded by PRD-01 v1.4.1 §6 and §7]; Spec 7 (Job Status Architecture and CTA Rules) [legacy out-of-repo reference; superseded by PRD-01 v1.4.1 §7]; Spec 12 (Branding and UI) [legacy out-of-repo reference; no canonical in-repo successor; UI ground truth is the Lovable FE audit per governing principle]; Spec 13 (Global Navigation and Routing) [legacy out-of-repo reference; no canonical in-repo successor in the active spec set; treat as deferred platform-shell concern, does not govern the launch build]; Spec 2 (Multi-Tenancy) [legacy out-of-repo reference; superseded by PRD-08 v1.2 (role and location model) and PRD-10 v1.2 (admin portal tenant management)]; PRD-01 v1.4.1 (Job Record); PRD-02 v1.5 (New Job Intake); PRD-03 v1.4.1 (Campaign Engine); PRD-04 (Needs Attention); PRD-06 v1.3.1 (Job Detail); SPEC-03 v1.3 (Job Type and Scenario); SPEC-11 v2.0 (Campaign Template Architecture); Reconciliation Report 2026-04-16; Save State 2026-04-21 (Pending Approval elimination, templated architecture)  
**Related PRDs and specs:** PRD-01 v1.4.1, PRD-02 v1.5, PRD-03 v1.4.1, PRD-04, PRD-06 v1.3.1; SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0  
**Tracking issues:** [#68 A query/endpoint](https://github.com/frizman21/smai-server/issues/68) · [#69 B card list](https://github.com/frizman21/smai-server/issues/69) · [#70 C filter bar + URL](https://github.com/frizman21/smai-server/issues/70) · [#71 D search](https://github.com/frizman21/smai-server/issues/71) · [#72 E overflow menu](https://github.com/frizman21/smai-server/issues/72) · [#73 F inline Resume](https://github.com/frizman21/smai-server/issues/73) · [#74 G empty/scope/mobile](https://github.com/frizman21/smai-server/issues/74)  
**Revision note (v1.1):** Removed Draft, Awaiting Estimate, `attach_estimate`, and `complete_job_setup` from all filter options, sort tables, card anatomy, badge colors, and ACs. Added Pending Approval / `review_plan`. Updated "Customer Waiting" label to "Reply Needed" to match Lovable. All jobs enter `in_campaign` at creation; no pre-campaign states exist in the launch build.  
**Revision note (v1.2):** Aligned history references to the consolidated `job_proposal_history` table per PRD-01 v1.2 §12. All event writes (`job_marked_won`, `job_marked_lost`, `job_deleted`, `job_issue_flagged`) now land in `job_proposal_history` discriminated by `event_type`. Added physical table naming clarifier to §4. Prose continues to say "jobs" and "job_campaigns" for readability. See DL-026, DL-027.  
**Revision note (v1.3):** Three related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, PRD-01 v1.4, PRD-02 v1.5, PRD-03 v1.4, and PRD-06 v1.3 drive. Nothing else.

1. **Pending Approval eliminated across all Jobs List surfaces.** Per PRD-01 v1.4 and PRD-02 v1.5, no job record ever sits in a Pending Approval state. Removed Pending Approval from the §5 status list, the §6 CTA priority sort table, the §7.1 filter options, the §9.1 engagement fact rules, the §9.1 triage text table, the §9.2 CTA button table, the §10 status badge specification, and the §12.2 empty state examples. Removed AC-05 (Pending Approval filter). Removed `job_campaigns.status` from the §17 API response shape (no longer needed for any operative card-rendering rule). New builders point added to §2 on Pending Approval absence.

2. **Variable step count replaces hardcoded four-step cadence.** Per SPEC-11 v2.0 and PRD-03 v1.4, step count is sourced from the active template variant. §9.1 In Campaign triage text updated: "{N} of 4 follow-ups sent" becomes "{N} of {M} follow-ups sent" where M is the total step count from the active template variant (readable from `campaign_steps` for the active `job_campaigns`). AC-18 updated.

3. **Job Type display label clarification.** Per SPEC-03 v1.3 §7.1 and §8 casing rules, the raw `job_type` enum value should be transformed to a human-readable label when displayed to operators. §9.1 Row 1 fallback name rendering note added. Card status badge unchanged (no Job Type displayed in badge). Scenario was considered for card display and explicitly excluded — it remains an internal categorization for template selection, not an operator-scan field.

Material section changes in v1.3: header, §2 (new builders point), §4 (locked constraints updated), §5 (Pending Approval bullet removed), §6 (review_plan row removed, table renumbered), §7.1 (Pending Approval filter row removed), §9.1 (engagement fact and triage text rows removed; Job Type display note added; variable step count), §9.2 (review_plan row removed), §10 (Pending Approval badge row removed), §11.5 (PRD-03 version reference), §12.2 (example list cleanup), §17 (job_campaigns.status removed from response shape), §18 (slice dependencies version-referenced), §19 (AC-05 removed and renumbered; AC-18 wording for variable step count), §20 (OQ-03 version reference).

**Revision note (v1.4):** Surgical consistency cleanup per CONSISTENCY-REVIEW-2026-04-22. Five edits, all surface-level, no logic changes:

1. **Default sort rule reconciled (B-02).** §2 point 2 and AC-02 rewritten to match §6: the All Jobs default sorts by recency (`jobs.created_at` descending). CTA priority governs only under status-filtered views. Recency remains the tiebreaker within the same CTA priority tier under filtered views. §6 was already correct; the §2 point and AC-02 were the stale assertions.

2. **Slice C filter count corrected (H-01).** §18 Slice C "ten options" updated to "nine options" to match §7.1 (Pending Approval removed in v1.3 reduced the count from ten to nine).

3. **In Campaign filter SQL aligned to v1.3 API contract (H-02).** §7.1 In Campaign filter row drops the `AND job_campaigns.status = active` condition. Per PRD-01 v1.4, an `in_campaign` job with null `status_overlay` is definitionally in an active campaign; the extra condition is redundant and references a field §17 v1.3 removed from the API response.

4. **"Paused (Campaign Hold)" → "Paused" (B-01-adjacent).** Lines 118 (§5 status list) and 295 (§10 badge table) updated to the canonical "Paused" label. Aligns with PRD-01 §7 status_overlay value `paused` and the "Paused" filter label already in §7.1.

5. **L-06 application: no operational changes.** "Customer Waiting" appears only in the v1.1 revision note (audit trail, retained) and inside SQL/triage prose tied to the `customer_waiting` enum value (which is unchanged). No UI-facing operational sites in PRD-05 require renaming under the locked convention.

Patch note (2026-04-22): B-02 + H-01 + H-02 + B-01-adjacent + L-06 inventory. Ref CONSISTENCY-REVIEW-2026-04-22.

**Patch note (2026-04-23):** Two changes; no behavioral change. (1) H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1`, `PRD-03 v1.4` → `PRD-03 v1.4.1`, `PRD-06 v1.3` → `PRD-06 v1.3.1`. Audit-trail revision-note text preserved byte-exact. (2) M2P-08 L-01 legacy annotations applied to §0 source-truth line: Specs 6, 7, 12, 13, 2 each annotated as out-of-repo references with their canonical in-repo successor (or noted as deferred / no-successor where applicable, e.g., Spec 12 superseded by Lovable FE per governing principle). Matches the L-01 treatment PRD-01 v1.4.1 received on 2026-04-22. No version bump on PRD-05 (sweep + annotation are pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01, M2P-08.

**Patch note (2026-04-23, M2P-07 follow-up):** §10 Status Badge Specification table rebuilt with five columns: `Operator-facing status | Color name | Color hex | Style | Badge label`. Final canonical name + hex pairs: Reply Needed = Coral / `#F56B4B`, Delivery Issue = Red / `#E53935`, Paused = Amber / `#F5A623`, In Campaign = Teal / `#00B3B3`, Won = Green / `#27AE60`, Lost = Gray / `#9CA3AF` (outline). The `Color hex` column's rendering role depends on `Style`: for solid badges the hex fills the background and text is white (`#FFFFFF`); for outline badges (Lost only) the background is transparent, the hex is the border, and text uses the same hex as the border. The name + hex pair is the canonical reference convention across PRD-04, PRD-05, and PRD-06; it keeps the docs human-readable while pinning the exact value. The outline style is reserved for terminal states with no urgency or follow-up, preserving the de-emphasis intent that the prior PRD-04 v1.2.1 text expressed via "Gray outline." This closes the M2P-07 follow-up gap (initial hex-only normalization stripped both the name disambiguation and the outline-vs-fill style cue) and finalizes the PRD-04 / PRD-05 / PRD-06 badge convention. Propagated to PRD-04 §8 and PRD-06 §9.1 in the same patch cycle. No behavioral change. Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-07 follow-up.

---

## 1. What This Is in Plain English

The Jobs list is the complete inventory of every job in the system for the active location — open and closed, running and stopped, new and old. Where Needs Attention shows only what requires human action right now, Jobs shows everything.

An operator comes to Jobs when they want to see the full picture: what is running, what is done, what is stuck, how many jobs are active. They also come here when they want to find a specific job by customer name or job name and navigate to its detail.

The list shows all jobs sorted by CTA priority first (same ladder as Needs Attention), then by recency within the same tier. Every card has the same elements as Needs Attention cards. The CTA button is present on every card — even for In Campaign, Won, and Lost jobs, where it reads "View Job." The difference from Needs Attention is that no jobs are excluded. Everything is here.

The screen has a filter bar and a search field. Filters are single-select status groupings that narrow the list. Search runs against job name and customer name. Neither filter nor search change the sort order — priority and recency always govern within whatever subset is shown.

Every card has a three-dot overflow menu giving access to secondary actions: Mark Won, Mark Lost, Flag Issue, Delete Job. These are context-sensitive — some are unavailable depending on the job's current status.

---

## 2. What Builders Must Not Misunderstand

1. **All jobs appear here — including Won and Lost.** The Jobs list is the complete inventory. There is no default "open only" view. The default filter is All Statuses. Won and Lost jobs are visible. The operator can filter them out using the filter bar.

2. **Sort order depends on the active filter.** The All Jobs default view sorts by recency (`jobs.created_at` descending) — this is an inventory view, not a triage view. Status-filtered views sort by CTA priority first, with recency as the tiebreaker within the same CTA tier. The CTA priority ladder is the same ladder as Needs Attention. See §6 for the full rule.

3. **The CTA button is present on every card — always.** In Campaign, Won, and Lost jobs all show a "View Job" CTA. There is no card without a CTA. This is the principle of visual consistency: every card has the same anatomy.

4. **The Jobs list never shows the operator a blank screen with no data.** If the filter returns zero results, an empty state is shown with context-specific copy. If the account has no jobs at all, a first-time empty state is shown with a "+ New Job" CTA.

5. **Filters are single-select, not multi-select.** One filter is active at a time. Selecting a new filter replaces the current one.

6. **Filter state persists in the URL.** The active filter is stored as a query parameter. Back navigation restores the filter. Deep links with filter parameters work correctly.

7. **The "+ New Job" button opens the modal (PRD-02). It does not navigate to a route.** `/jobs/new` must not exist. Attempting to navigate there returns 404 or redirects.

8. **Delete Job is a soft delete. The record is never destroyed.** The operator cannot undo a delete from the UI in Buc-ee's, but the record exists in the database. This preserves audit integrity.

9. **Mark Won and Mark Lost on the list card perform the same state transition as on Job Detail.** The transition is executed via the same backend endpoint. It is not a different code path.

10. **The three-dot overflow menu is context-sensitive.** Mark Won and Mark Lost are unavailable on jobs already in Won or Lost state. Delete Job is available on all statuses but requires a confirmation step. Flag Issue is available on all statuses.

11. **No Pending Approval state appears on the Jobs list.** Per PRD-01 v1.4.1 and PRD-02 v1.5. The durable job record is written only on Approve and Begin Campaign at intake; by the time a job is queryable on the Jobs list, its campaign is already active (or in another overlay state like delivery issue, paused, etc.). The Pending Approval filter, badge, engagement fact, triage text, and `review_plan` CTA have been removed from this PRD in v1.3. The Pending Approval filter URL value (`?status=pending-approval`) is no longer routable; if encountered in a deep link it should be treated as `?status=all` (see OQ-04).

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- Which jobs appear and in what order (all jobs, CTA priority sort)
- The filter bar: all filter options, their groupings, what each filters to
- Search: what fields are searched, how it works
- Card anatomy: every element on every Jobs list card
- The three-dot overflow menu: all actions, availability by status, confirmation behavior
- Empty states per filter selection
- The "+ New Job" button behavior
- Location scope enforcement
- The route and URL behavior including filter persistence
- Error states

**This PRD does not cover:**
- Needs Attention screen (PRD-04)
- Job Detail screen and sub-flows (PRD-06)
- New Job intake modal (PRD-02)
- Analytics screen (Analytics PRD)
- The Campaigns screen (separate, read-only in MVP)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| All jobs appear on the Jobs list — open and closed. No exclusions. | Spec 6 |
| Default filter is All Statuses (or All Open Statuses — see OQ-01). | Spec 7, Lovable FE audit — confirm against live sandbox |
| Sort is CTA priority order, same ladder as Needs Attention. Recency is tiebreaker. | Spec 6 |
| CTA button present on every card including In Campaign, Won, Lost ("View Job"). | Spec 7, Lovable FE audit |
| `/jobs/new` must not exist as a routed page. New Job is a modal. | Session State v6.0, PRD-02 v1.5 |
| Filter state preserved in URL as query parameter. | Spec 13 |
| Three-dot overflow menu: Mark Won, Mark Lost, Flag Issue, Delete Job. | Session State v6.0 |
| Delete Job is soft delete. Record is not destroyed. | Audit integrity, Platform Spine |
| Mark Won and Mark Lost on list card use the same backend endpoint as Job Detail. | PRD-01 v1.4.1, PRD-03 v1.4.1 |
| Search runs against job name and customer name in MVP. | Spec 7 |
| Filters are single-select. | Spec 7, Lovable FE audit |
| Location scope enforced server-side. Backend filters by account_id + location_id. | Spec 2, Spec 13 |
| Status badge colors: canonical values from Spec 12. | Spec 12 |
| Engagement fact and triage text rules: same as PRD-04. | Spec 7, Spec 10 |
| No Pending Approval state appears on the Jobs list. No `review_plan` CTA. No Pending Approval filter, badge, or sort priority entry. | PRD-01 v1.4.1; PRD-02 v1.5; Save State 2026-04-21 |
| Step count is variable per active template variant. "{N} of {M} follow-ups sent" where M is sourced from `campaign_steps` count for the active `job_campaigns`. | SPEC-11 v2.0; PRD-03 v1.4.1 |
| Job Type display label per SPEC-03 v1.3 §7.1 and §8 casing rules. Raw enum values must be transformed to display labels for operator-facing rendering. | SPEC-03 v1.3 |
| Physical table names: `job_proposals` (jobs), `campaigns` (job_campaigns), `job_proposal_history` (consolidated history). Prose in this PRD continues to say "jobs" and "job_campaigns" for readability. All lifecycle event writes land in `job_proposal_history`. | PRD-01 v1.4.1 §12, DL-026, DL-027 |

---

## 5. All Jobs, All Statuses

The Jobs list query returns all jobs within the active location scope, across all statuses, with no exclusions. This includes:

- In Campaign
- Reply Needed
- Delivery Issue
- Paused
- Won
- Lost

Jobs are returned sorted by CTA priority then recency. The filter bar narrows this set. Search narrows it further. The sort order does not change based on filter or search.

Note: Pending Approval was removed from this list in v1.3 per PRD-01 v1.4.1. No job record ever sits in a Pending Approval state under the collapsed intake flow (PRD-02 v1.5).

---

## 6. Sort Order

Sort behavior depends on the active filter.

Default view (All Jobs filter active):

Jobs sort by `jobs.created_at` descending — most recently created job appears first. No CTA priority applied. This is an inventory view. The operator is scanning their full job list by recency, not by interrupt priority.

Status-filtered views (any filter other than All Jobs):
When the operator has filtered to a specific status or status group, jobs within that filtered set sort by CTA priority first, then by `jobs.created_at` descending as the tiebreaker within the same tier.

CTA priority order (for filtered views):

| Priority | `cta_type` | Operator-facing status |
|---|---|---|
| 1 | `open_in_gmail` | Reply Needed |
| 2 | `fix_delivery_issue` | Delivery Issue |
| 3 | `resume_campaign` | Paused |
| 4 | `view_job` | In Campaign, Won, Lost |

Note: Prior versions carried `review_plan` at priority 3 mapping to Pending Approval. Removed in v1.3 per PRD-01 v1.4.1 (no Pending Approval state exists). Subsequent priorities renumbered.

Sort is computed server-side and returned in order. The frontend renders the list as received. No client-side re-sorting.

---

## 7. Filter Bar

The filter bar is a horizontal row of single-select options at the top of the Jobs list, directly below the page title and search field. Exactly one option is active at all times. The active option is visually highlighted (teal underline or teal text — per Lovable design).

### 7.1 Filter options (canonical, in display order)

| Filter label | `status` query param value | What it shows |
|---|---|---|
| All | `all` | All jobs regardless of status |
| Open | `open` | All jobs where `pipeline_stage = in_campaign` (not won or lost) |
| Reply Needed | `reply-needed` | Jobs where `status_overlay = customer_waiting` |
| Delivery Issue | `delivery-issue` | Jobs where `status_overlay = delivery_issue` |
| In Campaign | `in-campaign` | Jobs where `pipeline_stage = in_campaign` AND `status_overlay = null` |
| Paused | `paused` | Jobs where `status_overlay = paused` |
| Won | `won` | Jobs where `pipeline_stage = won` |
| Lost | `lost` | Jobs where `pipeline_stage = lost` |
| Closed | `closed` | Jobs where `pipeline_stage = won` OR `pipeline_stage = lost` |

Note: Prior versions carried a Pending Approval filter (`status=pending-approval`) selecting `job_campaigns.status = pending_approval`. Removed in v1.3 per PRD-01 v1.4.1 (no Pending Approval state exists). See OQ-04 for handling of legacy URLs.

**Default filter on initial page load:** All (`status=all`). Jobs sorted by `jobs.created_at` descending.

**Filter state in URL:** The active filter is persisted as `?status=<value>` on the `/jobs` route. Example: `/jobs?status=reply-needed`. When the operator navigates to Job Detail and returns via back navigation, the filter is restored from the URL parameter. The frontend reads the `status` query param on mount and applies the corresponding filter.

**Filter execution:** Filters are applied server-side. When the operator selects a filter, the frontend sends a new request with the filter parameter. The backend returns only the jobs matching the filter, already sorted. Filters are not applied client-side from a full result set.

---

## 8. Search

### 8.1 Behavior

A search input field appears above the filter bar or inline with it (per Lovable design — confirm placement against live sandbox). The placeholder text is "Search jobs..."

Search is applied client-side against the current filtered result set returned by the most recent backend query. It is not a separate backend search endpoint at Buc-ee's scale.

Search is case-insensitive. It matches on any substring, not just prefix.

### 8.2 Searchable fields (MVP)

- `jobs.job_name`
- `job_contacts.customer_name`

Search does not currently match on: job number, phone number, address, or policy number. These are post-MVP search fields.

### 8.3 Behavior while searching

- As the operator types, the list filters in real time (debounced at 200ms).
- Jobs that do not match the search string are hidden.
- The sort order among matching jobs does not change — CTA priority and recency still govern.
- If the search produces zero matches within the current filter set, the empty search state is shown (Section 12.3).
- Clearing the search field restores the full filtered result set.

### 8.4 Search and filter interaction

Search and filter operate together. The filter determines which jobs are fetched from the backend. Search then narrows the client-side result. An operator filtered to "Reply Needed" and searching "Smith" sees only Reply Needed jobs whose job name or customer name contains "Smith."

---

## 9. Card Anatomy

Every card on the Jobs list has the same structural elements as Needs Attention cards (PRD-04, Section 7). They are specified fully here so this PRD is self-contained.

Each card is tappable. Tapping anywhere on the card navigates to the Job Detail screen for that job (`/jobs/:jobId` or `/:locationId/jobs/:jobId`).

### 9.1 Card elements (top to bottom, left to right)

**Row 1: Status badge + job name + job value**

- **Status badge** — left-aligned. Color and label per Section 10 (Status Badges).
- **Job name** — `jobs.job_name`. If null, render `{job_type_display_label} + " — " + jobs.address_line1` where `job_type_display_label` is the human-readable label for `jobs.job_type` per SPEC-03 v1.3 §7.1 and §8 casing rules (not the raw enum string). Truncate at 60 characters with ellipsis.
- **Job value** — right-aligned. Renders `jobs.job_value_estimate` formatted as currency (e.g., "$4,200"). If null, render nothing (no placeholder, no zero).

**Row 2: Customer name + time since last activity**

- **Customer name** — `job_contacts.customer_name`. If null, render "Unknown Customer" in muted gray (`--muted-foreground`).
- **Time since last activity** — right-aligned. Derived from `jobs.updated_at`. Format: "2h ago", "1d ago", "3d ago". No exact timestamps.

**Row 3: Engagement fact**

A single line stating the most recent meaningful event for this job. Rules for rendering (evaluated in priority order, first match wins):

| Condition | Engagement fact text |
|---|---|
| `status_overlay = customer_waiting` | "Customer replied {time ago}" |
| `status_overlay = delivery_issue` | "Email delivery failed {time ago}" |
| `pipeline_stage = won` | "Marked Won {time ago}" |
| `pipeline_stage = lost` | "Marked Lost {time ago}" |
| Most recent outbound message is `status = sent` | "Follow-up #{step_order} sent {time ago}" |
| `status_overlay = paused` | "Campaign paused {time ago}" |
| No messages and no overlay | "Job created {time ago}" |

The time reference derives from the relevant event timestamp in `job_proposal_history` or `messages.sent_at`. It is not `jobs.updated_at`.

Note: Prior versions carried a "`job_campaigns.status = pending_approval` → 'Campaign plan ready for review'" row. Removed in v1.3.

**Row 4: Triage text**

One sentence, meaning-second, per `cta_type`:

| `cta_type` | Triage text |
|---|---|
| `open_in_gmail` | "This customer is warm — respond before they go cold." |
| `fix_delivery_issue` | "Your follow-up isn't reaching this customer. Fix their email to resume." |
| `resume_campaign` | "Your campaign is on hold. Resume when ready." |
| `view_job` (In Campaign) | "Campaign running — {N} of {M} follow-ups sent." |
| `view_job` (Won) | "Job closed as Won." |
| `view_job` (Lost) | "Job closed as Lost." |

For In Campaign jobs with `cta_type = view_job`, the triage text includes both the send count (N, derived from the count of successful outbound `messages` rows for that job's active `job_campaigns` record) and the total step count (M, derived from the count of `campaign_steps` rows for that active `job_campaigns` record). M is variable per template variant per SPEC-11 v2.0 and PRD-03 v1.4.1 §7.1. If either count cannot be determined, render "Campaign running."

Note: Prior versions carried a `review_plan` triage text row ("Review and approve the campaign plan to begin automated follow-ups."). Removed in v1.3. The In Campaign row previously read "{N} of 4 follow-ups sent" with a hardcoded total; updated to variable {M}.

**Row 5: CTA button + three-dot overflow menu**

- **CTA button** — right-aligned, primary. Label and behavior per Section 9.2.
- **Three-dot overflow menu icon** — appears to the right of or above the CTA button (per Lovable design). Opens the overflow menu (Section 11).

### 9.2 CTA button per status

| `cta_type` | Button label | Tap behavior |
|---|---|---|
| `open_in_gmail` | Open in Gmail | Opens the Gmail thread directly in Gmail |
| `fix_delivery_issue` | Fix Delivery Issue | Opens Fix Issue slide-out (PRD-06 v1.3.1 §11.2) |
| `resume_campaign` | Resume Campaign | Resume inline (same as PRD-04 §7.1 inline behavior) |
| `view_job` | View Job | Navigates to Job Detail |

Note: Prior versions carried a `review_plan` row with a "Review & Approve Plan" button opening the Plan Review modal on PRD-06. Removed in v1.3. Campaign plan approval lives at intake per PRD-02 v1.5 §8.4 (Campaign Ready surface), not on the Jobs list or Job Detail.

**Resume Campaign inline on Jobs list:** Same behavior as Needs Attention. No navigation. Send resume request to smai-backend. On success, card updates immediately — `status_overlay` clears, `cta_type` becomes `view_job`, triage text updates to "Campaign running." On failure, toast: "Couldn't resume — try again." Card state unchanged.

---

## 10. Status Badge Specification

Canonical colors from Spec 12. All surfaces must use these exact values.

| Operator-facing status | Color name | Color hex | Style | Badge label |
|---|---|---|---|---|
| Reply Needed | Coral | `#F56B4B` | solid | Reply Needed |
| Delivery Issue | Red | `#E53935` | solid | Delivery Issue |
| Paused | Amber | `#F5A623` | solid | Paused |
| In Campaign | Teal | `#00B3B3` | solid | In Campaign |
| Won | Green | `#27AE60` | solid | Won |
| Lost | Gray | `#9CA3AF` | outline | Lost |

The `Color hex` column is the canonical color of the badge; its rendering role depends on the `Style` column. For **solid** badges, the color hex fills the badge background and the text is white (`#FFFFFF`). For **outline** badges (Lost only), the badge background is transparent, the color hex is the border, and the text uses the same hex as the border. Outline style is reserved for terminal states with no urgency or follow-up — Lost is the only badge that uses it.

The `Color name` column is the canonical English label, paired one-to-one with its hex value. Both columns are authoritative; when referencing a badge color in prose or in other docs, use the name + hex pair (e.g., `Coral / #F56B4B`) to keep the docs human-readable while pinning the exact value. Names are pinned to hex; never change one without the other.

The badge label "In Campaign (Auto)" appears in the Spec 12 badge label list. On the Jobs list card the full label "In Campaign" is used. The "(Auto)" qualifier is a display variant for certain contexts — confirm against the live Lovable sandbox which variant appears on the list card.

Note: Prior versions carried a Pending Approval badge (`#4B8BF5` background). Removed in v1.3. Spec 12 still lists the color for reference but it is not used on operator-facing surfaces under the current build.

---

## 11. Three-Dot Overflow Menu

The three-dot menu appears on every job card in the Jobs list. It opens a small dropdown with secondary actions. It does not appear on the Needs Attention screen (actions there are handled by the primary CTA).

### 11.1 Menu items and availability

| Action | Available when | Behavior |
|---|---|---|
| Mark Won | `pipeline_stage` is NOT `won` or `lost` | See Section 11.2 |
| Mark Lost | `pipeline_stage` is NOT `won` or `lost` | See Section 11.3 |
| Flag Issue | All statuses | See Section 11.4 |
| Delete Job | All statuses | See Section 11.5 |

When a menu item is unavailable, it is either hidden or rendered as grayed-out and non-tappable. The Lovable FE audit must confirm which approach — confirm against live sandbox before building.

### 11.2 Mark Won

Tapping Mark Won opens a brief confirmation: "Mark this job as Won? This will stop all automated messaging."

On confirmation:
- Calls smai-backend with the Won transition.
- smai-backend executes the full job closure write (PRD-01 v1.4.1 §9; PRD-03 v1.4.1 §10.4): `pipeline_stage = won`, `status_overlay = null`, `cta_type = view_job`, `won_at = now()`, campaign stopped, `job_proposal_history` row written with `event_type = job_marked_won`.
- Card updates in place: status badge changes to Won, triage text changes to "Job closed as Won," CTA changes to "View Job."
- Toast: "Job marked as Won."

On backend failure:
- Toast: "Couldn't update job — try again."
- Card state reverts to previous state.

Mark Won is not available on Won or Lost jobs. If somehow called against a Won or Lost job, the backend rejects it with a typed error.

### 11.3 Mark Lost

Identical to Mark Won in structure and UX, substituting Lost.

Confirmation: "Mark this job as Lost? This will stop all automated messaging."

On confirmation:
- `pipeline_stage = lost`, `lost_at = now()`, `cta_type = view_job`, campaign stopped, `job_proposal_history` row written with `event_type = job_marked_lost`.
- Card updates: badge changes to Lost, triage text to "Job closed as Lost," CTA to "View Job."
- Toast: "Job marked as Lost."

### 11.4 Flag Issue

Flag Issue is a lightweight internal signal. In Buc-ee's, it creates a history row for SMAI internal visibility. It does not change the job's `pipeline_stage`, `status_overlay`, or `cta_type`. It does not affect the campaign.

Tapping Flag Issue opens a brief text input prompt: "Describe the issue (optional)" with a Submit button and a Cancel link.

On submit (with or without text):
- Writes a `job_proposal_history` row with `event_type = job_issue_flagged`, `changed_by = <operator email>`, and the submitted description text in `metadata`.
- Toast: "Issue flagged."
- Card state unchanged.

On cancel:
- Dropdown closes. No write occurs.

Flag Issue is available on all job statuses including Won and Lost.

### 11.5 Delete Job

Delete Job is a soft delete. The job record is marked as deleted (a `deleted_at` timestamp or an `is_deleted` boolean on the `job_proposals` table — engineering-design decision, see OQ-02). The record is not destroyed. It is excluded from all frontend queries after deletion but remains in the database for audit purposes.

Deleting a job that is In Campaign must stop the campaign first. Before soft-deleting, smai-backend:
1. Stops the active campaign run (same closure path as job closure in PRD-03 v1.4.1 §10.4, setting `job_campaigns.status` to a terminal status).
2. Writes `job_proposal_history` row with `event_type = job_deleted`, `changed_by = <operator email>`.
3. Sets the deleted flag on the job record.

Tapping Delete Job opens a confirmation: "Delete this job? This cannot be undone."

On confirmation:
- smai-backend executes the delete sequence above.
- The card is removed from the Jobs list immediately.
- Toast: "Job deleted."

On backend failure:
- Toast: "Couldn't delete job — try again."
- Card remains.

On cancel:
- Dropdown closes. No write occurs.

Delete Job is available on all statuses. A job being In Campaign does not block deletion — it triggers the campaign stop first.

---

## 12. Empty States

### 12.1 No jobs at all (account has zero jobs)

Shown when the account has no job records in the database.

**Heading:** "No jobs yet"  
**Body:** "Upload a proposal to create your first job."  
**CTA:** "+ New Job" button that opens the New Job modal.

### 12.2 No jobs matching current filter

Shown when the active filter returns zero results (but other jobs exist under other filters).

**Heading:** "{Filter name} — nothing here"  
**Body:** "No jobs match this filter right now."  
**Secondary link:** "View all jobs" — clears the filter to All.

Examples:
- "Reply Needed — nothing here"
- "Delivery Issue — nothing here"
- "Paused — nothing here"
- "Won — nothing here"

### 12.3 No jobs matching search

Shown when search produces zero matches within the current filter.

**Heading:** "No results for "{search term}""  
**Body:** "Try a different name or clear the search."  
**Action:** An "×" button in the search field that clears the search and restores the filtered list.

---

## 13. Screen Header and "+ New Job" Button

The screen header contains:
- **Page title:** "Jobs" (left-aligned)
- **"+ New Job" button** (right-aligned, primary teal)

Tapping "+ New Job" opens the New Job modal (PRD-02). It does not navigate to a route. `/jobs/new` must not be a real route — it returns 404 or redirects to `/jobs`. The modal opens on top of the current Jobs list screen.

On mobile (390px), the "+ New Job" button may be rendered as a floating action button or repositioned — confirm against the Lovable mobile audit. The behavior is identical: tap opens the modal.

---

## 14. Location Scope

Identical rules to PRD-04 Section 11.

---

## 15. Route and URL Behavior

**Route:** `/jobs` (single-location) or `/:locationId/jobs` (multi-location).

**Filter query parameter:** `?status=<value>` as defined in Section 7.1.

**Deep links:** Any specific job is linkable via `/jobs/:jobId`. If the job does not exist or the user does not have access, the frontend shows an inline error and offers "Back to Jobs."

**Location switching:** When switching location, the route updates to `/:newLocationId/jobs`. The filter resets to default.

**Back navigation:** When the operator navigates to Job Detail from the Jobs list and returns via back navigation, the browser restores the previous URL including the `?status` query parameter. The Jobs list re-renders with the previous filter applied.

---

## 16. System Boundaries

| Responsibility | Owner |
|---|---|
| Jobs list query (all jobs, location-scoped, sorted) | smai-backend |
| Filter application (server-side, per filter parameter) | smai-backend |
| Sort order (CTA priority + recency, returned in order) | smai-backend |
| Location scope enforcement | smai-backend |
| Mark Won / Mark Lost state transitions and writes | smai-backend (same endpoint as Job Detail) |
| Resume Campaign inline write | smai-backend |
| Flag Issue `job_proposal_history` write | smai-backend |
| Delete Job soft-delete write, campaign stop, and `job_proposal_history` write | smai-backend |
| Search (client-side against returned result set) | smai-frontend |
| Filter state persistence in URL | smai-frontend |
| Card rendering (badge, name, value, engagement fact, triage text, CTA, overflow menu) | smai-frontend |
| Engagement fact timestamp derivation | smai-frontend (from event timestamps in API response) |
| In Campaign triage text send count | smai-frontend (from messages count in API response) |
| Confirmation dialogs (Mark Won, Mark Lost, Delete Job) | smai-frontend |
| Empty state rendering | smai-frontend |
| "+ New Job" modal trigger | smai-frontend |

---

## 17. API Response Shape

The Jobs list endpoint must return all data needed to render every card element without additional fetches. For each job:

- `job.id`
- `job.job_name`
- `job.job_type`
- `job.address_line1`
- `job.job_value_estimate`
- `job.cta_type`
- `job.pipeline_stage`
- `job.status_overlay`
- `job.updated_at`
- `job.won_at` (for "Marked Won {time ago}" engagement fact)
- `job.lost_at` (for "Marked Lost {time ago}" engagement fact)
- `job_contacts.customer_name`
- Most recent relevant `job_proposal_history` row: `event_type`, `change_date`
- Most recent outbound message: `step_order`, `sent_at`
- Count of successfully sent messages for the active campaign run (for In Campaign triage text — N value)
- Total `campaign_steps` count for the active campaign run (for In Campaign triage text — M value)

The filter parameter is passed as a query parameter. The backend applies the filter and returns only matching jobs in priority + recency order.

Note: Prior versions returned `job_campaigns.status` for the Pending Approval filter and engagement fact. Both removed in v1.3 (no Pending Approval state exists). `job_campaigns.status` is no longer needed for any operative card-rendering rule. If Mark chooses to still return it for engineering reasons (debugging, future use), that is fine; the FE does not consume it for any documented purpose.

---

## 18. Implementation Slices

### Slice A: Jobs list query and API endpoint ([#68](https://github.com/frizman21/smai-server/issues/68))
Implement the backend query returning all jobs in the active location, sorted per §6 (default by recency under All filter; CTA priority + recency under filtered views). Implement filter parameter handling for all nine filter options (Pending Approval removed in v1.3). Return all card-rendering fields per §17 in a single response, including total `campaign_steps` count for the active campaign run (M value for In Campaign triage text), relevant `job_proposal_history` event timestamps, and send counts.

Dependencies: PRD-01 v1.4.1 (job record with `cta_type` current; `job_proposal_history` writes per §12), PRD-03 v1.4.1 (campaign lifecycle history rows written; `campaign_steps` row count per active run).  
Excludes: Search (client-side), overflow menu actions.

### Slice B: Card list rendering ([#69](https://github.com/frizman21/smai-server/issues/69))
Implement the card layout for all status types. Render status badge (with exact hex colors from Section 10), job name, job value, customer name, time since last activity, engagement fact (all conditions from Section 9.1), triage text (all variants from Section 9.1), and CTA button. Implement card tap navigation.

Dependencies: Slice A.  
Excludes: Overflow menu, sub-flow modals.

### Slice C: Filter bar and URL persistence ([#70](https://github.com/frizman21/smai-server/issues/70))
Implement the filter bar with all nine options. Implement single-select behavior with teal active highlight. Write filter selection to `?status` query parameter. Read `?status` on mount and apply matching filter. Implement filter reset on location switch.

Dependencies: Slice A.

### Slice D: Search ([#71](https://github.com/frizman21/smai-server/issues/71))
Implement the search input with 200ms debounce. Apply client-side case-insensitive substring match against `job_name` and `customer_name` from the current filtered result set. Implement zero-results empty state (Section 12.3). Implement clear behavior.

Dependencies: Slice B.

### Slice E: Three-dot overflow menu ([#72](https://github.com/frizman21/smai-server/issues/72))
Implement the overflow menu with all four actions. Implement context-sensitive availability (Mark Won / Mark Lost hidden on Won or Lost jobs). Implement confirmation dialogs for Mark Won, Mark Lost, and Delete Job. Implement all backend calls and card update behavior. Implement Flag Issue text input prompt and `job_proposal_history` write with `event_type = job_issue_flagged`.

Dependencies: Slice B. PRD-01 v1.4.1 (state transition endpoints; `job_proposal_history` schema), PRD-03 v1.4.1 §10.4 (campaign stop on delete and on close).

### Slice F: Inline Resume Campaign ([#73](https://github.com/frizman21/smai-server/issues/73))
Implement the Resume Campaign inline action on the list card (same as PRD-04 Slice C). Card updates in place on success. Toast on failure.

Dependencies: Slice B. PRD-03 v1.4.1 §13.2 (Resume logic).

### Slice G: Empty states, location scope, mobile ([#74](https://github.com/frizman21/smai-server/issues/74))
Implement all three empty state variants (Section 12). Implement location scope enforcement and switching behavior. Implement mobile layout (390px). Confirm "+ New Job" button placement on mobile.

Dependencies: Slices A, B, C.

---

## 19. Acceptance Criteria

**AC-01: All jobs appear by default**
Given an account with jobs in In Campaign, Reply Needed, Won, and Lost statuses, when the Jobs list loads with the default filter, then all jobs across all statuses are present in the list.

**AC-02: Sort order — recency under default, CTA priority under filtered views**
Given the All Jobs filter is active (default), when the list renders, then jobs sort by `jobs.created_at` descending — the most recently created job appears first regardless of CTA. Given a status-filtered view (any filter other than All Jobs) with one In Campaign job and one Reply Needed job, when the list renders, then the Reply Needed job appears above the In Campaign job regardless of creation order.

**AC-03: Sort order — recency tiebreaker**
Given two Reply Needed jobs (same `cta_type = open_in_gmail`), one updated 30 minutes ago and one updated 2 days ago, when the list renders under a filtered view, then the job updated 30 minutes ago appears first.

**AC-04: Filter — Reply Needed**
Given the operator selects the "Reply Needed" filter, when the list renders, then only jobs with `status_overlay = customer_waiting` appear. Jobs in all other statuses are absent.

**AC-05: Filter state in URL**
Given the operator selects the "Reply Needed" filter, when the URL is read, then it contains `?status=reply-needed`. When the operator navigates to a Job Detail and returns via back navigation, then the "Reply Needed" filter is still active and the URL still contains `?status=reply-needed`.

**AC-06: Search narrows current filter**
Given the operator has the "Reply Needed" filter active and types "Johnson" in the search field, when results render, then only Reply Needed jobs with "Johnson" in the job name or customer name appear.

**AC-07: Search zero results**
Given the operator searches for a string that matches no jobs in the current filter, when results render, then the search empty state appears (§12.3) with the search term displayed.

**AC-08: Every card has a CTA button**
Given a job with `cta_type = view_job` (In Campaign), when the card renders, then a "View Job" button is present on the card.

**AC-09: Mark Won from overflow**
Given an In Campaign job, when the operator taps the three-dot menu and selects Mark Won and confirms, then `pipeline_stage = won`, the campaign is stopped, a `job_proposal_history` row with `event_type = job_marked_won` is written, the card badge updates to Won, triage text reads "Job closed as Won," and the CTA button reads "View Job."

**AC-10: Mark Won unavailable on Won job**
Given a Won job, when the operator opens the three-dot menu, then Mark Won is not available (hidden or grayed out).

**AC-11: Delete Job stops campaign**
Given an In Campaign job, when the operator deletes it and confirms, then `job_campaigns.status` is set to a terminal status before the job is soft-deleted, a `job_proposal_history` row with `event_type = job_deleted` is written, and the card disappears from the list.

**AC-12: Delete Job is soft delete**
Given a deleted job, when the database is queried directly, then the job record exists with `deleted_at` set (or `is_deleted = true`). It is absent from all frontend queries.

**AC-13: Flag Issue writes history row**
Given any job, when the operator taps Flag Issue, enters optional text, and submits, then a `job_proposal_history` row exists with `event_type = job_issue_flagged`, `changed_by = <operator email>`, and the submitted text in `metadata`.

**AC-14: No `/jobs/new` route**
Given a browser navigating directly to `/jobs/new`, when the request resolves, then the page returns 404 or redirects to `/jobs`. No intake page is served.

**AC-15: Location scope**
Given a multi-location user with access to Location A and Location B, when Location A is active, then only jobs belonging to Location A appear in the list. Jobs from Location B are absent.

**AC-16: Engagement fact — Won job**
Given a job marked Won 3 days ago, when the card renders, then the engagement fact reads "Marked Won 3d ago."

**AC-17: In Campaign triage text with variable send count**
Given an In Campaign job whose active campaign run has M total `campaign_steps` rows and 2 successfully sent outbound `messages`, when the card renders, then the triage text reads "Campaign running — 2 of M follow-ups sent" with the actual numeric value of M substituted (M is variable per template variant per SPEC-11 v2.0).

**AC-18: No Pending Approval filter, badge, or CTA**
Given any job in the system, when the Jobs list loads with any filter, then no card displays a Pending Approval badge, no card shows a "Review & Approve Plan" CTA, no `cta_type = review_plan` value is present in any card data, and the filter bar does not include a Pending Approval option.

---

## 20. Open Questions and Implementation Decisions

**OQ-01: Default filter — All Statuses or All Open Statuses?**
The spec states "All jobs appear" on the Jobs list, suggesting All Statuses as the default. However, for a pilot operator with a mix of open and closed jobs, landing on All Statuses means Won and Lost jobs are in the default view, which adds visual noise. The Lovable FE audit should confirm the actual default filter in the live sandbox. This must be resolved before Slice C is built. Both are valid product choices; it just needs to be locked.

**OQ-02: Delete Job implementation — `deleted_at` timestamp or `is_deleted` boolean?**
Both achieve soft delete. `deleted_at` is more information-rich (preserves when it was deleted). `is_deleted` is simpler to query. This is an engineering-design decision. All frontend queries must add `WHERE deleted_at IS NULL` (or `WHERE is_deleted = false`) to exclude deleted jobs.

**OQ-03: `job_issue_flagged` event_type writeback to PRD-01**
Section 11.4 requires writing a `job_proposal_history` row with `event_type = job_issue_flagged`. This value is present in the canonical `event_type` enum in PRD-01 v1.4.1 §12. No further writeback action required; included here for traceability.

**OQ-04: Legacy `?status=pending-approval` URL handling**
The Pending Approval filter is removed in v1.3 (per PRD-01 v1.4.1). Existing bookmarks, deep links, or browser history entries referencing `?status=pending-approval` may still exist for users who used the application under prior versions. The frontend should treat this URL value as equivalent to `?status=all` on parse: render the All filter, replace the URL parameter via `history.replaceState`, and not show an error or empty state. No backend change required (the Pending Approval filter is no longer a valid backend parameter; if the backend receives it, it should respond as if `status=all` was sent, or return a typed validation error that the frontend swallows and falls back to All). Mark to confirm preferred backend behavior.
