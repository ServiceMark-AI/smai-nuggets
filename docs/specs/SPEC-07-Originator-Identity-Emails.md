# SPEC-07: Originator Identity in Sent Emails

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| Spec name | Originator Identity in Sent Emails |
| Spec ID | SPEC-07 |
| Version | 1.2 |
| Status | Ready for build, backend-primary |
| Date | 2026-04-22 |
| Product owner | Kyle |
| Tech lead | Mark |
| Design lead | Kyle |
| Source | April 6 Jeff demo session; April 17-18 Jeff clarification texts on signature format and single-location originator model; Mark's recommendation 2026-04-17 to drop Gmail signature read; v1.3 cycle verification pass 2026-04-22 |
| Related docs | PRD-08 v1.2 Settings (user record fields); PRD-09 v1.3.1 Gmail Layer (transport); PRD-10 v1.2 SMAI Admin Portal (location and account record fields, Admin-Portal-managed configuration); PRD-02 v1.5 New Job Intake (collapsed flow; Office Location at Step 4; Submit at Step 5; Campaign Ready surface; Approve and Begin Campaign); PRD-03 v1.4.1 Campaign Engine (template lookup at Submit; atomic write at Approve); SPEC-11 v2.0 Campaign Template Architecture (merge field substitution model); CC-06 Buc-ee's MVP Definition |

**Revision note (v1.1):** Complete rewrite. v1.0 read the originator's Gmail signature at campaign generation time and stored it in the campaign context, with a workspace-level default and a constructed-from-profile fallback. v1.1 removes all three of those. The signature is now constructed from SMAI data only: the originator's user record, the job's location record, and the account record. No Gmail API read, no priority chain, no workspace-level template, no fallback logic. The `gmail.settings.basic` OAuth scope is no longer needed and has been removed from PRD-09 v1.2. The originator identity contract (From display name, per-job signature composition) is unchanged. What changed is the data source.

**Revision note (v1.2):** Verification pass against the v1.3 cycle (PRD-01 v1.4, PRD-02 v1.5, PRD-03 v1.4, PRD-09 v1.3, PRD-10 v1.2; SPEC-11 v2.0, SPEC-12 v1.0). Surgical scope: only changes the v1.3 cycle drives. No changes to the data inputs (user/location/account fields), the validation contract (loud fail on missing required field), the HTML/plain-text signature template, or the From display name construction. Three categories of change:

1. **Signature composition reframed as template merge field substitution per SPEC-11 v2.0.** Per SPEC-11 v2.0 §10, the entire campaign email body (subject and content) is rendered from a template variant via deterministic merge field substitution at intake Submit. The signature block is part of the template body, not a separately-composed artifact stored in three campaign-context fields. The data inputs SPEC-07 v1.1 named (`users.first_name`, `users.last_name`, `users.title`, `users.cell_phone`, location fields, `accounts.logo_url`, `accounts.company_name`) are exposed as merge fields per SPEC-11 v2.0 §10. Render output is part of the rendered template body content stored on the `campaigns` record per PRD-03 v1.4 §6.4 and SPEC-11 v2.0. The §7 signature template structure, §8 validation rules, and §9 edge case behavior are all preserved. What changed is the abstraction layer at which composition happens.

2. **Collapsed intake flow vocabulary aligned to PRD-02 v1.5.** v1.1 references "campaign generation time" and "the operator taps 'Create Follow-up Campaign Plan.'" That button does not exist in the launch build. Per PRD-02 v1.5 collapsed flow: the operator taps Submit at Step 5 of intake; template lookup and in-memory render happen between Submit and the Campaign Ready surface; the operator reviews the rendered plan on the Campaign Ready surface; the operator taps Approve and Begin Campaign which performs the atomic durable write. Composition happens at the Submit-to-render moment; the rendered content is persisted at Approve. The §6 Workflow Overview, §10 UX-Visible Behavior, and §12 Implementation Slices are updated to use this vocabulary.

3. **Stale references refreshed.** PRD-02 v1.4 → v1.5. PRD-09 v1.2 → v1.3. PRD-10 (no version, called "Location Configuration") → PRD-10 v1.2 SMAI Admin Portal. The §4 line 102 reference to PRD-10 §6 was a pre-existing typo (Location Configuration was §6 in PRD-10 v1.0; in PRD-10 v1.2 it is §8); corrected. §14 OQ row about pre-existing v1.0 campaign contexts removed (no production campaigns existed before the v1.3 cycle reset).

Material section changes in v1.2: §0 (meta refresh, v1.2 revision note); §2 (builder points 2, 3, 4 reframed; new point 9 on merge field substitution model); §3 (scope language aligned); §4 (new locked constraint row on render-time merge field substitution; PRD-02/PRD-09/PRD-10 refs updated; pre-existing §6 vs §8 typo corrected); §6 (workflow rewritten with v1.5 collapsed flow vocabulary); §7.6 (reframed as merge field exposure rather than separately stored campaign context fields); §8 (rule language aligned to intake Submit / Approve); §10 (Campaign Ready surface terminology); §11 (PRD-10 v1.2 refs; SPEC-11 v2.0 cross-references added); §12 (Slices D and F reframed); §13 (ACs reframed in render-output terms); §14 (stale OQ removed); §15 (out-of-scope language aligned).

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep, with H2P-03 closure. Operational references updated: `PRD-03 v1.4` → `PRD-03 v1.4.1` and `PRD-09 v1.3` → `PRD-09 v1.3.1`. The H2P-03 PRD-09 fix specifically closes the five operational sites (lines 18, 113, 351, 395, 419 per CONSISTENCY-REVIEW-2026-04-23 evidence) where the v1.2 revision note's "PRD-09 v1.2 → v1.3" stale-reference refresh under-shot the same-day PRD-09 v1.3.1 minor bump. Audit-trail revision-note text preserved byte-exact (the v1.2 revision-note sentence describing the PRD-09 v1.2 → v1.3 update is intentionally retained as-is per audit-trail discipline; only operational references outside the revision-note block are swept). No version bump on SPEC-07 (sweep is pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01, H2P-03.

---

## 1. What This Is in Plain English

Every campaign email that SMAI sends goes out from the operational mailbox configured for the location. The email is sent on behalf of the originator, the estimator who created the job. The customer receiving the email should believe they are hearing from a specific person at a specific Servpro office, not from a generic inbox.

v1 composes the signature block from data SMAI already holds. The originator's first name, last name, title, and cell phone come from their user record. The office name, street address, city, state, postal code, and office phone come from the job's location record. The company logo comes from the account record. All three are exposed as merge fields in the campaign template per SPEC-11 v2.0 and substituted at render time when the operator submits the New Job intake form.

The customer sees a real person from a real office with the right branding and the right contact info. SMAI does not appear in the From field or the signature. The composition is deterministic and repeatable, and there is no dependency on what the originator has configured in their personal Gmail account.

This spec defines how originator identity is constructed and applied to every outbound campaign email. It covers two surfaces: the From display name and the signature block.

This is a backend and comms-layer spec. There are no operator-facing UI changes beyond the campaign approval preview reflecting the real constructed signature instead of placeholder data, which is a consequence of the backend sending correct data rather than a separate build.

---

## 2. What Builders Must Not Misunderstand

1. **Emails are sent from the operational mailbox, not from the originator's personal Gmail account.** The sending identity at the SMTP/API level is the operational mailbox (e.g., `nedallas@mail.servpro-nedallas.com`). What this spec changes is the display name in the "From" header and the signature block content. The underlying sending address does not change.

2. **The signature is constructed from SMAI data only.** There is no Gmail API call to read the originator's Gmail signature. There is no workspace-level default signature template. There is no fallback priority chain. The data comes from three tables: `users`, `locations` (via the job's `location_id`), and `accounts`. If any required field is missing on any of those rows, template render fails at intake Submit with a typed error per SPEC-11 v2.0 §10.3, and the operator does not reach the Campaign Ready surface. The missing data must be corrected before the operator can re-submit. No silent fallback.

3. **The signature's location data comes from the job's location, not the user's.** For an Originator, the job's location and the user's assigned location are the same by design (Originators are single-location per PRD-08 v1.2 §2). For an Admin, the job's location is whichever location the Admin selected at intake (per PRD-02 v1.5 §8.2). The signature reflects the job's geography in both cases. This matters when an Admin originates a job at a location other than where they sit: the signature represents the job's office, not the Admin's home office.

4. **Composition happens at intake render time.** When the operator taps Submit at Step 5 of the New Job intake form per PRD-02 v1.5 §8.3, the campaign engine performs template lookup by (`job_type`, `scenario_key`) per SPEC-11 v2.0 §8 and renders the template body via merge field substitution. The user/location/account fields are merge fields per SPEC-11 v2.0 §10. The rendered content (including the composed signature block) is shown to the operator on the Campaign Ready surface per PRD-02 v1.5 §8.4 and is durably written when the operator taps Approve and Begin Campaign per PRD-03 v1.4.1 §6.4. The rendered content does not recompose at each send. If any source data (user title, location phone, account logo) changes mid-campaign, the campaign emails continue to use the snapshot captured at the Approve moment. New jobs created after the update use the new data.

5. **The signature is HTML.** The logo is an image served from a hosted URL. Text fields render as standard HTML paragraphs. Plain-text multipart alternative uses a text-only version without the logo.

6. **The From display name is always the originator's full name.** The operational mailbox address is used for sending, but the "From:" display name the customer sees is the originator's first name plus last name. This is an email header setting, not a signature field. The two are separate.

7. **No operator-facing signature editor exists in SMAI.** Originators do not compose or upload their own signatures. The data that feeds the signature is collected through the Settings screen (user fields per PRD-08 v1.2 §8.1) and the SMAI Admin Portal (location fields per PRD-10 v1.2 §8 and account fields per PRD-10 v1.2 §7). The operator never sees a "signature preview" or "edit signature" affordance.

8. **Per-originator customization is not supported in v1.** If Jeff wants a different signature layout than his NE Dallas sales reps, he gets the same template with his data filled in. Visual differences across originators come only from the data values, not the template structure.

9. **Signature composition is implemented as template merge field substitution per SPEC-11 v2.0.** The signature block is part of the campaign template body, not a separately-composed artifact stored on three campaign-context fields. The user-record, location-record, and account-record fields named in this spec are exposed as merge fields per SPEC-11 v2.0 §10 (e.g., `{user_first_name}`, `{user_last_name}`, `{user_title}`, `{user_cell_phone}`, `{location_display_name}`, `{location_address_line_1}`, `{location_phone_number}`, `{account_logo_url}`, `{account_company_name}`). The render output is part of the rendered template body content stored on the `campaigns` record at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4. This spec governs the input fields, the validation contract (loud fail on missing required field), and the signature template structure. SPEC-11 v2.0 governs the rendering mechanism. The two specs are complementary; the data inputs and the signature template defined here are unchanged by the v1.3 cycle reframing.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**
Jeff's requirement from the April 6 session and April 17-18 clarifications: every campaign email should appear to come from a specific estimator at a specific office, with that person's name, title, office information, and contact details in the signature. Jeff also confirmed (April 18) that each originator operates in exactly one market in almost all cases, which lets the signature data model flow cleanly from user record to job's location record without multi-market complexity.

**What this covers:**
- From display name construction: originator's first name + last name in the email "From:" header display name
- Signature block construction: HTML signature template assembled from user record, job's location record, and account record, exposed as merge fields per SPEC-11 v2.0 §10
- Location resolution rule: the job's `location_id` is the single source for which location populates the signature
- Render-time storage: rendered signature is part of the rendered template body persisted at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4, stable for the campaign's lifetime
- Campaign Ready surface preview accuracy: the rendered plan shown on the Campaign Ready surface (PRD-02 v1.5 §8.4) reflects the real composed signature
- Data completeness validation: template render fails cleanly at intake Submit when required fields are missing per SPEC-11 v2.0 §10.3

**What this does not cover:**
- The actual sending address (always the operational mailbox, unchanged)
- Reading any signature from Google Workspace via Gmail API (explicitly removed in v1.1)
- Workspace-level default signature templates (explicitly removed in v1.1)
- Fallback priority chains (explicitly removed in v1.1)
- Per-originator signature editor in SMAI operator UI
- Per-originator template customization
- Live signature refresh during an active campaign
- Non-Gmail email providers (Google Workspace only, MVP constraint)
- Signature behavior for manually-sent emails (SMAI does not send manual emails)
- Email footer branding or legal disclaimers distinct from the originator signature block
- SMS identity (separate channel)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Signature is constructed from SMAI data only. No Gmail signature read. No workspace-level default. No fallback chain. | Mark's recommendation 2026-04-17; Kyle concurrence 2026-04-17 |
| Signature data comes from three tables: `users` (originator), `locations` (job's `location_id`), `accounts` (logo and company identity). | This spec |
| The job's `location_id` is the single source for location data in the signature. | Kyle design decision 2026-04-18 confirming the model applies to both Originator and Admin roles |
| Originators are single-location. The user's assigned location and the job's location are the same for Originator-originated jobs by construction. | PRD-08 v1.2 §2; Jeff confirmation 2026-04-18 |
| Admins may originate jobs at any location they have access to. Location selection at intake is required for Admins. | PRD-02 v1.5 §8.2 |
| Signature composition is implemented as template merge field substitution per SPEC-11 v2.0 §10. The signature block is part of the campaign template body. User/location/account fields are exposed as merge fields. The render output is part of the rendered template body content stored on the `campaigns` record at Approve. There is no separately-stored signature artifact on the campaigns record. | SPEC-11 v2.0 §10; PRD-03 v1.4.1 §6.4 |
| Render happens at intake Submit (in-memory) per PRD-02 v1.5 §8.3; rendered content is shown on the Campaign Ready surface per PRD-02 v1.5 §8.4; durable write happens at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4. Render does not happen again at send time. Rendered content does not update mid-campaign. | PRD-02 v1.5; PRD-03 v1.4.1 |
| Signature is HTML. Logo is a hosted image served by URL. | This spec |
| From display name is always first name + last name from the originator's user record. Never a generic label, never the mailbox address, never a location name. | This spec |
| Approval-first. No unapproved outbound. This spec does not change the approval gate. | Platform Spine v1.4 |
| Append-only proof. Composed signature is part of the job's proof. | Platform Spine v1.4 |
| Gmail Layer: one dedicated operational mailbox per location, OAuth-connected once. The signature composition does not touch the Gmail API. | PRD-09 v1.3.1 |
| Account-level fields required for signatures: `logo_url`, `company_name`. Configured in the SMAI Admin Portal. | PRD-10 v1.2 §7 |
| Location-level fields required for signatures: `display_name`, `address_line_1`, `address_line_2` (optional), `city`, `state`, `postal_code`, `phone_number`. Configured in the SMAI Admin Portal. | PRD-10 v1.2 §8 |
| User-level fields required for signatures: `first_name`, `last_name`, `title`, `cell_phone`. Configured in the operator Settings screen. | PRD-08 v1.2 §8.1 |

---

## 5. Actors and Objects

**Actors:**
- **Originator**, the user who created the job. Their user record populates the personal fields in the signature. Single-location by design.
- **Admin**, also creates jobs. Same personal-fields treatment. Multi-location by design: selects the job's location at intake.
- **System (SMAI / Campaign Engine)**, at intake Submit, performs template lookup by (`job_type`, `scenario_key`) per SPEC-11 v2.0 §8, reads the three source rows, validates required fields, renders the template body via merge field substitution per SPEC-11 v2.0 §10, and shows the rendered plan on the Campaign Ready surface. At Approve and Begin Campaign, performs the atomic durable write per PRD-03 v1.4.1 §6.4 with the rendered content persisted on the `campaigns` record.
- **SMAI internal operations**, configures account-level and location-level signature fields in the SMAI Admin Portal per PRD-10 v1.2 §7 and §8 during onboarding and on change.
- **Customer**, the end recipient. Sees the originator's name as the sender and the rendered signature block at the bottom of each email.

**Objects:**
- **From display name**, the human-readable name in the email client's "From:" field. Constructed as `first_name + " " + last_name` from the originator's user record.
- **Operational mailbox**, the actual sending address (e.g., `nedallas@mail.servpro-nedallas.com`). Does not change.
- **User record** (`users` table), supplies `first_name`, `last_name`, `title`, `cell_phone` for the signature merge fields.
- **Location record** (`locations` table), supplies `display_name`, `address_line_1`, `address_line_2`, `city`, `state`, `postal_code`, `phone_number` for the signature merge fields. Resolved via the job's `location_id`.
- **Account record** (`accounts` table), supplies `logo_url` and `company_name` for the signature merge fields.
- **Campaign template variant**, the source of the signature block structure per SPEC-11 v2.0 §7.1. The signature is part of the template body. Templates are managed via PRD-10 v1.2 §9B.
- **Rendered template body**, the merge-field-substituted output produced at intake Submit and persisted at Approve and Begin Campaign on the `campaigns` record per PRD-03 v1.4.1 §6.4. Contains the rendered signature block. There is one rendered version per campaign run. All emails in the run use this version.

---

## 6. Workflow Overview

**At intake Submit** (when the operator taps Submit at Step 5 of New Job intake per PRD-02 v1.5 §8.3):

1. The campaign engine identifies the originator (the user who created the job) and reads the required fields from the user record.
2. The engine reads the required fields from the job's location record (via the job's `location_id`).
3. The engine reads the required fields from the account record.
4. The engine validates that all required fields are present (§8). If any required field is missing, template render fails per SPEC-11 v2.0 §10.3 with a typed error naming the missing field. The operator does not reach the Campaign Ready surface; the missing data must be corrected before re-submission.
5. The engine performs template lookup by (`job_type`, `scenario_key`) per SPEC-11 v2.0 §8.
6. The engine renders the template body via merge field substitution per SPEC-11 v2.0 §10. The signature block is part of the template body; the user/location/account fields are merge fields. Render is in-memory at this point; nothing is persisted.
7. The Campaign Ready surface (PRD-02 v1.5 §8.4) shows the rendered plan, including the rendered signature block, to the operator for approval.

**At Approve and Begin Campaign** (when the operator taps Approve and Begin Campaign on the Campaign Ready surface):

8. The campaign engine performs the atomic durable write per PRD-03 v1.4.1 §6.4. The rendered template body content (with signature) is persisted on the `campaigns` record alongside the `template_version_id`. The From display name is also persisted as part of the campaign run state.

**At send time** (each campaign email):

9. The campaign engine retrieves the rendered content for the campaign step from the `campaigns` record.
10. The email is constructed with:
   - "From:" display name = originator's first + last name (from campaign run state)
   - "From:" address = operational mailbox
   - "Reply-To:" = operational mailbox (so replies route back into SMAI's reply detection)
   - HTML body = rendered template body content (already includes the signature block)
   - Plain-text body (multipart alternative) = plain-text version of the rendered content
11. The email is sent via the Gmail API with the OBO token per PRD-09 v1.3.1.

---

## 7. Signature Construction

### 7.1 From Display Name

**Source:** `users.first_name` + " " + `users.last_name` from the originator's user record.

**Format:** "Jeff Stone"

**Email header construction:**
```
From: Jeff Stone <nedallas@mail.servpro-nedallas.com>
Reply-To: nedallas@mail.servpro-nedallas.com
```

Both `first_name` and `last_name` are required on the user record per PRD-08 v1.2. The From display name is never blank.

### 7.2 Signature Block Template

The signature block is part of the campaign template body per SPEC-11 v2.0 §7.1. It is rendered via merge field substitution at intake Submit using the following structure. Sources are labeled U (user), L (job's location), A (account); the bracketed fields below correspond to merge fields in the template per SPEC-11 v2.0 §10.

```
[U: first_name] [U: last_name]
[U: title]

[A: logo, rendered as <img src="[A: logo_url]" alt="[A: company_name]" width="200" />]

[L: display_name]
[L: address_line_1]
[L: address_line_2, omit entire line if field is empty]
[L: city], [L: state] [L: postal_code]
Office: [L: phone_number]
Cell: [U: cell_phone]
```

### 7.3 Example, Originator at NE Dallas

Given the data:
- User: Bob Smith, Senior Representative, cell (214) 555-5555
- Location: SERVPRO® of Northeast Dallas, 10280 Miller Rd, Dallas, TX 75238, office (214) 343-3973
- Account: Servpro franchise group, logo hosted at a GCS signed URL

The composed signature renders as:

```
Bob Smith
Senior Representative

[Servpro logo image]

SERVPRO® of Northeast Dallas
10280 Miller Rd
Dallas, TX 75238
Office: (214) 343-3973
Cell: (214) 555-5555
```

### 7.4 HTML Rendering

The HTML signature uses basic tags only. No custom CSS classes. No inline styles beyond the logo's width attribute. No external stylesheets. This keeps the signature readable in every major email client.

```html
<p>Bob Smith<br>Senior Representative</p>
<p><img src="{logo_url}" alt="{company_name}" width="200" /></p>
<p>SERVPRO® of Northeast Dallas<br>
10280 Miller Rd<br>
Dallas, TX 75238<br>
Office: (214) 343-3973<br>
Cell: (214) 555-5555</p>
```

The `alt` text on the logo image is the `company_name` from the account record. This ensures the signature remains legible in email clients that block images by default.

### 7.5 Plain-Text Rendering

A plain-text version of the signature is part of the rendered template body alongside the HTML version. It is identical to the HTML version except that the logo is represented by the `company_name` text and there are no HTML tags.

```
Bob Smith
Senior Representative

Servpro

SERVPRO® of Northeast Dallas
10280 Miller Rd
Dallas, TX 75238
Office: (214) 343-3973
Cell: (214) 555-5555
```

The plain-text version is used in the multipart/alternative part of the email. Email clients that render plain text see this version.

### 7.6 Render Output and Storage

The signature block is rendered via merge field substitution per SPEC-11 v2.0 §10 at intake Submit and is part of the rendered template body content. The rendered content is stored on the `campaigns` record at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4. There is no separately-stored `originator_signature_html` or `originator_signature_plain` field on the campaign record; the rendered signature lives inside the rendered template body as a substring.

The From display name, however, is kept as a distinct stored field on the campaign run state because it is an email header value (not body content). Final field name and storage shape per Mark's engineering decision; the product contract is that the From display name is recoverable for every send in the campaign run.

The rendered content is used for every email in the campaign run. No re-render at send time.

---

## 8. Rules, Validations, and Non-Negotiables

| Rule | Detail |
|------|--------|
| From display name is always first name + last name | Never the operational mailbox address, never a generic label, never "ServiceMark AI." Always the originator. |
| Sending address is always the operational mailbox | This does not change. The From display name is a header-level setting, not a sending address change. |
| Reply-To is the operational mailbox | Ensures customer replies route back through the operational mailbox into SMAI's reply detection pipeline. |
| Signature is rendered at intake Submit per SPEC-11 v2.0 §10 | Rendered content is persisted on the `campaigns` record at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4. Not re-rendered at send time. Not updated mid-campaign. Stable across all emails in the sequence. |
| All required fields must be present before template render succeeds | If `users.first_name`, `users.last_name`, `users.title`, `users.cell_phone`, the job location's `display_name`, `address_line_1`, `city`, `state`, `postal_code`, `phone_number`, or the account's `logo_url` or `company_name` is missing, template render fails per SPEC-11 v2.0 §10.3 with a typed error naming the missing field. The operator does not reach the Campaign Ready surface; the missing data must be corrected before re-submission. No fallback. No silent omission. |
| `address_line_2` is optional | If empty, the entire line is omitted. All other fields are required. |
| Signature is HTML in the HTML body, plain text in the plain-text body | Both versions are produced by the template render. Multipart/alternative email structure. |
| No inline signature editor in SMAI operator UI | The user-level fields are edited in operator Settings per PRD-08 v1.2. Location-level and account-level fields are edited in the SMAI Admin Portal per PRD-10 v1.2. |
| Append-only proof | The rendered signature is part of the rendered template body content stored on the `campaigns` record per PRD-03 v1.4.1 §6.4 as part of the proof record for the job. |
| Location resolution is always via the job's `location_id` | Never via the user's assigned location directly. For Originators the two are the same by construction; for Admins the job's `location_id` is what the Admin chose at intake. The signature always reflects the job's geography. |

---

## 9. Edge Cases and Failure Handling

| Scenario | Expected behavior |
|----------|-------------------|
| User record is missing `title` | Template render fails at intake Submit. Typed error: "Campaign cannot be generated. The originator's title is missing. Update the originator's Settings profile and try again." Operator does not reach the Campaign Ready surface. |
| User record is missing `cell_phone` | Same pattern. Typed error naming the missing field. |
| Location record is missing `address_line_1`, `city`, `state`, `postal_code`, or `phone_number` | Same pattern. Typed error: "Campaign cannot be generated. The office location's [field name] is missing. Contact support." (Operator cannot correct location data themselves; the SMAI Admin Portal is where this is fixed per PRD-10 v1.2 §8.) |
| Location record `address_line_2` is empty | Render succeeds. The address_line_2 line is omitted. |
| Account record is missing `logo_url` | Template render fails at intake Submit. Typed error: "Campaign cannot be generated. The account logo is missing. Contact support." |
| Account record is missing `company_name` | Same pattern. |
| Logo URL returns a 404 or fails to load when the customer opens the email | The email client shows the `alt` text (`company_name`) in place of the image. The signature remains readable. This is a runtime failure, not a render-time failure, and does not block sending. |
| Originator updates their title in Settings after Approve and Begin Campaign | Existing campaign emails continue using the rendered content captured at the Approve moment (with the old title). New jobs created after the update use the new title. No retroactive update. |
| Admin originates a job at a location other than where they personally sit | Rendered signature uses the job's location data (per §7). The Admin's personal data (name, title, cell) still appears because it is user-scoped, but the office data is the job's office. This is intentional. |
| Campaign is paused and resumed | Rendered content on the `campaigns` record is unchanged by pause/resume. Remaining emails use the same rendered content. |
| Multiple emails in the campaign sequence | All emails use the same rendered content stored on the `campaigns` record. No per-step variation in signature. |
| Email client blocks remote images | Logo does not render. `alt` text (`company_name`) is shown in its place. Remainder of signature renders normally. |

---

## 10. UX-Visible Behavior

This spec has one primary UX-visible effect: the rendered email preview on the Campaign Ready surface (PRD-02 v1.5 §8.4) shows the real rendered signature as part of the rendered template body, not placeholder data.

**Current state (placeholder):**
```
Best regards,
Alex Martinez
RestorationPros, LLC
(214) 555-0190
```

**Expected state after this spec (real rendered signature):**
```
Best regards,

Bob Smith
Senior Representative

[Servpro logo]

SERVPRO® of Northeast Dallas
10280 Miller Rd
Dallas, TX 75238
Office: (214) 343-3973
Cell: (214) 555-5555
```

**No other operator UI surfaces change.** The operator does not see a "signature preview" or "edit signature" affordance. The signature is rendered as part of the template body by the backend and shown inside the rendered email preview on the Campaign Ready surface. If data is missing at intake Submit time, the Campaign Ready surface does not appear; the operator sees a typed error instead (per §9) and is directed to update the missing data before re-submitting.

---

## 11. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Reading user record fields (`first_name`, `last_name`, `title`, `cell_phone`) at intake Submit | smai-backend / Campaign Engine |
| Reading location record fields via job's `location_id` at intake Submit | smai-backend / Campaign Engine |
| Reading account record fields (`logo_url`, `company_name`) at intake Submit | smai-backend / Campaign Engine |
| Validating all required fields are present before template render proceeds | smai-backend / Campaign Engine |
| Template lookup by (`job_type`, `scenario_key`) per SPEC-11 v2.0 §8 | smai-backend / Campaign Engine |
| Merge field substitution rendering the template body (including signature block) per SPEC-11 v2.0 §10 | smai-backend / Campaign Engine |
| Persisting rendered template body content on the `campaigns` record at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4 | smai-backend / Campaign Engine |
| Persisting From display name on the campaign run state | smai-backend / Campaign Engine |
| Setting "From:" display name in the email header at send time | smai-comms (reads from campaign run state) |
| Setting "Reply-To:" header to operational mailbox | smai-comms (already in place per PRD-09 v1.3.1) |
| Sending the rendered template body content as the email body at send time | smai-comms |
| Hosting the logo image (GCS upload, URL generation) | SMAI Admin Portal per PRD-10 v1.2 §7.2 |
| Collecting user-level signature fields | Operator Settings per PRD-08 v1.2 §8.1 |
| Collecting location-level signature fields | SMAI Admin Portal per PRD-10 v1.2 §8 |
| Collecting account-level signature fields | SMAI Admin Portal per PRD-10 v1.2 §7 |
| Rendering email preview with real rendered signature on the Campaign Ready surface per PRD-02 v1.5 §8.4 | smai-frontend (reads rendered content from intake response; no composition logic) |

---

## 12. Implementation Slices

### Slice A, User record signature field dependency
**Purpose:** Confirm `first_name`, `last_name`, `title`, and `cell_phone` are present on the user record and are required at user creation/edit per PRD-08 v1.2 §8.1.
**Components touched:** Depends on PRD-08 v1.2 Slices C and D.
**Key behavior:** No work in this spec. This slice is a dependency note: SPEC-07 requires the PRD-08 v1.2 user schema, which is the source of the user merge fields per SPEC-11 v2.0 §10.
**Dependencies:** PRD-08 v1.2 implemented.
**Excluded:** Render logic.

### Slice B, Location record signature field dependency
**Purpose:** Confirm `display_name`, `address_line_1`, `address_line_2`, `city`, `state`, `postal_code`, and `phone_number` are present on the location record per PRD-10 v1.2 §8.
**Components touched:** Depends on PRD-10 v1.2 implementation (Slice A: Backend Account and Location CRUD endpoints).
**Key behavior:** No work in this spec. Dependency note. Location fields are the source of the location merge fields per SPEC-11 v2.0 §10.
**Dependencies:** PRD-10 v1.2 Slice A implemented; SMAI Admin Portal supports location editing.
**Excluded:** Render logic.

### Slice C, Account record signature field dependency
**Purpose:** Confirm `logo_url` and `company_name` are present on the account record. Logo upload is implemented in the SMAI Admin Portal per PRD-10 v1.2 §7.2 (Slice B: Backend Logo upload pipeline).
**Components touched:** `accounts` table schema; SMAI Admin Portal logo upload endpoint.
**Key behavior:** No operator product work. Dependency note. Account fields are the source of the account merge fields per SPEC-11 v2.0 §10.
**Dependencies:** PRD-10 v1.2 Slices A and B implemented.
**Excluded:** Render logic.

### Slice D, Template merge field substitution at intake Submit
**Purpose:** Render the template body (including signature block) via merge field substitution at intake Submit per SPEC-11 v2.0 §10.
**Components touched:** Intake Submit handler in smai-backend; template render pipeline per SPEC-11 v2.0; PRD-02 v1.5 §8.3 Submit flow.
**Key behavior:** At intake Submit, perform template lookup by (`job_type`, `scenario_key`) per SPEC-11 v2.0 §8. Read user record, job's location record, and account record. Validate all required fields are present per §8 of this spec. Substitute the user/location/account merge fields per SPEC-11 v2.0 §10. Produce HTML and plain-text rendered template body content. Return rendered content in the intake Submit response so the frontend can display the Campaign Ready surface per PRD-02 v1.5 §8.4. On missing field, return typed error per SPEC-11 v2.0 §10.3 naming the missing field; the operator does not reach the Campaign Ready surface.
**Dependencies:** Slices A, B, C complete; SPEC-11 v2.0 render mechanism implemented; PRD-02 v1.5 collapsed flow implemented.
**Excluded:** Durable persistence (handled at Approve and Begin Campaign per PRD-03 v1.4.1 §6.4); email construction at send time (Slice E).

### Slice E, From display name and rendered content at send time
**Purpose:** Use the persisted rendered template body content and From display name to construct each outbound email.
**Components touched:** smai-comms email construction; reads from `campaigns` record per PRD-09 v1.3.1.
**Key behavior:** At send time, read the rendered HTML and plain-text template body content (which already includes the rendered signature) and the From display name from the campaign run state on the `campaigns` record. Set "From:" header display name. Use the rendered HTML as the HTML body. Use the rendered plain-text as the multipart/alternative plain-text body. No re-render. No append step (the signature is already inside the rendered body).
**Dependencies:** Slice D complete; PRD-03 v1.4.1 §6.4 atomic write implemented; PRD-09 v1.3.1 transport.
**Excluded:** Render logic (Slice D).

### Slice F, Campaign Ready surface preview reflects rendered signature
**Purpose:** The rendered email preview on the Campaign Ready surface shows the real rendered signature as part of the rendered template body per PRD-02 v1.5 §8.4.
**Components touched:** Campaign Ready surface "View Email" preview rendering on smai-frontend.
**Key behavior:** The preview reads the rendered HTML template body content from the intake Submit response. No frontend composition. No placeholder data. If the response contains rendered content, the preview shows the email with signature. If template render failed at intake Submit (missing required data), the Campaign Ready surface does not render and the typed error from Slice D is surfaced to the operator instead per SPEC-11 v2.0 §10.3 and PRD-02 v1.5.
**Dependencies:** Slice D complete; PRD-02 v1.5 Campaign Ready surface implemented.
**Excluded:** Backend render logic (Slice D).

---

## 13. Acceptance Criteria

**Given** an Originator whose user record has all required fields (`first_name`, `last_name`, `title`, `cell_phone`), whose assigned location has all required fields (`display_name`, `address_line_1`, `city`, `state`, `postal_code`, `phone_number`), and whose account has `logo_url` and `company_name`,
**When** they tap Submit at Step 5 of New Job intake per PRD-02 v1.5 §8.3,
**Then** template render succeeds per SPEC-11 v2.0 §10. The intake Submit response contains the rendered HTML and plain-text template body content, with the signature block rendered per §7 of this spec, and the From display name (first + last name from the user record).

**Given** a successful intake Submit response with rendered template body content,
**When** the Campaign Ready surface renders per PRD-02 v1.5 §8.4,
**Then** the email preview shows the rendered template body including the signature block: originator's name, title, account's logo, and the job's location display name, address, office phone, and the originator's cell phone. No placeholder data appears.

**Given** the operator taps Approve and Begin Campaign on the Campaign Ready surface,
**When** the atomic write happens per PRD-03 v1.4.1 §6.4,
**Then** the rendered template body content (including signature) and the From display name are persisted on the `campaigns` record. When the first email subsequently sends per PRD-09 v1.3.1 transport, the customer receives an email with the "From:" display name as the originator's first + last name, the sending address as the operational mailbox, and both the HTML body and the plain-text multipart alternative containing the rendered signature.

**Given** a user record missing `title`,
**When** intake Submit is attempted,
**Then** template render fails per SPEC-11 v2.0 §10.3 with a typed error naming the missing field. No campaign record is written. The Campaign Ready surface does not render.

**Given** a location record missing `phone_number`,
**When** intake Submit is attempted,
**Then** template render fails with a typed error naming the missing field. The operator is instructed to contact support because location data is not operator-editable (managed by SMAI Admin Portal per PRD-10 v1.2 §8).

**Given** an account record missing `logo_url`,
**When** intake Submit is attempted,
**Then** template render fails with a typed error naming the missing field.

**Given** a location record with empty `address_line_2`,
**When** template render succeeds,
**Then** the rendered signature in the template body omits the `address_line_2` line. All other lines render normally.

**Given** an Admin originating a job for a location other than their own home location,
**When** template render runs at intake Submit,
**Then** the rendered signature uses the job's location data (display_name, address, office phone) and the Admin's own user data (name, title, cell phone).

**Given** an Originator updates their title in Settings after Approve and Begin Campaign,
**When** the next scheduled campaign email sends,
**Then** the email uses the rendered template body content captured at the Approve moment (with the old title). The updated title applies to new campaigns created after the update.

**Given** a customer opens a campaign email in a client that blocks remote images,
**When** the email renders,
**Then** the `company_name` alt text is shown in place of the logo image. All other signature content renders normally.

---

## 14. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Logo storage and URL format | Engineering decision | Logo is hosted in GCS. Mark determines whether the URL is a signed URL with long expiry or a public CDN path. Both are acceptable. Recommendation: signed URL with expiry long enough to outlast the campaign window (e.g., 1-year signed URL, refreshed at template render time if near expiry). Carried over to PRD-10 v1.2 §17. |
| Logo max dimensions and file size | Engineering decision | Recommend max 200px wide (matches the `width="200"` attribute in the HTML template) and under 100 KB file size. Enforced at upload in the SMAI Admin Portal per PRD-10 v1.2 §7.2. Larger uploads rejected with a typed error. |
| Logo file format | Engineering decision | Recommend PNG with transparent background for maximum compatibility. SMAI Admin Portal guidance should state this explicitly. SVG is out of scope for v1 (email client rendering inconsistency). |
| Storage shape for the rendered template body and From display name on the `campaigns` record | Engineering decision | Per SPEC-11 v2.0 §11 the rendered content is persisted at Approve and Begin Campaign. The exact column shape (single rendered_html column, separate per-step columns, JSON blob) is Mark's call. Product contract: the rendered HTML, plain-text, and From display name are recoverable for every send in the campaign run. |
| Admin-originated job signature location resolution, confirm with Mark | Assumption | v1.2 assumes the campaign engine has access to the job's `location_id` at intake Submit and can join to the location record. PRD-02 v1.5 §8.2 already requires `location_id` to be set at intake before Submit can fire. Mark confirms the join is in place before Slice D. |

---

## 15. Out of Scope

- The actual sending address (always the operational mailbox; this spec does not change it)
- Reading any signature from Google Workspace via Gmail API (removed in v1.1)
- Workspace-level default signature templates (removed in v1.1)
- Fallback priority chains (removed in v1.1)
- Per-originator signature editor inside SMAI operator UI
- Per-originator template customization (all originators in an account share the same template with different data)
- Signature refresh during an active campaign (rendered content is captured at the Approve and Begin Campaign moment only per PRD-03 v1.4.1 §6.4)
- Non-Gmail email providers (Google Workspace only per MVP constraint)
- Email footer branding or legal disclaimers distinct from the originator signature block
- Operator-facing toggle for signature behavior
- SMS identity (separate channel, not in scope for MVP)
- Signature behavior for manually-sent emails (SMAI does not send manual emails)
- Any changes to the Campaign Ready surface layout per PRD-02 v1.5 §8.4; only the data it displays changes
- Multi-signature support per originator (one rendered signature per campaign run, period)
- Rich media signatures beyond a single hosted logo image (no GIFs, no embedded video, no tracking pixels in the signature block)
- The template authoring methodology that produces the template body containing the signature merge fields (governed by SPEC-12 v1.0)
- The template variant management mechanism (load, activate, version) for the template that contains the signature block (governed by SPEC-11 v2.0 and PRD-10 v1.2 §9B)
