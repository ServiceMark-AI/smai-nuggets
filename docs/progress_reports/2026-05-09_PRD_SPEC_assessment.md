# Project assessment vs. PRDs and SPECs

**Date:** 2026-05-09
**Targets:** [`docs/prd/PRD-01..PRD-10`](../prd/), [`docs/specs/SPEC-02..SPEC-12`](../specs/)
**Source of truth (current):** repo at HEAD on `main` (commit `673f81f`)
**Predecessor report:** [`2026-05-08_PRD_SPEC_assessment.md`](2026-05-08_PRD_SPEC_assessment.md)
**Companion report:** [`2026-05-09_MVP_v1.2_assessment.md`](2026-05-09_MVP_v1.2_assessment.md)
**Scope:** Code, schema, seed, jobs, services. Excludes content authoring (campaign markdown).

---

## 0. What changed since 2026-05-08

A material slug of v0.1 issues landed in the last 24 hours. Closed:

| Issue | Commit | Effect |
|---|---|---|
| #42 | `30bb274` | `job_proposals` schema reconciled to PRD-01 §8.1; `campaigns.template_version_id` column added |
| #87 | `2ed1b81` | Analytics MTD/YTD on the Conversion Rate hero tile (SPEC-05) |
| #91 | `9e385b6` | Analytics per-location Conversion Rate breakdown (SPEC-06) |
| #106 | `23cfe1a` | `tenants.company_name`, `tenants.job_reference_required`, `audit_logs` table + `AuditLogger` service, admin tenant edit |
| #107 | `e6c9c52` | Logo upload pipeline — `tenants.logo_url` column + Active Storage `has_one_attached :logo` |
| #151 | `e66a5b7` | DASH job number end-to-end — `job_proposals.dash_job_number`, validator gating Approve, `MailGenerator.prefix_dash_job_number` |
| #152 | `1d1e8a7` | `users.title` + `invitations.title`; wired through `MailGenerator` signature |
| (n/a) | `4e9c40a`, `6f82762` | Admin user editing from `/admin/tenants/:id`; invite-modal parity; role-gated invitation surfaces |
| (n/a) | `5437106` | Hotfix: 3-pass `location_id` backfill for production migration |
| (n/a) | `ff5bd96` | `MailGenerator` prepends customer salutation to every rendered body |
| (n/a) | `5b9e35f`, `35c7718`, `673f81f` | Dev-only `letter_opener_web` for inspecting outbound mail; sidebar link; invitation links route through it |
| (n/a) | `847ed5c` | System tests: forgot-password and password-reset end-to-end |
| (n/a) | `2b96dbe` | Dropped the "Pending data" callout from the tenant analytics view |

Net effect on the gap inventory: 7 of the 8 items in §21's "recommended next-up sequence" from the prior report are at least partially addressed. The remaining structural gaps are **`job_proposal_history` / activity timeline** and **`Campaign` versioning + atomic activation** (SPEC-11 §11).

---

## 1. Architectural delta (unchanged)

The PRD/SPEC suite was authored against a Kotlin/Micronaut + Firestore + Cloud Tasks + Pub/Sub stack. The repo is a Rails 8.1 monolith on Postgres + Sidekiq cron polling. See §0 of the [prior report](2026-05-08_PRD_SPEC_assessment.md#0-read-this-first--architectural-delta) for the full mapping; nothing in that table changed in the last 24 hours except:

- `audit_logs` is **now present** (was "table does not exist"). Schema: `tenant_id`, `actor_user_id`, `action`, `target_type`, `target_id`, `payload jsonb`, `created_at` — `db/schema.rb:56-69`.

The product-level loop (intake → approve → send → stop on reply / failure / pause) remains end-to-end functional.

---

## 2. PRD-01 — Job Record (v1.4.1)

**State: Schema reconciled to §8.1. Append-only history table is still the largest contract gap.**

### Newly closed

- `job_proposals.dash_job_number` (string, indexed) — `db/schema.rb:206, 225`. PRD-02 §5 / PRD-10 §7.5 dependency.
- `job_proposals.customer_*` slot fully filled per §8.1: `customer_title`, `customer_first_name`, `customer_last_name`, `customer_email`, `customer_house_number`, `customer_street`, `customer_city`, `customer_state`, `customer_zip` — all present.
- `internal_reference` retained alongside `dash_job_number` (the former is the legacy free-text slot; the latter is the spec-mandated thread key).
- `campaigns.template_version_id` (string) added per §5 / SPEC-11 §7.3 — `db/schema.rb:124`. **Currently unpopulated**; `CatalogLoader` doesn't write it (`grep template_version_id app/` returns only the schema/migration). The column is the foothold; surface wiring is the next step.

### Still open

| § | Item | State |
|---|---|---|
| §2 #5 / §12 | **Append-only `job_proposal_history` table** | ❌ Still missing. AC-04 still fails. Blocks PRD-04 §9 ("Handled by SMAI" feed), PRD-06 §10 (Activity Timeline), SPEC-09 §9 (loss-reason payload). |
| §6 / §7 | "Pending Approval eliminated" | ⚠️ Unchanged. `JobProposal.status: { drafting:0, approving:1, approved:2 }` is still the model (`app/models/job_proposal.rb:13`); `cta` still returns `:review_proposal` / `:review_campaign` for those states (`app/models/job_proposal.rb:82-86`). The flow works; the internal-state model still carries states PRD-01 v1.4 explicitly removed. |
| §10 | Field locks server-side | ⚠️ Unchanged. No PATCH-time write rejections on `job_type_id`, `scenario_id`, `location_id`, `customer_email`. |

`JobProposal.cta_for(pipeline_stage:, status_overlay:)` remains the single shared computation (`app/models/job_proposal.rb:70-80`). ✅ AC-02, AC-03 still conform.

---

## 3. PRD-02 — New Job Intake (v1.5)

**State: §5 DASH-required-on-tenant gating now landed; collapsed-flow gap unchanged.**

### Newly closed

- §5 DASH job number capture: `JobProposal#dash_job_number_required_when_approved` validator (`app/models/job_proposal.rb:22`) blocks Approve when the tenant carries `tenants.job_reference_required = true` and the field is blank.
- Subject-line prefix: `MailGenerator.prefix_dash_job_number` (`app/services/mail_generator.rb:145-150`) writes `[DASH-{number}]` at the front of every rendered subject, idempotent.

### Still open

| § | Item | State |
|---|---|---|
| §1 / §2 #2 / §8.4 | **Collapsed flow: nothing persists until Approve** | ❌ Unchanged. Job record is written on Submit (Upload + Create); operators who decide not to approve leave a `drafting`/`approving` row. AC-05 still fails. The deviation is now narrower in scope (DASH gating is enforced at Approve, not at Submit) but the persistence model still differs from the spec. |
| §10 | `job_created` and `campaign_approved` history events at Approve | ❌ No history table. |
| §13 | Atomic write on Approve | ⚠️ Same fragmentation as before. |

**Decision still pending:** ship the spec faithfully (defer durable write to Approve) or update PRD-02 to match the as-built upload-then-approve flow. The latter is much smaller work and the wedge #1 unblock is now in place either way.

---

## 4. PRD-03 — Campaign Engine (v1.4.1)

**State: §7.3 subject prefix now lands at send time; §6.4 versioning column exists but cohort attribution still implicit.**

### Newly closed

- §7.3 `[{job_number}]` subject prefix — `MailGenerator.prefix_dash_job_number` invoked at `app/services/mail_generator.rb:206`. Wedge #1 dependency cleared.
- §6.4 `campaigns.template_version_id` — column added; the `CampaignInstance` reads its `Campaign` parent's value implicitly. Cohort attribution at the *query* level is now possible; `CatalogLoader` does not yet populate the column on load.

### Still open (unchanged)

| § | Item | State |
|---|---|---|
| §6.4 | `template_version_id` populated on every campaign run | ⚠️ Column exists; values not written. PRD-07 §1A cohort attribution still implicit. |
| §7.2 | Render at Approve, store on `campaign_steps` | ⚠️ Still inverted — render happens at send time on `CampaignStepInstance.final_subject/body` via `CampaignSweepJob#deliver`. Mid-campaign data drift still bleeds into approved-but-unsent steps. |
| §8 | Pre-send checklist (7 conditions in order) | ⚠️ Same — gates exist but not as the explicit numbered checklist. |
| §9.2 / §9.3 | Writes to `messages` / `message_events` / `delivery_issues` tables | ❌ Tables don't exist; data lives in `campaign_step_instances` JSONB columns. |
| §10 | Stop conditions write history events | ❌ No history table. |
| §12 | Fix Issue creates a *new* `job_campaigns` row carrying `template_version_id` | ⚠️ Resume happens in place. |

---

## 5. PRD-04 — Needs Attention (v1.2.1)

**State: Unchanged. Paused jobs still excluded from the scope.**

`JobProposal.needs_attention` (`app/models/job_proposal.rb:29-37`) covers `drafting` / `approving` plus `approved + in_campaign` with overlay `customer_waiting` / `delivery_issue`. **Paused is still excluded.** Per CC-06 governance over Spec 7, Paused jobs *should* surface here with `resume_campaign` — AC-03 fails.

This is a one-line scope change but flagged in the prior report and not yet acted on; mention it again here so it doesn't keep sliding.

---

## 6. PRD-05 — Jobs List (v1.4)

**State: Mostly unchanged. Three-dot overflow + Flag Issue + Delete Job + canonical badge palette still not pinned.**

The only post-2026-05-08 change here is implicit: the dashboard surfaces `dash_job_number` via the proposal show page (commit `e66a5b7` includes view updates). The filter set is still `(search, status, owner, creator, location)`; SPEC-02 originator label still says "Owner" (`app/views/job_proposals/index.html.erb:49`).

---

## 7. PRD-06 — Job Detail (v1.3.1)

**State: Unchanged structurally. Activity Timeline still blocked on missing `job_proposal_history`.**

DASH job number now renders on the show page via the proposal model (commit `e66a5b7` adds the column and edit-form field). Everything else from §6 of the prior report stands.

---

## 8. PRD-07 — Analytics (v1.2)

**State: Materially advanced. SPEC-05 + SPEC-06 closed; Active Pipeline tile added; the recruiting-payload tiles are now in place.**

### Newly closed

- **MTD/YTD dual display** on the Conversion Rate hero tile (SPEC-05) — `app/services/analytics_calculator.rb:49-65` computes `conversion_rate_mtd_pct` / `conversion_rate_ytd_pct`; `app/views/analytics/_dashboard.html.erb:16-30` renders both inline.
- **Per-location breakdown** when "All Locations" is the scope (SPEC-06) — `app/services/analytics_calculator.rb:71-89` computes the `by_location` array; `app/views/analytics/_dashboard.html.erb:38-68` renders it as a collapsible row inside the tile, gated on `!current_user.scoped_to_location? && analytics.conversion_rate_by_location.size > 1`.
- **Active Pipeline** tile (`SUM(proposal_value) WHERE in_campaign`) — `analytics_calculator.rb:40`, view at line 87.
- **"Pending data" callout removed** from tenant view (commit `2b96dbe`) — the dashboard now reads as a real surface, not a stub.

### Still open

| Item | State |
|---|---|
| Avg Time to First Reply tile | ⚠️ Visible in the layout (`app/views/analytics/_dashboard.html.erb:96-101`) but rendered as `—` with `<em>pending inbound-message tracking</em>`. Data path needed. |
| Funnel — 5 stages with drop-off labels | ⚠️ 3 of 5 stages implemented (Activated, First-Followup-Delivered, Closed-Won); the middle two (Customer Replied, Operator Responded) are placeholders pending the same inbound-message data path. |
| Follow-Up Activity chart (grouped bars + area) | ❌ Not built. `follow_ups_by_day` data shape exists (`analytics_calculator.rb:108-114`) but no chart is rendered. |
| SPEC-05 period filter values match the canonical enum (`today | last_7d | last_30d | last_90d | month_to_date | year_to_date | custom`) | ⚠️ Still partial. |
| Cohort attribution by `template_version_id` | ⚠️ Column exists on `campaigns`; not yet plumbed. PRD-07 OQ-07 defers anyway. |

**Action:** the analytics deliverable is now ahead of where it was — the next slice is the Avg Time to First Reply data path (which would also unblock funnel stages 3–4), not more layout work.

---

## 9. PRD-08 — Settings (v1.2)

**State: §H signature inputs now complete. Audit logging on user mutations now in place.**

### Newly closed

- `users.title` (string) — `db/schema.rb:393`. Wired through invite + edit + signature (`app/services/mail_generator.rb:182, 225`).
- `invitations.title` carried through invite acceptance — `db/schema.rb:174`.
- Admin user editing from `/admin/tenants/:id` (commits `4e9c40a`, `6f82762`) — `app/controllers/admin/users_controller.rb:14` writes an `AuditLogger` row on every mutation.
- Self-edit profile path also writes audit rows (`app/controllers/users_controller.rb:35`).
- Forgot-password / password-reset end-to-end (commit `847ed5c`) with system test coverage.

### Still open

| § | Item | State |
|---|---|---|
| §11 | Path is `/tenant/{tenantId}/users/...`, verb PUT | ⚠️ URL contract still diverges (`/users` and `/admin/tenants/:tenant_id/users`); behavior is correct. |
| §10.3 | Self-removal guard ("can't remove the only Admin") | ⚠️ Verify in `Ability` / `Admin::UsersController#destroy`. |
| §6.2 | Sign Out revokes session in `sessions` table | ⚠️ Devise default; no `sessions` model. |

---

## 10. PRD-09 — Gmail Layer (v1.3.1)

**State: Unchanged. `application_mailboxes.location_id` still missing.**

`db/schema.rb:45-54` confirms `application_mailboxes` is still a singleton — no `location_id`, no `tenant_id` FK. Per-location mailboxes are still the next structural ask for PRD-09 §I; without them, signature fidelity at scale is undermined and a single revocation takes down all locations.

The plaintext `access_token` / `refresh_token` columns on both `email_delegations` and `application_mailboxes` are also still flagged for pre-launch hardening.

---

## 11. PRD-10 — SMAI Admin Portal (v1.3)

**State: Materially advanced. Account-level data fields and audit logging now landed.**

### Newly closed

- `tenants.logo_url` (string) and `has_one_attached :logo` (Active Storage) — `app/models/tenant.rb:12`, `db/schema.rb:351-358`. `Tenant#logo_image_url` resolves the blob first, falls back to the manual URL string, returns nil otherwise.
- `tenants.company_name` (string) — `MailGenerator` resolves `{company_name}` from it with fallback to `tenants.name` (`app/services/mail_generator.rb:228`).
- `tenants.job_reference_required` (boolean) — gates the DASH validator on `JobProposal`.
- `Admin::TenantsController#edit` / `#update` (`app/controllers/admin/tenants_controller.rb:36-51`) — both writes call `AuditLogger.write` with `before:` / `after:` snapshots.
- `audit_logs` table (`db/schema.rb:56-69`) with `tenant_id`, `actor_user_id`, `action`, `target_type`, `target_id`, `payload jsonb`. Indexes on `action`, `created_at`, `target_type/target_id`, `tenant_id` for the per-target audit drill.
- `AuditLogger` service (`app/services/audit_logger.rb`) called from `Admin::TenantsController`, `Admin::LocationsController`, `Admin::UsersController`, and self-service `UsersController`.

### Still open

| § | Item | State |
|---|---|---|
| §9.2 / §9A.2 | Sub-type ↔ scenario activation symmetry (sub-type only activates when ≥1 child scenario activates; scenario only activates when parent sub-type is active) | ❌ Still no symmetric guard. |
| §9B.1 | Template variant master list with `template_version_id`, `is_active`, `authoring_hypothesis`, `authored_by`, `authored_at`, `activated_at`, `deactivated_at`, `industry_classification` | ❌ `Campaign` has `template_version_id` (string) but none of the other authoring metadata columns. SPEC-11 §11 still open. |
| §9B.3 | Atomic two-step activation (new `is_active=true`, prior `is_active=false`) | ❌ Single Campaign per scenario; status enum is `{draft:0, approved:1, paused:2}` — no `is_active` boolean. |
| §10 | Audit logging for every admin write | ⚠️ **Partially closed.** `AuditLogger` covers `Admin::TenantsController`, `Admin::LocationsController`, `Admin::UsersController`. **Not yet covered:** `Admin::ScenarioActivationsController`, `Admin::JobTypeActivationsController`, `Admin::CampaignsController`, `Admin::CampaignStepsController`, `Admin::ApplicationMailboxController`, `Admin::JobTypesController`, `Admin::ScenariosController`, `Admin::IntegrationsController`, `Admin::InvitationsController`. The infrastructure is in place; the remaining controllers each need a one-line call. |

---

## 12. SPEC-02 — Originator Filter on Jobs List (v1.0)

**State: Unchanged. Still labeled "Owner."**

`app/views/job_proposals/index.html.erb:49`: `<%= label_tag :owner_id, "Owner", class: "form-label small mb-1" %>`. SPEC-02 §2 #1 calls for "Originator." Trivial fix; flagged twice now.

---

## 13. SPEC-03 — Job Type Sub-Categories (v1.3.3)

**State: Slug renames confirmed landed. Activation symmetry still not enforced.**

- ✅ `environmental_asbestos → trauma_biohazard` rename complete: `app/services/catalog_loader.rb:36` references `type_code: "trauma_biohazard"`, the `docs/campaigns/v1-output/trauma_biohazard/` directory is the live content path, and `db/seeds.rb` does not reference the old slug.
- ✅ `commercial_janitorial_deep_clean → commercial_deep_clean` rename complete: `db/seeds.rb:185` and `docs/campaigns/v1-output/general_cleaning/commercial_deep_clean.md` use the new slug; old slug not referenced.
- ⚠️ §10.3 sub-type activation gate (sub-type only activates if ≥1 scenario under it is activated) still not enforced server-side.
- ⚠️ §13.2 `scenarios.industry_classification` author-facing metadata column still missing.

---

## 14. SPEC-05 — Analytics MTD/YTD (v1.0)

**State: ✅ Closed.** See PRD-07 above. `app/services/analytics_calculator.rb:49-65` + `app/views/analytics/_dashboard.html.erb:16-30`.

---

## 15. SPEC-06 — Analytics Branch Comparison (v1.0)

**State: ✅ Closed.** See PRD-07 above. `app/services/analytics_calculator.rb:71-89` + `app/views/analytics/_dashboard.html.erb:38-68`. Role-gated on Admin + multi-location scope.

---

## 16. SPEC-07 — Originator Identity in Sent Emails (v1.2)

**State: ✅ Closed end-to-end.**

All §6 inputs are now wired:
- `users.first_name` / `users.last_name` / `users.title` / `users.phone_number` → `MailGenerator.append_signature` (`app/services/mail_generator.rb:179-189`).
- `tenants.company_name` (with fallback to `tenants.name`) → `{company_name}` merge field (`app/services/mail_generator.rb:228`).
- `tenants.logo_url` + `has_one_attached :logo` → `Tenant#logo_image_url` (`app/models/tenant.rb:35-38`). The signature builder doesn't yet emit a logo (text-only), but the data-source contract is met; HTML signature rendering is the remaining UX surface.
- Customer salutation prepended to every body (`app/services/mail_generator.rb:165-169`) — incidental SPEC-07 win since the operator doesn't have to author it per template.
- Test coverage at `test/services/mail_generator_test.rb` covers DASH prefix, salutation, signature with title, and missing-field omission.

---

## 17. SPEC-08 — Office Location Display Bug (v1.0)

**State: Unchanged.** Schema-protected (`locations.display_name NOT NULL`); regression test still not pinned.

---

## 18. SPEC-09 — Mark Won/Lost CTA Visibility (v1.2.1)

**State: Unchanged.** Mark Won / Mark Lost still on the show page header; loss-reason modal still requires `loss_reason` + `loss_notes`. The §9 history-event payload is still pending the missing `job_proposal_history` table.

---

## 19. SPEC-11 — Campaign Template Architecture (v2.0.2)

**State: Versioning column landed; activation atomicity, immutability, and authoring metadata still missing.**

- ✅ `campaigns.template_version_id` column exists (`db/schema.rb:124`).
- ❌ Column not populated by `CatalogLoader` or any seed path. Cohort attribution at runtime is moot until values land.
- ❌ §11 append-only versioning (`is_active`, `authored_by`, `authored_at`, `activated_at`, `deactivated_at`, `authoring_hypothesis`) — none added.
- ❌ §11.2 atomic two-step activation — `Campaign.status` enum (`draft/approved/paused`) is the closest analog; not the same contract.
- ❌ §11.1 content immutability — `/admin/campaigns/:id` still allows in-place edits.
- ⚠️ §10.4 render idempotency unchanged.

The migration that added `template_version_id` is the foothold; the rest of SPEC-11 is the remaining structural debt.

---

## 20. SPEC-12 — Template Authoring Methodology (v2.0)

**State: Out of scope for engineering** — content authoring methodology. 17 v1 active variants still load via `CatalogLoader`.

---

## 21. Cross-cutting findings (refreshed)

What carried over from the prior report and what's now resolved:

1. ~~**No `audit_logs` table.**~~ ✅ Closed for the data layer; controllers behind admin (5/14) write rows. The remaining 9 admin controllers need a one-line `AuditLogger.write` each.
2. ~~**No `tenants.logo_url` / `tenants.company_name`.**~~ ✅ Closed.
3. ~~**No `users.title`.**~~ ✅ Closed.
4. ~~**No `tenants.job_reference_required` / `job_proposals.dash_job_number` / subject prefix.**~~ ✅ Closed end-to-end.
5. ~~**Analytics MTD/YTD + per-location breakdown not built.**~~ ✅ Closed (SPEC-05 + SPEC-06).
6. **No `job_proposal_history` table.** ❌ Still open. Single biggest contract gap. Blocks PRD-01 §12, PRD-04 §9, PRD-06 §10, SPEC-09 §9, audit-trail discipline.
7. **No `messages` / `message_events` / `delivery_issues` tables.** ⚠️ Still collapsed into `campaign_step_instances` JSONB. Document via ADR.
8. **`drafting`/`approving` job statuses contradict PRD-01's "Pending Approval eliminated."** ⚠️ Unchanged.
9. **Render at send time (not Approve time).** ⚠️ Unchanged.
10. **Sidekiq cron polling instead of Cloud Tasks + Pub/Sub.** ⚠️ Unchanged; ADR worth writing.
11. **OAuth tokens stored plaintext.** ⚠️ Unchanged. `email_delegations` and `application_mailboxes` carry `access_token` / `refresh_token` as plain `text`. Pre-launch hardening.
12. **`application_mailboxes` still singleton.** ⚠️ Unchanged. PRD-09 §5.1 one-per-location.
13. **`campaigns.template_version_id` exists but is never populated.** ⚠️ New finding — column landed in `30bb274` but `CatalogLoader` doesn't write to it. Cohort attribution remains implicit.
14. **`needs_attention` scope still excludes Paused.** ⚠️ One-line fix; flagged twice now.
15. **SPEC-02 originator filter still labeled "Owner."** ⚠️ Trivial; flagged twice now.

---

## 22. Recommended next-up sequence

The wedge-#1 / signature-fidelity / analytics demo deliverables from the prior report are now in place. The remaining work, in priority order:

1. **`AuditLogger.write` on the remaining 9 admin controllers** (PRD-10 §10). Mechanical; one PR.
2. **`needs_attention` scope includes Paused** (PRD-04 §6 / AC-03). One-line scope change.
3. **SPEC-02 rename** — `Owner` → `Originator` filter label and param. Trivial.
4. **`job_proposal_history` table + writes from every transition controller and job** (PRD-01 §12). Unlocks PRD-04 feed, PRD-06 timeline, SPEC-09 §9 payload.
5. **`application_mailboxes.location_id`** (PRD-09 §5.1). Migration + lookup refactor in `ApplicationMailbox.current`.
6. **Reconcile `JobProposal#status: drafting/approving/approved` with PRD-01 v1.4's "no Pending Approval" rule** — either drop the states or update PRD-01 to match the as-built upload-then-approve flow. The latter is much smaller work and arguably no worse for the operator.
7. **Inbound-message tracking** to unblock the funnel stages 3–4 and Avg Time to First Reply tile (PRD-07 §1A).
8. **`Campaign` versioning** — full SPEC-11 §11 (`is_active`, authoring metadata, activation atomicity, content immutability). The `template_version_id` column is the foothold; the rest of the contract is what's left.
9. **OAuth token encryption at rest** (PRD-09 §7.1 deviation — pre-launch hardening).
10. **Render at Approve time** (PRD-03 §7.2 / SPEC-11 §10.2). Pin behavior either way with a regression test.

Items 1–3 are zero-risk same-day work. Items 4 + 5 are the next real structural lifts. Items 6–10 are scope decisions or pre-launch hardening.

---

## Caveats

- This pass reads code, schema, services, jobs, and routes against HEAD `673f81f`. It does not run the test suite or exercise the live UI.
- The companion CC-06 v1.2 report ([`2026-05-09_MVP_v1.2_assessment.md`](2026-05-09_MVP_v1.2_assessment.md)) is the ground-truth pilot-readiness check; this report is the per-PRD/per-SPEC drill-down beneath it.
- Issue numbers in §0 reference [ServiceMark-AI/smai-nuggets](https://github.com/ServiceMark-AI/smai-nuggets/issues) per the repo split convention.
