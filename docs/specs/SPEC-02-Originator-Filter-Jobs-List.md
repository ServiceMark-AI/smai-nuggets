# SPEC-02: Originator Filter on Jobs List

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Originator Filter on Jobs List |
| Spec ID | SPEC-02 |
| Version | 1.0 |
| Status | Ready for build |
| Date | 2026-04-08 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | April 6 Jeff demo session; Lovable UI audit April 8 |
| Related docs | PRD-05 Jobs List; CC-06 Buc-ee's MVP Definition; SPEC-03 Job Type Sub-Categories; SPEC-08 Office Location Display Bug |

---

## 1. What This Is in Plain English

The Jobs List currently lets users filter by location and by status. It does not let them filter by who created the job. Every job card already shows the originator's name inline, so the data is there — but there is no way to isolate one originator's jobs from the list.

Jeff's use case is direct: he has multiple estimators (Arturo, Joe, and others) logging jobs across his Dallas location. He needs to be able to pull up just Arturo's jobs, or just Joe's jobs, to review their pipeline, coach on follow-up behavior, and track individual conversion performance. Without this filter, the Jobs List is useful for a solo operator but not for a manager overseeing a team.

This spec adds an Originator filter dropdown to the Jobs List filter bar, sitting alongside the existing Location and Status filters. It filters the list to jobs created by the selected originator. It does not change how jobs are created, what data is stored, or any other screen.

---

## 2. What Builders Must Not Misunderstand

1. **"Originator" is the controlled term for the user role that creates jobs, in UI-visible strings only.** The rule applies to operator-facing surfaces: filter labels, dropdown options, badges, toast copy, placeholder text, column headers, and any other string a user reads on screen. The filter must be labeled "Originator" to match the terminology used everywhere else in the product UI. This rule does not govern spec prose, PRD prose, engineering documentation, commit messages, or code identifiers, where "operator" and "user" are acceptable.

2. **The filter is scoped to the currently selected location.** If "All Locations" is selected, the Originator dropdown shows all originators across all locations. If a specific location is selected, the Originator dropdown shows only originators associated with that location. The two filters work together, not independently.

3. **The Originator dropdown is populated from active users in the tenant, not from job data.** Do not build this by scanning jobs to find unique originator names. Pull from the user list for the tenant (filtered by location if a location is selected). This ensures originators with zero jobs in the current filter period still appear as options.

4. **Admin users see all originators. Originator-role users see only themselves.** An originator logging in should not be able to filter to another originator's jobs. The dropdown is present for Admin role users only. For Originator-role users, the filter is either hidden or locked to their own name with no ability to change it.

5. **"All Originators" is the default selection.** The filter defaults to showing all jobs, matching the current behavior. No jobs are hidden on page load.

6. **This filter does not affect the Needs Attention screen.** Needs Attention has its own location filter. Originator filtering on Needs Attention is out of scope for this spec.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Jeff's day-one requirement from the April 6 session: "we need that sector filter by person." Confirmed as a hard requirement before go-live, not a post-launch enhancement.

**What this covers:**
- Originator filter dropdown on the Jobs List filter bar
- Filter behavior: narrows the job list to jobs where the originator matches the selected user
- Interaction between the Originator filter and the existing Location filter
- Role-based visibility: Admin sees the filter with all options; Originator sees only their own name (or filter is hidden)
- Default state: "All Originators" selected, all jobs visible
- Empty state: when no jobs exist for the selected originator + location + status combination

**What this does not cover:**
- Originator filtering on Needs Attention screen
- Originator filtering on Analytics (the Originator Performance table already breaks down by originator)
- Any changes to how originator is assigned to a job (always the logged-in user at creation time)
- Sorting the Jobs List by originator
- Any new originator-level permissions or data visibility rules beyond what is described here

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Controlled terminology: "Originator" is the role name. Not "user," "operator," or "estimator." | Decision Ledger |
| Three roles in v1: Admin, Manager, Originator. Manager is suppressed from UI but present in DB enum. | Locked decision; memory |
| Every job is attributed to the logged-in user at creation time. OBO (on behalf of) is not in scope for v1. | Locked decision; CC-06 |
| Jobs, Needs Attention, and Analytics are the MVP operational surfaces. Jobs List filter changes are in scope. | CC-06 Buc-ee's MVP Definition |
| Admin and Originator roles are active in v1. Manager is dormant. | Locked decision |
| The location filter ("All Locations" dropdown) already exists on the Jobs List and must not be broken. | UI audit April 8 |
| The status filter ("All Statuses" dropdown) already exists and must not be broken. | UI audit April 8 |

---

## 5. Actors and Objects

**Actors:**
- **Admin** — sees the full Originator filter with all originators in the tenant (scoped by selected location). Can filter to any originator's jobs.
- **Originator** — sees a locked or hidden Originator filter. Can only see their own jobs. Cannot view another originator's job list.
- **Manager** — suppressed in v1 UI. No behavior to define here.
- **System** — populates the Originator dropdown from the tenant user list, filtered by location if a location is active.

**Objects:**
- **Jobs List** — the screen this spec modifies.
- **Filter bar** — the row containing Location, Status, and now Originator filters.
- **Originator dropdown** — the new filter control.
- **Job record** — contains originator_id (the user who created the job). Already stored. Not modified by this spec.
- **User record** — contains name, role, and associated location(s). Source for populating the dropdown.

---

## 6. Workflow Overview

**Admin workflow:**
1. Admin opens Jobs List. Filter bar shows: Location | Originator | Status. Originator defaults to "All Originators."
2. Admin selects a location (e.g., "DFW"). The Originator dropdown updates to show only originators associated with DFW.
3. Admin selects an originator (e.g., "Arturo Mendez"). The job list filters to show only Arturo's jobs at the DFW location with the current status filter applied.
4. Admin can combine all three filters freely. The list updates on each filter change.
5. Admin clears originator filter back to "All Originators." Full list (within location and status filter) returns.

**Originator workflow:**
1. Originator opens Jobs List. The Originator filter either shows their own name locked (no dropdown interaction) or is not visible as a filter control.
2. The list shows only their own jobs, as it does today. No change to their experience beyond possibly seeing their own name as a non-interactive label.

---

## 7. States and Transitions

The Originator filter has three states:

| Filter state | Condition | List behavior |
|-------------|-----------|---------------|
| All Originators (default) | No originator selected | Shows all jobs matching location + status filters |
| Specific originator selected | Admin has chosen one originator | Shows only jobs where originator_id matches selected user |
| Locked / hidden | Logged-in user is Originator role | Shows only the logged-in user's jobs; filter control reflects this or is absent |

**Filter interaction rules:**

| Location filter | Originator filter | Result |
|----------------|-------------------|--------|
| All Locations | All Originators | All jobs in tenant |
| All Locations | Specific originator | All jobs by that originator across all locations |
| Specific location | All Originators | All jobs at that location |
| Specific location | Specific originator | Jobs by that originator at that location |
| Specific location | Specific originator | + Status filter applied on top |

---

## 8. Detailed Behavior

### 8.1 Filter Bar Layout

**Current layout:**
```
[Search jobs...]          [All Statuses ▼]
```
Location filter is in the sidebar header (top left, "All Locations" dropdown), not in the filter bar row.

**New filter bar layout:**
```
[Search jobs...]    [All Originators ▼]    [All Statuses ▼]
```

The Originator filter sits between the search field and the Status filter. This maintains visual left-to-right scoping logic: search narrows by text, originator narrows by person, status narrows by job state.

Note: Location filter remains in the sidebar header where it currently lives. Do not move it.

### 8.2 Originator Dropdown — Admin

**Default label:** "All Originators"

**Dropdown options (when All Locations is selected):**
```
All Originators          ← always first, clears filter
─────────────────
[Avatar initials]  Arturo Mendez    DFW
[Avatar initials]  Joe Williams     DFW
[Avatar initials]  Sarah Chen       Houston
[Avatar initials]  Marcus Johnson   Atlanta
...all active originators in tenant, alphabetical by first name
```

**Dropdown options (when a specific location is selected, e.g., DFW):**
```
All Originators
─────────────────
[Avatar initials]  Arturo Mendez    DFW
[Avatar initials]  Joe Williams     DFW
```
Only originators whose primary location matches the selected location appear.

**Originator display format in dropdown:** "[First name] [Last name]" with location name as secondary text. The location name shown as secondary text follows the same display priority rule defined in SPEC-08 §7.1: `locations.display_name` if non-null and non-empty, else `locations.name`. Never the raw `location_id` or slug. Use the same avatar initial chip style already used in the Originator Performance table on Analytics.

**After selection:** Dropdown label updates to show the selected originator's name (e.g., "Arturo Mendez"). A clear/reset indicator (×) appears on the chip to return to "All Originators."

### 8.3 Originator Dropdown — Originator Role

**Option A (preferred):** Hide the Originator filter entirely for Originator-role users. The Jobs List already scopes to their own jobs by default based on their session. Adding a filter control they cannot interact with creates confusion.

**Option B:** Show the filter but lock it to the logged-in user's name with no dropdown interaction.

**Engineering decision:** Choose Option A or B based on what is simpler to implement correctly. Product preference is Option A. Either is acceptable for v1.

### 8.4 Filter Application

- Filters apply immediately on selection. No "Apply" button required.
- All three active filters (location, originator, status) are applied as AND conditions. A job must match all active filters to appear.
- Filter state persists for the session. If an Admin navigates to Job Detail and returns to Jobs List, the originator filter they set should still be active.
- Filter state does not persist across sessions. Fresh login returns to default (All Originators).

### 8.5 Empty State

When the combination of active filters returns zero jobs:

```
No jobs found
Try adjusting your filters or create a new job.
```

Same empty state pattern used for other zero-result filter combinations. No special originator-specific messaging needed.

---

## 9. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| Label must be "Originator" | Controlled terminology. No variations. |
| Admin sees all, Originator sees self | Role-based scoping is enforced server-side, not just in the UI. An Originator-role API request must not return other originators' jobs regardless of what filter parameters are sent. |
| Default is "All Originators" | No jobs are hidden on page load for Admin users. |
| Location filter scopes the Originator dropdown | When DFW is selected, only DFW originators appear in the dropdown. The dropdown updates reactively when location changes. |
| Originator dropdown populated from user list, not job data | Source is the tenant user list filtered by role (Originator) and location (if selected). Not derived from scanning job records. |
| Filter interaction is AND, not OR | A job must match every active filter to appear. |
| No server-side filter bypass | Role enforcement happens at the API layer. Frontend filter state is cosmetic enforcement only; backend must also enforce. |

---

## 10. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| Selected originator has no jobs in current location + status combination | Empty state shown. No error. |
| Originator is deactivated/deleted while filter is set to them | On next data refresh, their jobs may still appear (jobs are not deleted when a user is deactivated). Filter option for that user is removed from the dropdown going forward. |
| Tenant has only one originator | Dropdown shows "All Originators" and that one originator. Filter is functional but minimally useful. No special handling. |
| Location filter changes after an originator is selected | If the newly selected location does not include the current originator filter selection, reset the originator filter to "All Originators" and show a brief indicator that the filter was cleared (e.g., the dropdown briefly highlights or the label returns to default). Do not silently show a zero-result list without explanation. |
| Originator filter set to a user who has no access to the selected location | Should not occur if the dropdown is correctly scoped. If it does occur due to a data inconsistency, return an empty state, not an error. |
| API returns originator list slowly | Show the dropdown in a loading state (spinner or skeleton) rather than an empty dropdown. Do not show the filter as broken. |
| User is both Admin and has jobs | Admin users see all originators including themselves. Their own jobs are not specially marked. |

---

## 11. UX-Visible Behavior

### Filter bar — default state (Admin, All Locations, All Originators)

| Element | Visible |
|---------|---------|
| Search field | "Search jobs..." placeholder |
| Originator filter | "All Originators ▼" dropdown |
| Status filter | "All Statuses ▼" dropdown |

### Filter bar — originator selected

| Element | Visible |
|---------|---------|
| Originator filter label | "[Originator name]" with × clear control |
| Job list | Filtered to that originator's jobs within active location and status filters |

### Filter bar — Originator role user

| Element | Visible |
|---------|---------|
| Originator filter | Hidden (Option A) or locked to user's own name (Option B) |
| Job list | User's own jobs only, unchanged from current behavior |

### Dropdown open state

| Element | Visible |
|---------|---------|
| First option | "All Originators" (bold or highlighted if currently selected) |
| Divider | Horizontal rule below "All Originators" |
| Originator rows | Avatar chip + full name + location name, alphabetical |
| Originator in current location | Full list if All Locations; scoped list if specific location |

### Empty state

| Element | Visible |
|---------|---------|
| Message | "No jobs found" |
| Sub-message | "Try adjusting your filters or create a new job." |
| New Job button | Present in top-right header, unchanged |

---

## 12. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Enforcing role-based job scoping at the API layer (Originator sees only own jobs) | smai-backend (Mark) |
| Exposing a tenant user list endpoint filterable by role and location | smai-backend (Mark) |
| Accepting originator_id as a filter parameter on the jobs list endpoint | smai-backend (Mark) |
| Rendering the Originator filter dropdown | Frontend |
| Populating the dropdown from the user list API | Frontend |
| Reactively updating the dropdown when location filter changes | Frontend |
| Applying the originator filter parameter to the jobs list API request | Frontend |
| Persisting filter state for the session | Frontend |
| Clearing originator filter when location changes to incompatible selection | Frontend |

**Engineering decision (not product scope):** Whether the jobs list endpoint accepts originator_id as a query parameter or whether this is handled via a separate filter mechanism is Mark's call. Product requires that the filtered result set is computed server-side, not by hiding rows client-side after fetching all jobs.

---

## 13. Implementation Slices

### Slice A — Backend: originator_id filter parameter on jobs list endpoint
**Purpose:** Allow the jobs API to accept and apply an originator filter server-side.
**Components touched:** smai-backend jobs list endpoint.
**Key behavior:** When originator_id is passed as a query parameter, return only jobs where the originator matches. Respect existing role-based scoping (Originator-role requests cannot override their own scope by passing another user's ID).
**Dependencies:** Existing jobs list endpoint. Existing role enforcement.
**Excluded:** Frontend. User list endpoint.

### Slice B — Backend: tenant user list endpoint scoped by role and location
**Purpose:** Provide the frontend with the list of originators to populate the dropdown.
**Components touched:** smai-backend users endpoint (existing or new).
**Key behavior:** Return active users with Originator role for the tenant. Accept optional location_id parameter to scope to a specific location. Return: user_id, display name, location name, avatar initials or color.
**Dependencies:** Existing user/tenant data model.
**Excluded:** Frontend. Job filtering.

### Slice C — Frontend: Originator filter dropdown component
**Purpose:** Render the Originator filter in the Jobs List filter bar.
**Components touched:** Jobs List filter bar; new Originator dropdown component.
**Key behavior:** Fetch user list from Slice B endpoint. Render dropdown with "All Originators" default. Update dropdown options when location filter changes. Show avatar chip + name + location in each row. Update filter label on selection. Show × clear control when active.
**Dependencies:** Slices A and B complete.
**Excluded:** Role enforcement (handled by backend). Session persistence.

### Slice D — Frontend: Role-based filter visibility
**Purpose:** Hide or lock the Originator filter for Originator-role users.
**Components touched:** Jobs List filter bar; Originator dropdown component.
**Key behavior:** If logged-in user role is Originator, apply Option A (hide) or Option B (lock). Jobs List API request automatically scopes to the logged-in user's jobs via existing role enforcement — no filter parameter needed.
**Dependencies:** Slice C complete. Role data available in session/auth context.
**Excluded:** Any changes to job data scoping logic (already handled by backend).

---

## 14. Acceptance Criteria

**Given** an Admin user on the Jobs List with "All Locations" and "All Originators" selected,
**When** the page loads,
**Then** all jobs in the tenant are visible, and the Originator filter dropdown shows "All Originators" as the active selection.

**Given** an Admin user who selects "DFW" in the Location filter,
**When** they open the Originator dropdown,
**Then** only originators associated with the DFW location are shown as options.

**Given** an Admin user who selects "Arturo Mendez" in the Originator filter with "DFW" location active,
**When** the filter is applied,
**Then** only jobs where originator is Arturo Mendez AND location is DFW are shown. Jobs by other originators at DFW are not shown.

**Given** an Admin user with "Arturo Mendez" selected in the Originator filter,
**When** they change the Location filter to a location where Arturo has no association,
**Then** the Originator filter resets to "All Originators" and the job list shows all jobs at the new location.

**Given** an Admin user with an originator filter active that produces zero results,
**When** the list renders,
**Then** the empty state "No jobs found / Try adjusting your filters or create a new job." is shown. No error occurs.

**Given** an Originator-role user on the Jobs List,
**When** the page loads,
**Then** the Originator filter is hidden (Option A) or locked to their own name (Option B). The list shows only their own jobs. No other originator's jobs are visible regardless of what filter parameters are manipulated client-side.

**Given** an Originator-role user who attempts to pass another user's originator_id to the jobs API directly,
**When** the request is processed,
**Then** the backend returns only the requesting user's jobs, ignoring the override attempt.

**Given** an Admin user who selects an originator and navigates to a Job Detail screen and then returns to Jobs List,
**When** they return,
**Then** the Originator filter is still set to the originator they selected before navigating away.

---

## 15. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Jobs list endpoint currently supports originator_id filter | Assumption | If not currently supported, Slice A is required before any frontend work can proceed. Frontend agent must confirm with Mark. |
| User list endpoint exists and returns role + location data | Assumption | If no such endpoint exists, Slice B must be built. Frontend agent must confirm with Mark. |
| Option A vs Option B for Originator-role filter visibility | Engineering decision | Product preference is Option A (hide). Either is acceptable. Mark and frontend agent decide based on implementation simplicity. |
| Avatar color/initials generation | Engineering decision | Use same pattern as Originator Performance table on Analytics if one exists. If not, use initials from first + last name with a deterministic color assignment. |
| Location-to-originator association data model | Assumption | Assumes a user has a primary location stored on their record. If originators can be associated with multiple locations, the scoping logic for the dropdown needs clarification from Mark before Slice B is built. |
| Filter state persistence across sessions | Out of scope for v1 | Session-only persistence is sufficient. localStorage or similar is not required. |

---

## 16. Out of Scope

- Originator filter on Needs Attention screen
- Originator filter on Analytics (Originator Performance table already provides this)
- Sorting the Jobs List by originator name
- Multi-select originator filter (select more than one originator at a time)
- Any change to how originator is assigned to a job at creation time
- On-behalf-of (OBO) job creation — explicitly cut from v1
- Manager role behavior — Manager is suppressed in v1 UI
- Any new originator-level data visibility permissions beyond what is described here
