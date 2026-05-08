# Project assessment vs. PRDs and SPECs

**Date:** 2026-05-08
**Targets:** [`docs/prd/PRD-01..PRD-10`](../prd/), [`docs/specs/SPEC-02..SPEC-12`](../specs/)
**Source of truth (current):** repo at HEAD on `main` (commit `3aedfbb` and predecessors)
**Companion report:** [`2026-05-08_MVP_v1.2_assessment.md`](2026-05-08_MVP_v1.2_assessment.md) — this PRD/SPEC pass complements that CC-06 pass; where the two overlap the more detailed take is here, but findings are consistent.
**Scope:** Code, schema, seed, jobs, services. Excludes content authoring (campaign markdown).

---

## 0. Read this first — architectural delta

The PRD/SPEC suite was authored against a different stack than the one the project actually built on. This is the single largest source of "divergence" findings below; flagging it once here so individual sections can be terse.

| PRD/SPEC assumption | Repo reality |
|---|---|
| Two services: `smai-backend` (Kotlin/Micronaut, Cloud Run) + `smai-comms` | One Rails 8.1 monolith |
| Postgres (Cloud SQL) + Firestore `smai-comms-db` (`obo-accounts`, email log) | Postgres only |
| Cloud Tasks `sm-comms-email-send` for sends | Sidekiq cron `CampaignSweepJob` polling every 5 min |
| Gmail Pub/Sub push → `GmailPushController` for replies | Sidekiq cron `GmailReplyPollJob` polling every 1–2 min |
| Cloud KMS encryption of OBO tokens | Plaintext `access_token` / `refresh_token` columns on `email_delegations` and `application_mailboxes` (Rails encrypted attrs not used) |
| `accounts` table + `account_id` FKs everywhere | `tenants` table (memory: Organization layer was removed) |
| Append-only `job_proposal_history` with 21-value `event_type` enum | **Table does not exist.** No history rows are written for any event |
| `audit_logs` table for admin-portal writes | **Table does not exist** |
| Per-location `obo-accounts` keyed by `location_id` | Singleton `application_mailboxes` table, no `location_id` |
| OIDC service-to-service auth | N/A (single process) |

These are not necessarily wrong — Rails-on-Postgres at this scale is a defensible substitution — but every PRD in §0 below carries a note where the implementation choice meaningfully diverges from the spec contract.

The product-level behaviors (intake → approve → send → stop on reply / failure / pause) are working end-to-end in the actual stack, exercised by 647 passing tests.

---

## 1. PRD-01 — Job Record (v1.4.1)

**State: Mostly aligned at the field level; structurally divergent on history and on the persisted "approving" state.**

### What's there
- `job_proposals` carries `pipeline_stage` (string), `status_overlay` (string), `customer_*` fields, `location_id`, `job_type_id` (FK), `scenario_id` + `scenario_key`, `proposal_value`, `internal_reference`, `loss_reason`, `loss_notes`, `closed_at`, `closed_by_user_id`, `created_by_user_id`, `owner_id`, `tenant_id`. Jobs/contacts collapse into one row (PRD calls for separate `job_contacts`; the operator product behaves identically — see §16 OQ-04).
- `JobProposal.cta_for(pipeline_stage:, status_overlay:)` is a single shared computation (`app/models/job_proposal.rb:64`). Surfaces read it; no per-screen reimplementation. ✅ AC-02, AC-03 conform.
- `JobProposal#cta_type` honors `drafting` / `approving` with `:review_proposal` / `:review_campaign` instead of the canonical `view_job` etc. — see "Pending Approval" finding below.
- `scenario_key` is non-nullable in practice (joined to `scenarios.code`). Scenarios scoped to job_type via `scenarios.job_type_id` + unique `(job_type_id, code)`. ✅ AC-09, AC-10 partial.
- `internal_reference` is the DASH-number slot but is free-text and not gated by a per-tenant flag.

### Gaps vs. PRD-01
| § | Item | State |
|---|---|---|
| §2 #5 / §12 | **Append-only `job_proposal_history` table** | ❌ Missing. No table, no rows are written for any of the 21 `event_type` values. AC-04 fails. This is the single biggest contract gap in PRD-01. |
| §6 / §7 | Pending Approval eliminated | ⚠️ Partial. The PRD is unambiguous: `pending_approval` is not a state. The code has `JobProposal.status: { drafting:0, approving:1, approved:2 }` and the `approve` controller action (`job_proposals_controller.rb:204`) flips `approving → approved` after launch. The `JobProposal#cta_type` helper returns `:review_proposal` / `:review_campaign` for these states — values that PRD-01 v1.4 explicitly removed. The operator-visible flow is "upload → review/edit → click Approve → campaign starts," which matches the spec; the *internal state model* still carries the eliminated states. |
| §8.1 | `cta_type` not stored | ✅ Computed at query time. |
| §8.1 | `on_behalf_of_user_id` absent | ✅ Not present anywhere. |
| §8.1 | `dash_job_number` field | ❌ Missing. `internal_reference` is the de-facto slot. |
| §10 | Field locks server-side | ⚠️ Validators on `JobProposal` enforce non-empty for many fields but `job_type_id`, `scenario_id`, `location_id`, `customer_email` are not write-locked after creation. AC-05, AC-07, AC-08, AC-09 are not covered by tests. |
| §12 enum-casing | Canonical uppercase enum convention | ❌ Code stores lowercase strings/integers. Defensible (Rails convention), but the wire format will require translation if a non-Rails consumer ever joins. |

**Action:** Add `job_proposal_history` (job_id, event_type, old_status, new_status, details, changed_by, metadata jsonb, change_date). Wire writes from every transition controller and every job. Either rip the `drafting`/`approving` states out of `JobProposal#status` and merge into `pipeline_stage`, or document the deviation explicitly (and rename the helper return values).

---

## 2. PRD-02 — New Job Intake (v1.5)

**State: Builds and works, but the *collapsed flow* is not implemented — the durable write happens at upload, not at Approve.**

### What's there
- PDF upload → `JobProposalsController#create` → `JobProposalProcessor` (Gemini, with deterministic stub fallback). Customer fields, address, value, scenario classification all populate. ✅ AC-02.
- Intake is a routed page (`/job_proposals/new`), not a modal. AC-01 ("`/jobs/new` must not exist") is met by accident — there is no `/jobs/*` route at all; the resource is named `job_proposals`.
- Job Type + Scenario both required and operator-selected; Scenario scoped to Job Type via `Scenario.where(job_type_id:)`. AC-10, AC-11 conform structurally.
- Office Location: Originators have `users.location_id`; admins do not. The intake form treats this correctly but the PRD's strict role-conditional rendering (read-only label vs. dropdown) needs verification against the view.
- Campaign launch happens on `JobProposal#update` if eligible (auto-launch on edit) and via explicit `launch_campaign` button.

### Gaps vs. PRD-02
| § | Item | State |
|---|---|---|
| §1 / §2 #2 / §8.4 | **Collapsed flow: nothing persists until Approve** | ❌ The job record is written on Submit (Upload + Create). The "Campaign Ready surface" is the proposal show page, not a separate review-then-write modal. Operators who decide *not* to approve leave a `drafting`/`approving` row in the database. AC-05 ("no `job_proposals` rows exist for this submission" before Approve) fails. |
| §8.1 §5 (Section 5) | DASH job number required when tenant flag is on | ❌ No tenant flag, no required-on-tenant gating. Field exists as `internal_reference` but is always optional. AC-12 (loud failure when no active variant) — see PRD-03. |
| §10 | `job_created` and `campaign_approved` history events at Approve | ❌ No history table; nothing is written. |
| §13 | Atomic write on Approve | ⚠️ Approve currently flips `JobProposal.status` to `approved`; the campaign instance + step instances were already created at launch (which itself happens earlier). The transaction surface is fragmented relative to the spec's single atomic write. |

**Action:** Either (a) ship the spec faithfully — defer the durable write to Approve and treat the proposal-show edit page as ephemeral state; or (b) document the deviation and update PRD-02 to match the as-built upload-then-approve flow. The latter is much smaller work and arguably no worse for the operator.

---

## 3. PRD-03 — Campaign Engine (v1.4.1)

**State: Functional end-to-end. Templated architecture is in place; the missing piece is `template_version_id` cohort attribution and the per-step rendering snapshot semantics.**

### What's there
- Templates in DB: `Campaign` (per scenario) → `CampaignStep` rows with `template_subject`, `template_body`, `offset_min`, `sequence_number`. Loaded by `CatalogLoader` from `docs/campaigns/v1-output/`.
- `CampaignLauncher.launch(job_proposal)` (`app/services/campaign_launcher.rb`) creates a `CampaignInstance` (polymorphic via `host_type/host_id`) plus per-step `CampaignStepInstance` rows. Idempotent. ✅
- `MailGenerator.render` substitutes merge fields against the proposal, originator, location, tenant context. Has a `render_safely` and a preview path. Builds From-display + signature inline.
- `CampaignSweepJob` (Sidekiq cron, every 5 min):
  - Picks step instances where `planned_delivery_at <= now`
  - Gates on `CampaignInstance.active`, `Campaign.approved`, **`JobProposal.approved`** (this is the operator approval gate)
  - Atomic claim via conditional UPDATE on `email_delivery_status: pending → sending`
  - Sends via `GmailSender` (OAuth OBO via `EmailDelegation`)
  - Marks step `sent` or `failed`; promotes parent `CampaignInstance` to `completed` after final step or `stopped_on_delivery_issue` on failure
- `GmailReplyPollJob` (Sidekiq cron, every 1–2 min):
  - Polls each in-flight thread's Gmail history
  - Detects inbound replies → flips `CampaignInstance` to `stopped_on_reply`, `JobProposal.status_overlay = customer_waiting`
  - Detects async bounces → `stopped_on_delivery_issue`, `delivery_issue` overlay
- Pause/Resume on `JobProposalsController` flips overlays and instance status correctly.
- Mark Won/Lost via dedicated controller actions.

### Gaps vs. PRD-03
| § | Item | State |
|---|---|---|
| §6.4 / §7 / SPEC-11 | `campaigns.template_version_id` on each campaign run | ❌ Missing. `CampaignInstance` has `campaign_id` (FK to the `Campaign` row used) but the `Campaign` row is not versioned. Cohort attribution (PRD-07 §1A future contract) is implicit-only. |
| §6.4 | "Re-verify variant at write time; write uses the variant returned at Submit" | N/A under the as-built flow (no separate Submit/Approve render moments). |
| §7.2 | Rendered subject/body stored on `campaign_steps` at Approve, sent verbatim | ⚠️ Inverted. `CampaignStep.template_subject/body` carry the *unrendered* template; `CampaignStepInstance.final_subject/body` are populated only **at send time** by `CampaignSweepJob#deliver`. The PRD requires rendering at Approve (or Submit) so the operator approves exact content. Mid-campaign data changes (originator title, location phone) would currently leak into already-approved-but-not-yet-sent steps. Acceptable for the pilot; not spec-compliant. |
| §7.3 | `[{job_number}]` subject prefix | ❌ Not implemented in `MailGenerator` or the sender. SPEC-09 / CC-06 wedge #1 dependency. |
| §8 | Pre-send checklist (7 conditions in order) | ⚠️ Partial. The sweep query gates on workspace mailbox, instance active, campaign approved, proposal approved. Per-row gates on `status_overlay = null`, idempotency (no duplicate `messages` row), OBO token availability, customer_email presence are mixed in but not as the explicit numbered checklist. |
| §9.2 / §9.3 | Writes to `messages`, `message_events`, `delivery_issues` tables | ❌ None of these tables exist. Step send results live on `campaign_step_instances` (`gmail_send_response`, `email_delivery_status`). Inbound replies live on `campaign_step_instances.last_reply` / `gmail_reply_payload` / on `JobProposal.last_reply`. The data is captured; the model split called for in PRD-03 is collapsed. |
| §10 | Stop conditions write history events | ❌ No history table. |
| §12 | Fix Issue creates a *new* `job_campaigns` row carrying `template_version_id` from the prior run | ⚠️ Fix Issue isn't wired as a distinct flow; the operator edits `customer_email` on the proposal (which **is locked** by PRD-01 §10 except via Fix Issue) and re-runs. No new `CampaignInstance` is spawned for resume; the existing instance is resumed in place. |
| §13.2 | Resume modifies the active row (no new run) | ✅ Matches behavior. |
| §16 | "`CampaignController` initialization must not be tenant-callable" | N/A — there is no such endpoint exposed; campaign initialization is internal to the launcher. ✅ |

**Action:** Add `campaigns.template_version_id` (or version `Campaign` itself with append-only rows + `is_active`) for SPEC-11 v2.0.x conformance. Decide whether to render at Approve (spec) or at send (current); if the latter, add a regression test pinning the behavior so a future change doesn't accidentally introduce an inconsistency.

---

## 4. PRD-04 — Needs Attention (v1.2.1)

**State: Functional via existing routes, but not implemented as a dedicated screen.**

### What's there
- `JobProposal.needs_attention` scope (`app/models/job_proposal.rb:23`):
  ```ruby
  drafting_or_approving = where(status: [:drafting, :approving])
  approved_with_overlay = where(status: :approved, pipeline_stage: :in_campaign,
                                status_overlay: %w[customer_waiting delivery_issue])
  ```
- Surfaced on `/job_proposals?filter=needs_attention`. Sidebar link with count badge.
- For regular users, `/` redirects to the needs-attention list (root of home).
- Mark Won / Lost / Pause / Resume CTAs on the proposal show page (commit `ff99128` added the loss-reason modal).

### Gaps vs. PRD-04
| § | Item | State |
|---|---|---|
| §5 / §6 | Surfacing logic includes `cta_type IN (open_in_gmail, fix_delivery_issue, resume_campaign)` | ⚠️ The `needs_attention` scope **excludes Paused** (only `customer_waiting` / `delivery_issue`). Per CC-06 governance over Spec 7, Paused jobs *should* appear with `resume_campaign`. AC-03 fails. The `drafting`/`approving` jobs *do* appear (consistent with the as-built upload-before-approve flow), even though PRD-04 v1.2 removed those paths. |
| §6 | Sort by CTA priority (customer_waiting > delivery_issue > paused), recency tiebreaker | ⚠️ Sort order on the index isn't pinned to that priority ladder; verify against `JobProposalsController#index`. |
| §7 | Card anatomy (badge, name, value, customer name, time-since, engagement fact, triage text, CTA) | ⚠️ The current index is a card list (commit `e12352c`) but engagement-fact / triage-text per CTA aren't wired per-row. |
| §9 | "Handled by SMAI" feed (today-only history events) | ❌ No history table → no feed. |
| §10 | Empty states ("You're all caught up") | ⚠️ Verify against view. |
| §11 | Location scope — Originator restricted to own location, Admin can switch | ⚠️ Originators are scoped via `users.location_id` (good); the multi-location switcher / "All Locations" toggle for Admin isn't a dedicated affordance — the index filter has a Location dropdown instead. |
| §12 | Real-time updates (30s) | ❌ Not implemented. |
| §15 | Single endpoint returns all card-render data | ⚠️ `JobProposalsController#index` joins enough data; the per-card "engagement fact event" join isn't included. |

**Action:** Add Paused to the `needs_attention` scope (one-line change). Decide whether to ship a dedicated Needs Attention screen or formalize the filter-on-index approach in PRD-04.

---

## 5. PRD-05 — Jobs List (v1.4)

**State: Implemented as the proposals index. Most behaviors present; status-badge color hex codes and the three-dot overflow menu are partial.**

### What's there
- `/job_proposals` is the all-jobs list. Filter bar: search, status, owner, creator, location.
- Card list (commit `e12352c`).
- Mark Won / Lost CTAs.
- New Job button → `/job_proposals/new` (modal-opening behavior is not implemented; it navigates).

### Gaps vs. PRD-05
| § | Item | State |
|---|---|---|
| §6 | Default sort: `created_at DESC` under "All", CTA-priority under filtered views | ⚠️ Verify against the index controller. |
| §7.1 | Filter bar with 9 status filters (`all`, `open`, `reply-needed`, `delivery-issue`, `in-campaign`, `paused`, `won`, `lost`, `closed`) | ⚠️ Current filter is by `status:` (drafting/approving/approved) and `?filter=needs_attention`. The status-overlay-discriminated filters from PRD-05 aren't all present. |
| §10 | Status badge canonical hex (Coral `#F56B4B`, Red `#E53935`, Amber `#F5A623`, Teal `#00B3B3`, Green `#27AE60`, Gray `#9CA3AF`) | ⚠️ Not pinned in CSS. Verify in `app/assets/`. |
| §11 | Three-dot overflow: Mark Won, Mark Lost, Flag Issue, Delete Job | ⚠️ Mark Won / Mark Lost present; **Flag Issue and Delete Job are not implemented**. AC-09 conforms; AC-11, AC-12, AC-13 fail. |
| §11.5 | Soft delete with campaign stop | ❌ Not implemented. |
| §13 | "+ New Job" opens modal; `/jobs/new` 404s | ❌ Routes to `/job_proposals/new` (a routed page). |
| §17 | API includes `M` total step count for In Campaign triage text | ⚠️ Per-card data is fetched lazily. |

**Action:** Decide whether Flag Issue / Delete Job are worth shipping for the pilot. Pin badge hex codes in a stylesheet so they don't drift. The filter set is currently overloaded with `status` (= the proposal-approval state) instead of pipeline-stage + overlay; reconciling this depends on PRD-01's `approving` decision.

---

## 6. PRD-06 — Job Detail (v1.3.1)

**State: Functional. The Activity Timeline and several sub-flows are missing because the underlying tables aren't there.**

### What's there
- `/job_proposals/:id` — full-page proposal view with all sections.
- Header with status, value, customer.
- Pause / Resume / Mark Won / Mark Lost / Revert (`revert_pipeline_stage`) actions.
- Edit Details → routed edit page (not a slide-out).
- Campaign instance + step instance views as nested resources (`/job_proposals/:id/campaign_instances/:id`, `/job_proposals/:id/step_instances/:id`).
- `last_reply` jsonb shows the customer reply preview; deep-link to Gmail thread is on the show page.

### Gaps vs. PRD-06
| § | Item | State |
|---|---|---|
| §6 | Header CTA matches `cta_type` | ✅ via `job_proposal_cta_link` helper. |
| §7 | Pipeline stage tracker | ⚠️ Present as status text; not as a horizontal progress bar matching the spec. |
| §8.5 | Office Location uses `display_name` (not raw id/slug) | ✅ schema enforces `display_name NOT NULL`; SPEC-08 is structurally fixed. |
| §9.1 | Next Action Panel with badge + triage text per status | ⚠️ Not laid out as a dedicated panel. |
| §9.2 | "Follow-up N of M sent" with M sourced from `campaign_steps` count | ⚠️ Not surfaced explicitly. |
| §10 | **Activity Timeline** | ❌ No history table → no timeline. AC-04 / AC-15 fail. |
| §11.1 | "Open in Gmail" CTA opens Gmail thread directly; SMAI does not provide a compose surface | ⚠️ The deep link exists; the operator-reply detection path is `GmailReplyPollJob` polling outbound from the operational mailbox, which is a different mechanism than the spec's Pub/Sub but achieves the same operator-replied state change. |
| §11.2 | Fix Delivery Issue slide-out | ❌ Not implemented as a sub-flow; the operator edits the proposal and resumes. |
| §11.3 / §11.4 | Pause / Resume confirmation dialogs | ⚠️ Single-tap actions; no confirmation. |
| §12 / SPEC-09 | Mark Won / Mark Lost as always-visible secondary CTAs (not in overflow) | ✅ Present on show page. Mark Lost requires `loss_reason` + `loss_notes` via modal (commit `ff99128`). |
| §13 | Edit Job slide-out | ❌ Routed page, not a slide-out. |
| §14 | Scenario lock | ⚠️ No write-rejection on PATCH attempts to `scenario_id`. |

**Action:** Add the activity timeline once `job_proposal_history` exists. The slide-out vs. routed-page debate is UX scope and arguably not worth the lift for the pilot.

---

## 7. PRD-07 — Analytics (v1.2)

**State: Backend exists at the most basic level; MTD/YTD and branch comparison (the v1.2 deltas) are not built.**

### What's there
- `AnalyticsCalculator` service (`app/services/analytics_calculator.rb`) computes:
  - Total proposals
  - Won / lost / in-flight counts
  - Conversion rate (% won)
  - Follow-ups sent, first-followup-delivered count, last-30-day window
  - Originator leaderboard (per-originator stats)
- `/analytics` (regular) and `/admin/analytics` (cross-tenant).
- Per the PRD's own §1A, the architecture decision is "FE computes from raw rows; backend ships filtered results." The current Rails view does the opposite — controller passes a precomputed `analytics` object. Consistent with what was actually built but inverse of the documented direction.

### Gaps vs. PRD-07 / SPEC-05 / SPEC-06
| Item | State |
|---|---|
| Conversion Rate hero tile, dominant size | ⚠️ Single rate number; visual hierarchy not pinned. |
| Closed Revenue tile | ✅ Implicitly via won-jobs total; not labeled "Closed Revenue." |
| Active Pipeline tile (`SUM(job_value_estimate) WHERE in_campaign`) | ❌ Not surfaced. |
| Avg Time to First Reply tile | ❌ Not computed. |
| Follow-Ups Sent tile | ✅ |
| Funnel (5 stages, drop-off labels, amber-only on unanswered) | ❌ |
| Originator Performance table | ✅ Exists; close-rate column + reply-rate column. Reply-rate column muted as TODO. |
| Follow-Up Activity chart (grouped bars + area, sends/replies/closed-won) | ❌ |
| Filter bar (period, location, job_type) | ⚠️ Present; period values aren't the SPEC-05 enum (`today | last_7d | last_30d | last_90d | month_to_date | year_to_date | custom`). |
| **MTD / YTD dual display on Conversion Rate tile** (SPEC-05) | ❌ Single number only. |
| **Per-location breakdown when "All Locations"** (SPEC-06) | ❌ Not built. Originator leaderboard exists but is not a location breakdown. |
| Job Type filter values match SPEC-03 v1.3.3 (5 active) | ⚠️ Filter source is `tenant_job_types` activations; verify the 5-vs-7 reduction landed. |
| Cohort attribution by `template_version_id` | ❌ Field doesn't exist. PRD-07 OQ-07 explicitly defers this anyway. |

**Action:** SPEC-05 + SPEC-06 are the bulk of the analytics work the pilot demo (CC-07 recruitment) depends on. Best to scope a single PR that adds: (1) MTD/YTD computations, (2) per-location breakdown, (3) Active Pipeline tile, (4) Avg Time to First Reply tile.

---

## 8. PRD-08 — Settings (v1.2)

**State: The team-management slice is implemented; the SPEC-07 signature-bearing fields are partially missing.**

### What's there
- `/profile`, `/profile/edit`, `/change_password` — Profile card analog.
- `/users` index — Team list.
- `/invitations` — Add Member flow (form captures first/last name + phone, commit `936d338`).
- `users.is_admin` boolean drives Admin-only controls.
- `users.location_id` — single-location for Originators; nullable for Admins. ✅ §8.2.
- `users.first_name`, `users.last_name`, `users.phone_number` — present.
- `email_delegations` table for per-user OBO connection; `/auth/google_oauth2` reconnect flow.

### Gaps vs. PRD-08
| § | Item | State |
|---|---|---|
| §2 #12 / §8.1 | `users.title` required | ❌ Missing. SPEC-07 §6.4 fails — campaign generation will not include the operator's title. |
| §8.1 | `cell_phone` rename (vs `phone_number`) | ⚠️ Schema column is `phone_number`. Cosmetic; behavior identical. |
| §11 | Path is `/tenant/{tenantId}/users/...`, verb PUT | ⚠️ Code uses `/users` and `/invitations` (no `tenant_id` in path; tenant comes from session). The frontend behavior is correct; the URL contract diverges. |
| §10.3 | Self-removal guard ("can't remove the only Admin") | ⚠️ Verify in `Ability` class and `UsersController#destroy` (which doesn't appear to exist — no `destroy` action wired). |
| §13 | Manager role suppressed | ✅ Two-role boolean (`is_admin`); no `manager` value to suppress. |
| §11 | `audit_log` writes on user mutations | ❌ No `audit_logs` table. |
| §6.2 | Sign Out revokes session in `sessions` table | ⚠️ Devise default session handling; no `sessions` model. |

**Action:** Add `users.title` (string, nullable, validate presence on Originator records). Wire it through invite + edit + `MailGenerator.signature`.

---

## 9. PRD-09 — Gmail Layer (v1.3.1)

**State: Functional via the Rails-native OAuth + polling stack. The PRD's "two-service Cloud-native" architecture is not the implementation, and the locked Servpro mailbox addresses don't yet exist as seeded data.**

### What's there
- `email_delegations` (per-user OBO) + `application_mailboxes` (singleton operational mailbox).
- `omniauth-google-oauth2` for the OAuth dance; callback at `/auth/google_oauth2/callback`.
- `GmailSender` builds RFC-822 messages with thread headers (`References`, `In-Reply-To`) and sends via `Gmail API users.messages.send`.
- `GmailSender#refresh_token!` handles short-lived access-token rollover.
- `GmailReplyPollJob` polls each in-flight thread for inbound replies and async bounces.
- Outbound `From:` header uses display-name + delegated address; signature constructed in `MailGenerator.append_signature` from user + tenant + location data (no Gmail signature read — aligned with SPEC-07 v1.1+).

### Gaps vs. PRD-09
| § | Item | State |
|---|---|---|
| §5.1 | **One operational mailbox per location** | ❌ `application_mailboxes` is a singleton (no `location_id` FK). PRD-09 §I one-per-location. |
| §5.2 | Servpro NE Dallas / Boise / Reno mailbox seeds | ❌ Not seeded (operational task; SMAI staff). |
| §5.3 | `mail` subdomain DNS guidance | N/A (operational, not code). |
| §6.3 | OAuth scopes `gmail.send`, `gmail.readonly` only | ✅ Verify `omniauth_callbacks_controller` / OmniAuth init. |
| §7.1 | Firestore `obo-accounts` schema, KMS-encrypted tokens | ❌ Postgres + plaintext. Acceptable; document the deviation. |
| §8.1–§8.3 | Gmail watch + Pub/Sub push + `WatchRenewalService` | ❌ Replaced with cron polling. Trust posture is different — a missed poll cycle delays reply detection by 1–2 min, which is fine for the pilot but a security audit will flag the divergence. |
| §8.6 | `MachineOpenDetector` (filters out-of-office, NDRs, no-reply) | ⚠️ `GmailReplyPollJob` does basic filtering; verify the OOO / NDR / no-reply heuristics are in place. |
| §10 | `delivery_issues` table | ❌ Not present. Delivery issues live as a status overlay only; the per-attempt detail is on `campaign_step_instances`. |
| §13 | Agent 09 governance gate | N/A (no Agent 09 in this codebase). |

**Action:** Prioritize adding `application_mailboxes.location_id` and the lookup in `ApplicationMailbox.current` — without it the per-location signature fidelity is undermined and a single revocation takes down all locations. Document the Pub/Sub-vs-polling deviation in a short ADR.

---

## 10. PRD-10 — SMAI Admin Portal (v1.3)

**State: Frontend present and ahead of the v1.2 "backend-only" posture, but the data-plane fields and audit logging are missing.**

### What's there
- `/admin/tenants` (CRUD, nested under it: locations, invitations, activations).
- `/admin/tenants/:id/locations` (new/create — full Location lifecycle).
- `/admin/tenants/:id/job_type_activations`, `/admin/tenants/:id/scenario_activations` (multi-select toggles + bulk-activate).
- `/admin/job_types` (master list CRUD), `/admin/scenarios` (CRUD).
- `/admin/campaigns` (CRUD with approve/pause/resume; per-step CRUD and reorder).
- `/admin/application_mailbox` connect/disconnect.
- `/admin/integrations` (probe + status).
- `Admin::BaseController` enforces `is_admin`.

### Gaps vs. PRD-10
| § | Item | State |
|---|---|---|
| §7 | `accounts.logo_url`, `accounts.company_name` | ❌ `tenants` has only `name`. SPEC-07 signature composition fails. |
| §8 | `locations.display_name`, `address_line_1/2`, `city`, `state` (2-letter), `postal_code`, `phone_number` | ✅ All NOT NULL on `locations`. AC-22 passes. |
| §8.3 | Activation gate (location can be `is_active=true` only when all required fields populated) | ⚠️ Validators are unconditional; functionally equivalent. |
| §9.2 / §9A.2 | Sub-type ↔ scenario activation symmetry (sub-type only activates when ≥1 child scenario activates; scenario only activates when parent sub-type is active) | ❌ No symmetric guard. The activation endpoints write rows independently. |
| §9B.1 | Template variant master list with `template_version_id`, `is_active`, `authoring_hypothesis`, `authored_by`, `authored_at`, `activated_at`, `deactivated_at`, `industry_classification` | ❌ `Campaign` is a flat row keyed `(tenant?, scenario_id)`; no version, no hypothesis, no authoring metadata. |
| §9B.3 | Atomic two-step activation (new `is_active=true`, prior `is_active=false`) | ❌ Single Campaign per scenario today. |
| §10 | Audit logging for every admin write | ❌ No `audit_logs` table. AC for §10 fails universally. |
| §12.4 | Jeff tenant: 5 sub-types (General Cleaning, Mold Remediation, Structural Cleaning, Trauma/Biohazard, Water Mitigation) | ⚠️ Demo tenant has 5 activations — verify the rename from `environmental_asbestos` → `trauma_biohazard` landed. |
| §12.6 | 17 scenarios activated for Jeff | ✅ `tenant_scenarios.count == 17` for the demo tenant. |
| §12.7 | 17 active template variants | ✅ Approved campaigns count matches. |

**Action:** Add `tenants.logo_url`, `tenants.company_name`, `tenants.job_reference_required`. Add `audit_logs`. Decide whether to version `Campaign` for SPEC-11 v2.0.x compliance — required if cohort attribution (PRD-07) is on the roadmap.

---

## 11. SPEC-02 — Originator Filter on Jobs List (v1.0)

**State: Almost there; field is named "Owner" instead of "Originator."**

- ✅ The Jobs index has a filter dropdown that scopes by the user who originated each job — the underlying mechanism (`owner_id`) is correct.
- ⚠️ The label and parameter name are "Owner," not "Originator." SPEC-02 §2 #1: "the filter must be labeled 'Originator'."
- ⚠️ Role-based visibility (Admin sees all; Originator sees only self) — verify in the controller.
- ⚠️ Location-scoping the dropdown (Admin selects location → Originator dropdown narrows) — verify.

**Action:** Rename the filter label and form parameter to "Originator." Confirm role-based scoping is enforced server-side.

---

## 12. SPEC-03 — Job Type Sub-Categories (v1.3.3)

**State: Schema and seed are aligned; rename surgery (`environmental_asbestos` → `trauma_biohazard`) needs verification.**

- ✅ `job_types` master list table with `type_code` unique slug.
- ✅ `scenarios` table with `(job_type_id, code)` unique constraint.
- ✅ `tenant_job_types` and `tenant_scenarios` activation joins with `is_active` flag.
- ✅ Operator picker is sourced from per-tenant activation (verify against intake form).
- ✅ Demo tenant: 5 sub-types active, 17 scenarios.
- ⚠️ Slug rename `environmental_asbestos → trauma_biohazard` — need to grep the seed and any active records.
- ⚠️ Slug rename `commercial_janitorial_deep_clean → commercial_deep_clean` — same.
- ⚠️ §10.3 sub-type activation gate (a sub-type can only be activated if ≥1 scenario under it is activated) is **not** enforced server-side. Admins can produce the operational dead-end the rule was added to prevent.
- ⚠️ §13.2 `industry_classification` author-facing metadata field on `scenarios` — column doesn't exist (`scenarios` has `code`, `description`, `short_name`, `job_type_id`, `campaign_id`).

**Action:** Verify rename surgery via grep on `environmental_asbestos` and `commercial_janitorial_deep_clean`; rename if found. Add the §10.3 activation-gate validator. Add `scenarios.industry_classification` if templates need it for author calibration.

---

## 13. SPEC-05 — Analytics MTD/YTD (v1.0)

**State: Not started.**

- Time-period filter has 4 buckets at most (last_30d-shaped); MTD and YTD are not computed.
- Conversion Rate tile renders one number; SPEC-05 §7.2 requires MTD + YTD displayed simultaneously.
- Per the patched §1A, this is intended as an FE computation in the current build; the backend can ship the same raw query results either way.

**Action:** Two-line addition to `AnalyticsCalculator` (period-bounded conversion rate) plus dual rendering in the dashboard partial. Smallest meaningful Analytics deliverable.

---

## 14. SPEC-06 — Analytics Branch Comparison (v1.0)

**State: Not started.**

- No per-location breakdown row inside the Conversion Rate tile.
- Required only when "All Locations" is the active scope and the user is Admin — the role-gating already exists.

**Action:** Pair with SPEC-05 in the same PR. The data is `JobProposal.where(location_id:)` × the same conversion query.

---

## 15. SPEC-07 — Originator Identity in Sent Emails (v1.2)

**State: Mostly there; signature data inputs are partially missing.**

- ✅ `From:` display = `users.first_name` + " " + `users.last_name`. Built in `GmailSender#build_message`.
- ✅ Reply-To = operational mailbox.
- ✅ Signature constructed from SMAI data (no Gmail signature read). `MailGenerator.append_signature` handles it.
- ✅ Signature pulled from job's location, not user's location (matters when an Admin originates a job at a non-home location).
- ✅ `address_line_2` is optional and dropped when blank.
- ❌ `users.title` missing (covered in §8 above).
- ❌ `accounts.logo_url`, `accounts.company_name` missing → `{logo}` and `{company_name}` merge fields can't render the spec'd content; `MailGenerator` falls back to `tenant.name`.
- ⚠️ §8 "loud fail at intake Submit if any required field is missing" — `MailGenerator#render_safely` returns missing-field info; `JobProposal#campaign_readiness_blockers` uses it in the launch path. Whether the gate is triggered at the intake-Submit moment vs. the launch moment is moot under the as-built flow.

**Action:** Bundled with §8 PRD-08 + §10 PRD-10 — adding `users.title`, `tenants.logo_url`, `tenants.company_name` unblocks the SPEC-07 §6 contract end-to-end.

---

## 16. SPEC-08 — Office Location Display Bug (v1.0)

**State: Structurally fixed.**

- ✅ `locations.display_name` is NOT NULL; the bug ("loc-atl" leaking) is structurally impossible.
- ✅ `JobProposal#location_label` (or equivalent) renders `display_name`.
- ⚠️ No regression test pins the priority order (display_name preferred over name); a one-line test would close the SPEC.

**Action:** Add a regression test asserting display_name renders correctly on the Job Detail OFFICE field.

---

## 17. SPEC-09 — Mark Won/Lost CTA Visibility (v1.2.1)

**State: Functional.**

- ✅ Mark Won and Mark Lost are visible secondary CTAs on the proposal show page (commit history).
- ✅ Mark Lost requires `loss_reason` + `loss_notes` via modal (commit `ff99128`). `JobProposal.loss_reason` and `loss_notes` columns exist.
- ⚠️ §9 specifies the loss reason is written to `job_proposal_history.metadata` JSON. With no `job_proposal_history` table, `loss_reason`/`loss_notes` live on the proposal row instead. Functionally equivalent for the pilot.
- ⚠️ §8 form-factor distinctions (desktop / tablet / mobile sticky footer) — verify against view.
- ⚠️ §7 availability (only on `pipeline_stage = in_campaign`, hidden on terminal `won`/`lost`) — verify.

**Action:** When `job_proposal_history` lands, write the loss reason to a `job_marked_lost` event row in addition to the column.

---

## 18. SPEC-11 — Campaign Template Architecture (v2.0.2)

**State: The deterministic-template-resolve-and-render path is in place; the append-only versioning is not.**

- ✅ `CatalogLoader` loads templates from `docs/campaigns/v1-output/` (deterministic, idempotent).
- ✅ Lookup by `(job_type, scenario_key)` via `Scenario` → `Campaign`.
- ✅ Merge-field substitution in `MailGenerator.substitute`.
- ✅ Loud fail when a campaign isn't found — `CampaignLauncher` returns `:no_campaign`; the proposal-edit UI shows `campaign_readiness_blockers`.
- ✅ Step count and cadence are variable per template (no hardcoded 4-step / 24h pattern).
- ✅ `{state}` merge field (v2.0.2) — verify `MailGenerator` resolves `location.state`.
- ❌ §11 append-only versioning. `Campaign` is mutable; no `template_version_id`, no `is_active`, no `authoring_hypothesis`, no `activated_at` / `deactivated_at`.
- ❌ §11.2 atomic two-step activation. Single Campaign per scenario.
- ❌ §11.1 content immutability. Campaigns can be edited in place via `/admin/campaigns/:id`.
- ❌ §7.3 `campaigns.template_version_id` on each campaign run. Cohort attribution unavailable.
- ⚠️ §10.4 render idempotency — the rendered subject/body lives on `CampaignStepInstance.final_subject/body` and is populated **at send time**. The PRD calls for render at intake/approve.

**Action:** This is the structural debt to clear if the weekly review ritual (CC-02 strategy memo, PRD-07 cohort attribution) is on the roadmap. A migration adding `template_version_id` to `campaigns` (template parent) + `template_version_id` to `campaign_instances` is the smallest viable foothold.

---

## 19. SPEC-12 — Template Authoring Methodology (v2.0)

**State: Out of scope for engineering — content authoring methodology.**

- The 17 v1 active variants (§12.7 of PRD-10) are present in `docs/campaigns/v1-output/` and load via `CatalogLoader`.
- This SPEC governs *how* campaigns are authored (master prompt, hypothesis-first ritual, anti-jargon rules), not what code does.

**Action:** None at the code level. Content review is governed by Kyle and Ethan per the SPEC.

---

## 20. Cross-cutting findings

These don't fit cleanly under one PRD/SPEC but recurred while reviewing:

1. **No `job_proposal_history` table.** Single biggest contract gap. Blocks PRD-01 §12, PRD-04 §9 ("Handled by SMAI"), PRD-06 §10 (Activity Timeline), SPEC-09 §9 (loss-reason payload), and the audit-trail discipline named throughout the suite.
2. **No `audit_logs` table.** Blocks PRD-08 §11 user-mutation audit and PRD-10 §10 admin-portal audit.
3. **`accounts` semantics on `tenants`.** Memory note confirms Organization was removed; verify any PRD prose referring to `accounts` is consistent with the `tenants` mapping.
4. **No `messages` / `message_events` / `delivery_issues` tables.** PRD-03 + PRD-09 reference all three; the data is captured in `campaign_step_instances` JSONB columns. Acceptable; would be worth a short ADR documenting the choice.
5. **`approving` / `drafting` job statuses contradict PRD-01 v1.4's "Pending Approval eliminated" rule.** The flow works but the model is inconsistent with the spec.
6. **Render at send time (not Approve time).** Per PRD-03 v1.4.1 §6.4 / SPEC-11 §10.2 the rendered content should be persisted at Approve so the operator approves *exactly* what is sent. Today it is rendered as the `CampaignSweepJob` fires.
7. **Sidekiq cron polling everywhere instead of Cloud Tasks + Pub/Sub.** Acceptable for pilot scale; document via ADR so future deployment work isn't surprised.
8. **OAuth tokens stored plaintext.** `email_delegations` and `application_mailboxes` carry `access_token` / `refresh_token` as plain `text` columns. Pre-launch hardening.

---

## 21. Recommended next-up sequence

If the goal is conformance to the PRDs as written, in priority order:

1. **`job_proposal_history` table + writes from every transition** (PRD-01 §12). Unlocks: PRD-04 feed, PRD-06 timeline, SPEC-09 §9, audit story.
2. **`tenants.logo_url`, `tenants.company_name`, `users.title`** (SPEC-07 §6 / PRD-08 §8.1 / PRD-10 §7). Unblocks signature correctness.
3. **`tenants.job_reference_required` + `job_proposals.dash_job_number` + subject-prefix in `MailGenerator`** (PRD-02 §8.1 / PRD-03 §7.3). The wedge #1 dependency.
4. **`application_mailboxes.location_id`** (PRD-09 §5.1). One mailbox per location.
5. **`audit_logs` table + writes on every `Admin::*` controller action** (PRD-10 §10).
6. **MTD/YTD + per-location breakdown** (SPEC-05 + SPEC-06). The pilot demo's recruiting payload.
7. **`Campaign.template_version_id` + activation atomicity** (SPEC-11 §11.2). Cohort attribution backbone.
8. **Reconcile `JobProposal#status: drafting/approving/approved` with PRD-01's "no Pending Approval" rule** — either drop the states or update PRD-01 to match the as-built flow.

If the goal is to update the PRDs to match the as-built system, the items above flip in scope but the same list governs.

---

## Caveats

- This pass reads code, schema, services, jobs, and routes. It does not run the test suite or exercise the live UI — gaps marked "verify against view" need a hands-on confirmation pass.
- The `docs/campaigns/v1-output/` markdown was not reviewed for SPEC-12 conformance; that is content QA territory.
- The companion CC-06 v1.2 report ([`2026-05-08_MVP_v1.2_assessment.md`](2026-05-08_MVP_v1.2_assessment.md)) is the ground-truth pilot-readiness check; this report is the per-PRD/per-SPEC drill-down beneath it.
