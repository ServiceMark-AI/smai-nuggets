# PRD-07: Analytics
**Version:** 1.2  
**Date:** April 21, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked — April 4, 2026); Analytics redesign sessions (April 2 and April 4, 2026); ANLYT-01 through ANLYT-10 PRD tags (locked April 4–5, 2026); Session State v6.0; SPEC-03 v1.3 (Job Type and Scenario); SPEC-05 (Analytics MTD/YTD Conversion Rate); SPEC-06 (Analytics Branch Comparison); SPEC-11 v2.0 (Campaign Template Architecture); PRD-01 v1.4.1 (Job Record); PRD-02 v1.5 (New Job Intake); PRD-03 v1.4.1 (Campaign Engine); Reconciliation Report 2026-04-16; Save State 2026-04-21 (templated architecture, scenario layer, Pending Approval elimination)  
**Related PRDs and specs:** PRD-01 v1.4.1, PRD-02 v1.5, PRD-03 v1.4.1; SPEC-03 v1.3, SPEC-05, SPEC-06, SPEC-11 v2.0  
**Tracking issues:** [#85 A endpoint + metrics](https://github.com/frizman21/smai-server/issues/85) · [#86 B filter bar](https://github.com/frizman21/smai-server/issues/86) · [#87 C hero tiles](https://github.com/frizman21/smai-server/issues/87) · [#88 D funnel](https://github.com/frizman21/smai-server/issues/88) · [#89 E originator table](https://github.com/frizman21/smai-server/issues/89) · [#90 F follow-up chart](https://github.com/frizman21/smai-server/issues/90) · [#91 G per-location breakdown](https://github.com/frizman21/smai-server/issues/91) · [#92 H empty/mobile/role](https://github.com/frizman21/smai-server/issues/92)  
**Backend status:** No Analytics backend has been built. This is a greenfield backend implementation against this PRD. No reconciliation risk.  
**Revision note (v1.1):** Aligned LOB filter options and terminology to SPEC-03 (seven RESTORATION sub-types; the "Line of Business" label becomes "Job Type" on operator-facing surfaces). Added MTD and YTD conversion rate dual display per SPEC-05. Added per-location conversion rate breakdown payload per SPEC-06 (UI implementation governed by SPEC-06). Added physical table naming clarifier per PRD-01 v1.2. Prose continues to say "jobs" and "messages" for readability.  
**Revision note (v1.2):** Three related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, PRD-01 v1.4, PRD-02 v1.5, PRD-03 v1.4, PRD-06 v1.3, PRD-05 v1.3, and PRD-04 v1.2 drive. Nothing else.

1. **Job Type sub-type taxonomy refresh.** Per SPEC-03 v1.3 (refined 2026-04-21 per Jeff's input), the seven active Restoration sub-types are now Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. Supersedes the prior seven-value list (Water Damage, Fire & Smoke, Mold Remediation, Storm Damage, Biohazard / Sewage, Contents / Pack-Out, Specialty Cleaning). §6.3 filter table options and `lob` query parameter values updated. §2 builder point 11 updated. §4 locked constraint row updated. §13.1 request parameter inline reference updated. AC-18 list updated. The `lob` query parameter name itself is retained for backward compatibility with existing Lovable wiring; values change.

2. **Templated architecture cohort dimension noted as future-deferred.** Per SPEC-11 v2.0, every campaign run carries a `campaigns.template_version_id` referencing the variant that rendered the run. This enables future template-cohort attribution analysis (which template variants convert better, where drop-offs concentrate by variant). No current Analytics zone surfaces template-cohort breakdowns; the field is captured upstream and will be available when this lens is built. New §4 locked constraint row added. New OQ-07 added. §3 "does not cover" updated. Scenario-level filtering similarly deferred and noted in §3 and a new locked-constraint row.

3. **Collapsed intake flow clarification on the analytics window.** Per PRD-01 v1.4 and PRD-02 v1.5, no job record exists in a Pending Approval state; the durable write happens atomically on Approve and Begin Campaign at intake. `campaign_started_at` is set as part of that atomic write. This clarifies (does not change) the §6.1 analytics window semantics: every job in the database has `campaign_started_at` populated. Cancellations at the Campaign Ready surface leave no record (nothing was ever written). The "campaign_started_at IS NOT NULL" filter remains as a defensive guard but is structurally unnecessary under v1.4+. §6.1 note added; §13.3 SQL filter retained.

Material section changes in v1.2: header, §2 (builder point 11 sub-types), §3 (scenario and template-cohort deferrals added), §4 (sub-type constraint updated; two new constraint rows), §6.1 (collapsed-flow clarification note), §6.3 (Job Type filter table values rewritten), §13.1 (param value note), §17 (AC-18 sub-type list updated; new AC-23 for template-cohort and scenario-filtering absence), §18 (new OQ-07 for template cohort).

**Patch note (2026-04-22):** Surgical `period` enum alignment to SPEC-05 dropdown per CONSISTENCY-REVIEW-2026-04-22 M-08/M-09. SPEC-05 dropdown is authoritative. Final enum: `today | last_7d | last_30d | last_90d | month_to_date | year_to_date | custom`. `60d` dropped (not present in SPEC-05). `today`, `last_7d`, and `custom` added. Custom period requires `start_date` and `end_date` query params. Edits: §6.1 dropdown table rebuilt; §6.1 Custom-is-post-MVP sentence struck and replaced with Custom semantics; §10.5 chart bucketing table drops the dead `Last 60 days` row and adds an open-question note for bucketing rules on the three new periods; §13.1 request shape enum updated and `start_date`/`end_date` params added with conditional-required semantics. No version bump per plan. Ref CONSISTENCY-REVIEW-2026-04-22.

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1` and `PRD-03 v1.4` → `PRD-03 v1.4.1` to match the parallel patches. Audit-trail revision-note text preserved byte-exact. No version bump on PRD-07 (sweep is pointer-hygiene only). PRD-07 source-truth contains no out-of-repo Spec orphans, so M2P-08 L-01 annotations are not applicable here. Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01.

**Patch note (2026-04-23, H2P-02 casing):** Period-label casing alignment to SPEC-05 and the §6.1 dropdown table. Five operational-text sites rewritten to Title Case: §2 point 6 (`Last 30 days` → `Last 30 Days`), §6.1 Delta period prose (`Last 90 days` → `Last 90 Days`), AC-12 (`Last 90 days` → `Last 90 Days`), AC-14 (`Last 30 days` → `Last 30 Days`). One bucket-descriptor cleanup at §10.5: `Current month to date` rewritten to `Current month` to remove visual collision with the `Month to Date` period-filter label and to match the `Month -2 / Month -1` shorthand pattern used for the other two buckets in the same sentence. No semantic change; the bucket still represents the in-progress current month within a Last 90 Days view. Audit-trail revision-note text preserved byte-exact (the v1.2 patch note at line 21 retains its `Last 60 days` historical reference). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-02.

**Patch note (2026-04-23, Wave 6D — Mark closures):** Four CONSISTENCY-REVIEW-2026-04-23 findings closed per Mark's answers (transcribed call 2026-04-23). (1) M2P-01: OQ-04 marked RESOLVED — `/api/analytics` confirmed as the as-built endpoint path. (2) M2P-02: OQ-06 marked RESOLVED — operator-local time zone, derived from the browser; backend stores UTC; FE renders local. SPEC-05 carries the parallel resolution. (3) M2P-05 / OQ-08: OQ-08 marked RESOLVED — chart bucketing for all seven periods is a frontend concern in the current build per the broader Analytics architecture decision below; suggested current FE rules documented in the OQ-08 resolution. (4) H2P-05: `messages.status = 'delivered'` dropped from §8.1 stage 2 definition (line 295) and §13.3 SQL `Follow-Ups Sent` query (line 786); `delivered` is no longer in the canonical `messages.status` enum per Mark ("we can't accurately determine if an email was delivered, and the industry has moved away from using this. I say drop it."). Funnel stage 2 label "First Follow-Up Delivered" and JSON response key `first_followup_delivered` retained — these are operator-facing labels referring to the funnel concept, not the enum value. Plus: new §1A "Current Implementation Note" added documenting the Mark architecture decision: backend ships raw query results from jobs / messages tables in the current build; FE handles period filtering, MTD/YTD computation, chart bucketing, and aggregation client-side. Sections that imply backend computation describe the eventual contract; the current build is a thin subset. Migration path documented: reporting tables when raw queries get clunky, then data warehouse with nightly jobs. The §1A note will be retired and the body of the PRD activated as literal backend contract when reporting tables or warehouse are introduced. No version bump on PRD-07 (resolutions and notes; no behavioral change in spec). Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-01, M2P-02, M2P-05, H2P-05; transcribed call with Mark 2026-04-23.

---

## 1. What This Is in Plain English

Analytics is the performance dashboard. It is not a generic activity summary. It answers one question for Jeff and his managers every day: is SMAI making follow-up better, and how is each person on the team performing?

The screen has four zones, rendered top to bottom in this order:

1. **Hero tiles** — five performance metrics at a glance, dominated by Conversion Rate
2. **Conversion funnel** — where jobs are won and lost across five pipeline stages, with dollar-denominated drop-off labels
3. **Originator Performance table** — per-person breakdown of active jobs, pipeline, reply rate, and close rate, ranked by close rate
4. **Follow-Up Activity chart** — a grouped bar chart with an area series showing sends, replies, and closed-won jobs over time

Three filters at the top of the screen — date range, location, job type — scope all four zones simultaneously when selected. The filters are present in the Lovable FE but real data binding is implemented in the Cursor build per the data contract definitions in this PRD.

Analytics is read-only. No operator action is taken from this screen. No CTA leads to a state change. It is an observation surface only.

---

## 1A. Current Implementation Note (Backend Architecture)

**This PRD specifies the eventual Analytics contract. The current build implements a simpler subset.**

Per Mark (transcribed call 2026-04-23), the current backend implementation is intentionally thin: it ships raw query results from the `jobs` and `messages` tables in response to filter-scoped requests. The frontend handles period filtering, MTD / YTD computation, chart bucketing, and metric aggregation client-side.

This is a deliberate scale-appropriate choice for the Servpro pilot and early v1:
- Data volumes are small (tens to hundreds of thousands of jobs over the first year-plus); the database can return raw filtered rows quickly enough that backend aggregation adds no value
- FE-side computation gives the product flexibility to change period definitions, bucket sizes, and chart types without backend changes ("if a customer says 'I want fortnight buckets,' that's a frontend change")
- No reporting tables or data warehouse are warranted at current scale; introducing them now would be premature

**Migration path** (per Mark, same call): when query performance degrades from raw-table scans, introduce simple reporting tables to make queries faster. When that ceases to scale, move to a data warehouse (e.g., BigQuery) with nightly aggregation jobs.

**Implication for this PRD:** Sections that specify backend-computed metrics, bucketing rules, or aggregation contracts (notably §6.1 period values, §7 hero tile metric definitions, §8 funnel stage counts, §10.5 chart bucketing, §13.1-§13.3 API contract) describe the eventual contract. The current build returns the raw rows needed for the FE to compute these; the FE owns the computation. When backend aggregation is introduced (reporting tables or warehouse), the contract specified here governs.

**Implication for OQs:** OQ-04 (endpoint path) and OQ-06 (timezone) resolve as documented in §18. OQ-08 (chart bucketing for `today` / `last_7d` / `custom`) resolves by deferral to FE; the bucketing rules in §10.5 become the eventual backend contract, not a current backend requirement.

This note will be retired and the body of the PRD activated as the literal backend contract when reporting tables or a data warehouse are introduced. Until then, treat sections that imply backend computation as "what the contract becomes when the work moves backend; the FE handles it for now."

Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-05 / OQ-08; transcribed call with Mark 2026-04-23.

---

## 2. What Builders Must Not Misunderstand

1. **Conversion Rate is the dominant hero metric. It must render visually larger than the other four tiles.** The other four tiles are uniform in size and treatment. Conversion Rate has larger type and the definition subtext. No background fill, no color accent — size and type weight carry the hierarchy. The MTD and YTD dual display sits inside this tile per SPEC-05 §7.

2. **"Active Pipeline" is not "Pipeline at Risk."** The tile was explicitly renamed. Do not use alarm language for jobs that are running normally. Neutral color, neutral subtext. Amber appears in exactly one place on this screen: the dollar figure in the funnel drop-off label for unanswered replies.

3. **No red, no green, no coral anywhere on Analytics.** The entire screen uses one color family: teal at varying opacities for active/positive data, muted gray for passive or historical data, and amber in exactly one location. Any deviation from this is wrong.

4. **Every metric on this screen derives from the same base dataset.** There is no independently authored number. If a number cannot be traced to the data definitions in Section 6, it must not appear. This applies to the prototype seed data and to the production implementation equally.

5. **Filters are server-side, not client-side.** When the operator changes the date range, location, or Job Type filter, a new API request is issued. The backend computes all metrics for the new scope. The frontend does not recompute metrics from a cached full dataset.

6. **Delta comparison ("X pts vs prior period") compares the current period to the equivalent prior period.** If the selected range is Last 30 Days, the prior period is the preceding 30 days. The delta is computed server-side and returned alongside the current metric value. For MTD, the prior period is the same MTD window in the prior month. For YTD, the prior period is the same YTD window in the prior year. See SPEC-05.

7. **The chart legend shows period-aggregate totals. The chart tooltip shows the hovered time-bucket value.** These are two different numbers from the same dataset and are both correct. They must not be treated as a discrepancy.

8. **Admin sees all originators in the Originator Performance table. Originator sees only their own row.** This is a role-based visibility rule enforced server-side, not client-side.

9. **Filters do not include an Originator filter.** The originator filter was deliberately removed. Performance comparison happens through the Originator Performance table, not through a top-level filter that destroys the leaderboard view.

10. **Analytics is a read-only screen. No state changes originate from it.** No API write calls are made from this screen. Every endpoint called is a GET or equivalent read-only query.

11. **Job Type values on the filter match SPEC-03 v1.3.** For v1, the active taxonomy is the seven Restoration sub-types per SPEC-03 v1.3 §7.1: Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. The filter label on the operator-facing surface is "Job Type" (matching SPEC-03 §8), not "Line of Business." Internal prose in this PRD uses both interchangeably for readability during the transition.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- The screen route, layout, and section order
- The filter bar: all three filters, their options, and their data contract behavior
- Zone 1: all five hero tiles — metric definitions, display format, delta calculation, color rules
- Zone 2: the conversion funnel — all five stages, bar rendering, drop-off label logic, right-side summary, color rules
- Zone 3: the Originator Performance table — columns, data definitions, sort order, bar rendering, role-scoped visibility
- Zone 4: the Follow-Up Activity chart — series definitions, chart architecture, legend, tooltip, the "SMAI activated" reference line
- The complete backend API contract: all query parameters, all response fields, all metric computation definitions
- MTD and YTD conversion rate data payload (UI implementation per SPEC-05)
- Per-location conversion rate breakdown payload (UI implementation per SPEC-06)
- Role-based visibility rules
- Empty state behavior
- Color system for Analytics

**This PRD does not cover:**
- Needs Attention, Jobs List, Job Detail, or any other screen
- The admin portal (separate codebase; see PRD-10)
- Campaign template analytics or per-template-variant cohort reporting (deferred — `template_version_id` cohort dimension is captured upstream per SPEC-11 v2.0 §11.3 and PRD-03 v1.4.1 §6.4 but no current zone surfaces it; see OQ-07)
- Scenario-level filtering on the Job Type filter or as a standalone filter dimension (deferred — `scenario_key` is captured per SPEC-03 v1.3 and PRD-01 v1.4.1 §8.1 but no current zone surfaces it)
- CSV export or data download (post-MVP, Spec 16 explicitly excludes this)
- External SIEM or analytics integrations (post-MVP)
- The specific UI rendering of MTD/YTD dual display (SPEC-05 governs)
- The specific UI rendering of the per-location Conversion Rate breakdown (SPEC-06 governs)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| Conversion Rate is the dominant hero metric — larger type, definition subtext. | April 4 audit, ANLYT-01 |
| No red, green, or coral anywhere on Analytics. One teal family. Amber appears once only. | April 4 color system decision |
| "Active Pipeline" — not "Pipeline at Risk." Neutral color. | April 4 decision, ANLYT-03 |
| Amber appears exactly once: the dollar figure in the funnel label for unanswered replies. | April 4 decision |
| Funnel drop-off labels are factual, muted gray. Amber only on the operator-actionable figure. | April 4 decision, ANLYT-06 |
| Originator table: location on secondary line under name. Not a separate column. | April 4 audit |
| Admin sees all originators. Originator sees only their own row. | ANLYT-07 |
| Chart legend: period-aggregate totals. Chart tooltip: time-bucket values. Both correct simultaneously. | April 4 PRD tag |
| Filters are server-side. New API request on every filter change. | April 4 decision |
| Delta comparison uses equivalent prior period. | April 4 decision |
| Originator filter removed from filter bar. Table handles comparison. | April 4 decision, April 2 session |
| No Campaigns nav item in operator UI. Analytics is at /analytics. | Session State v6.0 |
| Analytics is read-only. No write API calls. | Product doctrine |
| Job Type values: seven Restoration sub-types per SPEC-03 v1.3 §7.1 — Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. Operator-facing filter label is "Job Type" not "Line of Business." Reconstruction and other deferred sub-types do not appear in the filter. | SPEC-03 v1.3 |
| Scenario-level filtering on the Job Type filter or as a standalone filter dimension is deferred. `scenario_key` is captured upstream per SPEC-03 v1.3 and PRD-01 v1.4.1 §8.1 but no current Analytics zone surfaces or filters by it. | SPEC-03 v1.3; Save State 2026-04-21 |
| Template cohort attribution (per template variant analysis) is deferred. `campaigns.template_version_id` is captured upstream per SPEC-11 v2.0 §11.3 and PRD-03 v1.4.1 §6.4 but no current Analytics zone surfaces a template-cohort breakdown. See OQ-07 for the future-build framing. | SPEC-11 v2.0; Save State 2026-04-21 |
| Conversion Rate tile includes MTD and YTD dual display. MTD and YTD filter period options available. | SPEC-05 |
| Per-location Conversion Rate breakdown (Admin, "All Locations" only) payload included in analytics response. UI rendering governed by SPEC-06. | SPEC-06 |
| `campaign_started_at` is set as part of the atomic Approve and Begin Campaign write at intake (PRD-02 v1.5 §8.4 / PRD-03 v1.4.1 §6.4). Every job in the database has `campaign_started_at` populated. Cancellations at the Campaign Ready surface leave no record. The `campaign_started_at IS NOT NULL` filter in §13.3 is defensive but structurally unnecessary under v1.4+. | PRD-01 v1.4.1; PRD-02 v1.5; PRD-03 v1.4.1 |
| Physical table names: `job_proposals` (jobs), `campaigns` (job_campaigns), `job_proposal_history`. Prose in this PRD continues to say "jobs" for readability. Analytics SQL references physical names. | PRD-01 v1.4.1 §12, DL-026, DL-027 |

---

## 5. Screen Route and Layout

**Route:** `/analytics` (single-location) or `/:locationId/analytics` (multi-location).

**Section order (top to bottom):**
1. Filter bar
2. Zone 1: Hero tiles (five metrics)
3. Zone 2: Conversion funnel
4. Zone 3: Originator Performance table
5. Zone 4: Follow-Up Activity chart

This order is locked. Zone 3 (Originator) appears above Zone 4 (chart). This was a deliberate decision made April 2 to prioritize the management view.

**Navigation:** Analytics appears as the fourth item in the sidebar (desktop) and fourth tab in the mobile bottom nav (390px). It is highlighted when the current route is `/analytics` or `/:locationId/analytics`.

---

## 6. Filter Bar

Three filter controls render as pill-shaped buttons in a horizontal row at the top of the Analytics screen. All three pills have identical visual treatment when no filter is being actively edited — same border, same background. No pill gets a teal border or color accent unless it is actively being edited.

Selecting any filter sends a new request to the backend with the updated filter parameters. All four zones recompute and rerender from the new API response.

### 6.1 Date range filter

| Option | `period` param | Window |
|---|---|---|
| Today | `today` | Start of current calendar day through end of current calendar day (per SPEC-05) |
| Last 7 Days | `last_7d` | 7 calendar days before today, inclusive (per SPEC-05) |
| Last 30 Days | `last_30d` | 30 calendar days before today, inclusive (per SPEC-05) |
| Last 90 Days (default) | `last_90d` | 90 calendar days before today, inclusive (per SPEC-05) |
| Month to Date | `month_to_date` | First of current calendar month through today (per SPEC-05) |
| Year to Date | `year_to_date` | January 1 of current calendar year through today (per SPEC-05) |
| Custom | `custom` | Operator-selected start and end dates (per SPEC-05). Requires `start_date` and `end_date` query parameters. |

Default is Last 90 Days. SPEC-05 §4 dropdown layout is authoritative for the operator-facing dropdown ordering, dividers, and labels.

**Window definition:** A job enters the analytics window based on `jobs.campaign_started_at` — the timestamp when the job was activated and the first campaign step was scheduled. Jobs where `campaign_started_at` falls within the selected window are included. Jobs where `campaign_started_at` is null are excluded from all metrics.

Note: Under PRD-02 v1.5 collapsed intake flow and PRD-01 v1.4.1, `campaign_started_at` is set as part of the atomic Approve and Begin Campaign write at intake. Every job in the database has `campaign_started_at` populated. Cancellations at the Campaign Ready surface leave no record (nothing was ever written). The `campaign_started_at IS NOT NULL` filter remains as a defensive guard but is structurally unnecessary under v1.4+ — the database does not contain non-approved jobs.

**Delta period:** The prior period is the equivalent-length window immediately preceding the selected window. For Last 90 Days, the prior period is the 90 days before the current window. For MTD, the prior period is the same MTD window in the prior month (e.g., April 1–8 vs. March 1–8). For YTD, the prior period is the same YTD window in the prior year. All deltas are computed against this prior period.

### 6.2 Location filter

| Option | `location_id` param | Scope |
|---|---|---|
| All Locations (default for multi-location Admin) | `all` | All locations the user has access to |
| {Location name} | Location UUID | Single location |

Single-location users see no location filter — the pill is hidden and all data is scoped to their one location automatically.

Multi-location users see "All Locations" as the default. Selecting a specific location scopes all metrics, funnel, originator table, and chart to that location only.

### 6.3 Job Type filter

Filter label on the operator-facing surface: "Job Type" (per SPEC-03 v1.3 §8). The `lob` query parameter name is retained for backward compatibility with existing Lovable wiring; values change per the v1.3 taxonomy refresh.

| Option | `lob` param | Scope |
|---|---|---|
| All Job Types (default) | `all` | All job types |
| Contents | `contents` | `jobs.job_type = 'contents'` |
| Environmental / Asbestos | `environmental_asbestos` | `jobs.job_type = 'environmental_asbestos'` |
| General Cleaning | `general_cleaning` | `jobs.job_type = 'general_cleaning'` |
| Mold Remediation | `mold_remediation` | `jobs.job_type = 'mold_remediation'` |
| Structural Cleaning | `structural_cleaning` | `jobs.job_type = 'structural_cleaning'` |
| Temporary Repairs | `temporary_repairs` | `jobs.job_type = 'temporary_repairs'` |
| Water Mitigation | `water_mitigation` | `jobs.job_type = 'water_mitigation'` |

Default is All Job Types. The available options are the seven Restoration sub-types per SPEC-03 v1.3 §7.1. Reconstruction and other deferred sub-types are not activated for any v1 tenant and must not appear in the filter.

The available Job Type options shown in the dropdown are further narrowed to types with at least one activated job in the account's data — do not show options for types with zero jobs in scope.

Note: Prior versions of this PRD enumerated the v1.3 taxonomy's predecessor list (Water Damage, Fire & Smoke, Mold Remediation, Storm Damage, Biohazard / Sewage, Contents / Pack-Out, Specialty Cleaning) with `lob` values like `water_damage`, `fire_smoke`, `storm_damage`, etc. Replaced in v1.2 per SPEC-03 v1.3 (refined 2026-04-21 per Jeff's input). Backend and Lovable wiring must be updated to the new values before the filter goes live.

Scenario-level filtering (further narrowing within a Job Type) is deferred. `scenario_key` is captured upstream per SPEC-03 v1.3 but no current Analytics zone exposes it.

---

## 7. Zone 1: Hero Tiles

Five metric tiles rendered in a horizontal row. All five tiles are identical in card treatment (same border, same background, same padding) with one exception: Conversion Rate uses larger type to signal primacy. No background fill on any tile. No color accent on any tile except the delta line, which uses teal for positive movement.

### 7.1 Tile layout (all five)

Each tile contains:
- **Metric label** — all-caps, small, muted gray. E.g., "CONVERSION RATE."
- **Metric value** — the primary number, large type.
- **Delta line** — "X pts vs prior period" or "X% vs prior period" or "+X vs prior period." Teal if positive movement (e.g., rate went up, revenue went up). Muted gray if flat. No color if data is insufficient for a delta.
- **Definition subtext** — one short phrase defining what the metric measures. Muted gray, smaller type.

Conversion Rate tile additionally renders slightly larger type for the value to signal visual dominance, and includes the MTD/YTD dual display below the primary value and delta per SPEC-05. The per-location expansion toggle governed by SPEC-06 also lives inside this tile.

### 7.2 Metric definitions

**Tile 1: Conversion Rate**

| Property | Specification |
|---|---|
| Label | CONVERSION RATE |
| Value | `ROUND((won_jobs / activated_jobs) * 100)` displayed as an integer percentage. E.g., "34%" |
| Definition subtext | "Won jobs as a % of activated proposals" |
| Delta | Change in percentage points vs prior period. Display as "X pts vs prior period." |
| Numerator | `COUNT(DISTINCT jobs.id) WHERE pipeline_stage = 'won' AND campaign_started_at IN window AND location IN scope AND job_type IN lob_scope` |
| Denominator | `COUNT(DISTINCT jobs.id) WHERE campaign_started_at IS NOT NULL AND campaign_started_at IN window AND location IN scope AND job_type IN lob_scope` |
| MTD/YTD dual display | Below the primary value and delta, the tile renders two secondary figures: MTD and YTD conversion rates, each independently calculated per SPEC-05 §6. Both render regardless of which date range filter is active. When a denominator is zero, display "—" for that figure. Rendering governed by SPEC-05 §7. |
| Per-location breakdown | When the location filter is set to "All Locations" AND the requesting user is Admin, a collapsible per-location breakdown is available inside this tile. Payload delivered via the `conversion_rate_by_location` array in the response. UI rendering governed by SPEC-06. |
| Edge case | If denominator is 0, display "--" not 0% |

**Tile 2: Closed Revenue**

| Property | Specification |
|---|---|
| Label | CLOSED REVENUE |
| Value | Sum of `jobs.job_value_estimate` for won jobs in scope. Formatted as currency. E.g., "$387,400" |
| Definition subtext | "Proposal value of won jobs" |
| Delta | Change in dollar amount vs prior period. Display as "+$X vs prior period" or "-$X vs prior period." |
| Query | `SUM(job_value_estimate) WHERE pipeline_stage = 'won' AND campaign_started_at IN window AND location IN scope AND job_type IN lob_scope AND job_value_estimate IS NOT NULL` |
| Edge case | If sum is 0, display "$0." If no won jobs, display "$0" not "--." |

**Tile 3: Active Pipeline**

| Property | Specification |
|---|---|
| Label | ACTIVE PIPELINE |
| Value | Sum of `jobs.job_value_estimate` for jobs currently In Campaign. Formatted as currency. E.g., "$614,800" |
| Definition subtext | "Jobs currently in campaign" |
| Delta | Change in dollar amount vs prior period. Muted gray always — this metric does not use teal/positive coloring because the direction of change carries no evaluative meaning for the operator. |
| Query | `SUM(job_value_estimate) WHERE pipeline_stage = 'in_campaign' AND campaign_started_at IN window AND location IN scope AND job_type IN lob_scope AND job_value_estimate IS NOT NULL` |
| Color rule | Neutral color for value and delta. No amber. No teal accent. |
| Edge case | If no active jobs, display "$0." |

**Tile 4: Avg Time to First Reply**

| Property | Specification |
|---|---|
| Label | AVG TIME TO FIRST REPLY |
| Value | Mean hours from `jobs.campaign_started_at` to first inbound `messages.created_at` for that job, scoped to Won jobs only. Displayed as "X.X hrs." E.g., "6.2 hrs." |
| Definition subtext | "Hours from send to first customer reply, won jobs" |
| Delta | Change in hours vs prior period. Lower is better — teal if hours decreased, muted gray if increased. |
| Query | `AVG(EXTRACT(EPOCH FROM (first_reply_at - campaign_started_at)) / 3600) WHERE pipeline_stage = 'won' AND campaign_started_at IN window AND location IN scope` where `first_reply_at` = `MIN(messages.created_at WHERE direction = 'inbound' AND job_id = jobs.id)` |
| Scope | Won jobs only. Jobs without a customer reply are excluded from this average even if Won (edge case: operator marks Won without customer replying). |
| Edge case | If fewer than 3 won jobs with replies in scope, display "--" to avoid misleading averages on sparse data. |

**Tile 5: Follow-Ups Sent**

| Property | Specification |
|---|---|
| Label | FOLLOW-UPS SENT |
| Value | Count of outbound emails sent by SMAI in the period. Integer. E.g., "186" |
| Definition subtext | "Automated emails sent in period" |
| Delta | Change in count vs prior period. Teal if increased. Muted gray if decreased (fewer sends may indicate fewer activations, not an improvement). |
| Query | `COUNT(messages.id) WHERE direction = 'outbound' AND channel = 'email' AND job_id IN (SELECT id FROM jobs WHERE campaign_started_at IN window AND location IN scope AND job_type IN lob_scope)` |
| Edge case | If 0, display "0." |

---

## 8. Zone 2: Conversion Funnel

**Section title:** "Where Jobs Are Won and Lost" — rendered above the funnel as a section header.

The funnel shows five pipeline stages as horizontal bars on a single card. Each bar represents the count of jobs that reached that stage. Bars narrow as the funnel progresses downward. The bar widths are proportional to the count at each stage relative to the top stage (Proposals Activated = 100% width).

### 8.1 Five funnel stages

| Stage | Label | Job count definition |
|---|---|---|
| 1 | Proposals Activated | All jobs with `campaign_started_at IN window AND location IN scope AND job_type IN lob_scope` |
| 2 | First Follow-Up Delivered | Jobs where at least one outbound message was successfully sent (`messages.status = 'sent'`) for this job's active campaign run |
| 3 | Customer Replied | Jobs with at least one inbound message (`messages.direction = 'inbound'`) within the window |
| 4 | Operator Responded | Jobs where at least one outbound message was sent after the first inbound message (operator replied to a customer reply) |
| 5 | Closed Won | Jobs where `pipeline_stage = 'won'` |

**Stage 2 note:** In practice, Proposals Activated and First Follow-Up Delivered have identical job counts because SMAI always sends Email 1 at T+0 on activation, with no delay. The bar for Stage 2 still renders at 97% width of Stage 1 to make the progression visible. The right-side metadata for Stage 2 displays "N jobs · 100%" not a dollar figure (which would be identical to Stage 1 and confusing).

### 8.2 Bar rendering

Each bar is teal at full opacity. All five bars use the same teal color — no color differentiation between stages. The Closed Won bar renders on a very light teal background fill (`teal/8` or equivalent) that spans the full row width. This gives the final stage presence and distinction without introducing a second color.

Bar widths: proportional to job count. Stage 1 = 100% width. Each subsequent stage = (stage_count / stage_1_count) * 100%.

### 8.3 Right-side metadata per row

Each funnel row shows metadata to the right of the bar:

| Stage | Right-side metadata |
|---|---|
| Proposals Activated | `{N} jobs · ${total_pipeline_value}` |
| First Follow-Up Delivered | `{N} jobs · 100%` |
| Customer Replied | `{N} jobs · ${sum of job_value_estimate for replied jobs}` |
| Operator Responded | `{N} jobs · ${sum of job_value_estimate for responded jobs}` |
| Closed Won | Teal/10 background pill or inset card: `{N} of {Stage 1 count} closed · {conversion_rate}% conversion · {active_count} still in campaign · {lost_count} closed lost` |

Dollar values in metadata are neutral muted-foreground color. The Closed Won row uses the teal/10 background on the right-side summary card as a subtle visual anchor.

### 8.4 Drop-off labels

Drop-off labels appear between funnel stages where a notable drop is detectable. They appear as small lines between the rows.

**Between Stage 3 (Customer Replied) and Stage 4 (Operator Responded):**

This is the only drop-off that receives amber treatment. When `(Stage 3 count - Stage 4 count) >= 1`, render:

`"{N} replies never got a response — ${unanswered_reply_pipeline_value} at risk"`

- "N replies never got a response — " renders in `text-muted-foreground` (gray).
- `${unanswered_reply_pipeline_value} at risk` renders in `text-amber-600`.

`unanswered_reply_pipeline_value` = `SUM(job_value_estimate) WHERE job_id IN (jobs with inbound messages but no subsequent outbound messages by operator, within scope)`

When `Stage 3 count - Stage 4 count = 0`, this label is not rendered.

**Between Stage 1 and Stage 5 (aggregate drop):**

No inline drop-off label between other stages. The right-side summary on the Closed Won row ("40 still in campaign · 13 closed lost") communicates the aggregate disposition.

**Between any other consecutive stages:**

No drop-off labels between Stages 1–2, 2–3, or 4–5. Factual counts in the bars and metadata are sufficient.

### 8.5 Color rules for funnel (absolute)

- All bars: teal. No exceptions.
- Right-side metadata text: muted gray. No exceptions.
- Closed Won row background: teal/8. No other row gets a background.
- Amber: appears only on the dollar figure in the unanswered-reply drop-off label. Nowhere else in the funnel.
- No red. No green. No coral.

---

## 9. Zone 3: Originator Performance Table

**Section title:** "Originator Performance" — rendered above the table.

### 9.1 Table columns

| Column | Header | Content |
|---|---|---|
| 1 | Originator | Avatar initials (2-letter, teal background) + Full name + Location on secondary line |
| 2 | Active Jobs | Count of jobs with `pipeline_stage = 'in_campaign'` attributed to this originator within scope |
| 3 | Pipeline | Sum of `job_value_estimate` for Active Jobs for this originator. Currency formatted. |
| 4 | Reply Rate | `(jobs with at least one inbound reply / jobs activated) * 100` for this originator within scope. Integer %. |
| 5 | Close Rate | `(jobs marked Won / jobs activated) * 100` for this originator within scope. Integer %. Shown as both a percentage label and a proportional teal bar. |

### 9.2 Sort order

Rows are ranked by Close Rate descending. Highest close rate at the top. Ties broken by Pipeline value descending.

### 9.3 Close Rate bar rendering

The Close Rate column shows both a percentage text value and a proportional horizontal bar:

- The originator with the highest close rate gets a bar at full opacity (`opacity-1.0`).
- Every other originator's bar opacity is proportional to their close rate relative to the top originator: `opacity = MAX(0.6, (originator_close_rate / max_close_rate))`.
- Minimum bar opacity floor: 0.6. No bar should render below 0.6 opacity — it becomes unreadable.
- All bars are teal. No performance-rank color coding (no green for top, no red for bottom). Position in the ranked list communicates performance. Color does not.

### 9.4 Location secondary line

Under each Originator name, a secondary line renders the originator's primary location name (e.g., "DFW" or "Servpro Northeast Dallas"). This line always renders, even when the location filter is scoped to a single location.

### 9.5 Role-scoped visibility

- **Admin** sees all originators who have at least one activated job within the selected scope (period, location, job type).
- **Originator** sees only their own row. No other originator's data is returned by the API.

This visibility rule is enforced server-side. The API returns only the rows the requesting user is permitted to see. The frontend renders whatever the API returns — it does not filter client-side.

### 9.6 Empty state

If an originator has zero activated jobs in the selected scope, they do not appear in the table. If no originators have jobs in scope, the table section renders: "No originator data for this period and filter selection."

### 9.7 Data definitions

All originator metrics are scoped to jobs where `jobs.created_by_user_id = originator.user_id` AND `campaign_started_at IN window` AND `location IN scope` AND `job_type IN lob_scope`.

| Metric | Formula |
|---|---|
| Active Jobs | `COUNT(id) WHERE pipeline_stage = 'in_campaign'` for this originator within scope |
| Pipeline | `SUM(job_value_estimate) WHERE pipeline_stage = 'in_campaign'` for this originator within scope |
| Reply Rate | `COUNT(jobs with ≥1 inbound message) / COUNT(all activated jobs)` for this originator |
| Close Rate | `COUNT(jobs WHERE pipeline_stage = 'won') / COUNT(all activated jobs)` for this originator |

---

## 10. Zone 4: Follow-Up Activity Chart

**Section title:** "Follow-Up Activity" — rendered as card title.

### 10.1 Chart type

A Recharts `ComposedChart` combining:
- An area series (background) for Follow-Ups Sent
- Two grouped bar series (foreground) for Replies Received and Jobs Closed Won

Single X-axis (time). Dual Y-axis: left for Follow-Ups Sent (higher scale), right for Replies and Won bars (lower scale).

### 10.2 Three stat blocks

Three large numbers appear above the chart within the card, in a horizontal row, before the chart area:

| Block | Label | Value |
|---|---|---|
| 1 | Follow-Ups Sent | Period-aggregate count of all outbound emails in scope |
| 2 | Replies Received | Period-aggregate count of jobs with at least one inbound reply in scope |
| 3 | Jobs Closed Won | Period-aggregate count of won jobs in scope |

These stat blocks are read from the same data as the rest of the screen. They show the full-period totals for the selected filter scope.

### 10.3 Legend

Horizontal row of three items, left-aligned, above the chart plot area:

- Full-opacity teal dot · "Follow-Ups Sent ({period_total})"
- Teal at 70% opacity dot · "Replies Received ({period_total})"
- Teal at 40% opacity dot · "Jobs Closed Won ({period_total})"

Legend shows **period-aggregate totals** — the same values as the three stat blocks above. Font: `text-sm text-muted-foreground`. Gap: `gap-6`.

### 10.4 Chart series

**Follow-Ups Sent (area series)**
- Renders behind bars.
- Line: full-opacity teal, 2px stroke.
- Area fill: teal at 10% opacity.
- Left Y-axis. Scale: 0 to (max_monthly_sends * 1.2), rounded to nearest 10.
- Connects each time bucket as a smooth curve.

**Replies Received (bar series)**
- Renders in front of area fill.
- Bar color: teal at 70% opacity.
- Right Y-axis. Scale: 0 to (max_monthly_replies * 1.5), rounded to nearest 5.
- Left bar in each time-bucket group.
- Bar width: approximately 24px. Corner radius: 3px top corners only.

**Jobs Closed Won (bar series)**
- Renders in front of area fill, beside Replies Received.
- Bar color: teal at 40% opacity.
- Right Y-axis (same as Replies).
- Right bar in each time-bucket group.
- Bar width: approximately 24px. Corner radius: 3px top corners only.

Gap between bar pairs: 4px. Gap between time-bucket groups: 32px.

### 10.5 Time bucketing

| Date range | Time bucket | X-axis labels |
|---|---|---|
| Last 30 Days | Weekly | Week labels (e.g., "Mar 9", "Mar 16") |
| Last 90 Days | Monthly | Month abbreviations (e.g., "Jan", "Feb", "Mar") |
| Month to Date | Daily | Day labels (e.g., "Apr 1", "Apr 2") |
| Year to Date | Monthly | Month abbreviations |

For Last 90 Days: three buckets (Month -2, Month -1, Current month).

Note: bucketing rules for `today`, `last_7d`, and `custom` are not yet defined and are tracked under OQ-08 (added in the 2026-04-22 patch). These three period values are accepted by the API per §13.1 but the chart bucketing strategy for each is open. Frontend must either gracefully handle unknown bucketing (e.g., daily for `today` and `last_7d`, with `custom` deferred until the OQ resolves) or return a defined behavior. Resolve with Mark before Slice that touches the chart.

### 10.6 Tooltip

On hover over any time-bucket group, show all three values:

```
{Month / Week label}
Follow-Ups Sent: {bucket_value}
Replies Received: {bucket_value}
Jobs Closed Won: {bucket_value}
```

Dark background tooltip, same treatment as tooltips elsewhere in the product.

**Tooltip values show the time-bucket count**, not the period aggregate. This is correct and expected — the legend shows period totals, the tooltip shows bucket-level detail. Both are valid and must not be treated as a discrepancy.

### 10.7 "SMAI activated" reference line

A dashed vertical line positioned at the first time bucket (leftmost data point). It represents when SMAI was activated for this account.

- Style: 1px dashed line, `border-border` color.
- Z-index: above area fill, below bars and area line.
- Label: "SMAI activated" — positioned immediately to the right of the dashed line, top of the chart area.
- Label style: `text-xs text-muted-foreground`. It annotates the line. It is not a floating title.
- The label must render fully and not be clipped by the card boundary.

In production, the reference line is positioned at the account's first `campaign_started_at` date, bucketed to the nearest time bucket boundary.

### 10.8 Gridlines

Horizontal gridlines at 25%, 50%, 75% of the left Y-axis scale. Style: 1px, `border-border` at 25% opacity. Render behind all data elements.

### 10.9 Chart dimensions

Card: `bg-card`, `rounded-xl`, `shadow-sm`. Padding: `px-6 py-5`. Chart height: 280px. Bottom padding inside the chart area: minimum `pb-6` to prevent bars from running to the card edge.

---

## 11. Color System for Analytics (Absolute Rules)

These rules apply to every pixel of the Analytics screen. No exceptions.

| Color | Usage |
|---|---|
| Teal (full opacity) | Primary bars, area line, avatar backgrounds, Conversion Rate delta, positive deltas |
| Teal 70% | Replies Received bars, legend dot for Replies |
| Teal 40% | Jobs Closed Won bars, legend dot for Won |
| Teal 10% | Area fill for Follow-Ups Sent series |
| Teal 8% | Closed Won funnel row background |
| Muted gray (`text-muted-foreground`) | All labels, subtexts, metadata, passive drop-off labels, chart axis labels, legend text, delta when flat |
| Amber (`text-amber-600`) | Dollar figure in unanswered-reply drop-off label only. Appears once on the entire screen. |
| **Green** | **Never. Removed entirely.** |
| **Red** | **Never. Removed entirely.** |
| **Coral** | **Never. Removed entirely.** |

No performance ranking, no outcome coloring, no alarm coloring. One teal family tells the story. Amber marks exactly one operator-actionable fact.

---

## 12. Role-Based Visibility

| Element | Admin | Originator |
|---|---|---|
| Hero tiles | Full account scope (filtered by location/job type selection) | Scoped to their own jobs only |
| Funnel | Full account scope | Scoped to their own jobs only |
| Originator table | All originators visible | Only their own row visible |
| Chart | Full account scope | Scoped to their own jobs only |
| Per-location Conversion Rate breakdown (SPEC-06) | Available when "All Locations" is selected | Not available |

For Originator-scoped views, the hero tiles, funnel, and chart all reflect only the jobs where `jobs.created_by_user_id = requesting_user.id`. The API enforces this — it does not return cross-originator data to an Originator user regardless of what the frontend requests.

---

## 13. Backend API Contract

Analytics uses a single backend endpoint that computes all metrics for a given filter scope and returns them in one response. No waterfall fetches. No separate requests per zone.

### 13.1 Request parameters

```
GET /api/analytics
  ?account_id={uuid}                                                                # from auth context
  &period={today|last_7d|last_30d|last_90d|month_to_date|year_to_date|custom}       # date range filter
  &start_date={ISO_DATE}                                                            # required if period=custom
  &end_date={ISO_DATE}                                                              # required if period=custom
  &location_id={uuid|all}                                                           # location filter
  &lob={job_type|all}                                                               # job type filter (param name retained for compat)
```

The `period`, `location_id`, and `lob` parameters are required. If omitted, the backend returns a 400 error. When `period=custom`, both `start_date` and `end_date` are also required and the backend returns 400 if either is missing or malformed. SPEC-05 dropdown is authoritative for the operator-facing labels and ordering. See OQ-04 for the endpoint path confirmation with Mark.

### 13.2 Response structure

```json
{
  "period": {
    "start": "ISO_DATE",
    "end": "ISO_DATE",
    "prior_start": "ISO_DATE",
    "prior_end": "ISO_DATE"
  },
  "hero": {
    "conversion_rate": {
      "value": 34,
      "delta_pts": 8,
      "delta_direction": "up",
      "mtd": 29,
      "ytd": 31,
      "mtd_denominator": 12,
      "ytd_denominator": 78
    },
    "closed_revenue": {
      "value": 387400,
      "delta_value": 42000,
      "delta_direction": "up"
    },
    "active_pipeline": {
      "value": 614800,
      "delta_value": -18000,
      "delta_direction": "down"
    },
    "avg_time_to_first_reply_hours": {
      "value": 6.2,
      "delta_hours": -0.4,
      "delta_direction": "down"
    },
    "follow_ups_sent": {
      "value": 186,
      "delta_count": 22,
      "delta_direction": "up"
    }
  },
  "conversion_rate_by_location": [
    {
      "location_id": "uuid",
      "location_name": "Northeast Dallas",
      "activated_jobs": 42,
      "won_jobs": 18,
      "conversion_rate_pct": 43
    }
    // ... one row per active location; returned only when location_id=all AND user is Admin; empty array otherwise
  ],
  "funnel": {
    "proposals_activated": {
      "count": 80,
      "pipeline_value": 1428700
    },
    "first_followup_delivered": {
      "count": 80,
      "delivery_rate_pct": 100
    },
    "customer_replied": {
      "count": 51,
      "pipeline_value": 892400
    },
    "operator_responded": {
      "count": 47,
      "pipeline_value": 834800
    },
    "closed_won": {
      "count": 27,
      "total_activated": 80,
      "conversion_rate_pct": 34,
      "still_in_campaign": 40,
      "closed_lost": 13
    },
    "unanswered_reply_count": 4,
    "unanswered_reply_pipeline_value": 57600
  },
  "originators": [
    {
      "user_id": "uuid",
      "name": "Alex Martinez",
      "initials": "AM",
      "location_name": "DFW",
      "active_jobs": 11,
      "pipeline_value": 312400,
      "reply_rate_pct": 71,
      "close_rate_pct": 42
    }
    // ... additional originators, sorted by close_rate_pct desc
  ],
  "chart": {
    "period_totals": {
      "follow_ups_sent": 186,
      "replies_received": 51,
      "jobs_closed_won": 27
    },
    "time_buckets": [
      {
        "label": "Jan",
        "start": "ISO_DATE",
        "end": "ISO_DATE",
        "follow_ups_sent": 58,
        "replies_received": 15,
        "jobs_closed_won": 8
      },
      {
        "label": "Feb",
        "start": "ISO_DATE",
        "end": "ISO_DATE",
        "follow_ups_sent": 82,
        "replies_received": 24,
        "jobs_closed_won": 11
      },
      {
        "label": "Mar",
        "start": "ISO_DATE",
        "end": "ISO_DATE",
        "follow_ups_sent": 46,
        "replies_received": 12,
        "jobs_closed_won": 8
      }
    ],
    "smai_activated_at": "ISO_DATE"
  }
}
```

Notes on the response additions:

- **`hero.conversion_rate.mtd`** and **`hero.conversion_rate.ytd`** are the MTD and YTD conversion rates as integer percentages, computed independently of the active `period` filter per SPEC-05 §6. Both respect the active location and Job Type filters. Return `null` when the respective denominator is zero.
- **`hero.conversion_rate.mtd_denominator`** and **`ytd_denominator`** support the frontend "—" display rule (SPEC-05 §7): when a denominator is zero, the frontend renders "—" rather than 0%.
- **`conversion_rate_by_location`** is returned only when `location_id = all` AND the requesting user is Admin. Empty array otherwise. UI rendering and expand/collapse behavior governed by SPEC-06.

### 13.3 Metric computation definitions (authoritative)

All queries are scoped to the period window and filter parameters. `window` means `campaign_started_at >= period.start AND campaign_started_at <= period.end`. `location_scope` means `location_id = filter.location_id` or `location_id IN user_permitted_locations` when filter is `all`. `lob_scope` means `job_type = filter.lob` or no `job_type` filter when filter is `all`.

**Activated jobs base set:**
```sql
SELECT id, job_value_estimate, pipeline_stage, created_by_user_id, won_at, campaign_started_at
FROM jobs
WHERE campaign_started_at IS NOT NULL
  AND campaign_started_at BETWEEN :period_start AND :period_end
  AND location_id IN (:location_scope)
  AND job_type IN (:lob_scope)
  AND (deleted_at IS NULL OR is_deleted = false)
```

**Conversion Rate:**
```sql
COUNT(id) FILTER (WHERE pipeline_stage = 'won') * 100.0
/ NULLIF(COUNT(id), 0)
FROM activated_jobs
```

**Conversion Rate MTD (SPEC-05):**
Same formula as Conversion Rate, with the window bounded to `campaign_started_at >= first_day_of_current_month AND campaign_started_at <= today`. Ignores the active `period` filter. Respects `location_scope` and `lob_scope`. Returns null if denominator is zero.

**Conversion Rate YTD (SPEC-05):**
Same formula as Conversion Rate, with the window bounded to `campaign_started_at >= january_1_of_current_year AND campaign_started_at <= today`. Ignores the active `period` filter. Respects `location_scope` and `lob_scope`. Returns null if denominator is zero.

**Conversion Rate by location (SPEC-06):**
For each `location_id` in the user's permitted locations where at least one activated job exists in the current window:
```sql
SELECT location_id,
       COUNT(id) AS activated_jobs,
       COUNT(id) FILTER (WHERE pipeline_stage = 'won') AS won_jobs,
       ROUND(COUNT(id) FILTER (WHERE pipeline_stage = 'won') * 100.0 / NULLIF(COUNT(id), 0)) AS conversion_rate_pct
FROM activated_jobs
GROUP BY location_id
```
Returned only when `location_id = all` AND `requesting_user.role = admin`.

**Closed Revenue:**
```sql
SUM(job_value_estimate) FILTER (WHERE pipeline_stage = 'won')
FROM activated_jobs
WHERE job_value_estimate IS NOT NULL
```

**Active Pipeline:**
```sql
SUM(job_value_estimate) FILTER (WHERE pipeline_stage = 'in_campaign')
FROM activated_jobs
WHERE job_value_estimate IS NOT NULL
```

**Avg Time to First Reply (won jobs only):**
```sql
AVG(
  EXTRACT(EPOCH FROM (first_reply.created_at - j.campaign_started_at)) / 3600.0
)
FROM activated_jobs j
JOIN LATERAL (
  SELECT MIN(created_at) as created_at
  FROM messages
  WHERE job_id = j.id AND direction = 'inbound'
) first_reply ON true
WHERE j.pipeline_stage = 'won'
  AND first_reply.created_at IS NOT NULL
```

Returns null if fewer than 3 qualifying rows.

**Follow-Ups Sent:**
```sql
SELECT COUNT(m.id)
FROM messages m
JOIN jobs j ON j.id = m.job_id
WHERE m.direction = 'outbound'
  AND m.channel = 'email'
  AND m.status = 'sent'
  AND j.campaign_started_at BETWEEN :period_start AND :period_end
  AND j.location_id IN (:location_scope)
  AND j.job_type IN (:lob_scope)
```

**Funnel — Customer Replied:**
```sql
SELECT COUNT(DISTINCT j.id)
FROM activated_jobs j
WHERE EXISTS (
  SELECT 1 FROM messages m
  WHERE m.job_id = j.id AND m.direction = 'inbound'
)
```

**Funnel — Operator Responded:**
```sql
SELECT COUNT(DISTINCT j.id)
FROM activated_jobs j
WHERE EXISTS (
  SELECT 1 FROM messages m_in
  WHERE m_in.job_id = j.id AND m_in.direction = 'inbound'
)
AND EXISTS (
  SELECT 1 FROM messages m_out
  JOIN messages m_in2 ON m_in2.job_id = j.id AND m_in2.direction = 'inbound'
  WHERE m_out.job_id = j.id
    AND m_out.direction = 'outbound'
    AND m_out.created_at > m_in2.created_at
)
```

**Funnel — Unanswered reply pipeline value:**
```sql
SELECT SUM(j.job_value_estimate)
FROM activated_jobs j
WHERE EXISTS (
  SELECT 1 FROM messages m_in WHERE m_in.job_id = j.id AND m_in.direction = 'inbound'
)
AND NOT EXISTS (
  SELECT 1 FROM messages m_out
  JOIN messages m_in2 ON m_in2.job_id = j.id AND m_in2.direction = 'inbound'
  WHERE m_out.job_id = j.id
    AND m_out.direction = 'outbound'
    AND m_out.created_at > m_in2.created_at
)
AND j.job_value_estimate IS NOT NULL
```

**Originator metrics:**
All originator metrics are derived from the `activated_jobs` base set filtered by `created_by_user_id = originator.user_id`. Reply Rate and Close Rate use the activated job count for that originator as the denominator.

**Chart time buckets:**
Follow-Ups Sent per bucket: count of outbound emails where `sent_at` falls within the bucket date range.
Replies Received per bucket: count of distinct jobs with an inbound message where `messages.created_at` falls within the bucket.
Jobs Closed Won per bucket: count of jobs where `pipeline_stage = 'won'` and `won_at` falls within the bucket.

**Delta computation:**
For each hero metric, compute the identical metric against the prior period (`prior_start` to `prior_end`). Return both values. The frontend computes the delta display value: `current - prior`. Sign and direction (`up` / `down` / `flat`) are returned by the backend.

---

## 14. Empty State

When no jobs have been activated within the selected scope (denominator is zero for all metrics):

**Heading:** "No data for this period"  
**Body:** "Analytics will populate once jobs are running campaigns. Try a different date range or filter."  
**Visual:** Minimal placeholder — no mock charts, no fake data. Clean empty state.

The filter bar remains active so the operator can change the scope. Individual zones do not render skeleton placeholder charts.

---

## 15. System Boundaries

| Responsibility | Owner |
|---|---|
| Analytics API endpoint: all metric computation | smai-backend |
| Period window computation and prior period | smai-backend |
| MTD and YTD computation and window bounding (SPEC-05) | smai-backend |
| Per-location Conversion Rate breakdown computation (SPEC-06) | smai-backend |
| Originator visibility enforcement (Admin vs Originator) | smai-backend |
| Filter parameter validation | smai-backend |
| All SQL queries and aggregations | smai-backend (Cloud SQL / PostgreSQL) |
| Hero tile rendering (value, delta, subtext, color) | smai-frontend |
| MTD/YTD dual display rendering (SPEC-05 §7) | smai-frontend |
| Per-location breakdown expand/collapse UI (SPEC-06) | smai-frontend |
| Funnel bar width computation (proportional to Stage 1) | smai-frontend |
| Funnel drop-off label rendering (conditional on unanswered_reply_count >= 1) | smai-frontend |
| Originator table sort (by close_rate_pct desc) | smai-backend (returned pre-sorted) |
| Close Rate bar opacity computation | smai-frontend |
| Chart axis scale computation | smai-frontend (from bucket data) |
| Chart time bucketing (monthly/weekly/biweekly/daily) | smai-backend (returns bucketed data; frontend renders) |
| Tooltip rendering | smai-frontend (Recharts built-in) |
| "SMAI activated" reference line positioning | smai-frontend (from `smai_activated_at` in response) |
| Color system enforcement | smai-frontend |
| Empty state rendering | smai-frontend (when all counts are 0) |

---

## 16. Implementation Slices

### Slice A: API endpoint and metric computation ([#85](https://github.com/frizman21/smai-server/issues/85))
Implement the `/api/analytics` endpoint. Implement all SQL queries from Section 13.3 against the Cloud SQL database. Implement prior-period delta computation. Implement the originator visibility filter (Admin vs Originator). Implement the MTD and YTD computations (SPEC-05) and return them in the `hero.conversion_rate` object. Implement the per-location conversion rate breakdown (SPEC-06) and return it in `conversion_rate_by_location` when `location_id = all` AND Admin. Return the full response structure per Section 13.2.

Dependencies: PRD-01 (jobs table with `campaign_started_at`), PRD-03 (messages table with direction, status, channel).  
Excludes: Frontend rendering.

### Slice B: Filter bar and request wiring ([#86](https://github.com/frizman21/smai-server/issues/86))
Implement the filter bar UI (three pills, all identical treatment). Wire filter selection to issue a new API request with updated parameters. Implement the location filter behavior (hidden for single-location users, All Locations default for multi-location). Implement the Job Type filter showing only types with active data, using the seven RESTORATION sub-types from SPEC-03 §7. Add Month to Date and Year to Date to the date range filter dropdown per SPEC-05.

Dependencies: Slice A. SPEC-03. SPEC-05.

### Slice C: Zone 1 — Hero tiles ([#87](https://github.com/frizman21/smai-server/issues/87))
Implement all five tiles with correct metric labels, value formatting, delta display, definition subtext. Implement Conversion Rate visual dominance (larger type). Implement delta color rules (teal for positive, muted gray for flat). Implement the Avg Time to First Reply "--" edge case for sparse data. Implement the MTD/YTD dual display inside the Conversion Rate tile per SPEC-05 §7.

Dependencies: Slice A. SPEC-05.

### Slice D: Zone 2 — Funnel ([#88](https://github.com/frizman21/smai-server/issues/88))
Implement all five funnel stages with proportional bar widths. Implement right-side metadata per stage. Implement the unanswered-reply drop-off label (conditional render, amber dollar figure). Implement the Closed Won row teal/8 background. Enforce color rules.

Dependencies: Slice A.

### Slice E: Zone 3 — Originator table ([#89](https://github.com/frizman21/smai-server/issues/89))
Implement the table with all five columns. Implement the location secondary line. Implement Close Rate proportional bars with 0.6 opacity floor. Implement role-scoped visibility (frontend renders what API returns). Implement empty state for zero originators in scope.

Dependencies: Slice A.

### Slice F: Zone 4 — Chart ([#90](https://github.com/frizman21/smai-server/issues/90))
Implement the Recharts ComposedChart with area series and two grouped bar series. Implement the three stat blocks above the chart. Implement the legend with period-aggregate totals and matching opacity dots. Implement the dual Y-axis. Implement the "SMAI activated" dashed reference line and label. Implement the tooltip showing time-bucket values. Implement time bucketing based on selected period (including daily buckets for MTD and monthly for YTD). Implement gridlines. Enforce color system (teal family only, no green, no coral).

Dependencies: Slices A, B.

### Slice G: Per-location Conversion Rate breakdown (SPEC-06) ([#91](https://github.com/frizman21/smai-server/issues/91))
Implement the collapsible per-location breakdown inside the Conversion Rate tile when `location_id = all` and the user is Admin. Render the `conversion_rate_by_location` payload per SPEC-06 UI rules. Maintain session-only expand/collapse state.

Dependencies: Slices A, C. SPEC-06.

### Slice H: Empty state, mobile, role visibility ([#92](https://github.com/frizman21/smai-server/issues/92))
Implement the empty state for zero activated jobs in scope. Implement mobile layout (390px). On mobile, hero tiles stack 2x3 or scroll horizontally; funnel renders vertically; originator table scrolls horizontally; chart renders full width. Confirm role visibility behavior end to end.

Dependencies: Slices A–G.

---

## 17. Acceptance Criteria

**AC-01: Single API call per filter change**
Given the operator changes the date range filter, when the filter is applied, then exactly one new API request is issued to `/api/analytics` with the updated `period` parameter. No other API requests are made. The entire screen re-renders from the single response.

**AC-02: Conversion Rate formula**
Given a scope with 80 activated jobs and 27 won jobs, when the hero tiles render, then the Conversion Rate tile displays "34%" (27/80 = 33.75%, rounded to integer).

**AC-03: Conversion Rate definition subtext**
Given any scope, when the hero tiles render, then the definition subtext under the Conversion Rate value reads exactly: "Won jobs as a % of activated proposals."

**AC-04: Active Pipeline is neutral color**
Given any scope, when the Active Pipeline tile renders, then no amber, no teal accent, and no alarm styling is applied to the value or delta. The tile is visually identical in color treatment to Closed Revenue and Follow-Ups Sent.

**AC-05: Amber appears exactly once**
Given a scope with at least one unanswered customer reply, when the full Analytics screen renders, then amber styling (`text-amber-600`) appears in exactly one location: the dollar figure in the unanswered-reply drop-off label. Every other element on the screen uses teal or muted gray.

**AC-06: No green, red, or coral anywhere**
Given any scope with any data, when the full Analytics screen renders, then no element uses green, red, or coral color values. An automated color audit against the rendered DOM must find zero instances.

**AC-07: Funnel bar widths are proportional**
Given a funnel where Proposals Activated = 80 and Closed Won = 27, when the funnel renders, then the Proposals Activated bar is at 100% width and the Closed Won bar is at 34% width (27/80).

**AC-08: Unanswered-reply label conditional**
Given a scope with 4 unanswered replies, when the funnel renders, then the drop-off label "4 replies never got a response — $57,600 at risk" appears between Customer Replied and Operator Responded rows, with the dollar figure in amber.  
Given a scope with 0 unanswered replies, when the funnel renders, then no drop-off label appears between those rows.

**AC-09: Originator table — Admin visibility**
Given an Admin user with "All Locations" selected, when the Originator Performance table renders, then all originators who have activated jobs in scope appear as rows.

**AC-10: Originator table — Originator visibility**
Given a logged-in Originator, when the Originator Performance table renders, then exactly one row appears: the logged-in user's own row. No other originator's data is visible.

**AC-11: Close Rate bar opacity floor**
Given an originator with the lowest close rate in the table, when the table renders, then their Close Rate bar has an opacity of no less than 0.6. It is clearly visible against the card background.

**AC-12: Chart legend vs tooltip distinction**
Given a Last 90 Days scope with Follow-Ups Sent total = 186 and February bucket = 82, when the chart renders and the operator hovers over the February bucket, then the chart legend shows "Follow-Ups Sent (186)" and the tooltip shows "Follow-Ups Sent: 82." Both values are displayed simultaneously and neither is an error.

**AC-13: "SMAI activated" reference line fully rendered**
Given any scope, when the chart renders, then the "SMAI activated" label appears fully visible, positioned to the right of the dashed vertical reference line, and is not clipped by the card boundary.

**AC-14: Delta uses prior period**
Given a Last 30 Days scope where the current period shows Conversion Rate = 34% and the prior 30-day period showed 26%, when the hero tile renders, then the delta line reads "8 pts vs prior period" in teal.

**AC-15: Filter location scope enforcement**
Given a multi-location Admin who selects "DFW" in the location filter, when all zones render, then every metric, funnel count, originator row, and chart value reflects only jobs where `location_id` matches the DFW location. Jobs from other locations are absent.

**AC-16: Empty state for zero activated jobs**
Given a filter scope with no activated jobs (denominator = 0), when the screen renders, then the heading "No data for this period" and the body text appear. No metrics render as 0% or $0. No placeholder charts render.

**AC-17: Avg Time to First Reply sparse data guard**
Given a scope with fewer than 3 won jobs with customer replies, when the hero tile renders, then Avg Time to First Reply displays "--" not a numeric value.

**AC-18: Job Type filter options match SPEC-03 v1.3**
Given a multi-job-type account, when the Job Type filter dropdown is opened, then the options shown are "All Job Types" plus the seven Restoration sub-types from SPEC-03 v1.3 §7.1 (Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation), further narrowed to types with at least one activated job in scope. No Reconstruction or other deferred sub-types appear.

**AC-19: MTD/YTD dual display present**
Given any scope, when the Conversion Rate tile renders, then MTD and YTD secondary figures are visible below the primary value and delta, each independently calculated per SPEC-05. The MTD and YTD values render regardless of which date range filter is active. When MTD or YTD denominator is zero, the respective figure renders as "—" not "0%."

**AC-20: MTD period filter selection**
Given the operator selects "Month to Date" in the date range filter, when all zones render, then every metric, funnel count, and chart bucket reflects only jobs where `campaign_started_at` falls between the first day of the current calendar month and today (inclusive).

**AC-21: Per-location breakdown Admin-only**
Given an Originator (non-Admin) with "All Locations" selected, when the response is inspected, then `conversion_rate_by_location` is empty. The per-location breakdown UI does not render.  
Given an Admin with "All Locations" selected, when the response is inspected, then `conversion_rate_by_location` contains one row per active location with the requested fields. The UI per SPEC-06 becomes available.

**AC-22: Per-location breakdown hidden when single location selected**
Given an Admin with a specific location (not "All Locations") selected, when the Conversion Rate tile renders, then the per-location breakdown UI is not available on this view. The `conversion_rate_by_location` array may be empty or absent in the response.

**AC-23: No scenario filter, no template-cohort breakdown**
Given any user under any scope, when the Analytics screen renders, then the filter bar contains exactly three filters (date range, location, Job Type) and no Scenario filter. No zone surfaces a per-`scenario_key` or per-`template_version_id` breakdown. The API response does not include scenario-level or template-version-level aggregations. Both dimensions are captured upstream (per SPEC-03 v1.3 and SPEC-11 v2.0 respectively) and reserved for a future Analytics expansion (see OQ-07).

---

## 18. Open Questions and Implementation Decisions

**OQ-01: Database indexing for analytics queries**
The analytics queries join across `jobs` (`job_proposals`), `messages`, and potentially `job_campaigns` (`campaigns`) with date range filters. Engineering should confirm that `jobs.campaign_started_at`, `jobs.location_id`, `jobs.pipeline_stage`, `messages.direction`, and `messages.created_at` are indexed appropriately. At Buc-ee's scale this is not a concern. At any real volume, unindexed analytics queries will be slow.

**OQ-02: "won_at" timestamp availability**
The chart's "Jobs Closed Won per bucket" metric requires `won_at` to fall within the time bucket. The `won_at` field is defined in PRD-01 on the `job_proposals` table. Engineering should confirm this field is populated correctly by the Mark Won transition in PRD-03.

**OQ-03: Originator attribution for jobs created via Chrome extension**
Jobs created via the Chrome extension are attributed to `jobs.created_by_user_id` (the logged-in user at the time of creation). This is consistent with the OBO decision in PRD-01.

**OQ-04: Analytics endpoint path — confirm with Mark**
This PRD specifies `/api/analytics` as the endpoint path. Mark to confirm the actual path used in `smai-backend` matches or propose an alternative. This is an engineering-design question, not a product question. If the as-built path differs, update this PRD and the Lovable wiring accordingly before Slice B is built.

**OQ-04 RESOLVED (2026-04-23):** Confirmed `/api/analytics` per Mark (transcribed call 2026-04-23: "the backend endpoint was generated from the prd by Ethan. I'm 99% sure it matches the prd which is api/analytics which is great"). Closes M2P-01 from CONSISTENCY-REVIEW-2026-04-23.

**OQ-05: MTD/YTD trend delta calculation period**
When MTD is the active `period`, the trend delta compares against the same MTD window in the prior month (April 1–8 vs March 1–8). When YTD is the active `period`, it compares against the same YTD window in the prior year (Jan 1–April 8 2026 vs Jan 1–April 8 2025). This matches SPEC-05's intuitive-behavior preference. Mark to confirm at backend implementation time.

**OQ-06: Time zone for MTD/YTD boundaries**
MTD and YTD boundaries should be computed in a consistent time zone. SPEC-05 OQ flags this for Mark's decision: operator local time zone vs. tenant's configured time zone. This PRD inherits that open question.

**OQ-06 RESOLVED (2026-04-23):** Operator-local time zone, derived from the browser. Backend stores all timestamps in UTC; FE renders in browser-local time. Tenant-configured time zone considered and rejected for current build (Mark, transcribed call 2026-04-23: "let's say operator local on that"). Computed boundaries (MTD, YTD, today, last_N_days) are FE-side per the broader Analytics architecture decision below. Closes M2P-02 from CONSISTENCY-REVIEW-2026-04-23. SPEC-05 carries the parallel resolution.

**OQ-07: Template-cohort and scenario-level Analytics — future build framing**
Per SPEC-11 v2.0, every campaign run carries a `campaigns.template_version_id` referencing the variant that rendered it. Per SPEC-03 v1.3 and PRD-01 v1.4.1, every job carries a `scenario_key`. Both dimensions are captured upstream and stored on the canonical schema. They are not surfaced in v1.2 of this PRD. A future Analytics expansion (post-MVP) should add at minimum: (a) a Conversion Rate by template variant breakdown (which variant converts best); (b) a funnel-by-scenario lens (where do drops concentrate within Water Mitigation vs Mold Remediation, etc.); (c) a Reply Rate by template variant breakdown (which variant gets the most engagement). The data plumbing for all three exists today; the work is endpoint, response shape, and UI. Kyle to scope post-MVP. This is not an open product question for v1.2 — it is a future-build placeholder so the deferred dimensions don't get lost.

**OQ-08: Chart bucketing rules for `today`, `last_7d`, and `custom` periods**
Added in the 2026-04-22 patch. The §6.1 dropdown and §13.1 API now accept seven `period` values per SPEC-05 alignment, but §10.5 chart bucketing only defines rules for four (`last_30d`, `last_90d`, `month_to_date`, `year_to_date`). Bucketing for `today` (likely hourly), `last_7d` (likely daily), and `custom` (depends on selected window length) is not yet defined. Kyle to set product intent; Mark to confirm backend bucket-aggregation feasibility. Resolve before any Slice that touches the Follow-Up Activity chart against these three period values. Until resolved, the frontend should disable the chart or render a "Bucketing not yet supported for this date range" empty state when the selected period is `today`, `last_7d`, or `custom`.

**OQ-08 RESOLVED (2026-04-23):** Chart bucketing for all seven periods is a frontend concern in the current build. Per the Analytics architecture decision (see new §1A current-implementation note), the backend ships raw query results from the jobs and messages tables; the FE handles period filtering, MTD/YTD computation, and chart bucketing client-side. Bucketing rules for `today`, `last_7d`, and `custom` therefore become FE implementation choices, not backend contracts. Suggested current rules (FE owns, free to change without backend coordination): `today` = hourly buckets, `last_7d` = daily buckets, `custom` = adaptive based on window length (daily for ≤30 days, weekly for 31-90 days, monthly for >90 days). The §10.5 backend-bucketing table remains as the eventual contract for when reporting tables and/or a data warehouse are introduced (per Mark, transcribed call 2026-04-23). Closes M2P-05 from CONSISTENCY-REVIEW-2026-04-23.

**OQ-02 (updated v1.2):** PRD references updated to PRD-01 v1.4.1 and PRD-03 v1.4.1. The `won_at` field is populated by the Mark Won / Mark Lost transition per PRD-03 v1.4.1 §10.4 (closure path).
