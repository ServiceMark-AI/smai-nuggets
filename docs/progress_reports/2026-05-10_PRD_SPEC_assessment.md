# Project assessment vs. PRDs and SPECs

**Date:** 2026-05-10
**Targets:** [`docs/prd/PRD-01..PRD-10`](../prd/), [`docs/specs/SPEC-02..SPEC-12`](../specs/)
**Source of truth (current):** repo at HEAD on `main` (commit `b7f9810`)
**Predecessor report:** [`2026-05-09_PRD_SPEC_assessment.md`](2026-05-09_PRD_SPEC_assessment.md)
**Companion report:** [`2026-05-10_MVP_v1.2_assessment.md`](2026-05-10_MVP_v1.2_assessment.md)
**Scope:** Code, schema, seed, jobs, services. Excludes content authoring (campaign markdown).

---

## 0. What changed since 2026-05-09

The biggest gaps from the prior report — `job_proposal_history` and `Campaign` versioning + atomic activation — both substantially closed in the last 24 hours.

| PR | Commit | Effect |
|---|---|---|
| [#176](https://github.com/ServiceMark-AI/smai-nuggets/pull/176) | `5cda63f`, `874927c`, `4cca111`, `42a2562` | `loss_reasons` table (six product-defined codes) + FK on `job_proposals` (replacing free-text `loss_reason`); Mark Lost dropdown; "Why we lost this job" card on the proposal show page; Analytics pie chart with `loss_reasons_breakdown`. |
| [#178](https://github.com/ServiceMark-AI/smai-nuggets/pull/178) | `1a9bc3f`, `9034633`, `206d3bb`, `c150f9a` | `campaign_revisions` table with `drafting`/`active`/`retired` enum + partial unique index for one-active-per-campaign; `campaign_steps.campaign_revision_id` and `campaign_instances.campaign_revision_id` FKs (NOT NULL after backfill); `Admin::CampaignRevisionsController#create / #approve` (atomic flip); revision show page with edit-when-drafting; Campaign show page now reads-only with a Revisions table at the bottom. |
| [#179](https://github.com/ServiceMark-AI/smai-nuggets/pull/179) | `28cc907`, `2245107` | Bugsnag → Sentry for server-side error reporting (`sentry-ruby` + `sentry-rails`, JSON-DSN env var, `Admin → Integrations` row). Browser-side Bugsnag JS dropped. |
| [#180](https://github.com/ServiceMark-AI/smai-nuggets/pull/180) | `d7e5e9f`, `778bcb7` | Admin Job Prompt: current revision pinned in full at the top, table of older revisions below, per-revision show page. |
| [#181 / #182](https://github.com/ServiceMark-AI/smai-nuggets/pull/182) | `c66c28a`, `acbfcfd`, `dfe6e88` | Cross-tenant **Users** index under Platform Admin; tenant filter + name/email search; sidebar `controller_path` scoping fix so Team and admin Users don't both highlight on `/admin/users`. |
| [#183](https://github.com/ServiceMark-AI/smai-nuggets/pull/183) | `11dd14b`, `fbb3460`, `234aa1a`, `b7f9810` | `paper_trail` adopted with a locked-down `Version` subclass (`readonly?`, `before_update` / `before_destroy` raise) and JSON serializer; `JobProposal` wired with `has_paper_trail`; whodunnit captured via `ApplicationController#set_paper_trail_whodunnit`; Activity card on the proposal show page; per-version detail page at `/job_proposals/:id/histories/:id`. |
| (n/a) | (in PR #178) | `CampaignSweepJob` now routes through `CampaignStepMailer` → Action Mailer → letter_opener_web in development regardless of mailbox state, eliminating the "dev mailbox accidentally relays to a real customer" failure mode. |

Net effect: 4 of the 5 items in the 2026-05-09 §22 priority list are now closed (audit logging is the holdout, mechanical). The two remaining structural lifts are **`application_mailboxes.location_id`** and **inbound-message tracking** for the analytics tiles still rendered as `—`.

---

## 1. Architectural delta

Unchanged from prior report. The PRD/SPEC suite was authored against Kotlin/Micronaut + Firestore + Cloud Tasks + Pub/Sub; the repo is Rails 8.1 on Postgres + Sidekiq cron. Notable updates:

- `versions` table (paper_trail) exists. Schema: `item_type`, `item_id`, `event`, `whodunnit`, `object` (text), `object_changes` (text). The serializer is JSON (`config/initializers/paper_trail.rb`) — the default YAML safe-loader rejects `ActiveSupport::TimeWithZone`, which silently empties `version.changeset` whenever an update touches a timestamp column.
- `campaign_revisions` is the new authoring-version table (see §19 below). The previously-foothold-only `campaigns.template_version_id` is effectively superseded.
- `loss_reasons` is a small reference/lookup table (six codes, no tenant scope).

The product-level loop (intake → approve → send → stop on reply / failure / pause) remains end-to-end functional and now produces durable per-event history rows on every JobProposal mutation.

---

## 2. PRD-01 — Job Record (v1.4.1)

**State: §12 history table now closed via `paper_trail`. Append-only audit trail is durable; field-lock and "Pending Approval eliminated" still open.**

### Newly closed

- §2 #5 / §12 **Append-only history**. `paper_trail` adopted with a locked-down `Version` subclass that enforces `readonly?` plus `before_update` / `before_destroy` raises — once persisted, a row cannot be edited or deleted from Rails. Every create / update on `JobProposal` writes a `Version` row with `event`, `whodunnit`, `object_changes`. `updated_at` is on the ignore list so a noop touch doesn't produce a row.
- AC-04 ("All field changes write history events") now passes for `JobProposal` — every column except `updated_at` is captured in the changeset.
- Loss-reason history (SPEC-09 §9) rides this same path: `mark_lost` writes both `pipeline_stage` and `loss_reason_id` changes to the same `Version` row.

### Still open

| § | Item | State |
|---|---|---|
| §6 / §7 | "Pending Approval eliminated" | ⚠️ Unchanged. `JobProposal.status: { drafting:0, approving:1, approved:2 }` is still the model. The behavior matches the spec end-to-end; the internal-state model still carries states v1.4 explicitly removed. |
| §10 | Field locks server-side | ⚠️ Unchanged — no PATCH-time write rejections. |
| §12 (other models) | Other models surfaced in the timeline | ⚠️ Only `JobProposal` is currently `has_paper_trail`. Future PRDs that want CampaignInstance / CampaignStepInstance / CampaignRevision events in the same timeline would need their own opt-in. |

`JobProposal.cta_for(pipeline_stage:, status_overlay:)` remains the single shared computation. ✅ AC-02 / AC-03 still conform.

---

## 3. PRD-02 — New Job Intake (v1.5)

**State: Unchanged. Collapsed-flow gap remains.**

| § | Item | State |
|---|---|---|
| §1 / §2 #2 / §8.4 | Collapsed flow: nothing persists until Approve | ❌ Unchanged. Decision still pending. |
| §10 | `job_created` and `campaign_approved` history events at Approve | ✅ **Now riding paper_trail.** Every JobProposal `update!` writes a Version row; the field-level changeset captures status transitions implicitly. The "history event taxonomy" of `job_created` / `campaign_approved` is a query-layer concept that can be derived from `event = "create"` + `event = "update" WHERE 'status' IN object_changes`. |
| §13 | Atomic write on Approve | ⚠️ Same fragmentation as before. |

---

## 4. PRD-03 — Campaign Engine (v1.4.1)

**State: §6.4 cohort attribution now durable via `campaign_revisions`. Render-at-Approve still inverted.**

### Newly closed

- §6.4 — **`CampaignInstance.campaign_revision_id`** (NOT NULL) now ties every running customer sequence to the exact revision it launched against. `CampaignLauncher.launch` records `campaign_revision: campaign.active_revision` at instance-create time. An admin who approves a new revision later does not affect any in-flight instance — they keep their old steps until they complete or stop. This is the substantive PRD-03 §6.4 contract; the prior `campaigns.template_version_id` (string) column predates this work and is now arguably obsolete.

### Still open

| § | Item | State |
|---|---|---|
| §6.4 | `template_version_id` populated on every campaign run | ⚠️ Now superseded — `campaign_instances.campaign_revision_id` is the durable cohort key. PRD-07 cohort attribution should pivot to `(campaign_id, revision_number)` going forward. |
| §7.2 | Render at Approve, store on `campaign_steps` | ⚠️ Still inverted — render still happens at send time on `CampaignStepInstance.final_subject/body` via `CampaignSweepJob#deliver`. |
| §8 | Pre-send checklist (7 conditions in order) | ⚠️ Same — gates exist but not as the explicit numbered checklist. |
| §9.2 / §9.3 | Writes to `messages` / `message_events` / `delivery_issues` tables | ❌ Tables don't exist. |
| §10 | Stop conditions write history events | ✅ Indirectly closed for `JobProposal` — `pipeline_stage` and `status_overlay` changes are captured by paper_trail. ❌ Still open for `CampaignInstance` and `CampaignStepInstance`, neither of which has paper_trail. |
| §12 | Fix Issue creates a *new* `job_campaigns` row carrying `template_version_id` | ⚠️ Resume happens in place. |

---

## 5. PRD-04 — Needs Attention (v1.2.1)

**State: Activity-feed contract closed via the proposal-show timeline. Paused-jobs-in-scope still open.**

### Newly closed

- §9 "Handled by SMAI" feed shape — the proposal show page now carries an Activity card listing every paper_trail Version newest-first, with humanized summary, actor (resolved from whodunnit), time-ago, and event badge. Each row links to a per-version detail page that renders the field-level changeset. The PRD's "operator-readable feed of what the system has done" contract is met for JobProposal events. CampaignInstance / CampaignStepInstance events would need their own paper_trail opt-in to surface here.

### Still open

| § | Item | State |
|---|---|---|
| §6 / AC-03 | Paused jobs surface in `needs_attention` with `resume_campaign` | ❌ Unchanged. **Flagged on three consecutive reports now.** One-line scope change in `app/models/job_proposal.rb:29-37`. |

---

## 6. PRD-05 — Jobs List (v1.4)

**State: Unchanged. SPEC-02 originator label still says "Owner."** Three-dot overflow + Flag Issue + Delete Job + canonical badge palette still not pinned.

`app/views/job_proposals/index.html.erb:49` still labels the filter `Owner`. **Flagged on three consecutive reports now.**

---

## 7. PRD-06 — Job Detail (v1.3.1)

**State: §10 Activity Timeline now closed; §"Resolved template version" badge now lands.**

### Newly closed

- §10 **Activity Timeline.** Renders every paper_trail Version newest-first; each entry links to a per-version detail page; loss-reason changes write meaningful history payloads (the dropdown ID change is captured alongside the `pipeline_stage` flip).
- "Why we lost this job" card on `pipeline_stage_lost?` proposals (between the Job and Campaign cards). Surfaces `loss_reason.display_name` + `loss_notes`.
- **Resolved revision badge.** The Campaign card on the show page now reads `<campaign name> — Revision #<n>` linking to the campaign-instance detail page. Closes [#153](https://github.com/ServiceMark-AI/smai-nuggets/issues/153) by way of `campaign_instance.campaign_revision` rather than the original `campaigns.template_version_id` plumbing.

### Still open

Field-level locks still not enforced (PRD-01 §10 inheritance).

---

## 8. PRD-07 — Analytics (v1.2)

**State: "Why we lost" pie added; engagement-side metrics still pending the same data path.**

### Newly closed

- **Why we lost — pie chart at the bottom of the dashboard.** `AnalyticsCalculator#loss_reasons_breakdown` rolls up lost jobs by reason in `sort_order`; the view renders a CSS conic-gradient pie + a legend table. NULL `loss_reason_id` rows bucket as "Unspecified" so the slices always sum to `lost_count`. Empty-state copy when nothing is lost.

### Still open

Same as 2026-05-09:

| Item | State |
|---|---|
| Avg Time to First Reply tile | ⚠️ Placeholder pending inbound-message tracking. |
| Funnel — 5 stages | ⚠️ 3 of 5 stages live; stages 3 (Customer Replied) and 4 (Operator Responded) still pending. |
| Follow-Up Activity chart (grouped bars + area) | ❌ Not built. |
| SPEC-05 period filter values match canonical enum | ⚠️ Still partial. |
| Cohort attribution | ⚠️ Now feasible via `campaign_instances.campaign_revision_id`. PRD-07 OQ-07 still defers; whenever it's revisited, pivot the join to `campaign_revisions` rather than the legacy `campaigns.template_version_id`. |

**Action:** unchanged — the next slice is the inbound-message data path that unblocks reply-rate, time-to-first-reply, and funnel stages 3–4.

---

## 9. PRD-08 — Settings (v1.2)

**State: Unchanged structurally. Cross-tenant Users index added under Platform Admin.**

### Newly closed (peripheral)

- **Platform Admin → Users index** (PR #181/#182). Cross-tenant flat list with tenant filter + free-text search across email + first / last name + concatenated full name. Edit links route through the existing `/admin/tenants/:tenant_id/users/:id/edit` so the audit-logged edit path keeps doing the work. Doesn't touch the §H operator-side contract.

### Still open

Same as 2026-05-09 — URL contract, self-removal guard, sessions-table semantics.

---

## 10. PRD-09 — Gmail Layer (v1.3.1)

**State: Unchanged. `application_mailboxes.location_id` still missing. Dev relay risk now mitigated.**

### Newly mitigated (not a contract closure)

- `CampaignSweepJob` now routes through `CampaignStepMailer` → Action Mailer → `letter_opener_web` in development regardless of mailbox state. A connected dev account cannot accidentally relay a campaign step to a real customer. Production / staging behavior unchanged. Test coverage in `test/jobs/campaign_sweep_job_test.rb`.

### Still open

Same singletons, same plaintext token storage, same per-location mailbox gap.

---

## 11. PRD-10 — SMAI Admin Portal (v1.3)

**State: §9B template variant master list materially closed via `campaign_revisions`. Audit-logging coverage and authoring-metadata still partial.**

### Newly closed

- **§9B.1 template variant master list.** `campaign_revisions` provides `revision_number` (the version key), `status` enum (`drafting`/`active`/`retired`), `created_by_user`, `approved_by_user`, `approved_at`. Surfaced on the Campaign show page (Revisions table at the bottom).
- **§9B.3 atomic two-step activation.** `Admin::CampaignRevisionsController#approve` runs the previous-active-→-retired transition and the draft-→-active transition in the same database transaction. Combined with the partial unique index on `campaign_revisions.campaign_id WHERE status = 1`, the only-one-active invariant is enforced both at the model layer (validation) and the DB layer (constraint).
- **§11.1 content immutability.** `Admin::CampaignStepsController` (now nested under revisions) refuses any mutation when the parent revision isn't `:drafting`. Active and retired revisions are read-only; the only way to change content is to spawn a new draft from the active revision, edit, and approve. `CampaignRevision.spawn_draft_from_active` clones every step verbatim into the new revision so an in-flight operator can iterate without affecting live customer sequences.
- **Cross-tenant Admin → Users index** (PR #181/#182). See §9 above.
- **Admin → Job Prompt: per-revision show page** (PR #180). `pdf_processing_revisions` resources now expose `:show` so admins can read the full instructions for any prior revision (the index used to truncate to 200 chars).
- **Sentry replaces Bugsnag** (PR #179). `Admin → Integrations` row now reads `Sentry (error reporting)`; sidebar link target retargeted; bundled fallback DSN captures errors out-of-the-box.

### Still open

| § | Item | State |
|---|---|---|
| §9.2 / §9A.2 | Sub-type ↔ scenario activation symmetry | ❌ Still no symmetric guard. |
| §9B.1 (residual) | `authoring_hypothesis` on the revision row | ❌ Not yet a column on `campaign_revisions`. |
| §9B.1 (residual) | `industry_classification` on `scenarios` | ❌ Still missing — SPEC-03 §13.2. |
| §9B.1 (residual) | Explicit `deactivated_at` timestamp on retired revisions | ⚠️ Currently inferred from `updated_at` when status flipped to `:retired`. Not separately tracked. |
| §10 | Audit logging for every admin write | ⚠️ **Partially closed, unchanged scope.** `AuditLogger` covers `Admin::TenantsController`, `Admin::LocationsController`, `Admin::UsersController`, self-service `UsersController`. **Not yet covered:** `Admin::ScenarioActivationsController`, `Admin::JobTypeActivationsController`, `Admin::CampaignsController`, `Admin::CampaignStepsController`, `Admin::CampaignRevisionsController` (new), `Admin::ApplicationMailboxController`, `Admin::JobTypesController`, `Admin::ScenariosController`, `Admin::IntegrationsController`, `Admin::InvitationsController`. |

---

## 12. SPEC-02 — Originator Filter on Jobs List (v1.0)

**State: Unchanged. Still labeled "Owner."** Flagged on three consecutive reports.

---

## 13. SPEC-03 — Job Type Sub-Categories (v1.3.3)

**State: Unchanged.** Slug renames still landed; activation symmetry + `scenarios.industry_classification` still missing.

---

## 14. SPEC-05 — Analytics MTD/YTD (v1.0)

**State: ✅ Closed.** Unchanged.

---

## 15. SPEC-06 — Analytics Branch Comparison (v1.0)

**State: ✅ Closed.** Unchanged.

---

## 16. SPEC-07 — Originator Identity in Sent Emails (v1.2)

**State: ✅ Closed end-to-end.** Unchanged from 2026-05-09.

---

## 17. SPEC-08 — Office Location Display Bug (v1.0)

**State: Unchanged.** Schema-protected (`locations.display_name NOT NULL`); regression test still not pinned.

---

## 18. SPEC-09 — Mark Won/Lost CTA Visibility (v1.2.1)

**State: §9 history-event payload now meaningful. Loss-reason taxonomy now constrained.**

### Newly closed

- **§9 history-event payload on Mark Lost.** When an operator submits the Mark Lost modal, `JobProposalsController#mark_lost` flips `pipeline_stage` *and* sets `loss_reason_id` + `loss_notes` in one transaction; paper_trail records both changes on the same Version row. The audit trail now captures who picked which reason and when — the spec's stated outcome.
- **Loss-reason taxonomy.** Six product-defined codes via the `loss_reasons` table (`price_too_high`, `went_with_competitor`, `insurance_issue`, `no_response_from_customer`, `timing_scheduling_conflict`, `other`); the modal renders them as a dropdown. Replaces free text.
- **Surfacing.** "Why we lost this job" card on the proposal show page renders the picked reason + notes for `pipeline_stage_lost?` proposals; the analytics dashboard rolls them up in a pie at the bottom.

### Still open

`Mark Won / Mark Lost` CTA visibility itself remains unchanged from prior report — buttons on the proposal show page header.

---

## 19. SPEC-11 — Campaign Template Architecture (v2.0.2)

**State: Versioning + atomicity + immutability now landed via `campaign_revisions`. Authoring-metadata still partial.**

### Newly closed

- **§11 append-only versioning.** `campaign_revisions` table with `revision_number` (per-campaign monotonic), `status` enum (`drafting:0`, `active:1`, `retired:2`), `created_by_user_id` (NOT NULL), `approved_by_user_id` (optional), `approved_at`, timestamps.
- **§11.2 atomic two-step activation.** The flip-and-retire happens in one DB transaction inside `Admin::CampaignRevisionsController#approve`. A partial unique index on `campaign_revisions.campaign_id WHERE status = 1` enforces only-one-active at the DB layer, layered on top of the model's `only_one_active_per_campaign` validator. Belt-and-suspenders.
- **§11.1 content immutability.** Step routes are now nested under revisions (`/admin/campaigns/:campaign_id/revisions/:revision_id/steps/...`). `Admin::CampaignStepsController` rejects any mutation (create / update / destroy / reorder) when `revision.status_drafting?` is false. Active and retired revisions are read-only; "edit" means "spawn a new draft, modify the steps, approve".
- **§7.3 / §6.4 cohort attribution.** `campaign_instances.campaign_revision_id` (NOT NULL) records which revision a customer sequence launched against. In-flight customers stay on their revision regardless of subsequent activations, closing the "we updated templates and ruined an in-flight customer" failure mode the spec called out.
- **§10.2 render at send time vs. approve time** — still inverted (PRD-03 §7.2), but the cohort-attribution column makes the send-time render bind to a specific revision rather than to the live campaign template. The render-time drift surface is reduced even though the contract isn't fully satisfied.

### Still open

| § | Item | State |
|---|---|---|
| §11 | `authoring_hypothesis`, `industry_classification` columns | ❌ Not yet added. |
| §11 | Explicit `deactivated_at` (vs. inferring from `updated_at` on status flip) | ⚠️ Inferable; not a column. |
| §11 | `campaigns.template_version_id` (string) | ⚠️ Now arguably obsolete — superseded by `(campaign_id, revision_number)`. Worth a follow-up cleanup. |
| §10.2 | Render at Approve, store on the revision's steps | ❌ Still send-time render. |
| §10.4 | Render idempotency | ⚠️ unchanged. |

---

## 20. SPEC-12 — Template Authoring Methodology (v2.0)

**State: Out of scope for engineering** — content authoring methodology. Still loaded via `CatalogLoader`.

---

## 21. Cross-cutting findings (refreshed)

What carried over from the prior report and what's now resolved:

1. ~~No `audit_logs` table.~~ ✅ Closed for the data layer; **9 admin controllers still need a one-line `AuditLogger.write` each**.
2. ~~No `tenants.logo_url` / `tenants.company_name`.~~ ✅ Closed earlier.
3. ~~No `users.title`.~~ ✅ Closed earlier.
4. ~~No `tenants.job_reference_required` / `job_proposals.dash_job_number`.~~ ✅ Closed earlier.
5. ~~Analytics MTD/YTD + per-location breakdown not built.~~ ✅ Closed earlier.
6. ~~No `job_proposal_history` table.~~ ✅ **Closed via `paper_trail`**. PRD-01 §12, PRD-04 §9, PRD-06 §10, SPEC-09 §9 contracts now meet the "append-only audit trail with actor + payload" bar. **Caveat:** only `JobProposal` is paper-trailed; other models would need their own opt-in.
7. **No `messages` / `message_events` / `delivery_issues` tables.** ⚠️ Still collapsed into `campaign_step_instances` JSONB. Document via ADR.
8. **`drafting`/`approving` job statuses contradict PRD-01's "Pending Approval eliminated."** ⚠️ Unchanged.
9. **Render at send time (not Approve time).** ⚠️ Unchanged (PRD-03 §7.2 / SPEC-11 §10.2).
10. **Sidekiq cron polling instead of Cloud Tasks + Pub/Sub.** ⚠️ Unchanged; ADR worth writing.
11. **OAuth tokens stored plaintext.** ⚠️ Unchanged. Pre-launch hardening.
12. **`application_mailboxes` still singleton.** ⚠️ Unchanged. PRD-09 §I one-per-location.
13. ~~`campaigns.template_version_id` populated by loader.~~ ✅ Effectively superseded — `(campaign_id, campaign_revisions.revision_number)` is the durable cohort key. The original column is now obsolete.
14. **`needs_attention` scope still excludes Paused.** ⚠️ One-line fix; **flagged on three consecutive reports**.
15. **SPEC-02 originator filter still labeled "Owner."** ⚠️ Trivial; **flagged on three consecutive reports**.
16. **No `authoring_hypothesis` / `industry_classification`** (SPEC-11 §11 / SPEC-03 §13.2 author-facing metadata). New finding-equivalent — exposed as a residual gap once `campaign_revisions` closed the structural part.
17. **Browser-side error tracking dropped** in the Sentry swap (PR #179). Server-side unchanged; client-side is now uninstrumented. Worth restoring before pilot.

---

## 22. Recommended next-up sequence

The two big structural lifts from the prior report are closed. Refreshed priority list:

1. **`AuditLogger.write` rollout to the remaining 9 admin controllers** (PRD-10 §10). Mechanical; one PR. **Same #1 as 2026-05-09 — worth pulling in next.**
2. **`needs_attention` scope includes Paused** (PRD-04 §6 / AC-03). One-line scope change. **Flagged on three consecutive reports.**
3. **SPEC-02 rename — `Owner` → `Originator`.** Trivial. **Flagged on three consecutive reports.**
4. **`application_mailboxes.location_id`** + per-location lookup in `ApplicationMailbox.current` (PRD-09 §I).
5. **Inbound-message tracking** to unblock funnel stages 3–4, the Avg Time to First Reply tile, and the originator reply-rate column (PRD-07 §1A).
6. **Authoring metadata fill-in** for SPEC-11: `campaign_revisions.authoring_hypothesis`, `scenarios.industry_classification`, optionally an explicit `campaign_revisions.deactivated_at`.
7. **paper_trail rollout to `CampaignInstance` / `CampaignStepInstance` / `CampaignRevision`** if the activity timeline should also surface those state transitions. Optional and PRD-driven.
8. **Reconcile `JobProposal#status: drafting/approving/approved` with PRD-01 v1.4's "no Pending Approval" rule** — ship the spec or update the spec.
9. **OAuth token encryption at rest** (PRD-09 §7.1 deviation — pre-launch hardening).
10. **Render at Approve time** (PRD-03 §7.2 / SPEC-11 §10.2). Pin behavior either way with a regression test.
11. **Browser-side Sentry SDK** in `application.html.erb` (post-Bugsnag-swap regression).
12. **Drop or repurpose `campaigns.template_version_id`** (legacy column now superseded by `(campaign_id, revision_number)`).

Items 1–3 are still zero-risk same-day work. Item 4 is the next real structural lift. Item 5 is the binding constraint on closing PRD-07 fully. Item 6 closes SPEC-11 completely.

---

## Caveats

- This pass reads code, schema, services, jobs, and routes against HEAD `b7f9810`. It does not run the test suite or exercise the live UI.
- The companion CC-06 v1.2 report ([`2026-05-10_MVP_v1.2_assessment.md`](2026-05-10_MVP_v1.2_assessment.md)) is the ground-truth pilot-readiness check; this report is the per-PRD/per-SPEC drill-down.
- Issue / PR numbers in §0 reference [ServiceMark-AI/smai-nuggets](https://github.com/ServiceMark-AI/smai-nuggets/issues) per the repo split convention.
- The `paper_trail` choice was made late in the cycle (initial implementation began as a hand-rolled `JobProposalHistory` table before swapping). The contract is met; the storage layer is generic. If a future PRD wants per-event history queries that benefit from a denormalized table, a materialized view off `versions WHERE item_type = 'JobProposal'` is the cheaper path than re-implementing.
