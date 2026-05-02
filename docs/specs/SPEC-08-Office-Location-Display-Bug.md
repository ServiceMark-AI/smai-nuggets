# SPEC-08: Office Location Display Bug — Internal ID Leaking into Job Detail UI

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Office Location Display Bug — Internal ID Leaking into Job Detail UI |
| Spec ID | SPEC-08 |
| Version | 1.0 |
| Status | Ready for build — frontend + backend data join fix |
| Date | 2026-04-08 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | Lovable UI audit April 8 |
| Related docs | PRD-06 v1.3.1 Job Detail Screen; PRD-01 Job Record; Database Schema Final MVP Spec (Doc 11); MultiTenancy Final MVP Spec (Doc 2) |

---

## 1. What This Is in Plain English

The Job Detail screen has a "Job Details" section that shows four fields in a two-column grid: Created date, Job #, Originator, and Office. The "Office" field is supposed to show the human-readable location name — for example, "Atlanta" or "DFW."

Instead it is showing the internal location identifier: "loc-atl." That is the system's internal slug or ID for the Atlanta location, not the value that belongs in a customer-facing or operator-facing UI.

This is a data join bug. The job record stores a `location_id` — a foreign key reference to the `locations` table. The `locations` table has a `name` field (short label, e.g., "DFW," "Atlanta") and an optional `display_name` field (longer label). The frontend is rendering the raw `location_id` or an intermediate slug instead of joining to the locations table and using `locations.name`.

The fix is: wherever the Office field in Job Detail reads location data, it must read `locations.name` (or `locations.display_name` if populated) from the joined locations record — not the raw ID, slug, or any intermediate internal identifier.

This bug also surfaces in one other place that was visible in the UI audit: the Jobs List card shows the originator's location in small text below the originator name (e.g., "Alex Martinez · DFW"). That location label appears correct in the Jobs List. The bug is isolated to the Job Detail "OFFICE" field. Both surfaces must be confirmed as using the correct data source.

---

## 2. What Builders Must Not Misunderstand

1. **This is a data join bug, not a design change.** The layout of the Job Details section is correct. The field label ("OFFICE") is correct. Only the value being rendered is wrong. No layout, no label, and no UX pattern changes.

2. **The fix source is `locations.name`, with `locations.display_name` as a richer optional alternative.** The `locations` table has both fields. `name` is required and always present (e.g., "DFW," "Atlanta"). `display_name` is optional and nullable — it holds a longer version if configured (e.g., "Dallas–Fort Worth"). The display rule: use `display_name` if it is non-null and non-empty; otherwise use `name`. Never use the location ID, slug, or any internal identifier.

3. **The bug may be in the API response, the frontend rendering, or both.** If the jobs API response returns the raw `location_id` or slug without joining to the locations table, the bug is in the backend API response. If the API returns the correct location name but the frontend renders the ID anyway, the bug is in the frontend. This spec does not prescribe which layer is wrong — that is for Mark and the frontend agent to diagnose. It specifies the correct output regardless of where the fix lives.

4. **The fix must be applied consistently across all surfaces that display the Office/location name for a job.** The confirmed bug location is the Job Detail "OFFICE" field. Additional surfaces to confirm and fix if needed: the Jobs List card location label in the originator sub-line, the Needs Attention card (location does not appear to be displayed there currently, so likely not affected), and any other place `location_id` is resolved to a display value.

5. **No data migration is needed.** The `locations` table already has correct `name` values. The fix is a rendering/join fix, not a data correction.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Corrects a visible data rendering bug observed during the April 8 Lovable UI audit. The Job Detail screen shows "loc-atl" in the OFFICE field where it should show "Atlanta." This is a launch-blocking defect — Jeff's team cannot use the product professionally if internal IDs are leaking into operator-facing screens.

**What this covers:**
- Fixing the OFFICE field in the Job Details section of the Job Detail screen to display `locations.name` (or `display_name` if populated)
- Confirming the Jobs List card location label (in the originator sub-line) uses the correct display value and fixing it if not
- Confirming no other surfaces display raw location IDs and fixing any that do
- Defining the display priority rule: `display_name` if non-null, else `name`

**What this does not cover:**
- Changing the layout, label, or position of the OFFICE field
- Adding new location data to any screen that does not currently show it
- Editing location names (that is in Account/Organization Settings, unchanged by this spec)
- Any change to how `location_id` is stored on the job record
- Any change to the MultiTenancy filtering behavior

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| `locations` table schema: `name` (string, short label — e.g., "DFW", "Atlanta"), `display_name` (string, nullable — optional longer label). | Database Schema Final MVP Spec, Section 3.2 |
| "All Locations" is a virtual filter — not a database row. It is never a value stored on a job record. | Database Schema Final MVP Spec, Section 3.2; MultiTenancy Final MVP Spec |
| Job record stores `location_id` as a foreign key to the `locations` table. | Database Schema Final MVP Spec |
| The OFFICE field on Job Detail should display the human-readable location name, not an internal identifier. | PRD-06 Job Detail Screen; confirmed correct behavior visible on other jobs (e.g., Arthur Phillips showing "Atlanta" correctly in earlier audit screenshots) |
| The Jobs List card correctly shows location short name in the originator sub-line for existing records. | UI audit April 8 — e.g., "Marcus Johnson · Atlanta" visible in Jobs List |

---

## 5. Actors and Objects

**Actors:**
- **System (backend API)** — responsible for joining `location_id` to the `locations` table and returning the human-readable location name in job record API responses.
- **Frontend** — responsible for rendering the value returned by the API in the correct field without substituting the raw ID.

**Objects:**
- **Job record** — stores `location_id`. Does not store the location name directly.
- **`locations` table** — contains `id`, `name` (required), `display_name` (nullable). The source of truth for human-readable location labels.
- **Job Detail "OFFICE" field** — the field in the Job Details section that shows the location name. Currently displaying the raw internal identifier.
- **Jobs List card originator sub-line** — the secondary line on each job card showing "[Originator name] · [Location name] · Created [date]." Currently appears to show the correct value; needs confirmation.
- **API response for job detail** — should include a resolved `location_name` or `office` field, not a raw `location_id`.

---

## 6. Root Cause Analysis

Based on the UI audit, the most likely cause is one of two things:

**Scenario A — API response returns slug/ID instead of name:**
The job detail API response includes a `location_id` field (the raw foreign key, e.g., `"loc-atl"`) and does not include a resolved `location_name`. The frontend reads this field and displays it directly in the OFFICE field.

**Scenario B — API returns correct name for Jobs List but not for Job Detail:**
The jobs list endpoint joins to the `locations` table and returns `locations.name` correctly (explaining why "Atlanta" appears correctly in the Jobs List card). The job detail endpoint does not join to `locations` and returns only the raw `location_id`. The frontend renders whatever the job detail endpoint returns.

Either scenario requires the same fix: the job detail API response must include the resolved location name, and the frontend must render that resolved value.

**Evidence from the audit:**
- Jobs List card: "Marcus Johnson · Atlanta" — correct. Location name resolved.
- Job Detail OFFICE field: "loc-atl" — incorrect. Internal identifier leaking.

This suggests Scenario B is more likely — the jobs list endpoint joins correctly, the job detail endpoint does not.

---

## 7. Detailed Behavior

### 7.1 Correct OFFICE Field Display

**Current (broken):**
```
OFFICE
loc-atl
```

**Correct:**
```
OFFICE
Atlanta
```

Or, if `display_name` is configured for that location:
```
OFFICE
Atlanta–Downtown
```

**Display priority rule:**
1. If `locations.display_name` is non-null and non-empty for the job's location: display `display_name`.
2. Otherwise: display `locations.name`.
3. Never display `location_id`, a slug, or any internal identifier.

### 7.2 Job Detail API Response — Required Field

The job detail API response must include a resolved location label. Two acceptable approaches:

**Option A (preferred):** Include `location_name` as a top-level field in the job detail response, pre-resolved from the locations table join.

```json
{
  "id": "...",
  "location_id": "loc-atl",
  "location_name": "Atlanta",
  ...
}
```

**Option B:** Include a nested `location` object with both fields.

```json
{
  "id": "...",
  "location": {
    "id": "loc-atl",
    "name": "Atlanta",
    "display_name": null
  },
  ...
}
```

Mark decides which format. Product requirement: the resolved human-readable label is present in the response without requiring the frontend to make a separate API call.

### 7.3 Frontend Rendering Rule

The frontend reads the resolved location label from the API response and renders it in the OFFICE field. It does not apply any transformation or lookup — the API provides the display-ready value.

If the API response does not include a resolved label (i.e., the field is missing or null), the frontend shows "—" in the OFFICE field rather than the raw ID or an empty string.

### 7.4 Confirmation Sweep — Other Surfaces

The following surfaces must be checked and confirmed correct (or fixed if not) as part of this spec:

| Surface | Location label field | Current state | Required state |
|---------|---------------------|---------------|----------------|
| Job Detail — OFFICE field | `location_name` or equivalent | "loc-atl" — **broken** | "Atlanta" |
| Jobs List card — originator sub-line | Location name in "[Originator] · [Location] · [Date]" | "Atlanta" — appears correct | Confirm correct |
| Needs Attention card | Location name not currently displayed | N/A | N/A — not displayed |
| Campaign approval screen — header | "kyle smith · kyleasmith1@gmail.com" — location not shown | N/A | N/A — not displayed |
| Originator Performance table (Analytics) | Location name shown below originator name (e.g., "DFW") | Appears correct | Confirm correct |
| Analytics location filter dropdown | Location name shown as filter option | Appears correct | Confirm correct |

Only the Job Detail OFFICE field is confirmed broken. Other surfaces should be confirmed correct during the fix pass. If any additional surface is found to display a raw ID or slug, fix it as part of this spec.

---

## 8. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| Never display a raw location ID or slug | "loc-atl," "loc-dfw," or any internal identifier must never appear in any operator-facing UI surface. |
| Display priority: `display_name` over `name` | If `display_name` is non-null and non-empty, use it. Otherwise use `name`. |
| Fallback to "—" if resolved label is absent | If the API returns no resolved location label, the frontend shows "—" rather than blank or a raw ID. |
| No separate API call for location resolution | The resolved label is included in the job detail API response. The frontend does not need to make a secondary call to the locations endpoint to resolve the name. |
| No layout, label, or UX changes | The OFFICE field label, the two-column grid layout, and the Job Details section structure are all correct and unchanged. Only the value displayed is corrected. |
| Fix applies to job detail and all other confirmed-broken surfaces | The confirmation sweep in Section 7.4 identifies where to look. Fix everything found during that sweep. |

---

## 9. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| `locations.display_name` is an empty string (not null) | Treat as absent. Fall through to `locations.name`. |
| `locations.name` is absent (should not occur — required field) | Show "—" in the OFFICE field. Log a data integrity warning. |
| Job was created without a location (should not occur in v1) | Show "—" in the OFFICE field. No error. |
| Location is deactivated after job creation | The location record still exists with its name. Display the name normally. Deactivation does not remove the location record. |
| API response includes both `location_id` and `location_name` | Frontend uses `location_name`. Does not fall back to `location_id`. |
| API response includes only `location_id` (not fixed yet) | Frontend shows "—" rather than rendering the raw ID. This prevents the bug from displaying while the fix is in progress. |

---

## 10. UX-Visible Behavior

### Job Detail — Job Details section

**Current (broken):**

```
CREATED          JOB #
April 8, 2026    abc123

ORIGINATOR       OFFICE
Alex Martinez    loc-atl
```

**Correct (after fix):**

```
CREATED          JOB #
April 8, 2026    abc123

ORIGINATOR       OFFICE
Alex Martinez    Atlanta
```

No other element in the Job Details section changes. The two-column grid layout, the field labels, the Created date format, the Job # value, and the Originator name are all correct and unchanged.

---

## 11. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Joining `location_id` to `locations` table in the job detail query | smai-backend (Mark) |
| Returning the resolved location name in the job detail API response | smai-backend (Mark) |
| Applying `display_name` over `name` priority in the API response or frontend display logic | Either layer — Mark decides whether the API always returns the final display value or returns both fields for the frontend to apply the priority rule |
| Rendering the resolved location name in the OFFICE field | Frontend |
| Showing "—" when the resolved label is absent | Frontend |
| Confirming the Jobs List, Originator Performance table, and Analytics filter are using correct location names | Frontend and backend together — confirm during the fix pass |

---

## 12. Implementation Slices

### Slice A — Backend: Add resolved location name to job detail API response
**Purpose:** Include the human-readable location label in the job detail endpoint response so the frontend does not need to resolve it separately.
**Components touched:** Job detail API endpoint in smai-backend; job detail query (add join to `locations` table).
**Key behavior:** The job detail response includes `location_name` (the resolved display value applying the `display_name` over `name` priority) or a nested `location` object with `name` and `display_name`. Raw `location_id` may remain in the response for reference but must not be the only location field present.
**Dependencies:** `locations` table populated with correct `name` values for Jeff's locations. No schema change needed.
**Excluded:** Frontend rendering. Jobs list endpoint (already correct, confirm only).

### Slice B — Frontend: Render resolved location name in OFFICE field
**Purpose:** Fix the OFFICE field to display the resolved location name from the API response.
**Components touched:** Job Detail screen — Job Details section — OFFICE field.
**Key behavior:** Read `location_name` (or equivalent resolved field) from the API response. Render it in the OFFICE field. If the field is absent or null, render "—." Do not render the raw `location_id` or slug under any condition.
**Dependencies:** Slice A complete.
**Excluded:** Other surfaces. Layout changes.

### Slice C — Confirmation sweep of other surfaces
**Purpose:** Confirm that no other operator-facing surface displays a raw location ID, and fix any that do.
**Components touched:** Jobs List card originator sub-line; Originator Performance table (Analytics); Analytics location filter dropdown; any other surface identified during the sweep.
**Key behavior:** For each surface, confirm the location label displayed matches `locations.name` (or `display_name`). Document findings. Fix any that are broken.
**Dependencies:** Slice A complete (so the jobs API returns the correct data for all surfaces).
**Excluded:** Adding location display to surfaces that do not currently show it.

---

## 13. Acceptance Criteria

**Given** a Job Detail screen for any job,
**When** the Job Details section renders,
**Then** the OFFICE field displays the human-readable location name (e.g., "Atlanta," "DFW," "Houston"). No internal identifier, slug, or raw ID appears in this field.

**Given** a location record with `display_name = "Dallas–Fort Worth"` and `name = "DFW"`,
**When** the OFFICE field renders for a job at that location,
**Then** the field displays "Dallas–Fort Worth" (the `display_name` takes priority over `name`).

**Given** a location record with `display_name = null` and `name = "Atlanta"`,
**When** the OFFICE field renders for a job at that location,
**Then** the field displays "Atlanta" (falls back to `name` because `display_name` is null).

**Given** a job detail API response that does not include a resolved location label,
**When** the OFFICE field renders,
**Then** the field displays "—" rather than a raw ID, blank space, or an error.

**Given** the Jobs List, Originator Performance table, and Analytics location filter,
**When** location names are displayed on those surfaces,
**Then** all location labels show the human-readable name consistent with `locations.name` (or `display_name`). No raw IDs or slugs appear on any of these surfaces.

**Given** the Job Details section after this spec is implemented,
**When** a designer or QA reviewer compares it to the existing confirmed-correct Jobs List card,
**Then** the location name shown in the OFFICE field matches the location name shown in the originator sub-line of the Jobs List card for the same job.

---

## 14. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Bug is in job detail API response vs. frontend rendering | Must diagnose before build | Mark should check the raw job detail API response to confirm whether `location_name` is absent (Scenario B — API bug) or present but not rendered (frontend rendering bug). This determines which slice is the primary fix. If the API already returns the name correctly, Slice A scope reduces to a confirm-only. |
| `display_name` vs. `name` priority applied in API or frontend | Engineering decision | Mark decides whether the API always returns the final resolved display value (simpler for frontend) or returns both `name` and `display_name` for the frontend to apply the priority rule. Either is acceptable. |
| Jobs list endpoint confirmed correct | Assumption | Based on the UI audit showing "Atlanta" correctly on Jobs List cards, the jobs list endpoint appears to join correctly. Slice C confirms this formally. If the jobs list endpoint is also broken for some jobs (and the audit sample happened to show correct data), Slice A scope expands to fix both endpoints. |
| Jeff's location `name` values are correctly configured | Assumption | The locations for Jeff's tenant (DFW, Boise, Reno — or equivalent short names) must have `name` values that match what Jeff expects to see. If locations were created with slugs as the `name` value rather than human-readable names, the data must be corrected before the fix will show readable output. This is an SMAI operational setup task, not a code fix. |

---

## 15. Out of Scope

- Changing the layout, label, or position of the OFFICE field
- Adding location display to any surface that does not currently show it
- Editing location names (handled in Account/Organization Settings)
- Any change to how `location_id` is stored on the job record
- Any change to MultiTenancy filtering behavior
- Any change to the location selector in the sidebar navigation
- Adding a `display_name` to Jeff's location records (SMAI operational setup task if desired, not a build item)
