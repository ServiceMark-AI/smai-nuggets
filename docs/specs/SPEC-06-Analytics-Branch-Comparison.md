# SPEC-06: Analytics — Branch Comparison View on Conversion Rate

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Analytics — Branch Comparison View on Conversion Rate |
| Spec ID | SPEC-06 |
| Version | 1.0 |
| Status | Ready for build |
| Date | 2026-04-08 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | April 6 Jeff demo session; Lovable UI audit April 8 |
| Related docs | PRD-07 Analytics; SPEC-05 Analytics MTD/YTD; CC-06 Buc-ee's MVP Definition; MultiTenancy Final MVP Spec (Doc 2); CC-01 Platform Spine v1.4 |

**Patch note (2026-04-23, Wave 6D — Mark closures):** New §1A "Current Implementation Note" added documenting the Mark architecture decision (transcribed call 2026-04-23): backend ships raw query results from `jobs` and `messages` tables in the current build; FE handles per-location aggregation client-side from raw rows. References to "smai-backend computes per-location conversion rates" (notably §12 rows 311-313) describe the eventual backend contract for when reporting tables or a data warehouse are introduced; they are not current-build requirements. Operator-facing behavior is unchanged regardless of where the per-location aggregation runs. Admin-only visibility (§2 point 5, §6, §7) remains a server-side enforcement boundary even with FE-side aggregation: the backend filters raw rows by `users.role` before returning them. Mirrors the parallel PRD-07 §1A and SPEC-05 §1A notes. The §1A note will be retired and the body of the SPEC activated as literal backend contract when per-location aggregation moves backend. No version bump (note addition; no behavioral change in spec). Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-05; PRD-07 §1A; SPEC-05 §1A; transcribed call with Mark 2026-04-23.

---

## 1. What This Is in Plain English

Jeff runs three Servpro locations: Northeast Dallas, Boise, and Reno. He is starting SMAI on Dallas first. His proof case is simple and specific: he wants to show his ownership group that Dallas's conversion rate improved after SMAI went live, compared to the other branches running their old process. To make that case, he needs to see all three locations' conversion rates on the same screen at the same time, normalized to the same metric.

Right now the Analytics page lets you pick one location from the filter (All Locations, or a specific location). "All Locations" gives an aggregate. A specific location gives only that location's data. There is no view that shows each location as a separate row or bar on the same screen simultaneously.

This spec adds a per-location breakdown to the Conversion Rate stat block. When "All Locations" is selected in the location filter, the Conversion Rate stat optionally expands to show each location's rate as an individual figure below the aggregate. Jeff can look at this view and say: "Dallas was at 38% before. Now it's at 48%. Boise and Reno are both at 36%. The difference is SMAI."

This is not a cross-location dashboard. It is a breakdown within the existing Analytics page, within the existing Conversion Rate stat block, visible only to Admin users, and only when "All Locations" is the active location filter. It does not add a new page, a new navigation item, or a new report. It adds a toggleable expansion to one stat block on one existing screen.

---

## 1A. Current Implementation Note (Backend Architecture)

**This SPEC specifies the eventual per-location breakdown contract. The current build implements aggregation client-side.**

Per Mark (transcribed call 2026-04-23), the current backend implementation ships raw query results from the `jobs` and `messages` tables; the frontend computes the per-location conversion rates client-side from the raw rows. References elsewhere in this spec to "smai-backend computes per-location conversion rates" (notably §12 rows 311-313) describe the eventual backend contract — the destination state when reporting tables or a data warehouse are introduced. They are not current-build requirements.

This is consistent with the broader Analytics architecture decision documented in PRD-07 §1A and the parallel SPEC-05 §1A. At Servpro pilot scale (three locations), per-location aggregation in the FE is trivial; backend aggregation is introduced when data volumes warrant it.

**Implication for this SPEC:** The product behavior described throughout (Conversion Rate stat block expandable to show per-location rows, Admin-only visibility, sorted descending by rate, "—" when zero denominator, recalculation when time period or scope changes) is the operator-facing contract regardless of whether the per-location aggregation runs backend or frontend. Builders implementing the current build should compute per-location rates in the FE using the raw rows returned by `/api/analytics`.

**Implication for the Admin-only visibility constraint (§2 point 5, §6, §7).** Even with FE-side aggregation, the Admin-only restriction must still be enforced server-side: the backend response must filter raw rows by `users.role` so that an Originator's request never returns rows from locations outside their `users.location_id`. The FE cannot be the security boundary for cross-location data; the backend always owns access-scope filtering. What the FE owns in the current build is the *aggregation* of allowed rows, not the *gating* of which rows are allowed.

This note will be retired and the body of the SPEC activated as the literal backend contract when per-location aggregation moves backend. Until then, treat sections that imply backend computation as "what the contract becomes when the work moves backend; the FE handles it for now."

Ref: CONSISTENCY-REVIEW-2026-04-23 M2P-05; PRD-07 §1A; SPEC-05 §1A; transcribed call with Mark 2026-04-23.

---

## 2. What Builders Must Not Misunderstand

1. **This is a breakdown within the existing Conversion Rate stat, not a new section or page.** The per-location rows appear inside the existing Conversion Rate stat block when the operator expands it. No new screen is introduced. No new navigation item is added.

2. **The breakdown is only available when "All Locations" is the active location filter.** When a specific location is selected, the Conversion Rate stat shows that location's rate only — as it does today. The per-location expansion is not available in single-location mode because there is only one location to show.

3. **This is Admin-only.** Originator-role users see only their own location's data. The per-location breakdown exposes other locations' rates, which is not appropriate for Originator-role users. The expansion toggle is hidden for Originator-role users.

4. **The locked color design must not change.** One teal family at varying opacities. Amber only for operator-actionable pipeline exposure. No new colors. Per-location bars or figures use the teal palette already in use.

5. **This is not a cross-location analytics dashboard.** The MultiTenancy spec explicitly excludes "regional roll-ups or cross-location analytics dashboards" from MVP. This spec does not build that. It adds a within-tenant, within-existing-page, within-existing-stat-block expansion that is structurally different: it is scoped to one metric (conversion rate), on one existing screen (Analytics), within the existing "All Locations" filter state. It is a breakdown of an existing aggregated figure, not a new cross-location report.

6. **The rest of the Analytics page does not change when the breakdown is expanded.** The funnel, originator table, and follow-up activity chart continue to reflect the active location filter ("All Locations" aggregate). The per-location breakdown is additive to the Conversion Rate stat only. It does not drive filter changes or re-scope the rest of the page.

7. **The expansion state is a UI preference, not a persisted setting.** If the operator expands the breakdown, it stays expanded for the session. On a fresh page load it returns to collapsed. No backend persistence required.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Jeff's requirement from the April 6 session: "I'd like to move this up to all branches and get rid of this, and just make it normalized. Here's how all branches were measured the exact same. Dallas is now doing a different process and you'll see that Dallas's number has gone from 38% to 48%." He needs to show his ownership group — and himself — that SMAI is moving the number at Dallas relative to the other branches as a control group.

**What this covers:**
- A toggleable per-location breakdown within the Conversion Rate stat block
- Available only when "All Locations" is the active location filter
- Visible only to Admin-role users
- Shows each active location's conversion rate as an individual figure
- Uses existing teal color palette
- Expansion state is session-persistent, not backend-persisted

**What this does not cover:**
- A new analytics page, dashboard, or navigation item
- Cross-location breakdowns for any other stat block (Closed Revenue, Active Pipeline, Avg Time to First Reply)
- Cross-location breakdowns for the funnel section, originator table, or follow-up activity chart
- Regional groupings or hierarchical location roll-ups
- Location-level trend deltas (which location improved most, etc.)
- Originator-role access to other locations' data
- Any change to the existing location filter behavior
- Any change to the locked color design
- Comparison against a historical baseline (e.g., "Dallas before SMAI vs. after") — that is an operational reporting task, not a product feature

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Analytics color design locked: one teal family at varying opacities, amber only on operator-actionable pipeline exposure figure, no green/coral/red. | Memory; prior session decision |
| "Regional roll-ups or cross-location analytics dashboards" explicitly excluded from MVP. | MultiTenancy Final MVP Spec, Section 9 Out of Scope |
| Location data scoping: users with specific location access never see other locations' data. Admin users with "All Locations" access can see all active locations. | MultiTenancy Final MVP Spec, Section 4–5 |
| Conversion rate definition locked: won jobs as a % of activated proposal plans for the period. | PRD-07 Analytics |
| Jobs, Needs Attention, and Analytics are the MVP operational surfaces. | CC-06 Buc-ee's MVP Definition |
| Proof-grade analytics grounded in authorized plans and recorded events. | CC-04 Pricing & Packaging Brief |
| Analytics data binding happens in Cursor, not Lovable. | Memory; prior session decision |
| "All Locations" is a virtual filter — not a database row. Per-location data is derived from querying each active location_id in the tenant. | MultiTenancy Final MVP Spec, Section 3.2 |

---

## 5. Actors and Objects

**Actors:**
- **Admin** — the only role that sees the per-location breakdown. Has "All Locations" access. Sees all active locations in the tenant.
- **Originator** — does not see the per-location breakdown. Sees only their own location's conversion rate, as today.
- **System** — computes per-location conversion rates for the active time period and serves them in the analytics response when requested.

**Objects:**
- **Conversion Rate stat block** — the first hero stat on the Analytics page. Extended by this spec with a toggleable per-location breakdown section.
- **Per-location breakdown** — the expanded section showing each active location's conversion rate as a separate figure.
- **Location** — an active location in the tenant (e.g., DFW, Boise, Reno). Corresponds to a row in the `locations` table scoped to the tenant.
- **Expand/collapse toggle** — the UI control that shows or hides the per-location breakdown. Lives within the Conversion Rate stat block.
- **Location conversion rate** — won jobs / activated plans where both the job activation and the win are attributed to a specific location_id, within the active time period.

---

## 6. Workflow Overview

**Default state (page load):**
Admin loads the Analytics page with "All Locations" active. The Conversion Rate stat block shows the aggregate rate across all locations, as today. The per-location breakdown is collapsed. A subtle expand affordance (e.g., a "By location ›" link or a chevron) is visible at the bottom of the stat block.

**Expanded state:**
Admin taps the expand affordance. The stat block expands to reveal a list of per-location rows, each showing the location name and its conversion rate for the active time period. The aggregate figure remains visible above the breakdown. The funnel, originator table, and follow-up activity chart do not change.

**Interplay with time period filter:**
When the operator changes the active time period (e.g., from Last 90 Days to Month to Date), all per-location rates recalculate for the new period. The breakdown stays expanded if it was expanded — it does not collapse on filter change.

**Interplay with location filter:**
The per-location breakdown is only available when "All Locations" is selected. If the operator switches the location filter to a specific location (e.g., "DFW"), the stat block returns to single-location mode and the expansion toggle is hidden. If they switch back to "All Locations," the expansion toggle reappears and the breakdown can be re-expanded.

**Single-location filter (Originator role or specific location selected):**
No expansion toggle is shown. The stat block renders as today — one rate figure, one sub-label, one trend delta, plus the MTD/YTD dual display from SPEC-05.

---

## 7. States and Transitions

The Conversion Rate stat block has three states under this spec:

| State | Condition | What is shown |
|-------|-----------|---------------|
| Single-location | Specific location selected, or Originator-role user | Aggregate rate for that location. No expand toggle. MTD/YTD from SPEC-05. |
| All-locations collapsed (default) | Admin, "All Locations" active, breakdown not expanded | Aggregate rate for all locations combined. Expand toggle visible. MTD/YTD from SPEC-05. |
| All-locations expanded | Admin, "All Locations" active, breakdown expanded | Aggregate rate above. Per-location breakdown below. Collapse toggle visible. |

**Transitions:**

| From | Trigger | To |
|------|---------|-----|
| All-locations collapsed | Admin taps expand toggle | All-locations expanded |
| All-locations expanded | Admin taps collapse toggle | All-locations collapsed |
| All-locations expanded | Admin changes location filter to specific location | Single-location (breakdown hidden) |
| Single-location | Admin changes location filter to "All Locations" | All-locations collapsed (expansion does not persist across filter change) |
| All-locations (either) | Admin changes time period filter | Same state, per-location rates recalculate |

---

## 8. Detailed Behavior

### 8.1 Expand/Collapse Toggle

**Placement:** Below the MTD/YTD dual display (added by SPEC-05) within the Conversion Rate stat block.

**Collapsed state label:** "By location ›" or equivalent — a text link or chevron affordance that signals expandability. Low visual weight. Does not compete with the hero figure.

**Expanded state label:** "By location ∨" or equivalent — same affordance with direction indicator flipped.

**Visibility rules:**
- Shown only to Admin-role users.
- Shown only when "All Locations" is the active location filter.
- Hidden in all other conditions. The stat block shows no expansion affordance and no blank space where it would be.

**Tap target:** The entire "By location ›" row is tappable. Minimum tap target height follows existing interactive element standards in the product.

### 8.2 Per-Location Breakdown Layout

When expanded, the Conversion Rate stat block reveals a breakdown section below the existing content. The aggregate figure and MTD/YTD display remain visible above.

**Layout of the breakdown section:**

```
────────────────────────────────
CONVERSION RATE
34%
Won jobs as a % of activated proposals
↑ 8 pts vs prior period

MTD    YTD
28%    34%

By location ∨
────────────────────────────────
DFW              48%  ████████████░░░  
Boise            36%  █████████░░░░░░  
Reno             36%  █████████░░░░░░  
────────────────────────────────
```

**Per-location row elements:**
- Location name (short name, e.g., "DFW," "Boise," "Reno" — from `locations.name`)
- Conversion rate percentage for that location in the active time period
- A horizontal bar showing the rate proportionally (bar length scales to the highest rate among all visible locations, so the top performer fills most of the bar width and others are proportional to it)
- No rank numbers or labels like "1st," "2nd" — order is by conversion rate descending (highest first)

**Bar design:**
- Single teal color at standard opacity — same teal used in the Originator Performance close rate bars already visible on the page
- Bar track (unfilled background): light neutral, matching the existing bar track style on the page
- No separate color for underperforming locations. No red, no amber, no green. All bars are teal, varying in length only.
- Bar width is proportional: the highest-rate location's bar fills approximately 80% of the available width. All other bars scale from that.

**Location ordering:** Descending by conversion rate for the active period. Ties are broken alphabetically by location name.

**Location count:** All active locations in the tenant are shown. There is no cap. For Jeff's current three locations (DFW, Boise, Reno) this is a three-row list. For future tenants with more locations, the list grows. No pagination required for typical multi-location operators (who will have 2–15 locations).

**Rate display:** Percentage rounded to the nearest whole number. No decimal places. Consistent with the existing Conversion Rate hero figure format.

**Zero-denominator handling:** If a location has no activated plans in the active period, show "—" instead of a percentage. The bar is absent (not shown as a zero-length bar). The location row still appears with its name and "—" to make clear the location is active but has no data for this period.

### 8.3 No Changes to Other Analytics Sections

The following are explicitly not changed by this spec, even when the per-location breakdown is expanded:

- The aggregate Conversion Rate hero figure — still shows the all-locations aggregate
- The trend delta — still shows the prior-period delta for the aggregate
- The MTD/YTD dual display — still shows all-locations MTD and YTD rates
- The funnel section (Where Jobs Are Won and Lost)
- The Originator Performance table
- The Follow-Up Activity section and bar chart

None of these sections change when the per-location breakdown is expanded or collapsed. The breakdown is additive to the stat block only.

### 8.4 Interplay with SPEC-05 (MTD/YTD)

The MTD/YTD dual display from SPEC-05 shows all-locations MTD and YTD rates. The per-location breakdown from this spec shows rates for the active time period filter. These are intentionally different:

- MTD/YTD = always-on, always all-locations rates for those two fixed periods
- Per-location breakdown = rates for the active filter period, broken out by location

If an operator wants to see per-location rates for MTD, they select "Month to Date" as the active filter period and expand the breakdown. The per-location rows will then show MTD rates for each location. This is correct and intended behavior.

**There is no per-location MTD/YTD dual display.** The MTD and YTD figures in SPEC-05 are always all-locations aggregates. Adding per-location MTD and YTD figures is out of scope.

---

## 9. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| Admin-only | The expand toggle and per-location breakdown are never shown to Originator-role users. Role enforcement is at both the UI layer (toggle hidden) and the API layer (per-location data not returned for non-admin requests). |
| "All Locations" only | The expand toggle is shown only when "All Locations" is the active location filter. When a specific location is selected, the toggle disappears. |
| Locked color design | All bars are teal. No location is highlighted in amber, green, red, or any other color. Amber remains exclusively for the pipeline exposure figure. |
| Aggregate remains visible | The aggregate rate, sub-label, trend delta, and MTD/YTD figures are never hidden when the breakdown is expanded. They remain above the breakdown section. |
| Descending sort by rate | Locations ordered highest-to-lowest conversion rate for the active period. Ties broken alphabetically. |
| Zero denominator = "—" | No activated plans in period = "—" not "0%." Bar absent for that location. |
| Session-persistent expand state | Expansion state persists for the current session. Returns to collapsed on fresh page load. No backend persistence. |
| No filter-driving | Tapping a location row in the breakdown does not change the active location filter. The breakdown is read-only. |
| Per-location rates respect active time period | When the time period filter changes, per-location rates recalculate. The breakdown stays expanded. |
| No per-location trend delta | Per-location rows show the location name, its rate for the active period, and a proportional teal bar. No trend delta, no period-over-period comparison, no prior-period figure is shown per location. The trend delta in the stat block is the aggregate (all-locations) delta only. |
| No additional sections broken out by location | Only the Conversion Rate stat expands by location. All other analytics sections remain all-locations aggregate or single-location based on the filter. |

---

## 10. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| Tenant has only one location | The expand toggle is shown (Admin with "All Locations" selected) but the breakdown shows only one row. This is slightly redundant but not harmful. The toggle can optionally be hidden if only one active location exists — engineering decision. |
| All locations have zero activated plans for the active period | All rows show "—." No bars shown. The breakdown section renders with location names and dashes. No error. |
| One location has data, others do not | Locations with data show rate and bar. Locations without data show "—" and no bar. Mixed display is correct. |
| Backend returns per-location data slowly | Show a loading skeleton on the breakdown section while the data loads. Do not block the aggregate stat from rendering — show the aggregate immediately and load the breakdown separately if needed. |
| Location is deactivated mid-session | On next data refresh, deactivated locations no longer appear in the breakdown. No special handling needed — the list reflects active locations only. |
| Very long location name | Truncate with ellipsis at a reasonable character limit (approximately 20 characters for short names, truncate longer names). Hover or tap reveals full name if needed — engineering decision on tooltip behavior. |
| 10+ locations in the breakdown | The list grows. No pagination for v1. If a tenant has more than 10–15 active locations, the stat block becomes tall. This is acceptable for v1. Pagination or a "show fewer" collapse can be added later. |
| Operator expands breakdown, then changes time period filter | Breakdown stays expanded. Per-location rates recalculate for the new period. Smooth UX — no collapse/re-expand required. |
| Operator expands breakdown, switches to specific location, switches back to All Locations | Breakdown returns to collapsed state. The operator must re-expand. This prevents a confusing state where the breakdown appears but is stale from a prior all-locations view. |

---

## 11. UX-Visible Behavior

### Conversion Rate stat block — all-locations collapsed (default)

| Element | Visible |
|---------|---------|
| Stat label | CONVERSION RATE |
| Hero figure | Aggregate rate for active period |
| Sub-label | "Won jobs as a % of activated proposals" |
| Trend delta | "↑ X pts vs prior period" |
| MTD/YTD display | MTD [rate] / YTD [rate] (from SPEC-05) |
| Expand toggle | "By location ›" — visible to Admin only when "All Locations" active |

### Conversion Rate stat block — all-locations expanded

| Element | Visible |
|---------|---------|
| Stat label | CONVERSION RATE |
| Hero figure | Aggregate rate for active period (unchanged) |
| Sub-label | "Won jobs as a % of activated proposals" (unchanged) |
| Trend delta | "↑ X pts vs prior period" (unchanged) |
| MTD/YTD display | MTD [rate] / YTD [rate] (unchanged from SPEC-05) |
| Collapse toggle | "By location ∨" |
| Per-location rows | Location name / Rate / Teal bar — one row per active location, sorted descending |
| Zero-data location | Location name / "—" / No bar |

### Conversion Rate stat block — specific location selected or Originator role

| Element | Visible |
|---------|---------|
| All elements above toggle | Unchanged (single-location rate) |
| Expand toggle | Hidden — not shown, no blank space |
| Per-location breakdown | Not shown |

---

## 12. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Computing per-location conversion rates for the active time period | smai-backend (Mark) |
| Enforcing that per-location data is only returned for Admin-role requests | smai-backend (Mark) |
| Returning per-location breakdown as part of the analytics API response (or via a separate endpoint call) | smai-backend (Mark) |
| Rendering the expand/collapse toggle | Frontend |
| Rendering the per-location breakdown rows with bars | Frontend |
| Computing bar widths proportionally from the per-location rate data | Frontend |
| Managing session-persistent expand state | Frontend |
| Hiding the toggle for Originator-role users | Frontend (with role check from session/auth context) |
| Hiding the toggle when a specific location is selected | Frontend |
| Recalculating per-location data when the time period filter changes | Triggered by frontend re-fetch; computed by backend |
| Maintaining locked color design | Frontend |

**Engineering decision (not product scope):** Whether per-location rates are returned in the main analytics API response as an array (recommended) or fetched via a separate endpoint call when the user expands the breakdown is Mark's decision. The main analytics response already includes location context. Product preference is that per-location rates are in the primary response to avoid a loading delay on expand, but a separate call is acceptable if it does not cause visible lag.

---

## 13. Implementation Slices

### Slice A — Backend: Per-location conversion rate computation
**Purpose:** Compute conversion rate per active location for the active time period and serve it in the analytics response.
**Components touched:** Analytics API endpoint; conversion rate query logic.
**Key behavior:** When the requesting user has Admin role and "All Locations" access, the analytics response includes a `per_location_rates` array. Each element contains: `location_id`, `location_name` (short name), `conversion_rate` (float 0–1, or null if zero denominator), `activated_plans_count`, `won_count`. Array is sorted by conversion_rate descending, nulls last.
**Dependencies:** Existing conversion rate calculation logic. Location data model.
**Excluded:** Frontend. Single-location behavior is unchanged.

### Slice B — Frontend: Expand/collapse toggle on Conversion Rate stat
**Purpose:** Add the expand/collapse affordance to the Conversion Rate stat block.
**Components touched:** Conversion Rate stat block component on Analytics page.
**Key behavior:** Render "By location ›" toggle below the MTD/YTD display (from SPEC-05) when: (a) user role is Admin AND (b) active location filter is "All Locations." Toggle is hidden in all other conditions. Tapping toggle changes local expanded state. Session-persistent. Returns to collapsed on fresh page load.
**Dependencies:** Role context available in session. Location filter state accessible to the component. Slice A complete (so data is available on expand).
**Excluded:** Per-location rows (Slice C). Backend.

### Slice C — Frontend: Per-location breakdown rows
**Purpose:** Render the per-location rate rows when the stat is expanded.
**Components touched:** Conversion Rate stat block component — breakdown section.
**Key behavior:** Read `per_location_rates` from the analytics API response. Render one row per location: name, rate as percentage (whole number, rounded), proportional teal bar. Show "—" and no bar if rate is null. Sort descending by rate (already sorted by backend, frontend preserves order). Recalculate proportional bar widths from the data set (highest rate = widest bar at ~80% of available width, others proportional). Handle loading state with skeleton.
**Dependencies:** Slices A and B complete.
**Excluded:** Toggle behavior. Backend.

---

## 14. Acceptance Criteria

**Given** an Admin user on the Analytics page with "All Locations" active,
**When** the Conversion Rate stat block renders,
**Then** a "By location ›" toggle is visible below the MTD/YTD display. The aggregate rate, trend delta, and MTD/YTD figures are visible above it.

**Given** an Admin user who taps "By location ›",
**When** the breakdown expands,
**Then** per-location rows appear below the toggle, one per active location. Each row shows the location name, its conversion rate for the active period as a whole-number percentage, and a proportional teal bar. The highest-rate location has the widest bar. All bars are teal — no other colors used.

**Given** an Admin with the breakdown expanded who changes the time period filter to "Month to Date",
**When** the page updates,
**Then** the per-location rates recalculate for the MTD window. The breakdown remains expanded. The aggregate hero figure and MTD/YTD display also update. The breakdown did not collapse.

**Given** an Admin with the breakdown expanded who changes the location filter to "DFW",
**When** the page updates,
**Then** the stat block returns to single-location mode. The expand toggle disappears. The breakdown section is not shown. No blank space is left where the breakdown was.

**Given** an Admin who switches from "DFW" back to "All Locations",
**When** the page updates,
**Then** the stat block returns to collapsed all-locations mode. The "By location ›" toggle is visible. The breakdown is collapsed — the previous expanded state does not persist across location filter changes.

**Given** an Originator-role user on the Analytics page,
**When** the Conversion Rate stat block renders,
**Then** no expand toggle is visible. The stat block shows only the single-location rate for the originator's location, the trend delta, and the MTD/YTD display from SPEC-05. No other locations' data is accessible.

**Given** a location in the breakdown with no activated plans in the active period,
**When** the breakdown renders,
**Then** that location's row shows its name and "—" with no bar. The row is present — the location is not hidden.

**Given** a fresh page load after the operator had previously expanded the breakdown,
**When** the page renders,
**Then** the breakdown starts in the collapsed state. The operator must re-expand.

**Given** the per-location breakdown is expanded and all bars are rendered,
**When** a designer reviews the color palette,
**Then** all bars are the same teal color at standard opacity. No location is shown in a different color (no red for low performers, no green for high performers). The design language matches the existing Originator Performance close rate bars.

**Given** the backend returns null for a location's conversion rate (zero activated plans),
**When** the frontend renders that location's row,
**Then** it shows "—" not "0%." No bar is rendered for that location.

---

## 15. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Per-location rates in primary response vs. separate call | Engineering decision | Product preference is primary response inclusion to avoid load delay on expand. Mark decides based on query complexity and response size. If a separate call is used, the breakdown section shows a loading skeleton on expand until the call resolves. |
| Canonical distinction from excluded "cross-location dashboard" | Confirmed interpretation | The MultiTenancy spec excludes "cross-location analytics dashboards." This spec adds a within-stat-block, within-existing-screen, within-existing-filter-state breakdown of one metric. It is structurally not a new dashboard. However, Kyle should confirm this interpretation is aligned before build begins — if there is any ambiguity on what "cross-location dashboard" means in the governing doc, clarify it before marking this spec as approved. |
| Single-location tenant behavior | Engineering decision | If a tenant has exactly one active location, the "By location ›" toggle is mildly redundant. Frontend agent and Kyle can decide: (a) show it anyway (consistent, no special-casing), (b) hide it when only one location exists. Option (a) is simpler. |
| Bar width proportional ceiling | Engineering decision | Spec states ~80% of available width for the highest-rate bar. Frontend agent can adjust this to fit the visual design. The key constraint is that bars are proportional to each other, not that 80% is a hard number. |
| Tooltip on truncated location names | Engineering decision | If a location name is truncated with ellipsis, a tap/hover tooltip showing the full name is reasonable UX. Implementation is at the frontend agent's discretion. |
| Role check for toggle visibility | Assumption | Assumes role is available in the session/auth context accessible to the frontend without an additional API call. If not, confirm with Mark how role is surfaced to the frontend. |

---

## 16. Out of Scope

- Per-location breakdown for any stat other than Conversion Rate
- Per-location breakdown for the funnel section, originator table, or follow-up activity chart
- A new cross-location analytics page or dashboard
- Regional groupings or hierarchical location roll-ups
- Per-location MTD and YTD figures (MTD/YTD from SPEC-05 are always all-locations aggregates)
- Location-level trend deltas or period-over-period comparison per location
- Tapping a location row to filter the rest of the page to that location
- Ranking labels ("1st," "2nd," "3rd") on location rows
- Color-coding of locations by performance (all bars are teal — no red for low, no green for high)
- Pagination of the per-location list
- Originator-role access to other locations' data under any condition
- Backend persistence of the expand/collapse state
- Any change to how the existing location filter works
- Any change to the locked color design
