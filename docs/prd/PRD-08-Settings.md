# PRD-08: Settings
**Version:** 1.2  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark  
**Source truth:** Lovable FE audit (Phase 1, locked — April 5, 2026); SETTINGS-01 through SETTINGS-11 PRD tags (locked April 5, 2026); Session State v6.0; Spec 3 (Team Management and Role Permissions) [legacy out-of-repo reference; superseded by this PRD §6 through §10 (team management, roles, location assignment)]; Spec 4 (Account and Organization Settings) [legacy out-of-repo reference; superseded by PRD-10 v1.2 (account-level configuration is admin-portal scoped, not operator-facing per the managed-service posture)]; Spec 10 (Notifications) [legacy out-of-repo reference; no canonical in-repo successor; notifications are post-MVP and do not govern the launch build]; Spec 13 (Global Navigation and Routing) [legacy out-of-repo reference; no canonical in-repo successor in the active spec set; treat as deferred platform-shell concern, does not govern the launch build]; Spec 2 (Multi-Tenancy) [legacy out-of-repo reference; superseded by this PRD's role and location model and PRD-10 v1.2 admin portal tenant management]; Reconciliation Report 2026-04-16; SPEC-07 v1.1 (Originator Identity in Sent Emails); Jeff clarifications 2026-04-17 and 2026-04-18  
**Related PRDs:** PRD-01 (Job Record), PRD-07 (Analytics), PRD-02 (New Job Intake), PRD-10 (Location Configuration)  
**Tracking issues:** [#93 A endpoint + Profile card](https://github.com/frizman21/smai-server/issues/93) · [#94 B Team list](https://github.com/frizman21/smai-server/issues/94) · [#95 C Add Member](https://github.com/frizman21/smai-server/issues/95) · [#96 D Edit Member](https://github.com/frizman21/smai-server/issues/96) · [#97 E Remove Member](https://github.com/frizman21/smai-server/issues/97) · [#98 F errors + mobile](https://github.com/frizman21/smai-server/issues/98)  
**Decision Ledger:** DL-015 (Manager role dormant), DL-016 (single-role constraint), DL-028 (Settings endpoint path and verb alignment)  
**Revision note (v1.1):** Aligned user-mutation endpoints to the as-built backend pattern: `/tenant/{tenantId}/users/...`. Changed user update verb from PATCH to PUT per backend convention. Paths are now consistent with the backend implementation (Reconciliation Report 2026-04-16, DECISION 9). Added physical table naming clarifier. Prose continues to say "users" and refers to workspace/account interchangeably for readability.  
**Revision note (v1.2):** Added user-level fields required by SPEC-07 v1.1 signature composition: `first_name`, `last_name`, `title`, `cell_phone`. `first_name` and `last_name` replace the single `name` field. `cell_phone` is a rename of the existing `phone_number` field (same column, new name, signature-aware). `title` is net-new. All four are required. Restructured the Add Member and Edit Member modals accordingly. Replaced the "All Locations / Specific Locations" multi-location access pattern with a single-location dropdown for Originators; Admins see no Office Location field (their permission scope is implicit). This reflects Jeff's 2026-04-18 confirmation that originators are single-location in effectively all cases. Manager dormancy, endpoint paths, role display rules, and every other PRD-08 v1.1 contract are unchanged.
**Revision note (v1.2 clean, 2026-04-22):** Status lifted from Draft to Ready. Two cross-references updated: "PRD-02 v1.4 §8.2" → "PRD-02 v1.5 §8.2" in §2 point 13 and in §8.2 Add Member modal field table, aligning to the currently published PRD-02 version. No behavioral or contract changes. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 L-05, H-13).

**Patch note (2026-04-23):** M2P-08 L-01 legacy annotations applied to §0 source-truth line: Specs 3, 4, 10, 13, 2 each annotated as out-of-repo references with their canonical in-repo successor (or noted as deferred / no-successor where applicable). Matches the L-01 treatment PRD-01 v1.4.1 received on 2026-04-22. PRD-08 had no operational version-reference rot in the H2P-01 sweep target patterns (zero substitutions). No version bump on PRD-08 (annotation is pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01 (no-op for this doc), M2P-08.

---

## 1. What This Is in Plain English

Settings is a single flat screen. It has two components: a Profile card at the top and a Team list below it. That is the complete Buc-ee's operator-facing Settings screen. No sub-routes. No configuration panels. No toggles. No tabbed navigation.

The Profile card shows the logged-in user's own information and a Sign Out action. The Team list shows every active member of the workspace, their role, their Office Location (or "All Locations" for Admins), their Gmail connection status, and — for Admins only — controls to edit or remove them. An Admin can also add new members from this screen.

Everything an operator might expect to configure — email signatures, business hours, branding, outbound channel settings — is managed by SMAI internally at onboarding and administered through the internal admin portal. It is never surfaced to the operator. This is a governing product principle, not a deferred item.

---

## 2. What Builders Must Not Misunderstand

1. **Settings is a single flat screen with no sub-routes in Buc-ee's.** `/settings/account`, `/settings/organization`, `/settings/notifications`, and `/settings/campaigns` do not exist as operator-facing routes. If a user navigates to any of these, they redirect to `/settings`. The only valid operator Settings route is `/settings`.

2. **Manager role must not appear anywhere in the operator UI.** Manager exists in the database enum and is dormant. It must be suppressed from every Settings surface: no Manager badge in the Team list, no Manager option in the role dropdown in Add Member or Edit Member modals, no Manager description in the "What do roles mean?" accordion. This is a hard stop.

3. **The role display label for the non-Admin role is "Originator."** The database stores the role enum as `user`. The frontend always renders it as "Originator." Anywhere the word "Operator" or "User" appears as a role label in the operator-facing UI, it must be changed to "Originator."

4. **Business Hours, Branding, Business Address, Regional Settings, Default Email Signature, and Outbound Messaging Configuration are never shown to operators.** These are not deferred items. They do not exist on the operator Settings screen. They live in the internal admin portal. Do not build them here, do not add placeholders for them, and do not add navigation items that suggest they exist.

5. **SMS notification toggles are cut from Buc-ee's.** Notifications are always on and are not user-configurable in the pilot. The phone field on user records is collected for SMS routing when SMS is built — but the toggle UI must not be built until the SMS sending layer exists behind it.

6. **The Gmail connection status shown per user row is location-level, not user-level.** A user may have Gmail connected for one location but not another. In Buc-ee's, Jeff's pilot has one connection per location. The connection status displayed in the Team list reflects the status of the Gmail OAuth connection for the operational mailbox associated with the user's primary location.

7. **An Admin cannot remove themselves if they are the only Admin.** The backend enforces this. The frontend should disable or hide the delete/remove control on the logged-in user's own row when they are the only Admin, with a note: "You cannot remove yourself while you are the only Admin."

8. **The phone field in Add Member and Edit Member is optional.** It is collected for future SMS routing. The helper text must not say "Required if SMS alerts are enabled" — SMS alerts do not exist in Buc-ee's. The helper text is "Optional." Nothing more.

9. **Settings is workspace-scoped, never location-scoped.** The location switcher has no effect on Settings. Settings data (team list, user records) is always scoped to `account_id`, never to `location_id`. The `/:locationId` prefix is never applied to any Settings route.

10. **Originator sees the team list read-only.** No edit controls, no delete controls, no Add Member button. The list renders with all member rows visible but no interactive controls.

11. **User-mutation endpoints live under the tenant path pattern.** POST for invite, PUT (not PATCH) for update, DELETE for remove. All operate under `/tenant/{tenantId}/users/...`. The frontend screen path is still `/settings` — that is separate from the API path.

12. **User record carries the personal fields used in email signatures.** `first_name`, `last_name`, `title`, and `cell_phone` are required fields on every user record. SPEC-07 v1.1 reads these at campaign generation time to compose the outbound email signature. Missing any of the four means campaign generation will fail for that user. The four fields replace the prior single `name` field and the prior optional `phone_number` field. Helper text, modal layout, and the GET `/settings` response shape are all updated accordingly.

13. **Originators are single-location. Admins are multi-location.** The "All Locations / Specific Locations" radio pattern is removed. The modal renders a single-location dropdown for Originator-role users (required — this is the user's assigned location and drives both job scoping and signature composition per SPEC-07 v1.1). For Admin-role users, the Office Location field is hidden entirely — Admins have implicit access to all locations in the account and select the job's location at intake per PRD-02 v1.5 §8.2. This matches Jeff's 2026-04-18 confirmation that originators at Servpro franchise groups operate in exactly one market in effectively all cases.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- The Settings route and redirect behavior
- The Profile card: all fields, Sign Out action
- The Team list: all row fields, sort order, role-scoped controls
- Gmail connection status: display states, Reconnect CTA, what it reflects
- The "What do roles mean?" accordion: content, behavior
- The Add Member flow: modal fields, validation, invite behavior, backend writes
- The Edit Member flow: modal fields, editability, validation, backend writes
- The Remove Member flow: confirmation modal, self-removal guard, backend writes
- Role change behavior and audit logging
- Location access display and editing
- All error states specific to Settings

**This PRD does not cover:**
- Business Hours (never operator-facing)
- Branding configuration (never operator-facing)
- Business Address or Regional Settings (never operator-facing)
- Default Email Signature (never operator-facing)
- Outbound Messaging Configuration (never operator-facing)
- SMS notification toggles (cut from Buc-ee's)
- Campaign Settings (reserved route, not built)
- Internal admin portal Settings (separate codebase)
- OAuth connection management for the operational mailbox (Gmail Layer PRD)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| Settings is a single flat screen. No sub-routes in Buc-ee's. | Session State v6.0, SETTINGS-01, Lovable FE audit |
| Route: `/settings` only. No location prefix. Redirects from sub-routes. | Session State v6.0, Spec 13 |
| Manager role suppressed from all operator UI. Dormant in DB enum. | Session State v6.0, DL-015 |
| Role display label: "Originator" for non-Admin users. Never "Operator" or "User." | Session State v6.0, SETTINGS-04 |
| Business Hours, Branding, Org Settings, Email Signature, Messaging Config: never operator-facing. | Platform Spine, SETTINGS-10 |
| SMS notification toggles: cut from Buc-ee's. | Session State v6.0, SETTINGS-11 |
| Gmail connection status per user row: shown, with Reconnect CTA on disconnected state. | SETTINGS-04, SETTINGS-05, Lovable FE audit |
| Admin cannot remove themselves if they are the only Admin. | SETTINGS-07, Spec 3 |
| "What do roles mean?" accordion: describes Admin and Originator only. No Manager. | SETTINGS-09, Lovable FE audit |
| Phone field in Add/Edit Member: optional. Helper text is "Optional." Not linked to SMS. | Lovable FE audit finding |
| Originator sees team list read-only. No controls visible. | SETTINGS-05, Spec 3 |
| Settings is workspace-scoped. Location switcher has no effect. | Spec 13, Spec 2 |
| Role stored in DB as `admin` or `user`. Displayed as "Admin" or "Originator." | Session State v6.0, DL-015 |
| If the manager enum value is removed from the database before Phase 4 build starts, the frontend mapping in Slice B is no longer needed and can be omitted. | |
| User-mutation endpoints use `/tenant/{tenantId}/users/...` path pattern. Update verb is PUT, not PATCH. | Reconciliation Report 2026-04-16, DECISION 9, DL-028 |
| Table naming: prose in this PRD continues to say "users," "sessions," and "audit_log." These are their physical names; the consolidated `job_proposal_history` table from PRD-01 v1.2 is job-scoped and is not involved in Settings writes. Team and role changes write to `audit_log`, not `job_proposal_history`. | PRD-01 v1.2 §12, DL-026 |
| User record must carry `first_name`, `last_name`, `title`, and `cell_phone` as required fields. These populate the personal fields in the email signature composed per SPEC-07 v1.1. `first_name` and `last_name` replace the prior single `name` field. `cell_phone` is a rename of the existing `phone_number` field. | SPEC-07 v1.1 §4; Jeff signature requirement 2026-04-17 |
| Originators are single-location. Admins are multi-location. The "All Locations / Specific Locations" pattern is removed. | Jeff confirmation 2026-04-18; SPEC-07 v1.1 §4 |
| The Office Location field on the Add/Edit Member modal is a required single-location dropdown for Originators and is hidden for Admins. | This PRD §8.1, §9.1; SPEC-07 v1.1 §4 |

---

## 5. Screen Route and Navigation

**Route:** `/settings` — no location prefix, ever.

**Sub-route redirects:** Any request to `/settings/account`, `/settings/organization`, `/settings/team`, `/settings/notifications`, or `/settings/campaigns` redirects to `/settings`. These sub-routes do not render distinct pages in Buc-ee's.

**Nav item:** "Settings" is the fourth item in the sidebar navigation and the fourth tab in the mobile bottom nav (390px). It is highlighted when the current route starts with `/settings`.

**Workspace scope:** All data on this screen is scoped to `account_id` from the authenticated user's session. Location switcher changes have no effect on this screen.

**Back navigation:** No "Back" link is needed — Settings is a terminal nav destination. Browser back returns to the previously visited screen.

---

## 6. Profile Card

The Profile card renders at the top of the Settings screen. It shows the logged-in user's own information only. It is always read-only. No fields are editable from this card.

### 6.1 Profile card fields

| Field | Source | Display |
|---|---|---|
| Name | `users.first_name` + " " + `users.last_name` | Full name, composed from the two fields |
| Title | `users.title` | Secondary line under name, in muted text |
| Email | `users.email` | Email address |
| Cell Phone | `users.cell_phone` | Displayed if present |
| Role badge | `users.role` | "Admin" or "Originator" — pill badge, same styling as Team list |
| Avatar | `users.avatar_url` | Circular avatar image if present; initials fallback (first letter of `first_name` + first letter of `last_name`, teal background) if null |

### 6.2 Sign Out

A "Sign Out" button (or link) is present on the Profile card. Tapping Sign Out:
1. Revokes the session on smai-backend (deletes or marks as revoked the session record in the `sessions` table).
2. Redirects to `/auth/google` (the Google OAuth sign-in entry point).

No confirmation is required before signing out.

### 6.3 Profile card is read-only

The operator cannot edit their name, email, role, or avatar from the Profile card in Buc-ee's. These fields are set at invite time and managed by an Admin through the Edit Member modal (Section 9). If operators need to update their profile, an Admin must do it.

---

## 7. Team List

The Team list renders below the Profile card. It shows every active member of the workspace.

### 7.1 Sort order

Alphabetical by first name, ascending. Ties broken by last name ascending.

### 7.2 Row fields

Each Team member row shows the following fields:

| Field | Source | Display |
|---|---|---|
| Avatar | `users.avatar_url` | Circular avatar; initials fallback on null (first letter of `first_name` + first letter of `last_name`) |
| Name | `users.first_name` + " " + `users.last_name` | Full name — primary line |
| Title | `users.title` | Secondary line under name, muted text; always present (required field) |
| Role badge | `users.role` | "Admin" (teal) or "Originator" (neutral) — pill badge |
| Email | `users.email` | Secondary line |
| Cell Phone | `users.cell_phone` | Secondary line; always present (required field) |
| Office Location | Derived | For Originators: their assigned location's `display_name` (e.g., "SERVPRO® of Northeast Dallas"). For Admins: the static label "All Locations" in muted text. |
| Gmail status | Connection status for this user's location | See Section 7.3 |
| Edit control | Pencil icon | Admin only. Right-aligned. Opens Edit Member modal. |
| Delete control | Trash icon | Admin only. Right-aligned. Opens delete confirmation. |

**Manager badge must never appear.** If a `users.role` value of `manager` exists in the database, the row must render it as "Originator" in the UI. This is a display normalization until the DB enum is cleaned up.

### 7.3 Gmail connection status

Each user row shows a Gmail connection status line below the Office Location field.

**Connected state:**
- Small teal dot (•) followed by "Gmail connected" in `text-xs text-primary` (teal).

**Disconnected state:**
- Small amber dot (•) followed by "Gmail not connected" in `text-xs text-amber-600`, followed by a teal text link: "Reconnect →".

**What the status reflects:** The connection status of the Gmail OAuth token for the operational mailbox (`{location-identifier}@mail.{customer-primary-domain}`) associated with this user's Office Location. For Originators, this is their single assigned location. For Admins, the status displayed is the status of any operational mailbox the account holds; if any is disconnected, the amber state is shown. This status is stored on the `gmail_connections` table (or equivalent in the Gmail Layer schema — see Gmail Layer PRD).

**Reconnect CTA behavior:** Tapping 'Reconnect →' initiates the Google OAuth flow for the operational mailbox associated with this user's location. The reconnect route is /api/tenant/{tenantId}/obo/{accountId}/reconnect?returnTo={url}. The returnTo parameter should be set to the Settings screen URL so the operator is returned to Settings after completing the OAuth consent flow. The flow opens in a new browser tab or redirects (engineering-design decision). On successful reconnect, the row updates to show the connected state. The exact OAuth reconnect path is defined in the Gmail Layer PRD.

### 7.4 Role-scoped controls

**Admin view:** Pencil (edit) and trash (remove) icons appear right-aligned on every row except the logged-in user's own row when they are the only Admin (see Section 10.3).

**Originator view:** No edit controls, no delete controls, no Add Member button. The list renders identically in data but with no interactive controls. The Gmail Reconnect link is visible to the Originator for their own row only — they can reconnect their own mailbox.

### 7.5 "What do roles mean?" accordion

A "What do roles mean?" teal text link appears below the Team list header (above the first member row). It is collapsed by default. Tapping it expands an inline text block. Tapping again collapses it.

**Expanded content — exact copy:**

> **Admin** — Full access to all jobs, all locations, and all Settings. Can add, edit, and remove team members. Can change roles and Office Location assignments.
>
> **Originator** — Can create and manage jobs at their assigned location. Can respond to customers and upload estimates. Cannot modify team or settings.

Manager must not appear in this accordion. No other roles are described.

### 7.6 Add Member button

An "+ Add Member" button appears in the top-right corner of the Team section header. Visible to Admins only. Hidden entirely for Originators — not disabled, not grayed out, not present.

Tapping opens the Add Member modal (Section 8).

---

## 8. Add Member Flow

**Trigger:** Admin taps "+ Add Member."

**Display:** A centered modal. Background dimmed. Modal title: "Add Team Member."

### 8.1 Modal fields

| Field | Required | Validation | Notes |
|---|---|---|---|
| First Name | Yes | Non-empty | Used in email signatures and display throughout the product. |
| Last Name | Yes | Non-empty | Used in email signatures and display throughout the product. |
| Title | Yes | Non-empty | Used in email signatures. Helper text: "Used in your email signature. Example: Senior Representative, Account Manager, Production Manager." |
| Email | Yes | Valid email format; unique within workspace | The invite is sent to this address. The user must authenticate via Google OAuth with this email. |
| Cell Phone | Yes | US phone format (`(XXX) XXX-XXXX`) | Used in email signatures. Helper text: "Used in your email signature." |
| Role | Yes | One of: Admin, Originator | Dropdown. **Manager must not appear as an option.** Default: Originator. |
| Office Location | Conditional | Required when Role = Originator. Must be a valid location in the account. | Single-select dropdown of active locations for the account. **Rendered only when Role = Originator.** Hidden entirely when Role = Admin (Admins have implicit access to all locations and select the job's location at intake per PRD-02 v1.5 §8.2). |

**Field behavior notes:**
- If the Admin changes the Role dropdown from Originator to Admin mid-form, the Office Location field is removed from view and any previously selected value is discarded.
- If the Admin changes the Role dropdown from Admin back to Originator mid-form, the Office Location field reappears and is empty — the Admin must select a value before the form can be submitted.
- There is no multi-select location UI in v1.2. The "All Locations / Specific Locations" radio pattern from PRD-08 v1.1 is removed entirely.

### 8.2 Role dropdown options (exact)

The role dropdown contains exactly two options:
- Admin
- Originator

Manager must not appear. If the database enum includes `manager`, it must not surface in this dropdown under any circumstance.

### 8.3 Submit behavior

On "Add Member" button tap (primary teal, in the modal footer):

1. Client-side validation runs first: First Name non-empty, Last Name non-empty, Title non-empty, Email valid format, Cell Phone valid format, Role selected, Office Location selected (if Role = Originator).
2. If validation passes, smai-backend:
   a. Checks that the email is unique within the workspace (`users.email` unique constraint within `account_id`). If not unique, returns a typed error: "A team member with this email already exists."
   b. Creates a `pending_user` record (or equivalent invite record) tied to the workspace with the submitted first name, last name, title, email, cell phone, role, and — if Originator — the selected `location_id`.
   c. Sends an invitation email to the submitted address with a secure join link.
3. Modal closes. Toast: "Invitation sent to {email}."

**Pending state in Team list:** After invite is sent, the invited user appears in the Team list with a "Pending" badge (neutral color, not a role badge) until they complete Google OAuth onboarding. Their row shows first + last name, title, email, and the Pending badge. No Gmail status is shown until they connect. No edit or delete controls appear during pending state — Admin can cancel a pending invite via a separate "Cancel invite" link in the pending row.

### 8.4 Onboarding (invited user's flow)

The invite email contains a secure join link. When the invited user opens the link:
1. They are directed to Google OAuth consent.
2. The authenticated Google account email must match the invited email exactly.
3. On successful OAuth:
   - The pending user record is activated (`users.is_active = true`).
   - The user is placed in the workspace with the assigned role and Office Location (Originators) or all-location access (Admins).
   - The user is redirected to `/home` (Needs Attention).

No password creation. No local credentials. Google OAuth is the only onboarding mechanism.

### 8.5 On validation failure

Inline field-level errors under the offending fields. Modal stays open. No invite is sent until all validation passes.

### 8.6 On cancel

Cancel link in the modal footer. Modal closes. No record is created.

---

## 9. Edit Member Flow

**Trigger:** Admin taps the pencil icon on any Team member row (except self if only Admin — see Section 10.3).

**Display:** A centered modal. Background dimmed. Modal title: "Edit Team Member."

### 9.1 Modal fields

| Field | Required | Editable | Notes |
|---|---|---|---|
| First Name | Yes | Yes | Pre-populated with current value. |
| Last Name | Yes | Yes | Pre-populated with current value. |
| Title | Yes | Yes | Pre-populated. Helper text: "Used in your email signature." |
| Email | Yes | Yes | Pre-populated. If changed, the user's next login must use the new email with Google OAuth. Changing email does not re-send an invite. |
| Cell Phone | Yes | Yes | Pre-populated. US phone format. Helper text: "Used in your email signature." |
| Role | Yes | Yes | Dropdown — Admin or Originator only. See Section 9.2. |
| Office Location | Conditional | Yes | Required when Role = Originator. Hidden when Role = Admin. Single-select dropdown. Pre-populated with the user's current `location_id` if they are an Originator. See Section 9.2 for role-change behavior. |

### 9.2 Role change rules

- An Admin can change another user's role from Originator to Admin or Admin to Originator.
- **If the target user is the only Admin in the workspace, the role dropdown does not offer "Originator" for their row.** The backend enforces this (returns a typed error if attempted). The frontend should either disable the Originator option with a tooltip: "Cannot demote the only Admin," or hide the dropdown entirely for this user when they are the only Admin.
- An Admin cannot change their own role through this modal. The role dropdown is read-only on the logged-in Admin's own row.
- **Role change affects the Office Location field in the modal.** If the Admin changes the role from Originator to Admin, the Office Location field is removed from view and the previously assigned `location_id` is cleared on save. If the Admin changes the role from Admin to Originator, the Office Location field appears and must be filled before save.

### 9.3 Save behavior

On "Save Changes" button tap:

1. Client-side validation: First Name non-empty, Last Name non-empty, Title non-empty, Email valid format, Cell Phone valid format, Role selected, Office Location selected (if Role = Originator).
2. If validation passes, smai-backend:
   a. Updates `users` record: `first_name`, `last_name`, `title`, `email`, `cell_phone`, `role`, `location_id` (set to selected value if Originator, set to null if Admin).
   b. Logs the change to the audit log (`audit_log` table) with: actor_user_id (the Admin making the change), action = "update_user", entity_type = "user", entity_id = target user ID, metadata including old and new values for every changed field.
3. Modal closes. Toast: "Team member updated."

### 9.4 On validation failure

Inline errors. Modal stays open.

### 9.5 On cancel

Cancel link. Modal closes. No changes written.

---

## 10. Remove Member Flow

**Trigger:** Admin taps the trash icon on any Team member row.

### 10.1 Confirmation modal

A confirmation modal renders before any action is taken. The operator must explicitly confirm.

**Confirmation modal content:**
- Title: "Remove team member?"
- Body text: "Removing this team member will revoke their access to your workspace. Their activity history remains intact."
- Confirm button: "Remove" (destructive style — red background or destructive variant)
- Cancel link: "Cancel"

**The confirmation modal must always appear.** There is no soft delete that happens immediately on trash icon tap. The confirmation is required.

### 10.2 On confirm

smai-backend:
1. Sets `users.is_active = false` for the target user.
2. Revokes any active sessions for the target user (`sessions.revoked_at = now()`, `sessions.revoked_reason = 'admin_removed'`).
3. Does NOT delete the user record or any associated audit logs, job history, or event records. The user's activity history is preserved per the confirmation modal text.
4. Logs to `audit_log`: actor = logged-in Admin, action = "remove_user", entity_type = "user", entity_id = removed user.

The removed user is immediately unable to log in. Their jobs and activity remain attributed to them in the system.

The removed user's row disappears from the Team list after the confirm action completes.

Toast: "Team member removed."

### 10.3 Self-removal guard

An Admin cannot remove themselves if they are the only Admin in the workspace.

**Detection:** Before rendering the trash icon on a user row, smai-backend determines whether the logged-in user is the only Admin. If they are, their row does not show a trash icon. A muted note appears in place of the trash icon: "Only Admin" or equivalent — visually clear that the action is not available.

The backend also enforces this: if a DELETE request is sent for a user who is the only Admin, the backend returns a 422 with the message: "Cannot remove the only Admin. Assign the Admin role to another team member first."

### 10.4 On cancel

Modal closes. No changes.

---

## 11. Backend API Endpoints

All user-mutation endpoints in this section live under the `/tenant/{tenantId}/users/...` pattern. The update verb is PUT, not PATCH. This matches the as-built backend convention per the Reconciliation Report 2026-04-16 and DECISION 9 / DL-028. `{tenantId}` is the authenticated user's `account_id` from their session context.

### 11.1 GET /tenant/{tenantId}/settings

Returns the logged-in user's profile and the full team list.

**Response:**
```json
{
  "profile": {
    "id": "uuid",
    "first_name": "Kyle",
    "last_name": "Smith",
    "email": "kyle@servpro.com",
    "title": "VP of Operations",
    "cell_phone": "(214) 555-0100",
    "role": "admin",
    "avatar_url": null,
    "location_id": null,
    "location_name": null
  },
  "team": [
    {
      "id": "uuid",
      "first_name": "Kyle",
      "last_name": "Smith",
      "email": "kyle@servpro.com",
      "title": "VP of Operations",
      "cell_phone": "(214) 555-0100",
      "role": "admin",
      "avatar_url": null,
      "is_active": true,
      "location_id": null,
      "location_name": null,
      "gmail_connected": true,
      "gmail_connection_id": "uuid",
      "is_pending_invite": false,
      "is_only_admin": true
    }
  ]
}
```

`role` values in the response are `admin` or `user` (database enum values). The frontend maps `user` → display label "Originator." `manager` maps to "Originator" as a normalization until DB enum is updated.

`location_id` is the user's assigned single location. It is populated for Originators. It is null for Admins. `location_name` is the resolved display name from the `locations` table, null when `location_id` is null.

`gmail_connected` reflects the status of the operational mailbox OAuth connection for the user's assigned location (Originators) or the account's operational mailboxes (Admins; disconnected if any mailbox is disconnected). Defined by the Gmail Layer PRD.

`is_only_admin` is computed by the backend per row: true if this user is the only `admin`-role active user in the workspace. Drives the self-removal guard and role-demote guard on the frontend.

`is_pending_invite` is true for users who have been invited but have not completed Google OAuth onboarding.

### 11.2 POST /tenant/{tenantId}/users

Creates the pending invite record and sends the invitation email.

**Request body:**
```json
{
  "first_name": "string (required)",
  "last_name": "string (required)",
  "title": "string (required)",
  "email": "string (required, valid format, unique in workspace)",
  "cell_phone": "string (required, US format)",
  "role": "admin | user",
  "location_id": "uuid (required when role = user, must be null when role = admin)"
}
```

**On success:** 201. Invitation email sent. Pending user record created.  
**On duplicate email:** 422 with `{ "error": "email_exists", "message": "A team member with this email already exists." }`  
**On invalid role (e.g., manager):** 422 with `{ "error": "invalid_role" }`  
**On missing required signature field (first_name, last_name, title, cell_phone):** 422 with `{ "error": "missing_required_field", "field": "<field_name>" }`  
**On Originator with no location_id:** 422 with `{ "error": "originator_requires_location" }`  
**On Admin with a location_id set:** 422 with `{ "error": "admin_no_location" }` (Admins do not have an assigned location in the user record.)

### 11.3 PUT /tenant/{tenantId}/users/{user_id}

Updates an existing team member's record. The verb is PUT (not PATCH) to match the as-built backend convention per DL-028.

**Request body:** Same fields as POST. The backend treats the body as a full replacement of the mutable fields on the user record. Fields not included are left unchanged. (Engineering note: if Mark's `UserService` implementation actually treats this as a partial update rather than full replacement, that is an implementation detail; the product contract is that any subset of mutable fields can be updated in one request.)

**Guards enforced:**
- Cannot change role to `manager` (422).
- Cannot demote a user who is the only admin to `user` (422 with `{ "error": "only_admin_demotion_blocked" }`).
- Cannot change own role (422 with `{ "error": "self_role_change_blocked" }`).
- When role is set to `user` (Originator), `location_id` must be present and valid (422 with `{ "error": "originator_requires_location" }` if not).
- When role is set to `admin`, `location_id` must be null (422 with `{ "error": "admin_no_location" }` if set). If the user was previously an Originator with a `location_id`, the backend clears the field on role change to Admin.
- Required signature fields (`first_name`, `last_name`, `title`, `cell_phone`) cannot be set to null or empty strings (422 with `{ "error": "missing_required_field", "field": "<field_name>" }`).

**On success:** 200. Updated user record. Audit log entry written.

### 11.4 DELETE /tenant/{tenantId}/users/{user_id}

Soft-deletes a team member.

**Guards enforced:**
- Cannot remove the only Admin (422 with `{ "error": "only_admin_removal_blocked", "message": "Cannot remove the only Admin. Assign the Admin role to another team member first." }`).
- Cannot remove self (422 with `{ "error": "self_removal_blocked" }`).

**On success:** 200. `users.is_active = false`. Active sessions revoked. Audit log written.

### 11.5 DELETE /tenant/{tenantId}/users/{user_id}/invite

Cancels a pending invite (for users with `is_pending_invite = true`).

**On success:** 200. Pending user record deleted. Invite link invalidated.

---

## 12. Permissions Matrix for Settings

| Action | Admin | Originator |
|---|---|---|
| View own Profile card | Yes | Yes |
| Sign Out | Yes | Yes |
| View Team list | Yes | Yes |
| See edit and delete controls | Yes | No |
| Add Member | Yes | No |
| Edit Member | Yes | No |
| Remove Member | Yes | No |
| Cancel pending invite | Yes | No |
| Reconnect own Gmail | Yes | Yes |
| Change own role | No (neither role) | No |
| Remove self | No (blocked by guard) | No |

---

## 13. Error States

| Error | Trigger | Display |
|---|---|---|
| Page load failure | GET /tenant/{tenantId}/settings returns error | Inline banner: "Couldn't load settings. Check your connection and refresh." with Refresh button. |
| Duplicate email on invite | POST /tenant/{tenantId}/users returns email_exists | Inline error under Email field in Add Member modal: "A team member with this email already exists." Modal stays open. |
| Only Admin removal attempt | DELETE returns only_admin_removal_blocked | Toast: "Cannot remove the only Admin. Assign Admin to another member first." |
| Only Admin demotion attempt | PUT returns only_admin_demotion_blocked | Inline error in Edit Member modal role dropdown: "Cannot change role — this is the only Admin." |
| Invite send failure | POST /tenant/{tenantId}/users returns 500 | Toast: "Couldn't send invite — try again." Modal stays open. No pending record created. |
| Member update failure | PUT returns 500 | Toast: "Couldn't update team member — try again." Modal stays open. No changes written. |
| Member remove failure | DELETE returns 500 | Toast: "Couldn't remove team member — try again." Confirmation modal closes. Member row remains. |
| Invalid role in API response | `users.role = 'manager'` returned | Frontend renders "Originator" as the display label. Manager never shown. |

---

## 14. Data Integrity Rules

These are enforced server-side regardless of what the frontend sends. The frontend must not be the only guard.

1. `role` can only be set to `admin` or `user`. Any other value (including `manager`) is rejected with 422.
2. A workspace must always have at least one user with `role = admin`. Any operation that would leave zero Admins is rejected.
3. Email must be unique within `account_id`. Duplicate emails are rejected.
4. `first_name`, `last_name`, `title`, and `cell_phone` are required on every user record. Null, empty string, or missing values are rejected with 422.
5. Role-location consistency: `role = user` requires `location_id` present and valid (pointing to an active location in the account); `role = admin` requires `location_id = null`. Mismatches are rejected. Role changes clear or populate `location_id` accordingly per §9.2.
6. A user with `is_active = false` cannot log in. Active sessions are revoked immediately on deactivation.
7. Audit log entries for role changes, member additions, and member removals are written atomically with the main operation. If the audit log write fails, the entire operation rolls back.

---

## 15. System Boundaries

| Responsibility | Owner |
|---|---|
| GET /tenant/{tenantId}/settings response (profile + team list) | smai-backend |
| `is_only_admin` computation per row | smai-backend |
| `gmail_connected` status per row | smai-backend (reads from Gmail Layer connection state) |
| Invite email send | smai-backend (or via an email service) |
| Pending invite record creation | smai-backend |
| User record updates (PUT) | smai-backend |
| Soft delete and session revocation (DELETE) | smai-backend |
| Audit log writes for all Settings changes | smai-backend |
| Role enum validation (`admin` or `user` only) | smai-backend |
| Only-Admin guard (removal and demotion) | smai-backend |
| Role display mapping (`user` → "Originator", `manager` → "Originator") | smai-frontend |
| "What do roles mean?" accordion expand/collapse | smai-frontend |
| Add/Edit/Remove modal rendering | smai-frontend |
| Pending row rendering and cancel invite link | smai-frontend |
| Gmail Reconnect OAuth initiation | smai-frontend → OAuth flow (defined in Gmail Layer PRD) |
| Self-removal guard (hide trash icon on only-Admin row) | smai-frontend (reads `is_only_admin` from API) |
| Profile card Sign Out | smai-frontend → smai-backend session revocation → redirect |

---

## 16. Implementation Slices

### Slice A: GET /tenant/{tenantId}/settings endpoint and Profile card ([#93](https://github.com/frizman21/smai-server/issues/93))
Implement the GET endpoint. Return profile data and full team list with all fields from Section 11.1. Implement the Profile card: name, email, role badge, avatar with initials fallback, Sign Out action. Implement Sign Out: session revocation and redirect to /auth/google.

Dependencies: `users` and `sessions` tables (Spec 11 schema).

### Slice B: Team list rendering ([#94](https://github.com/frizman21/smai-server/issues/94))
Implement the Team list with all row fields per Section 7.2. Implement sort (alphabetical by first name). Implement Gmail connection status display (connected teal / disconnected amber with Reconnect link). Implement the "What do roles mean?" accordion with correct Admin and Originator copy only. Implement role display mapping (user → Originator, manager → Originator). Render edit/delete controls for Admin only, hidden for Originator.

Dependencies: Slice A.

### Slice C: Add Member flow ([#95](https://github.com/frizman21/smai-server/issues/95))
Implement the Add Member modal with all fields from Section 8.1 (First Name, Last Name, Title, Email, Cell Phone, Role, conditional Office Location). Implement the role dropdown with Admin and Originator only (no Manager). Implement the role-conditional Office Location single-select dropdown (shown for Originator, hidden for Admin). Implement POST /tenant/{tenantId}/users with all validations and guards (including `originator_requires_location` and `admin_no_location` 422 errors). Implement pending invite row in Team list. Implement cancel invite (DELETE /tenant/{tenantId}/users/{user_id}/invite).

Dependencies: Slice A, Slice B.

### Slice D: Edit Member flow ([#96](https://github.com/frizman21/smai-server/issues/96))
Implement the Edit Member modal with all fields pre-populated from Section 9.1. Implement PUT /tenant/{tenantId}/users/{user_id}. Implement role change guards (only-Admin demotion block, self-role-change block). Implement role-change behavior for the Office Location field (remove field and clear `location_id` on Admin; require field and populate `location_id` on Originator). Implement audit log write on every save, including metadata for every changed field.

Dependencies: Slice A, Slice B.

### Slice E: Remove Member flow ([#97](https://github.com/frizman21/smai-server/issues/97))
Implement the confirmation modal with exact copy from Section 10.1. Implement DELETE /tenant/{tenantId}/users/{user_id} with only-Admin removal guard and self-removal guard. Implement session revocation on confirmed delete. Implement audit log write. Implement the "Only Admin" indicator in place of the trash icon on protected rows.

Dependencies: Slice A, Slice B.

### Slice F: Error states and mobile ([#98](https://github.com/frizman21/smai-server/issues/98))
Implement all error states from Section 13. Implement mobile layout (390px). On mobile, the Team list renders in a single column. Edit/delete controls may collapse into a three-dot menu per row — confirm against Lovable mobile audit before implementing.

Dependencies: All preceding slices.

---

## 17. Acceptance Criteria

**AC-01: Single flat route**
Given a browser navigating to `/settings/account`, `/settings/organization`, `/settings/team`, or `/settings/notifications`, when the request resolves, then the browser is redirected to `/settings`. No sub-route renders a distinct page.

**AC-02: Manager role suppressed**
Given a workspace where any user has `role = 'manager'` in the database, when the Settings screen renders, then no "Manager" badge, no "Manager" option in any dropdown, and no "Manager" description in any accordion appears anywhere on screen. The user renders as "Originator."

**AC-03: Role display label**
Given any user with `role = 'user'` in the database, when their row renders in the Team list, then the role badge displays "Originator" — not "Operator," not "User," not any other label.

**AC-04: Admin controls hidden from Originator**
Given a logged-in Originator viewing Settings, when the screen renders, then no pencil icon, no trash icon, and no Add Member button appears anywhere on screen. The team list rows are visible but not interactive (except the Reconnect link on their own row if applicable).

**AC-05: "What do roles mean?" content**
Given any Admin or Originator tapping "What do roles mean?", when the accordion expands, then the copy describes Admin and Originator only. No Manager, no Operator, no User is mentioned anywhere in the expanded content.

**AC-06: Add Member — Manager absent from dropdown**
Given an Admin tapping "+ Add Member," when the Add Member modal opens, then the Role dropdown contains exactly two options: Admin and Originator. No Manager option exists.

**AC-07: Add Member — duplicate email rejected**
Given an Admin attempting to add a member with an email address that already exists in the workspace, when the form is submitted, then an inline error appears under the Email field reading "A team member with this email already exists." No invite is sent. The modal stays open.

**AC-08: Add Member — Cell Phone helper text**
Given an Admin opening the Add Member modal, when the Cell Phone field renders, then the helper text reads "Used in your email signature." No reference to SMS alerts appears.

**AC-09: Pending invite row**
Given an Admin who has sent an invite to a new member who has not yet completed onboarding, when the Team list renders, then a row for the pending member appears with a "Pending" badge instead of a role badge, and a "Cancel invite" link instead of edit/delete controls.

**AC-10: Remove confirmation modal always appears**
Given an Admin tapping the trash icon on any member row, when the trash icon is tapped, then a confirmation modal appears with the exact copy from Section 10.1 before any deletion occurs. No deletion happens on a single tap.

**AC-11: Self-removal guard — UI**
Given a logged-in Admin who is the only Admin in the workspace, when the Settings screen renders, then no trash icon appears on their own row. The area where the trash icon would appear shows "Only Admin" or equivalent muted text.

**AC-12: Self-removal guard — backend**
Given a DELETE request to `/tenant/{tenantId}/users/{user_id}` where the target user is the only Admin, when the request is processed, then the backend returns 422 with `error: only_admin_removal_blocked`. No deletion occurs.

**AC-13: Role demotion guard**
Given an Admin attempting to change a user's role from Admin to Originator when that user is the only Admin, when the PUT request is sent, then the backend returns 422 with `error: only_admin_demotion_blocked`. No role change occurs.

**AC-14: Gmail connected state**
Given a user whose operational mailbox OAuth token is valid, when their Team list row renders, then a teal dot and "Gmail connected" appears in `text-xs text-primary` color.

**AC-15: Gmail disconnected state**
Given a user whose operational mailbox OAuth token is expired or missing, when their Team list row renders, then an amber dot and "Gmail not connected" appears in `text-xs text-amber-600`, followed by a teal "Reconnect →" text link.

**AC-16: Settings is workspace-scoped**
Given a multi-location user switching their active location in the sidebar, when the Settings screen is open, then the Team list does not change — it continues to show all workspace members regardless of the selected location.

**AC-17: Audit log on role change**
Given an Admin changing another user's role from Originator to Admin, when the save succeeds, then an entry exists in `audit_log` with `actor_user_id = Admin's ID`, `action = 'update_user'`, `entity_type = 'user'`, `entity_id = target user's ID`, and metadata including the old role and new role.

**AC-18: Removed user cannot log in**
Given an Admin removing a team member, when the removal is confirmed and succeeds, then the removed user's `is_active = false`, all their `sessions` rows have `revoked_at` set, and any attempt to authenticate with their credentials results in a blocked login.

**AC-19: No Org Settings fields on operator screen**
Given any Admin or Originator navigating to `/settings`, when the screen renders, then no Business Hours, Branding, Business Address, Regional Settings, Default Email Signature, or Outbound Messaging Configuration UI is present anywhere on the page.

**AC-20: SMS toggles absent**
Given any user on the Settings screen, when the screen renders, then no SMS notification toggle, SMS alert toggle, or SMS preferences section exists anywhere on the page.

**AC-21: Endpoint path and verb alignment**
Given an Admin performing any user mutation, when the frontend issues the HTTP request, then the path matches `/tenant/{tenantId}/users/...` and the update request uses PUT (not PATCH). No endpoint under `/settings/team/...` is called.

**AC-22: Required signature fields on Add Member**
Given an Admin attempting to submit the Add Member modal with First Name, Last Name, Title, or Cell Phone empty, when Submit is tapped, then client-side validation blocks the submission with inline field-level errors. If the request reaches the backend with any of these fields empty, the backend returns 422 with `error: missing_required_field` naming the missing field. No invite is sent.

**AC-23: Office Location field is role-conditional**
Given an Admin opening the Add Member modal, when Role is set to Originator, then the Office Location field is visible and required. When Role is set to Admin, the Office Location field is not visible anywhere in the modal.

**AC-24: Role change clears or requires Office Location**
Given an Admin editing a team member whose current role is Originator, when the Admin changes the role dropdown from Originator to Admin, then the Office Location field is removed from view and any selected value is discarded on save (`location_id` is set to null on the user record). Given the Admin instead changes the role from Admin to Originator, then the Office Location field appears and must be filled before Save Changes is enabled.

**AC-25: Admin user has no assigned location in API response**
Given a user with `role = admin`, when the GET `/tenant/{tenantId}/settings` response is returned, then `location_id` and `location_name` are null for that user in both the `profile` and `team` payloads.

**AC-26: Originator user has a populated assigned location in API response**
Given a user with `role = user`, when the GET `/tenant/{tenantId}/settings` response is returned, then `location_id` is populated with the user's assigned location ID and `location_name` is populated with the resolved display name from the `locations` table.

**AC-27: Team list shows Office Location label per role**
Given an Admin viewing the Team list, when team rows render, then Originator rows show their assigned location's display name (e.g., "SERVPRO® of Northeast Dallas") and Admin rows show the static label "All Locations" in muted text.

**AC-28: Backend rejects Originator without location_id**
Given an Admin attempting to create or update a user with `role = user` and `location_id = null`, when the backend receives the request, then it returns 422 with `error: originator_requires_location`. No write occurs.

**AC-29: Backend rejects Admin with location_id set**
Given an Admin attempting to create or update a user with `role = admin` and `location_id` set to a non-null value, when the backend receives the request, then it returns 422 with `error: admin_no_location`. No write occurs. On role change from Originator to Admin via PUT, the backend clears `location_id` automatically if it was previously populated.

---

## 18. Open Questions and Implementation Decisions

**OQ-01: Invite email sender and template**
Invitation email behavior is specified: sent on Add Member submission, secure join link expires after 72 hours, invited user must complete Google OAuth with the exact invited email address to activate. Implementation mechanism (direct send vs. email service, from address) is Mark's engineering-design decision and does not affect the product spec.

**OQ-02: Reconnect OAuth flow destination**
RESOLVED. Gmail reconnect OAuth route is /api/tenant/{tenantId}/obo/{accountId}/reconnect?returnTo={url}. Mark confirmed April 8, 2026.

**OQ-03: Role enum cleanup in database**
The `users.role` enum currently includes `manager` as a value (confirmed in the database, DL-015). This PRD specifies that `manager` is mapped to "Originator" in the display layer as a temporary normalization. Mark should confirm whether the DB enum will be cleaned up (removing `manager`) before Phase 4 or after Buc-ee's go-live. If cleaned up before Phase 4, the frontend mapping is no longer needed. If not cleaned up, the mapping must persist.

**OQ-04: Pending invite visibility**
Section 8.3 specifies that pending invites appear in the Team list with a "Pending" badge. Engineering should confirm whether the GET /tenant/{tenantId}/settings endpoint returns pending users as part of the `team` array (with `is_pending_invite: true`) or as a separate `pending_invites` array. Either is valid; the frontend rendering is the same either way.

**OQ-05: GET endpoint path — confirm with Mark**
This PRD specifies `/tenant/{tenantId}/settings` as the GET endpoint path for the combined profile + team list response. The user-mutation endpoints are confirmed at `/tenant/{tenantId}/users/...` per DL-028. Mark to confirm whether the GET response lives at `/tenant/{tenantId}/settings` or elsewhere (e.g., `/tenant/{tenantId}/users` with profile embedded, or split into two endpoints). This is an engineering-design question; the product contract is that all required data loads in one or two requests without waterfall.

**OQ-06: PUT semantics — full replacement or partial update?**
This PRD specifies PUT as the verb for user updates per DL-028. Section 11.3 notes that the product contract allows any subset of mutable fields. Mark to confirm whether `UserService` implements the PUT as true full-replacement semantics or as partial-update semantics. Product does not care which, as long as the frontend can send any subset of fields in a single request.

**OQ-07: Migration of `name` to `first_name` + `last_name`**
v1.2 replaces the single `name` field with `first_name` and `last_name`. For Jeff's pilot, no production users exist yet, so no backfill is required — the first users created are created with the new fields. If any seed or test users exist with `name` populated, Mark decides whether to (a) split the existing string on the first space, (b) ask SMAI staff to re-enter the fields during onboarding, or (c) drop the seed data. Recommendation: (b) for accuracy.

**OQ-08: Rename of `phone_number` column to `cell_phone`**
v1.2 renames `users.phone_number` to `users.cell_phone` and upgrades it from optional to required. The semantic change (optional → required, signature-bearing) is larger than the name change. For Jeff's pilot, no production users exist with this field populated; the first users will be created with the new field. Mark decides column-rename mechanics (alter column name vs. add new column and drop old one). No data migration is required for Buc-ee's.

**OQ-09: Title field backfill for existing users**
`title` is net-new and required. For any existing seed or test users, `title` does not exist. Mark must either ask SMAI staff to populate the title for every existing user before v1.2 is deployed, or the v1.2 migration itself sets a placeholder value that an Admin must then correct before signature composition succeeds for that user. Recommendation: SMAI staff populates during cutover to avoid placeholder-in-signature risk.

**OQ-10: Cleanup of `user_location_access` and `location_access_type`**
v1.2 removes the "All Locations / Specific Locations" pattern. `users.location_access_type` and the `user_location_access` table are no longer used by this spec. Mark decides whether to drop the column and the table as part of the v1.2 migration or leave them in place (unused) until a later cleanup. Data model purists will prefer dropping now; pragmatists will prefer leaving them until they cause an actual problem. Either is acceptable for Buc-ee's.

---

## 19. Out of Scope

- Business Hours (never operator-facing — managed by SMAI at onboarding via internal admin portal)
- Branding configuration (never operator-facing)
- Business Address and Regional Settings (never operator-facing)
- Default Email Signature (never operator-facing)
- Outbound Messaging Configuration (never operator-facing)
- SMS notification toggles and SMS sending infrastructure (cut from Buc-ee's — SETTINGS-11)
- Campaign Settings at `/settings/campaigns` (reserved route, not built for Buc-ee's)
- SSO or non-Google OAuth identity providers (post-MVP)
- Multi-workspace user management (post-MVP)
- Role-based field-level security (post-MVP)
- Audit log UI visible to operators (post-MVP — Spec 16 explicitly excludes this)
- User groups or departmental hierarchies (post-MVP)
- Avatar upload or profile photo editing (post-MVP)
- Personal notification preferences (SMS toggles deferred, in-app notifications are always-on and not configurable)
- Internal admin portal Settings (separate codebase — never in operator product)
