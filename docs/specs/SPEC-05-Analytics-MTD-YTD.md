# SPEC-05: Analytics — MTD/YTD Conversion Rate and Time Period Options

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Analytics — MTD/YTD Conversion Rate and Time Period Options |
| Spec ID | SPEC-05 |
| Version | 1.0 |
| Status | Ready for build |
| Date | 2026-04-08 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | April 6 Jeff demo session; Lovable UI audit April 8 |
| Related docs | PRD-07 Analytics; CC-06 Buc-ee's MVP Definition; CC-01 Platform Spine v1.4 |

**Patch note (2026-04-23, Wave 6D — Mark closures):** Two changes; no behavioral spec change. (1) §14 timezone OQ marked RESOLVED — operator-local time zone derived from the browser, per Mark (transcribed call 2026-04-23). Backend stores all timestamps in UTC; FE renders in browser-local time. PRD-07 OQ-06 carries the parallel resolution. Closes M2P-02 from CONSISTENCY-REVIEW-2026-04-23. (2) New §1A "Current Implementation Note" added documenting the Mark architecture decision: backend ships raw query results from `jobs` and `messages` tables in the current build; FE handles MTD / YTD computation, period filtering, and trend deltas client-side. References elsewhere in this spec to "backend computes MTD and YTD" (notably §2 point 5, §8 row 235, §11 rows 291-294) describe the eventual contract for when reporting tables or a data warehouse are introduced; they are not current-build requirements. Operator-facing behavior is unchanged regardless of where the computation runs. Mirrors the parallel PRD-07 §1A note. Migration path documented inline. The §1A note will be retired and the body of the SPEC activated as literal backend contract when MTD/YTD computation moves backend. No version bump (resolutions and notes; no behavioral change in spec). Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-02, M2P-05; PRD-07 §1A; transcribed call with Mark 2026-04-23.

---

## 1. What This Is in Plain English

The Analytics page has a time period filter that currently offers: Today, Last 7 Days, Last 30 Days, Last 90 Days, and Custom. The Conversion Rate hero stat shows one figure — the rate for whatever period is selected — plus a trend delta compared to the prior period.

Jeff tracks his business on two calendars simultaneously: month-to-date and year-to-date. He uses these to manage his operation weekly: "here's how this month is running, here's how the year is tracking." Toggling a time filter to get each view, one at a time, is not how he works. He wants to see both periods at once on the Conversion Rate stat without touching the filter.

He also needs MTD and YTD as named, selectable time periods in the filter. "Last 30 days" is not the same as month-to-date — MTD resets on the 1st of every month, which is the period boundary his team tracks against.

This spec makes two focused changes to the Analytics screen:

1. **Adds Month to Date and Year to Date as selectable options in the time period filter dropdown.**
2. **Updates the Conversion Rate hero stat to show both the MTD rate and the YTD rate simultaneously**, regardless of which time period is active in the filter.

No other stats are changed. No other sections of the analytics page are touched. The locked design language (one teal color family at varying opacities, amber only on operator-actionable pipeline figures) is preserved exactly.

---

## 1A. Current Implementation Note (Backend Architecture)

**This SPEC specifies the eventual MTD/YTD contract. The current build implements computation client-side.**

Per Mark (transcribed call 2026-04-23), the current backend implementation ships raw query results from the `jobs` and `messages` tables; the frontend computes MTD, YTD, period filtering, and trend deltas client-side from the raw rows. References elsewhere in this spec to "backend computes MTD and YTD" (notably §2 point 5, §8 row 235, §11 rows 291-294) describe the eventual backend contract — the destination state when reporting tables or a data warehouse are introduced. They are not current-build requirements.

This is consistent with the broader Analytics architecture decision documented in PRD-07 §1A. At Servpro pilot scale, raw-row return + FE computation gives the product the flexibility to change MTD/YTD definitions, period boundaries, and trend-delta logic without backend changes. Backend aggregation is introduced when data volumes warrant it.

**Implication for this SPEC:** The product behavior described throughout (MTD/YTD shown simultaneously on the Conversion Rate stat, trend delta against prior equivalent period, "—" when zero denominator, recalculation on location filter change, etc.) is the operator-facing contract regardless of whether the computation runs backend or frontend. Builders implementing the current build should compute MTD and YTD in the FE using the raw rows returned by `/api/analytics`. When the backend migration happens, the FE computation moves backend and the response shape carries the precomputed values; the operator-facing behavior does not change.

**Implication for the OQ:** The timezone OQ (§14) resolves as documented in the OQ section — operator-local time zone derived from the browser. Because computation is FE-side in the current build, the timezone of computation is by definition the browser's timezone; the OQ becomes self-resolving for the current build. When backend computation is introduced, the backend will need to honor the same operator-local-from-browser convention (passed as a parameter or inferred from request context).

This note will be retired and the body of the SPEC activated as the literal backend contract when MTD/YTD computation moves backend. Until then, treat sections that imply backend computation as "what the contract becomes when the work moves backend; the FE handles it for now."

Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-02, M2P-05; PRD-07 §1A; transcribed call with Mark 2026-04-23.

---

## 2. What Builders Must Not Misunderstand

1. **MTD and YTD on the Conversion Rate stat are always shown simultaneously, regardless of the active time filter.** They are not toggled by the filter. The filter controls the rest of the page (funnel, originator table, follow-up activity chart). The Conversion Rate stat has its own always-on dual display.

2. **"Last 30 Days" is not the same as "Month to Date."** Last 30 Days is a rolling window — it always covers the 30 calendar days ending today. Month to Date always starts on the 1st of the current month. On April 8, MTD covers April 1–8. Last 30 Days covers March 9–April 8. They return different numbers. Both options must exist. Neither replaces the other.

3. **The locked analytics color design must not change.** The Analytics page uses one teal color family at varying opacities. Amber is used only for the operator-actionable pipeline exposure figure. No green, no coral, no red, no new colors are introduced by this spec. The MTD and YTD figures on the Conversion Rate stat use the same teal and neutral palette already in use.

4. **The trend delta on the Conversion Rate stat is not removed.** The existing "8 pts vs prior period" trend indicator stays. The spec adds MTD and YTD figures alongside the existing display — it does not replace the current stat behavior.

5. **The backend must compute MTD and YTD separately and efficiently.** These are distinct date-bounded queries, not derivable from the existing rolling-window queries. The frontend does not compute them from raw data.

6. **"Month to Date" and "Year to Date" are the display labels in the filter dropdown.** Use full words, not abbreviations ("MTD" / "YTD") in the dropdown list. The stat block may use the abbreviated form ("MTD" / "YTD") because space is constrained and the context makes the meaning clear.

7. **This spec does not add a date-range comparison mode.** Jeff asked to see MTD and YTD simultaneously, not to compare one period against another. The dual display shows two independently calculated current-period rates, not a before/after comparison.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Jeff's explicit requirement from the April 6 session: conversion rate shown split by month-to-date and year-to-date simultaneously, and MTD/YTD available as filter options because "Last 30 days" is not MTD. Confirmed as a pre-go-live requirement because the Analytics page is his primary proof instrument and he tracks his business on these periods.

**What this covers:**
- Adding "Month to Date" and "Year to Date" to the time period filter dropdown
- Defining the date boundaries for MTD and YTD correctly
- Updating the Conversion Rate hero stat to show MTD rate and YTD rate as a dual display
- Backend query support for MTD and YTD date-bounded conversion rate calculations
- Preserving all existing analytics behavior and design language

**What this does not cover:**
- Changes to any other hero stat (Closed Revenue, Active Pipeline, Avg Time to First Reply)
- Changes to the funnel section, originator performance table, or follow-up activity chart
- Date range comparison mode (comparing one period against another)
- Custom date range beyond what "Custom" already provides
- Changes to the locked color design (teal family, amber only for pipeline exposure)
- Fiscal year vs. calendar year configuration (YTD means calendar year to date — January 1 to today)
- Branch-level comparison within the Conversion Rate stat (addressed in SPEC-06)
- Any change to how conversion rate is defined or calculated (won jobs as a % of activated plans)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Analytics color design locked: one teal family at varying opacities, amber only on operator-actionable pipeline exposure figure, no green/coral/red. | Memory; prior session decision |
| Conversion rate definition locked: Won jobs as a % of activated proposal plans for the period. | PRD-07 Analytics; Campaign Engine spec |
| Jobs, Needs Attention, and Analytics are the MVP operational surfaces. | CC-06 Buc-ee's MVP Definition |
| Proof-grade analytics grounded in authorized plans and recorded events. | CC-04 Pricing & Packaging Brief |
| Analytics filter is not wired in the current Lovable build — real data binding happens in Cursor per PRD data contract. | Memory; prior session decision |
| The Analytics page is intended to function as Jeff's proof instrument. Data must be real and correctly calculated from actual job events. | CC-06; GTM pilot playbook |

---

## 5. Actors and Objects

**Actors:**
- **Admin** — primary user of analytics. Sees all data across locations and originators.
- **Originator** — may see analytics scoped to their own activity (role scoping per PRD-07). Analytics filter behavior for originator role is governed by PRD-07 and not changed by this spec.
- **System** — computes conversion rate figures for MTD, YTD, and the active filter period. Serves them to the frontend.

**Objects:**
- **Time period filter** — the dropdown in the analytics filter bar. Currently offers: Today, Last 7 Days, Last 30 Days, Last 90 Days, Custom.
- **Conversion Rate stat block** — the first hero stat on the Analytics page. Currently shows: one rate figure, descriptive sub-label, trend delta vs. prior period.
- **MTD conversion rate** — won jobs / activated plans where the job was activated between the 1st of the current calendar month and today (inclusive).
- **YTD conversion rate** — won jobs / activated plans where the job was activated between January 1 of the current calendar year and today (inclusive).
- **Active filter period conversion rate** — the existing rate figure, computed for whatever time period is selected in the filter. Preserved as-is.

---

## 6. Workflow Overview

**Time period filter — updated behavior:**

The operator opens the filter dropdown and selects a period. The page updates to show data for that period across all sections. No change to this behavior, except that two new options now appear in the dropdown.

**Conversion Rate stat — updated behavior:**

The stat always shows three data points simultaneously:
1. The rate for the active filter period (existing behavior, preserved).
2. The MTD rate (new, always shown regardless of filter).
3. The YTD rate (new, always shown regardless of filter).

When the operator changes the time filter, the active filter period rate updates. The MTD and YTD figures do not change — they are always computed against their fixed date boundaries and are not affected by the filter selection.

---

## 7. Detailed Behavior

### 7.1 Time Period Filter — New Options

**Current dropdown options:**
```
Today
Last 7 Days
Last 30 Days
Last 90 Days
Custom
```

**Updated dropdown options:**
```
Today
Last 7 Days
Last 30 Days
Last 90 Days
─────────────
Month to Date
Year to Date
─────────────
Custom
```

The two new options are grouped below the rolling-window options, separated by a divider, with Custom remaining at the bottom after another divider.

**Date boundary definitions:**

| Option | Start date | End date |
|--------|-----------|----------|
| Today | Start of current calendar day (midnight local time) | End of current calendar day |
| Last 7 Days | 7 calendar days before today, inclusive | Today |
| Last 30 Days | 30 calendar days before today, inclusive | Today |
| Last 90 Days | 90 calendar days before today, inclusive | Today |
| Month to Date | 1st of the current calendar month | Today |
| Year to Date | January 1 of the current calendar year | Today |
| Custom | Operator-selected start | Operator-selected end |

**MTD and YTD affect all sections of the analytics page** when selected as the active filter period — funnel, originator table, follow-up chart, and hero stats all update to reflect the MTD or YTD window. This is the same behavior as any other filter selection.

### 7.2 Conversion Rate Stat Block — Dual MTD/YTD Display

**Current stat block layout:**
```
CONVERSION RATE
34%
Won jobs as a % of activated proposals
↑ 8 pts vs prior period
```

**Updated stat block layout:**
```
CONVERSION RATE
34%
Won jobs as a % of activated proposals
↑ 8 pts vs prior period

MTD    YTD
28%    34%
```

**Design rules for the MTD/YTD section:**

- Positioned below the existing trend delta line, visually separated by a small amount of vertical space (not a full divider).
- "MTD" and "YTD" are label text in a smaller, lighter weight than the figures. Use the existing secondary label style already present elsewhere in the stat blocks.
- The MTD and YTD percentage figures are the same type size as secondary stat figures used elsewhere on the page (not as large as the hero "34%" figure, but clearly readable).
- Color: teal at the standard opacity used for the secondary/supporting figures on the page. No new colors. No amber (amber is reserved for the operator-actionable pipeline exposure figure only).
- If MTD and YTD are the same value (possible if the month just started, i.e., today is January 1 or the 1st of a month), both figures are still shown. No special handling for equality.
- If MTD or YTD cannot be calculated due to zero activated plans in the period, show "—" (em dash) instead of a percentage. Do not show "0%" — a zero denominator means the rate is undefined, not zero.

**The existing hero figure behavior:**

The large "34%" figure and the trend delta ("↑ 8 pts vs prior period") continue to reflect the active filter period selection. If the operator selects "Month to Date" as the active filter, the hero figure updates to show the MTD rate — and the MTD figure in the dual display would match it. This is not confusing because the YTD figure provides the contrast. If the operator selects "Year to Date," the hero figure shows the YTD rate and the YTD figure in the dual display would match it.

This is intentional and correct behavior. The dual display is not hidden or suppressed when MTD or YTD is the active filter period.

**Sub-label text:** "Won jobs as a % of activated proposals" — unchanged.

### 7.3 No Changes to Other Stat Blocks

The following hero stats are not changed by this spec:

- Closed Revenue — unchanged
- Active Pipeline — unchanged
- Avg Time to First Reply — unchanged

The following sections are not changed by this spec:

- Funnel / Where Jobs Are Won and Lost — unchanged
- Originator Performance table — unchanged
- Follow-Up Activity section and bar chart — unchanged

---

## 8. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| MTD and YTD always shown on Conversion Rate stat | These figures are always visible on the stat block regardless of which filter period is active. They do not disappear when a different period is selected. |
| MTD = calendar month to date | Starts on the 1st of the current calendar month. Not a rolling 30-day window. Not configurable. |
| YTD = calendar year to date | Starts on January 1 of the current calendar year. Not configurable. No fiscal year option. |
| Zero denominator = "—" not "0%" | If there are no activated plans in the MTD or YTD window, display "—" rather than a percentage. |
| Color design locked | Teal family only. Amber only for pipeline exposure figure. No new colors for MTD/YTD display. |
| Trend delta preserved | The "↑ X pts vs prior period" line on the Conversion Rate stat is preserved. It is not removed to make room for MTD/YTD. |
| Dropdown labels are full words | "Month to Date" and "Year to Date" — not "MTD" and "YTD" — in the dropdown list. |
| Stat block labels are abbreviated | "MTD" and "YTD" in the stat block itself where space is constrained. |
| Backend computes MTD and YTD | The frontend does not derive these from raw data or from other API responses. The backend serves them as distinct computed values. |
| Last 30 Days is not removed | MTD is added alongside Last 30 Days. Last 30 Days is not replaced. Both must exist as separate options. |

---

## 9. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| Today is January 1 (start of year and start of month) | MTD and YTD cover the same date range (today only). Both figures are shown. They will be identical or close to identical. No special handling. |
| Today is the 1st of a non-January month | MTD covers only today. YTD covers January 1 through today. Figures will differ. Show both. |
| No jobs activated in the MTD window | MTD rate shows "—". YTD rate calculated normally if jobs exist in the YTD window. |
| No jobs activated in the YTD window | Both MTD and YTD show "—". Hero figure and trend delta still render for the active filter period if that period has data. |
| Operator selects "Month to Date" as the active filter | Hero figure updates to match the MTD rate. The MTD label in the dual display will show the same figure. YTD remains unchanged. This is correct behavior, not a bug. |
| Operator selects "Year to Date" as the active filter | Hero figure updates to match the YTD rate. The YTD label in the dual display will show the same figure. MTD remains unchanged. Correct behavior. |
| Backend returns MTD and YTD in the same API response as the active filter period data | Preferred. If a separate API call is required, it must not cause a visible loading delay on the stat block. MTD and YTD should load at the same time as the primary stat figures. |
| Backend is slow to return analytics data | Show a loading skeleton on the stat block. Do not show stale data. |
| Conversion rate exceeds 100% | Not mathematically possible if defined as won / activated plans, since a job must be activated before it can be won. If data anomaly produces this, show the raw calculated figure without capping. Flag as a data integrity issue internally. |
| Location filter changes while MTD and YTD are displayed | MTD and YTD recalculate for the newly selected location. They are not fixed to a location — they follow the active location filter like every other figure on the page. |

---

## 10. UX-Visible Behavior

### Time period filter dropdown

| Element | Current | New |
|---------|---------|-----|
| Options above divider | Today, Last 7 Days, Last 30 Days, Last 90 Days | Unchanged |
| New divider | — | Horizontal rule |
| New options | — | Month to Date, Year to Date |
| New divider | — | Horizontal rule |
| Custom | At bottom | Remains at bottom |
| Selected state | Active option highlighted | Unchanged behavior; Month to Date and Year to Date participate normally |

### Conversion Rate stat block

| Element | Current | New |
|---------|---------|-----|
| Stat label | CONVERSION RATE | Unchanged |
| Hero figure | 34% (active period) | Unchanged |
| Sub-label | "Won jobs as a % of activated proposals" | Unchanged |
| Trend delta | "↑ 8 pts vs prior period" | Unchanged |
| MTD/YTD section | Does not exist | Added below trend delta |
| MTD label | — | "MTD" in secondary label style |
| MTD figure | — | Current MTD rate as percentage, or "—" if undefined |
| YTD label | — | "YTD" in secondary label style |
| YTD figure | — | Current YTD rate as percentage, or "—" if undefined |
| Color | Teal | Teal — no new colors |

---

## 11. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Computing MTD conversion rate (won jobs / activated plans where activation date is within current calendar month to today) | smai-backend (Mark) |
| Computing YTD conversion rate (won jobs / activated plans where activation date is within current calendar year to today) | smai-backend (Mark) |
| Serving MTD and YTD rates in the analytics API response | smai-backend (Mark) |
| Computing conversion rate for named periods: Month to Date, Year to Date, when selected as active filter | smai-backend (Mark) |
| Rendering the updated dropdown with Month to Date and Year to Date options | Frontend |
| Sending the correct date parameters to the analytics endpoint when MTD or YTD is selected | Frontend |
| Rendering the MTD/YTD dual display on the Conversion Rate stat block | Frontend |
| Showing "—" when MTD or YTD rate is undefined (zero activated plans) | Frontend |
| Preserving the hero figure, sub-label, and trend delta behavior | Frontend — must not break existing behavior |
| Maintaining locked color design | Frontend |

**Engineering decision (not product scope):** Whether MTD and YTD are returned as always-present fields in every analytics API response (recommended) or fetched via a separate call is Mark's decision. Product requires that they are available without a separate user action and render at the same time as the primary stat figures.

---

## 12. Implementation Slices

### Slice A — Backend: MTD and YTD computation and API exposure
**Purpose:** Compute and serve MTD and YTD conversion rates as distinct values in the analytics response.
**Components touched:** Analytics API endpoint; conversion rate calculation logic.
**Key behavior:** Every analytics response includes `conversion_rate_mtd` and `conversion_rate_ytd` as top-level fields. MTD = won / activated where activation_date >= first day of current month AND <= today. YTD = won / activated where activation_date >= January 1 of current year AND <= today. Both respect the active location filter. Both return null (not 0) when the activated plans denominator is zero.
**Dependencies:** Existing analytics endpoint and conversion rate calculation.
**Excluded:** Frontend rendering. Dropdown changes.

### Slice B — Backend: Named period query support for MTD and YTD filter selection
**Purpose:** Allow the analytics endpoint to accept "month_to_date" and "year_to_date" as named period parameters, returning all analytics data for those windows when they are the active filter selection.
**Components touched:** Analytics API endpoint; date parameter handling.
**Key behavior:** When the frontend sends `period=month_to_date`, compute all analytics sections (funnel, originator table, follow-up chart, hero stats) using the MTD date window. When `period=year_to_date`, use the YTD window. Existing period parameters (today, last_7_days, last_30_days, last_90_days, custom with date range) continue to function unchanged.
**Dependencies:** Slice A complete.
**Excluded:** Frontend. MTD/YTD always-on display (that is driven by Slice A, not this slice).

### Slice C — Frontend: Time period filter dropdown update
**Purpose:** Add Month to Date and Year to Date as selectable options in the filter dropdown.
**Components touched:** Analytics page time period filter dropdown.
**Key behavior:** Add two new options with a divider above and below them. Labels: "Month to Date" and "Year to Date." When selected, send the appropriate period parameter to the analytics API. All existing options and behaviors unchanged.
**Dependencies:** Slice B complete.
**Excluded:** Stat block changes.

### Slice D — Frontend: Conversion Rate stat block MTD/YTD dual display
**Purpose:** Add the always-on MTD and YTD figures to the Conversion Rate stat block.
**Components touched:** Conversion Rate hero stat component on Analytics page.
**Key behavior:** Read `conversion_rate_mtd` and `conversion_rate_ytd` from the API response. Render them below the trend delta line as a two-column display: "MTD [figure]" and "YTD [figure]." Show "—" if the value is null. Use existing teal secondary figure styling. Do not introduce new colors. Do not remove or alter the existing hero figure, sub-label, or trend delta. Render at the same time as the primary stat on page load.
**Dependencies:** Slice A complete.
**Excluded:** Other stat blocks. Dropdown.

---

## 13. Acceptance Criteria

**Given** an Admin on the Analytics page,
**When** the time period filter dropdown is opened,
**Then** "Month to Date" and "Year to Date" appear as options below the rolling-window options (Today, Last 7, Last 30, Last 90) and above Custom, separated by dividers.

**Given** an Admin who selects "Month to Date" as the active filter period,
**When** the page updates,
**Then** all analytics sections (funnel, originator table, follow-up chart, and hero stats) reflect data for the current calendar month starting on the 1st through today. The Conversion Rate hero figure matches the MTD rate. The YTD figure in the dual display remains independently calculated for the year.

**Given** an Admin on the Analytics page with any active filter period selected,
**When** the Conversion Rate stat block renders,
**Then** it shows: the hero rate for the active period, the trend delta, and below that, two figures labeled "MTD" and "YTD" with their current values. These MTD and YTD figures are visible regardless of which filter period is active.

**Given** the current date is April 8,
**When** MTD is computed,
**Then** it covers April 1 through April 8 inclusive. It does not cover March. It does not cover the prior 30 calendar days.

**Given** no jobs have been activated in the current calendar month,
**When** the Conversion Rate stat block renders,
**Then** the MTD figure shows "—" not "0%." The YTD figure renders normally if year-to-date data exists.

**Given** a location filter is active (e.g., "DFW" is selected),
**When** the Conversion Rate stat block renders,
**Then** the MTD and YTD figures reflect only jobs at the DFW location. They update when the location filter changes.

**Given** the Conversion Rate stat block renders with MTD and YTD figures added,
**When** a designer reviews the color palette,
**Then** no new colors have been introduced. The MTD and YTD figures use the same teal secondary figure styling already present on the page. No amber, no green, no red is used for these figures.

**Given** "Last 30 Days" is selected as the active filter period,
**When** the page renders,
**Then** "Last 30 Days" produces data for the rolling 30-day window ending today. It produces a different number than MTD for any date that is not day 30 of the current month. Both options exist independently in the dropdown. Neither replaces the other.

---

## 14. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| MTD and YTD returned in every analytics response vs. separate endpoint | Engineering decision | Product preference is that they are always-present fields in the standard analytics response (Slice A), so the stat block renders in one pass. A separate endpoint call is acceptable only if it does not cause a noticeable sequential load delay. Mark decides. |
| Trend delta calculation period when MTD or YTD is the active filter | Engineering decision | When MTD is the active period, the trend delta ("↑ X pts vs prior period") compares against the same MTD window in the prior month (e.g., April 1–8 vs. March 1–8). When YTD is active, it compares against the same YTD window in the prior year (e.g., Jan 1–April 8 2026 vs. Jan 1–April 8 2025). This is the most intuitive behavior. Mark should confirm this is the intended calculation before building. |
| Fiscal year vs. calendar year | Confirmed out of scope | YTD is always January 1 of the current calendar year. No fiscal year configuration is available in v1. |
| Time zone for date boundaries | RESOLVED 2026-04-23 | Operator-local time zone, derived from the browser. Backend stores all timestamps in UTC. FE renders in browser-local time and computes MTD / YTD boundaries in browser-local time per the §1A current-implementation note. Tenant-configured time zone considered and rejected for current build (Mark, transcribed call 2026-04-23: "let's say operator local on that"). When backend MTD/YTD computation is introduced (per §1A migration path), the backend must honor the same operator-local-from-browser convention, passed as a parameter or inferred from request context. PRD-07 OQ-06 carries the parallel resolution. Closes M2P-02 from CONSISTENCY-REVIEW-2026-04-23. |
| Analytics data binding in Cursor | Context note | Per the current build plan, real data binding for analytics happens in Cursor, not Lovable. The Lovable design surface shows the correct layout. This spec feeds the Cursor build directly. The frontend agent building this spec should work in the Cursor codebase against the PRD data contract and this spec. |

---

## 15. Out of Scope

- Changes to any hero stat other than Conversion Rate
- Changes to the funnel section, originator performance table, or follow-up activity chart
- Date range comparison mode (comparing one period against another side by side)
- Fiscal year configuration
- Custom date range behavior beyond what "Custom" already provides
- Branch-level comparison within the Conversion Rate stat (addressed in SPEC-06)
- Any change to how conversion rate is defined or calculated
- Any change to the locked color design
- Per-originator MTD/YTD breakdown within this stat block (that is in the Originator Performance table, which is unchanged)
- Historical period selection beyond the current MTD and YTD windows (e.g., "last month" or "last year")
