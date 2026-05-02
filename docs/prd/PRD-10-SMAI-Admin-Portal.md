# PRD-10: SMAI Admin Portal

---

## 0. Document Meta

| Field | Value |
|-------|-------|
| PRD name | SMAI Admin Portal |
| PRD ID | PRD-10 |
| Version | 1.3 |
| Status | Ready for build |
| Date | 2026-04-27 |
| Product owner | Kyle |
| Tech lead | Mark |
| Source | Admin Portal Memo 2026-04-20; SPEC-07 v1.1 (signature composition data dependencies); SPEC-03 v1.3.3 §10 (two-layer governance for job types AND scenarios; sub-type and scenario rename surgery); SPEC-11 v2.0.1 §11.2 (template variant activation, two-step atomic; master list scope vs tenant activation scope clarification); SPEC-12 v2.0 (template authoring methodology, rebased); PRD-01 v1.4.1 (canonical schema including `scenario_key` on `job_proposals` and `template_version_id` on `campaigns`); PRD-02 v1.5 (collapsed intake flow); PRD-03 v1.4.1 (campaign engine with template lookup); PRD-08 v1.2 (explicit deferral of location/account editing to the Admin Portal); PRD-09 v1.3.1 (Gmail Layer, one mailbox per location); Jeff's 2026-04-18 clarification on single-location Originators; Jeff feedback round 2026-04-25/26 (v1 authoring scope reduction to 17 variants for Jeff's tenant); Save State 2026-04-21 (templated architecture, scenario layer, Pending Approval elimination) |
| Related docs | PRD-08 v1.2 Settings; PRD-02 v1.5 New Job Intake; PRD-09 v1.3.1 Gmail Layer; SPEC-07 v1.1 Originator Identity; SPEC-03 v1.3.3 Job Type and Scenario; SPEC-11 v2.0.1 Campaign Template Architecture; SPEC-12 v2.0 Template Authoring; PRD-01 v1.4.1, PRD-03 v1.4.1, PRD-06 v1.3.1, PRD-05 v1.4, PRD-04 v1.2.1, PRD-07 v1.2; CC-06 Buc-ee's MVP Definition |
| Tracking issues | [#106 A account+location CRUD](https://github.com/frizman21/smai-server/issues/106) · [#107 B logo upload](https://github.com/frizman21/smai-server/issues/107) · [#108 C tenant job type activation](https://github.com/frizman21/smai-server/issues/108) · [#109 G tenant scenario activation](https://github.com/frizman21/smai-server/issues/109) · [#110 H template variant management](https://github.com/frizman21/smai-server/issues/110) · [#111 D/E/F/I/J/K/L post-pilot frontend (umbrella)](https://github.com/frizman21/smai-server/issues/111) |

**Revision note (v1.0):** Initial draft. Defines the SMAI Admin Portal: the internal, SMAI-staff-facing control plane for tenant configuration. Consolidates what was previously a standalone Location Configuration PRD with the broader set of Admin Portal capabilities surfaced in the Admin Portal Scope Memo (2026-04-20): account-level configuration, location-level CRUD, tenant job type activation (per SPEC-03 v1.2 §10), and audit logging. **Scope posture for Buc-ee's pilot:** the Admin Portal frontend need not ship in full for Jeff's go-live. What must ship is the complete backend surface (endpoints, validation, audit logging, and schema) against which SMAI staff configure Jeff's tenant via direct API calls, scripts, or controlled DB writes. The Admin Portal frontend is the long-term operator posture and the scalable configuration path for tenant #2 onward, but it is not a go-live gate. This framing is made explicit throughout the PRD and in the §15 slice priorities.

**Revision note (v1.2):** Three related changes tied to the 2026-04-21 strategic commitments. Surgical scope: only what SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0, PRD-01 v1.4, PRD-02 v1.5, PRD-03 v1.4, PRD-06 v1.3, PRD-05 v1.3, PRD-04 v1.2, and PRD-07 v1.2 drive. Nothing else. v1.1 was never cut; this version jumps from v1.0 to v1.2 to align the number with the sibling PRDs in the v1.3 cycle.

1. **Scenario taxonomy governance added as a peer to Job Type governance.** Per SPEC-03 v1.3 §10, the two-layer governance model (global master list + per-tenant activation) now covers scenarios in addition to job types. Every tenant has a scenario activation join scoped by `tenant_id` and `scenario_id`, with scenarios scoped to their parent job type. `industry_classification` author-facing metadata per scenario master list record (SPEC-03 v1.3 §13.2) is stored and surfaced to template authors; never exposed to operators or customers. New §9A Tenant Scenario Activation section added. New endpoints at `/admin/scenarios` and `/admin/accounts/{accountId}/scenarios`. Scenario seeds added to §12.

2. **Campaign template variant management added as a new core capability.** Per SPEC-11 v2.0 §11.2 and §7.1, the Admin Portal is the activation surface for campaign template variants. Template variants are keyed by (`job_type`, `scenario_key`), stored append-only with `template_version_id`, `is_active`, `authoring_hypothesis`, `authored_by`, `authored_at`, `activated_at`, `deactivated_at`, and (optionally) `industry_classification` inherited from the scenario. Activation is atomic and two-step per SPEC-11 v2.0 §11.2: the new variant flips to `is_active = true` and the prior active variant flips to `is_active = false` within one transaction. New §9B Campaign Template Variant Management section added. New endpoints at `/admin/template-variants`. Loader mechanism deferred to Mark per SPEC-11 v2.0 §12; activation endpoint is required regardless of loader path. Template seed approach documented in §12.5.

3. **Job type taxonomy refresh.** Per SPEC-03 v1.3 §7.1 (refined 2026-04-21 per Jeff's input), the seven active Restoration sub-types are now Contents, Environmental / Asbestos, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Water Mitigation. Supersedes the prior seven-value list. §12.3 job type master list seed and §12.4 tenant activation seed updated. AC on §16 updated. The prior taxonomy's values (Water Damage, Fire & Smoke, Storm Damage, Biohazard / Sewage, Contents / Pack-Out, Specialty Cleaning) are NOT in the SPEC-03 v1.3 master list; they must not be seeded.

Material section changes in v1.2: §0 (meta refresh, v1.2 revision note), §2 (builder points on scenario governance, template governance, industry_classification), §3 (scope expansion for scenarios and templates), §4 (locked constraints updated), §5 (actors and objects expanded), §6 (workflows expanded), §9 (SPEC-03 reference updated to v1.3), new §9A (Tenant Scenario Activation), new §9B (Campaign Template Variant Management), §10 (audit log event list expanded), §12 (job type taxonomy refresh, scenario seed, template seed notes), §13 (operator product reads extended), §15 (new slices for scenario and template activation), §16 (new ACs), §17 (open questions updated), §18 (system boundaries extended), §19 (out of scope updated).

**Patch note (2026-04-22):** Bulk reference update: all 9 occurrences of "PRD-09 v1.2" replaced with "PRD-09 v1.3.1" (§0 Source, §0 Related docs, §3, §4, §9 narrative, §13, §18, §19). PRD-09 was rev-bumped to v1.3.1 as part of the B-04 OQ-01 propagation (cta_type inputs corrected in PRD-09 §1 revision note and §4 locked-constraint row). No behavioral change in PRD-10. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 H-11).

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep (M2P-09 closure). Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1`, `PRD-03 v1.4` → `PRD-03 v1.4.1`, `PRD-04 v1.2` → `PRD-04 v1.2.1`, `PRD-05 v1.3` → `PRD-05 v1.4`, `PRD-06 v1.3` → `PRD-06 v1.3.1`. The 04-22 patch addressed only the PRD-09 references; this patch closes the parallel five sibling-PRD references that were stale in §0 Related docs and elsewhere. Audit-trail revision-note text preserved byte-exact. PRD-10 source-truth contains no out-of-repo Spec orphans, so M2P-08 L-01 annotations are not applicable here. No version bump on PRD-10 (sweep is pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01, M2P-09.

**Revision note (v1.3):** Five substantive changes grounded in Jeff's 2026-04-25/26 feedback round on v1 template authoring scope, plus reference-pointer hygiene from upstream patches.

1. **§12.4 Jeff tenant Job Type activation scope reduced from 7 sub-types to 5.** Per Jeff's explicit feedback: Contents is approximately 1% of his job volume and is handled manually outside SMAI when it occurs (deferred entirely from v1 authoring). Temporary Repairs are not bid by Jeff's operation ("we either do it or we don't, we don't bid one a year"). Both sub-types are removed from Jeff's tenant activation in v1 to avoid dead-end UX where the operator selects a sub-type and sees an empty Scenario picker. The sub-types remain in the global master list for future tenant activation. Sub-types activated for Jeff in v1: General Cleaning, Mold Remediation, Structural Cleaning, Trauma / Biohazard, Water Mitigation. Note: per SPEC-03 v1.3.2 sub-type rename, `environmental_asbestos` becomes `trauma_biohazard`.

2. **§12.6 Jeff tenant Scenario activation scope reduced from 33 to 17.** Per Jeff's explicit feedback round, the v1 scenario set for his tenant is 17 specific scenarios across the 5 activated sub-types (per §12.4). The remaining 16 master scenarios (those under Contents, Temporary Repairs, plus several deferred scenarios under the activated sub-types like `hvac_mold` and `recurring_commercial_service`) remain in the master list and are not activated for Jeff. §12.6 enumerates Jeff's exact 17-scenario activation set.

3. **§12.7 Campaign template variant seed updated from 34 to 17 variants required for Jeff's go-live.** Per SPEC-11 v2.0.1 §10.3 and the master-list-vs-activation-scope clarification in SPEC-11 v2.0.1 §17: tenant-activated tuples require active template variants; master list scenarios that are not activated for any tenant do not require variants. Jeff's go-live requires 17 active variants (one per activated tuple per §12.6). The remaining 16 master scenarios are authored if and when activated for some future tenant.

4. **Deactivation mechanic made explicit.** Prior v1.2 §12.4/§12.6 seeded "all 34 scenarios" with no explicit mechanism for deactivating individual scenarios for a tenant post-onboarding. v1.3 makes the mechanic explicit: a master scenario or sub-type is deactivated for a specific tenant by the SMAI Admin Portal scenario activation endpoint setting `is_active = false` on the relevant row in the activation join. Deactivated scenarios remain in the master list. Historical jobs retain their `scenario_key` per SPEC-03 v1.3.2 §10.3. Cascade behavior on parent job type deactivation is engineering-decision per §17. New §12.6.1 added covering the deactivation operation.

5. **Slug propagation from SPEC-03 v1.3.2.** Two scenario/sub-type renames propagate into PRD-10: sub-type `environmental_asbestos` → `trauma_biohazard`; scenario `commercial_janitorial_deep_clean` → `commercial_deep_clean`. §12.4 Job Type activation updated. §12.5 master list seed updated. §12.6 enumeration uses new slugs. Acceptance criteria in §16 updated.

6. **Reference-pointer hygiene.** SPEC-03 v1.3 → v1.3.2; SPEC-11 v2.0 → v2.0.1; SPEC-12 v1.0 → v2.0. Propagated throughout the document where these specs are referenced inline. No behavioral change.

Material section changes in v1.3: §0 (meta refresh, v1.3 revision note); §1 (description refreshed); §2 (builder points on scope governance, master list vs activation scope); §3 (scope refresh); §4 (locked constraints updated for activation scope clarification); §9B narrative (SPEC-12 v2.0 reference); §12.4 (Jeff Job Type activation scope reduced); §12.5 (master list seed unchanged at 33 scenarios; slug renames applied); new §12.5.1 explanatory note on master list completeness vs tenant activation; §12.6 (Jeff Scenario activation enumerated; 17 specific scenarios); new §12.6.1 (scenario deactivation operation); §12.7 (template variant seed updated to 17 variants); §13 (operator product reads unchanged in mechanism, scope reflects activation reality); §14 cutover options refreshed for 17-variant scope; §15 slice references updated; §16 acceptance criteria updated for slug renames and 17-variant scope; §17 open questions clarified for activation-scope-vs-master-list-scope distinction; §18 system boundaries refreshed for SPEC-12 v2.0 reference and 17-variant authoring; §19 out of scope unchanged.

Patch note (2026-04-27): PRD-10 v1.3 reflects v1 authoring scope reduction per Jeff feedback round, scenario and sub-type rename surgery propagation from SPEC-03 v1.3.2, and explicit deactivation mechanic. Ref: SPEC-03 v1.3.2 patch wave; Jeff feedback round 2026-04-25/26.

**Patch note (2026-04-29):** SPEC-03 v1.3.3 §10.3 adds a sub-type activation gate — the symmetric rule to the existing scenario-requires-parent-job-type validation. A `job_type` may be activated for a tenant only if at least one scenario under it is also activated for that tenant. This patch propagates the rule into PRD-10:

1. **§9.2 extended** with the symmetric validation paragraph; the activation endpoint rejects job-type activation with no activated scenarios under it, returning a typed error.
2. **New §2 builder point** noting the symmetric gate so neither rule is missed in implementation.
3. **New §16 AC** covering the gate enforcement.
4. **Reference-pointer hygiene:** SPEC-03 v1.3.2 → v1.3.3 swept throughout the document body. The historical revision-note block above is preserved byte-exact.

No version bump on PRD-10 (validation-rule addition is a clarification of the existing two-layer governance model, not a behavioral change in PRD-10's primary control flow). Ref: SPEC-03 v1.3.3 §10.3; CC-Spec consistency audit 2026-04-29.

---

## 1. What This Is in Plain English

The operator product ships what operators need to run jobs. But a lot of the data that makes the operator product work correctly, the office address that goes in every email signature, the company logo, which locations exist, which job types a tenant can create, which scenarios a tenant can use, and which campaign template variants are active for each (job type, scenario) pair, is not operator-editable. It is managed by SMAI staff, through a separate internal control plane called the **SMAI Admin Portal**, before the customer ever sees the product.

This PRD governs the Admin Portal. It is the source of truth for the six kinds of tenant-level configuration SMAI staff perform, all of which are go-live prerequisites:

1. **Account-level configuration**, the company logo and company name used in every outbound email signature.
2. **Location-level configuration**, creating, editing, and activating locations, including the address and phone number that appear in the signature block for every job at that location.
3. **Tenant job type activation**, selecting which job types from the global master list a given tenant can use in New Job intake.
4. **Tenant scenario activation**, selecting which scenarios (scoped beneath activated job types) a given tenant can use at intake. Per SPEC-03 v1.3.3, scenarios carry `industry_classification` author-facing metadata that is never exposed to operators or customers but is surfaced to template authors.
5. **Campaign template variant management**, managing the master list of campaign template variants keyed by (`job_type`, `scenario_key`), activating new variants via the atomic two-step operation per SPEC-11 v2.0.1 §11.2. Template authoring itself happens offline per SPEC-12 v2.0; the Admin Portal is the activation control plane.
6. **Audit logging**, capturing who changed what, when, for every write in the Admin Portal.

None of this is operator-facing. No ORG_ADMIN self-service. No tenant CRUD. This is entirely an SMAI-staff-operated control plane that makes the managed-service posture real.

**Important scope posture for Buc-ee's pilot:** the Admin Portal frontend need not be fully built before Jeff goes live. What must be built is the complete backend surface, the endpoints, validation rules, schema, and audit logging, that configures a tenant. For Jeff specifically, SMAI staff can exercise those endpoints via direct API calls, scripts, or controlled DB writes to complete the Buc-ee's seed (§12). The frontend UI is the long-term posture and becomes necessary when tenant #2 arrives and the cost of direct-backend configuration stops being acceptable. The §15 slice priorities reflect this split.

**Important scope reality for v1 authoring:** Per SPEC-12 v2.0 and Jeff's 2026-04-25/26 feedback round, v1 template authoring is scoped to Jeff's tenant activation (17 variants), not the full master list (33 scenarios across 7 sub-types). Master list scenarios that are not activated for any tenant do not require active template variants. This distinction is load-bearing: the master list is broader than any single tenant's active scope, and authoring is gated on activation, not master list presence. §12.5 covers the master list seed; §12.6 covers Jeff's specific activation; §12.7 covers the variants required for Jeff's go-live.

The Admin Portal is not a marketing surface, not a customer success surface, and not a billing surface. Those may live elsewhere or be added later.

---

## 2. What Builders Must Not Misunderstand

1. **The Admin Portal is internal-only.** No tenant role can authenticate to it. No customer-facing surface exists. Tenants do not know it exists, and do not see any indication of its existence through the operator product UI.

2. **The Admin Portal is the source of truth for tenant configuration.** Account, location, job type activation, scenario activation, and template variant activation data are written here and read by the operator product. Inverting this relationship (operator product writes that the Admin Portal reads) is wrong.

3. **Locations carry signature-block-bearing fields.** Every signature on every outbound email includes the location's `display_name`, `address_line_1`, `address_line_2`, `city`, `state`, `postal_code`, and `phone_number`. A location missing any of those required fields cannot be activated. This is enforced at the Admin Portal backend, before the operator product ever sees the location.

4. **Account logos are required and uploaded once per tenant.** The logo URL is referenced by every email signature. Logo upload is an Admin Portal capability, not an operator-facing capability. There is no tenant-uploaded-logo UI.

5. **Job type activation is per-tenant.** Per SPEC-03 v1.3.3 §10. The job type master list is global and SMAI-curated. Per-tenant activation controls which subset of the master list a given tenant can use. Activation changes are SMAI-initiated, audit-logged, and never customer-self-service.

6. **Job type taxonomy:** Per SPEC-03 v1.3.3 §7.1. The seven Restoration sub-types in the global master list are Contents, General Cleaning, Mold Remediation, Structural Cleaning, Temporary Repairs, Trauma / Biohazard, Water Mitigation. The prior taxonomy's values (Water Damage, Fire & Smoke, Storm Damage, Biohazard / Sewage, Contents / Pack-Out, Specialty Cleaning) are NOT in the master list and must not be seeded. The pre-v1.3.3 sub-type slug `environmental_asbestos` was renamed to `trauma_biohazard` per SPEC-03 v1.3.3 §7.1.

7. **Reconstruction, HVAC, Plumbing, Roofing, and Other are deferred from v1.** Per SPEC-03 v1.3.3 §7.3. They exist as valid values in the master list for forward compatibility but are not activated for any tenant in v1.

8. **Audit logging is non-negotiable.** Every write to the Admin Portal backend, including direct-DB writes performed during pilot bootstrapping, must produce an audit log entry. Every entry includes what changed, who changed it, and when.

9. **Scenario activation is scoped to its parent job type, and sub-type activation requires at least one activated scenario.** Per SPEC-03 v1.3.3 §10 and §10.3. The two rules are symmetric: (a) a tenant cannot have a scenario activated whose parent `job_type` is not also activated for that tenant; (b) a tenant cannot have a `job_type` activated unless at least one scenario under it is also activated for that tenant. Both rules are enforced at the activation endpoint and return typed errors. Together they prevent the operator-facing failure modes — empty Scenario dropdown after a sub-type pick (operational dead end), and SPEC-11 v2.0.1 mid-intake loud-failure when a tuple has no active template variant. Deactivating a job type implicitly hides its scenarios from operator intake (whether the join rows are cascaded is an engineering decision; product requires the dropdown behavior). The scenario master list is global and SMAI-curated. Per-tenant activation via the Admin Portal backend.

10. **Template variant activation is atomic and two-step.** Per SPEC-11 v2.0.1 §11.2. When SMAI staff activate a new variant for a (`job_type`, `scenario_key`) pair, the activation endpoint performs two writes within a single database transaction: the new variant flips to `is_active = true` AND the prior active variant (if any) flips to `is_active = false`. The activation endpoint is the only path to change `is_active` on a template variant. No "edit active variant in place" operation exists, content is immutable per SPEC-11 v2.0.1 §11.1; evolving a template means loading a new variant and activating it. Past campaign runs retain their original `template_version_id` references. Cohort attribution is preserved.

11. **`industry_classification` is author-facing metadata, never customer-facing.** Per SPEC-03 v1.3.3 §13.2 and Jeff's 2026-04-21 guidance. It is stored on scenario master list records to inform template authors (references to IICRC S500, IICRC S520, IICRC S540, OSHA, EPA, etc.). It is optionally inherited onto template variant records for author convenience per SPEC-11 v2.0.1 §7.1. It must not appear in any customer-facing email prose, in operator dropdowns, or in any UI surface accessible to a tenant. The Admin Portal surfaces it to SMAI staff (for audit and reference) but does not render it anywhere operators or customers can see.

12. **Master list scope and tenant activation scope are distinct.** Per SPEC-03 v1.3.3 §10.1 and SPEC-11 v2.0.1 §17. The master list contains all scenarios SMAI supports across all tenants and all operational realities. Per-tenant activation scopes the master list down to what each tenant actually uses. Scenarios in the master list with no active template variant are permitted as long as no tenant has them activated. Template authoring is gated on tenant activation, not master list presence. Implementation must preserve this distinction: seeding the master list is independent of seeding activations, and the master list seed completes regardless of tenant scope.

---

## 3. Purpose, Scope, and Non-Goals

**What this implements:**

The SMAI Admin Portal's six capabilities required for go-live: account-level configuration (logo, company name), location-level CRUD, tenant job type activation, tenant scenario activation, campaign template variant management (activation), and audit logging. Each capability has a backend endpoint set (required for pilot) and a frontend UI surface (post-pilot), with propagation behavior into the operator product on each API read.

**Scope split for pilot:**

- **Required for go-live (Slices A-C, new Slices G-H):** Backend endpoints under `/admin/*` for accounts, locations, job type master list and tenant activation, scenario master list and tenant activation, and template variant activation. Audit logging infrastructure. Server-side validation including location activation rule, scenario-scoped-to-job-type rule, and template variant activation invariants. Pilot seed data per §12 applied via these endpoints.
- **Post-pilot (Slices D-F, Slice I):** Admin Portal frontend UI. Logo upload UI. Location and account management UI. Tenant job type activation UI. Tenant scenario activation UI. Master list CRUD UI (job types, scenarios, template variants).

For tenant #2 and beyond, the frontend is no longer optional. Configuring additional tenants via curl is not a scalable approach. Treat the frontend as a near-term post-pilot priority, not an indefinite deferral.

**What this covers:**

- Account record configuration: `logo_url` upload and storage, `company_name` text field
- Location record CRUD: create, edit, activate/deactivate, with activation-blocking validation per the signature-bearing field set
- Tenant job type activation: multi-select against the global master list, with per-tenant activation join writes
- Tenant scenario activation: multi-select against the scenario master list (scoped to activated job types), with per-tenant activation join writes; including `industry_classification` author-facing metadata
- Campaign template variant management: loading new template variants into the master list, performing atomic two-step activation per SPEC-11 v2.0.1 §11.2, storing `authoring_hypothesis` and authoring attribution
- Job type master list CRUD (low-frequency, doctrine-level change)
- Scenario master list CRUD (low-frequency, doctrine-level change)
- Audit logging for every write to the Admin Portal backend
- SMAI staff authentication and authorization (backend API auth required for pilot; frontend SSO post-pilot)
- Pilot-specific seed data for Jeff's tenant: three locations, one account logo, the 5 activated Restoration sub-types per SPEC-03 v1.3.3 §7.1 (subset of the 7-sub-type master list), the 17 scenarios scoped to Jeff per SPEC-03 v1.3.3 §7.2 and Jeff's 2026-04-25/26 feedback round (subset of the 33-scenario master list), and the 17 initial template variants required for go-live

**What this does not cover:**

- Any operator-product UI (handled by PRD-08, PRD-02 v1.5, PRD-05 v1.4, PRD-06 v1.3.1, PRD-07 v1.2)
- User creation, role assignment, user field editing (handled by PRD-08 v1.2 in the operator product)
- Signature composition itself (handled by SPEC-07 v1.1, this PRD provides the data)
- Template authoring methodology and content production (handled by SPEC-12 v2.0, this PRD provides the activation control plane)
- Campaign rendering and merge-field substitution at intake (handled by PRD-03 v1.4.1 and SPEC-11 v2.0.1, this PRD provides the activated template the engine reads)
- Billing, invoicing, subscription management
- Customer self-service account management
- Migration tooling for existing production tenants (pilot is the first paying tenant; migration is not applicable)
- Multi-region, multi-language, or multi-currency tenant variants
- Gmail OAuth mailbox connection (handled by PRD-09 v1.3.1; Admin Portal surfaces status but does not perform the flow)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|------------|--------|
| Account record carries `logo_url` and `company_name`, both required for signature composition. | SPEC-07 v1.1 §6 |
| Location record carries `display_name`, `address_line_1`, `address_line_2`, `city`, `state`, `postal_code`, and `phone_number`. All except `address_line_2` are required for activation. | SPEC-07 v1.1 §6; PRD-09 v1.3.1 |
| Locations are activation-gated: a location with a missing required field cannot be activated. | This PRD §8.3 |
| Job type taxonomy is two-layer: global master list (SMAI-curated) + per-tenant activation join. | SPEC-03 v1.3.3 §10 |
| Scenario taxonomy is two-layer: global master list (SMAI-curated) + per-tenant activation join. Scenarios scoped to parent job type. | SPEC-03 v1.3.3 §10 |
| Master list scope is distinct from tenant activation scope. A scenario in the master list does not require an active template variant unless it is activated for some tenant. | SPEC-03 v1.3.3 §10.1; SPEC-11 v2.0.1 §17 |
| Active campaign template variants are required for every tenant-activated (`job_type`, `scenario_key`) tuple before that tenant goes live. | SPEC-11 v2.0.1 §10.3 |
| Template variant activation is atomic and two-step within a single database transaction. | SPEC-11 v2.0.1 §11.2 |
| Template variant content fields are immutable post-load (write-once); only `is_active`, `activated_at`, `deactivated_at` are mutable. | SPEC-11 v2.0.1 §11.1 |
| `template_version_id` is referenced by `campaigns.template_version_id` on every campaign run; cohort attribution depends on this. | SPEC-11 v2.0.1 §7.3 |
| `industry_classification` is author-facing metadata, never customer-facing. | SPEC-03 v1.3.3 §13.2; Jeff text 2026-04-21 |
| Audit logging is non-negotiable for every Admin Portal write. | This PRD §10 |
| SMAI staff authentication required for all `/admin/*` endpoints. Tenant roles cannot authenticate. | This PRD §11 |

---

## 5. Actors and Objects

**Actors:**
- **SMAI staff (`GLOBAL_ADMIN`, `GLOBAL_MEMBER`)** — authenticated SMAI users with access to the Admin Portal backend. `GLOBAL_ADMIN` has full CRUD on all admin resources. `GLOBAL_MEMBER` is read-only.
- **Tenant users** — cannot authenticate to the Admin Portal. The role enums (`ORG_ADMIN`, `ORIGINATOR`) are operator-product-only.
- **Operator product** — reads Admin-Portal-managed data via existing read paths in PRD-07 v1.2, PRD-02 v1.5, PRD-03 v1.4.1, SPEC-07 v1.1.

**Objects:**
- **Account** — the tenant company record. Carries `account_id`, `company_name`, `logo_url`, plus standard timestamps and audit fields.
- **Location** — a tenant office. Carries `location_id`, `account_id` (FK), `display_name`, `address_line_1`, `address_line_2`, `city`, `state`, `postal_code`, `phone_number`, `is_active`, plus standard timestamps and audit fields.
- **Job type master list entry** — a global SMAI-curated record. Carries `job_type` (slug, primary key), `display_name`, `parent_category`, `is_deprecated`, plus standard timestamps and audit fields. v1 active values: `contents`, `general_cleaning`, `mold_remediation`, `structural_cleaning`, `temporary_repairs`, `trauma_biohazard`, `water_mitigation`. Deferred values: `reconstruction`, `hvac`, `plumbing`, `roofing`, `other`.
- **Scenario master list entry** — a global SMAI-curated record. Carries `scenario_id` (UUID), `scenario_key` (string, unique within parent `job_type`), `job_type` (FK to job type master list), `display_name`, `industry_classification` (author-facing metadata, optional), `is_deprecated`, plus standard timestamps and audit fields.
- **Tenant job type activation join** — per-tenant table. Carries `tenant_id`, `job_type` (FK), `is_active`, `activated_at`, `activated_by`.
- **Tenant scenario activation join** — per-tenant table. Carries `tenant_id`, `scenario_id` (FK), `is_active`, `activated_at`, `activated_by`. Validation at write time: parent `job_type` must also be activated for the tenant.
- **Template variant master list entry** — a global SMAI-curated record. Carries `template_version_id` (UUID, primary key), `job_type`, `scenario_key`, `is_active`, `authoring_hypothesis`, `authored_by`, `authored_at`, `activated_at`, `deactivated_at`, optional `industry_classification`, plus content fields per SPEC-11 v2.0.1 §7.1. Content fields are write-once.
- **Audit log entry** — captures `event_type`, `resource_type`, `resource_id`, `acting_user_id`, `acting_user_email`, `event_timestamp`, `change_payload` (JSON of before/after state).

---

## 6. Workflow Overview

### Tenant onboarding (Buc-ee's example)

1. SMAI staff creates the account record (logo upload, `company_name`).
2. SMAI staff creates each location record with all required fields. Each location is activated only after passing the validation gate per §8.3.
3. SMAI staff seeds (or confirms already-seeded) the global job type and scenario master lists per §12.3 and §12.5.
4. SMAI staff sets the tenant's job type activation join to the appropriate subset (5 sub-types for Jeff per §12.4).
5. SMAI staff sets the tenant's scenario activation join to the appropriate subset (17 scenarios for Jeff per §12.6).
6. SMAI staff loads (or confirms already-loaded) the template variants required for the tenant's activated tuples. For Jeff, this is 17 variants per §12.7.
7. SMAI staff activates each template variant via the atomic two-step endpoint per §9B.3.
8. Onboarding QA verifies that for every row in the tenant's scenario activation join, exactly one active template variant exists for the (`job_type`, `scenario_key`) pair.
9. Tenant users gain access to the operator product. Their pickers show only the activated job types and scenarios. Campaign generation succeeds for the activated tuples and fails loudly for any tuple lacking an active variant (which should never happen post-QA).

### Post-onboarding configuration changes

Same pattern, smaller scope. Examples:
- Adding a fourth location for Jeff: SMAI staff creates the location record, validates required fields, activates.
- Activating an additional scenario for Jeff: SMAI staff sets `is_active = true` on the scenario activation join row. Verifies a template variant exists for the new tuple before activation; if not, blocks activation until variant is loaded.
- Deactivating a scenario for Jeff: SMAI staff sets `is_active = false` on the scenario activation join row. Deactivated scenario disappears from the operator's intake picker. Historical jobs with that scenario are unaffected. Per §12.6.1.
- Activating a new template variant version for an existing tuple: SMAI staff loads the new variant (via §9B.2), then activates via the two-step endpoint (§9B.3). Prior variant deactivates atomically.

---

## 7. Account-Level Configuration

### 7.1 Account Record Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `account_id` | UUID | Yes | Primary key. |
| `company_name` | string | Yes | Used in `{company_name}` merge field per SPEC-11 v2.0.1 §9.1. |
| `logo_url` | string (URL) | Yes | Signed GCS URL or public CDN URL pointing to uploaded logo. Required for signature composition per SPEC-07 v1.1. |
| Standard timestamps and audit fields | varies | Yes | `created_at`, `created_by`, `updated_at`, `updated_by`. |

### 7.2 Logo Upload Pipeline

- **Endpoint:** `POST /admin/accounts/{accountId}/logo` — accepts multipart upload. Image is validated for format (PNG, JPEG, SVG accepted), size (max 2 MB), and dimensions (recommended max 800x400, enforced max 2000x2000). Resized to a standard signature-block size if needed.
- **Storage:** GCS bucket `smai-account-assets`. Object path: `accounts/{accountId}/logo-{version}.{ext}`. Each upload increments the version. Old versions retained (no deletion).
- **URL generation:** Returns a signed URL (or public CDN URL if configured) that's set on `accounts.logo_url`.
- **Replacement:** Repeat upload replaces the URL on the account record. Old URLs remain accessible for past campaigns whose rendered content was already persisted.

### 7.3 Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/accounts/{accountId}` | GET | Retrieve account details. |
| `/admin/accounts/{accountId}` | PUT | Update `company_name`. |
| `/admin/accounts/{accountId}/logo` | POST | Upload logo per §7.2. |

All endpoints require `GLOBAL_ADMIN` auth. All writes are audit-logged per §10.

---

## 8. Location-Level Configuration

### 8.1 Location Record Fields

| Field | Type | Required for activation | Notes |
|-------|------|--------------------------|-------|
| `location_id` | UUID | Yes | Primary key. |
| `account_id` | UUID | Yes | FK to `accounts`. |
| `display_name` | string | Yes | Used in signature block (e.g., "NE Dallas"). |
| `address_line_1` | string | Yes | Used in signature block. |
| `address_line_2` | string | No | Optional second line; renders only if non-empty. |
| `city` | string | Yes | Used in signature block. |
| `state` | string | Yes | Two-letter state code. |
| `postal_code` | string | Yes | Used in signature block. |
| `phone_number` | string | Yes | Used in `{company_phone}` merge field. |
| `is_active` | boolean | n/a | Activation flag. False until validation gate passes. |
| Standard timestamps and audit fields | varies | Yes | |

### 8.2 Validation at Write Time

- All required fields per §8.1 must be present and non-empty before write succeeds.
- `state` must match a valid US state code (or, post-v1, valid international equivalent).
- `phone_number` validated for plausible format (10-digit US numeric or international format).

### 8.3 Activation Gate

A location can be activated (`is_active = true`) only when all required fields are present and pass validation. Attempting to activate an incomplete location returns a typed error naming the missing field. Operator-product reads of activated-only locations exclude inactive rows.

### 8.4 Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/accounts/{accountId}/locations` | GET | List locations for an account. |
| `/admin/accounts/{accountId}/locations` | POST | Create a new location (initially `is_active = false`). |
| `/admin/locations/{locationId}` | PUT | Update fields. |
| `/admin/locations/{locationId}/activate` | POST | Activate a location (validation gate per §8.3). |
| `/admin/locations/{locationId}/deactivate` | POST | Deactivate a location. |

All endpoints require `GLOBAL_ADMIN` auth. All writes are audit-logged per §10.

---

## 9. Tenant Job Type Activation

Governed by SPEC-03 v1.3.3 §10. The Admin Portal manages the per-tenant activation join.

### 9.1 Job Type Master List

Curated by SMAI. Mutations are doctrine-level changes and require a SPEC-03 revision. v1 active values: per SPEC-03 v1.3.3 §7.1. Deferred values: per SPEC-03 v1.3.3 §7.3.

### 9.2 Tenant Activation Join

Per SPEC-03 v1.3.3 §10. Bulk-write semantics: the activation endpoint accepts a list of `job_type` values to activate for a tenant; the response confirms each activation. Deactivation is also bulk; passing a job type currently activated and not in the new list flips its row to `is_active = false`.

**Sub-type activation gate (per SPEC-03 v1.3.3 §10.3).** A `job_type` may be activated for a tenant only if at least one scenario under that `job_type` is also activated for that tenant. The activation endpoint validates this at write time; attempting to activate a `job_type` with no activated scenarios under it returns a typed error naming the constraint and (where available) listing master scenarios under the sub-type that the SMAI operator could activate to satisfy it. This is the symmetric rule to §9A.2's scenario-requires-parent-job-type validation. Together the two rules prevent the operator-facing failure modes named in §2 point 9. Deactivating the last activated scenario under a sub-type implicitly satisfies the deactivation precondition for the parent sub-type; whether the cascade auto-deactivates the sub-type or requires SMAI operator confirmation is an engineering decision per §17.

### 9.3 Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/job-types` | GET | List the full job type master list. |
| `/admin/job-types` | POST | Add a new master list entry (rare; doctrine-level). |
| `/admin/job-types/{jobTypeId}` | PUT | Rename `display_name`, flip `is_deprecated`. The slug `job_type` is immutable. |
| `/admin/accounts/{accountId}/job-types` | GET | List job type activation state for a tenant. |
| `/admin/accounts/{accountId}/job-types` | PUT | Update job type activation state (bulk write). |

All endpoints require `GLOBAL_ADMIN` auth. All writes are audit-logged per §10.

---

## 9A. Tenant Scenario Activation

Governed by SPEC-03 v1.3.3 §10 (extended for scenario governance in v1.3 of that spec). The Admin Portal manages the per-tenant scenario activation join.

### 9A.1 Scenario Master List

Curated by SMAI. Mutations are doctrine-level changes and require a SPEC-03 revision. Each scenario master list record has the fields per §5 of this PRD.

### 9A.2 Tenant Scenario Activation Join

Bulk-write semantics. Validation at write time:

- Every activated scenario must have its parent `job_type` also activated for the tenant. Activating a scenario whose parent job type is not activated returns a typed error.
- Deactivating a scenario for which historical jobs exist does not affect those jobs' `scenario_key` references per SPEC-03 v1.3.3 §10.3.
- Deactivating a scenario removes it from the operator's Scenario picker on subsequent intakes; in-flight campaigns continue to send and remain associated with their original `template_version_id`.

Per SPEC-03 v1.3.3 §10.3: scenarios scoped to a deactivated job type are implicitly hidden from operator intake; whether the join rows are also cascaded is an engineering decision (§17).

### 9A.3 Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/scenarios` | GET | List the full scenario master list (optionally filtered by parent `job_type_id`). |
| `/admin/scenarios` | POST | Add a new scenario master list entry (requires parent `job_type_id`). |
| `/admin/scenarios/{scenarioId}` | PUT | Rename `display_name`, flip `is_deprecated`, update `industry_classification`. `scenario_key` and `job_type_id` are immutable. |
| `/admin/accounts/{accountId}/scenarios` | GET | List scenario activation state for a tenant (returns scenarios grouped by parent job type). |
| `/admin/accounts/{accountId}/scenarios` | PUT | Update scenario activation state (bulk write). Validates that every scenario being activated has its parent job type also activated for the tenant. |

All endpoints require `GLOBAL_ADMIN` auth. All writes are audit-logged per §10.

---

## 9B. Campaign Template Variant Management

Governed by SPEC-11 v2.0.1 §11. The Admin Portal is the activation control plane for campaign template variants. Template authoring itself happens offline per SPEC-12 v2.0; this section defines how authored variants are loaded into the master list and activated.

### 9B.1 Template Variant Record

Per SPEC-11 v2.0.1 §7.1. Template variants are global by (`job_type`, `scenario_key`); no per-tenant forking.

**Template variant fields (per SPEC-11 v2.0.1 §7.1):**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `template_version_id` | UUID | Yes | Primary key. Immutable. Referenced by `campaigns.template_version_id` on every campaign run. |
| `job_type` | string (FK → job type master list) | Yes | Parent job type. |
| `scenario_key` | string (FK → scenario master list) | Yes | Must belong to the parent `job_type`. Validated at load time. |
| `is_active` | boolean | Yes | Exactly one active per (`job_type`, `scenario_key`) pair. Mutable via activation endpoint only. |
| `authoring_hypothesis` | string | Yes | Free text describing what is being tested with this variant. Write-once. |
| `authored_by` | UUID (FK → SMAI staff user) | Yes | Write-once. |
| `authored_at` | timestamp | Yes | Write-once. |
| `activated_at` | timestamp | No | Set when `is_active` flips to true. Null until first activation. |
| `deactivated_at` | timestamp | No | Set when `is_active` flips back to false. Null while active. |
| `industry_classification` | string | No | Optional inherited value from the parent scenario's `industry_classification`. Author-facing only. Never customer-facing. |
| Content fields | varies | Yes | Step count, cadence, per-step subject and body with merge fields. Per SPEC-11 v2.0.1 §7.1. Write-once. |

**Immutability rule per SPEC-11 v2.0.1 §11.1:** Once a template variant is loaded, all fields are immutable except `is_active`, `activated_at`, and `deactivated_at`. Evolving a template means loading a new variant and activating it, not editing the existing one.

### 9B.2 Loading a New Variant

Template variants are authored offline per SPEC-12 v2.0. Loading is the act of inserting an authored variant into the master list with `is_active = false`. The loader mechanism is Mark's engineering decision per SPEC-11 v2.0.1 §13, options include an admin portal POST endpoint, a CI hook on merge to `smai-specs`, or a manual script. Regardless of the mechanism, the loaded variant must carry all required fields from §9B.1 and must pass validation:

- `job_type` and `scenario_key` reference existing, non-deprecated master list entries.
- `scenario_key` belongs to the parent `job_type`.
- `authoring_hypothesis` is non-empty.
- `authored_by` is a valid SMAI staff user (`GLOBAL_ADMIN` or `GLOBAL_MEMBER`).
- Content fields conform to the render contract per SPEC-11 v2.0.1 §7.1 (step count, cadence, merge field syntax).

### 9B.3 Activation (Atomic Two-Step)

Per SPEC-11 v2.0.1 §11.2. The activation endpoint performs the atomic two-step operation:

1. Flip the new variant's `is_active` to `true`; set `activated_at = now()`.
2. If a prior active variant exists for the same (`job_type`, `scenario_key`) pair, flip it to `is_active = false`; set `deactivated_at = now()`.

Both writes happen within a single database transaction. If the transaction fails, neither write takes effect. Concurrent activation attempts for the same pair are serialized by a row lock (`FOR UPDATE` on the prior-active row) or equivalent; one succeeds, the other fails with a serialization or constraint error and must be retried.

**First-ever activation edge case:** If no prior active variant exists for the pair (first time this pair is activated), step 2 is a no-op. The new variant simply becomes active. No special casing is required beyond the no-op outcome.

**Effect on campaign generation:** All subsequent campaign generation for that (`job_type`, `scenario_key`) pair uses the new variant. Past campaign runs retain their original `template_version_id` references. Cohort attribution per PRD-07 v1.2 OQ-07 is preserved.

### 9B.4 Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/template-variants` | GET | List template variants (optionally filtered by `job_type`, `scenario_key`, or `is_active`). |
| `/admin/template-variants` | POST | Load a new variant into the master list (initially `is_active = false`). Subject to §9B.2 validation. |
| `/admin/template-variants/{templateVersionId}` | GET | Retrieve a specific variant (read-only; content fields immutable). |
| `/admin/template-variants/{templateVersionId}/activate` | POST | Atomic two-step activation per §9B.3. |

All endpoints require `GLOBAL_ADMIN` auth. All writes (including load and activation) are audit-logged per §10.

### 9B.5 Variants Are Global

Per SPEC-11 v2.0.1 §10.3. Template variants are not per-tenant. Two tenants activated for the same (`job_type`, `scenario_key`) pair use the same active template variant. Per-tenant variation is restricted to merge-field values from the job context (originator name, location address, company phone, etc.) — not template content. Tenant-specific template forks are out of scope for v1.

---

## 10. Audit Logging

Every write to the Admin Portal backend produces an audit log entry. Reads do not produce audit entries.

### 10.1 Audit Log Record

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `audit_log_id` | UUID | Yes | Primary key. |
| `event_type` | enum | Yes | E.g., `account_logo_uploaded`, `location_activated`, `tenant_job_type_activated`, `tenant_scenario_activated`, `tenant_scenario_deactivated`, `template_variant_loaded`, `template_variant_activated`. |
| `resource_type` | string | Yes | E.g., `account`, `location`, `tenant_job_type_join`, `tenant_scenario_join`, `template_variant`. |
| `resource_id` | string | Yes | Primary key of the affected resource. |
| `acting_user_id` | UUID | Yes | The SMAI staff user who performed the change. |
| `acting_user_email` | string | Yes | Email of the acting user (denormalized for audit legibility). |
| `event_timestamp` | timestamp | Yes | When the change happened. |
| `change_payload` | JSON | Yes | Before/after state for mutable fields. For activation events, captures `is_active` transition. |

### 10.2 Direct DB Writes

Direct DB writes performed during pilot bootstrapping (per §14 cutover options) bypass the audit logging hook. Any such write must be documented in a cutover log (manual record) capturing the same fields. Post-pilot, direct DB writes are not permitted; all writes flow through the API.

---

## 11. Authentication and Authorization

### 11.1 Backend (pilot-required)

`GLOBAL_ADMIN` and `GLOBAL_MEMBER` roles. Backend API auth via existing SMAI staff auth mechanism. `GLOBAL_ADMIN` has full CRUD; `GLOBAL_MEMBER` is read-only.

Tenant-role users (`ORG_ADMIN`, `ORIGINATOR`) cannot authenticate to the Admin Portal. The auth check rejects any token bearing only tenant-level claims.

### 11.2 Frontend (post-pilot)

SSO via Google Workspace or comparable identity provider. SMAI staff sign in once; the frontend talks to the backend via authenticated session.

---

## 12. Pilot Seed Data

This section enumerates the configuration SMAI staff applies to Jeff's tenant before pilot go-live. The seed is applied via the `/admin/*` endpoints (preferred) or direct DB writes during cutover (acceptable per §14, with manual audit log entries).

### 12.1 Account Record

| Field | Value |
|-------|-------|
| `company_name` | (Jeff's exact preferred company name; provided pre-launch) |
| `logo_url` | (Servpro NE Dallas Servpro-branded logo, uploaded via §7.2) |

### 12.2 Locations

Three locations: NE Dallas, Boise, Reno. Each with all required fields per §8.1.

| `display_name` | `address_line_1` | `city` | `state` | `postal_code` | `phone_number` |
|--------|-------------------|--------|---------|---------------|----------------|
| NE Dallas | (provided pre-launch) | (provided) | TX | (provided) | (provided) |
| Boise | (provided pre-launch by Christian) | (provided) | ID | (provided) | (provided) |
| Reno | (provided pre-launch by Christian) | (provided) | NV | (provided) | (provided) |

All three are activated post-write per §8.3.

### 12.3 Job Type Master List Seed

Per SPEC-03 v1.3.3 §7.1 and §7.3. The full master list seed includes the seven Restoration sub-types plus the five deferred values (twelve total). Seed values:

**Active in master list:**
- `contents`
- `general_cleaning`
- `mold_remediation`
- `structural_cleaning`
- `temporary_repairs`
- `trauma_biohazard`
- `water_mitigation`

**Deferred (in master list, not activated for any tenant in v1):**
- `reconstruction`
- `hvac`
- `plumbing`
- `roofing`
- `other`

They are not activated for any tenant in v1. The exact slug values and the decision to seed them in v1 or defer are an engineering choice (Mark's call); either seeding them now or adding them at the time of tenant #2 is acceptable. Not blocking for pilot.

Note: Prior versions of this PRD seeded twelve values including Water Damage, Fire & Smoke, Storm Damage, Biohazard / Sewage, Contents / Pack-Out, and Specialty Cleaning. Those slugs are NOT in the SPEC-03 v1.3.3 master list and must not be seeded. Note also: the pre-v1.3.3 sub-type slug `environmental_asbestos` was renamed to `trauma_biohazard` per SPEC-03 v1.3.3 §7.1; only the new slug is seeded.

### 12.4 Tenant Job Type Activation Seed

Jeff's tenant is activated for **5 of the 7** Restoration sub-types in the master list:

- `general_cleaning`
- `mold_remediation`
- `structural_cleaning`
- `trauma_biohazard`
- `water_mitigation`

**Not activated for Jeff's tenant in v1:**

- `contents` — per Jeff's 2026-04-25/26 feedback: "out of a hundred jobs, maybe one is going to be just contents only" (~1% volume). Standalone contents jobs are handled manually outside SMAI when they occur.
- `temporary_repairs` — per Jeff's 2026-04-25/26 feedback: "I'd be surprised if we bid one a year. We are going out and doing it or we're not doing it." Not part of Jeff's bid workflow.

Both deactivated sub-types remain in the master list per §12.3 for future tenant activation.

No other tenant is activated for any type in v1. Reconstruction, HVAC, Plumbing, Roofing, and Other are NOT activated for Jeff's tenant; they are reserved for future verticals.

### 12.5 Scenario Master List Seed

Per SPEC-03 v1.3.3 §7.2 and §13.1. Each Restoration sub-type carries a set of scenarios that further specify the damage situation. The full scenario list per sub-type is defined in SPEC-03 v1.3.3 §7.2 (the v1 master list of 33 scenarios across all 7 sub-types). The master list is seeded with all 33 scenarios, each tagged with its parent `job_type`, a stable `scenario_key`, a `display_name`, and optionally an `industry_classification` string.

The scenario master list seed is populated during pilot onboarding via the `/admin/scenarios` POST endpoint (or equivalent bulk load, Mark's call). Every scenario entry references its parent job type; the server-side validation rejects a scenario with an unrecognized or deprecated parent job type slug.

`industry_classification` values are author-facing metadata referencing applicable industry standards (e.g., "IICRC S500 Category 1 Water Damage", "IICRC S520 Condition 2 Mold", "IICRC S540 Trauma and Crime Scene", "OSHA 29 CFR 1910.1001 Asbestos"). They are optional on the scenario record. They are never surfaced to operators or customers per §2 point 11 and SPEC-03 v1.3.3 §2 point 8.

Note: per SPEC-03 v1.3.3 patch surgery, scenario `commercial_janitorial_deep_clean` was renamed to `commercial_deep_clean`; only the new slug is seeded.

#### 12.5.1 Master List Completeness vs Tenant Activation

Per SPEC-03 v1.3.3 §10.1 and SPEC-11 v2.0.1 §17, the master list contains all scenarios SMAI supports across all tenants and operational realities (33 in v1). Per-tenant activation scope (Jeff's 17 in §12.6) is a subset of the master list. This distinction is load-bearing:

- **Master list seed completeness:** All 33 scenarios are seeded into the master list regardless of which scenarios are activated for any specific tenant. Master list seeding is independent of activation seeding.
- **Variant authoring is gated on activation, not master list presence:** Per SPEC-12 v2.0 §4 and SPEC-11 v2.0.1 §17, master scenarios with no active template variant are permitted as long as no tenant has them activated. Variants are authored when their first activating tenant is onboarded.
- **Future tenants:** A future tenant activating a master scenario that has no current active variant triggers an authoring obligation per SPEC-12 v2.0 §11.1, applied at that tenant's onboarding.

### 12.6 Tenant Scenario Activation Seed

Jeff's tenant is activated for **17 of the 33 scenarios** in the v1 master scenario set. The 17 activated scenarios are scoped to the 5 sub-types activated per §12.4. The remaining 16 master scenarios (across all sub-types) are not activated for Jeff in v1; they remain in the master list per §12.5.

**Jeff's activated scenarios (17 total):**

**Water Mitigation** (`water_mitigation`) — 6 scenarios:
- `clean_water_flooding`
- `gray_water`
- `sewage_backup`
- `pipe_burst`
- `appliance_failure`
- `storm_related_flooding`

**Mold Remediation** (`mold_remediation`) — 4 scenarios:
- `visible_mold_growth`
- `post_water_mold_discovered`
- `crawlspace_mold`
- `structural_mold`

(Not activated: `hvac_mold` — per Jeff: "too complicated to do into this type of tool, that's past the scope.")

**Structural Cleaning** (`structural_cleaning`) — 2 scenarios:
- `post_fire_soot_smoke`
- `post_water_deep_clean`

**General Cleaning** (`general_cleaning`) — 4 scenarios:
- `commercial_deep_clean`
- `post_construction_cleanup`
- `move_in_move_out`
- `odor_remediation`

(Not activated: `hvac_cleaning` — per Jeff: "very, very rare." `recurring_commercial_service` — per Jeff: "we don't do these. Janitorial isn't part of our model.")

**Trauma / Biohazard** (`trauma_biohazard`) — 1 scenario:
- `trauma_crime_scene`

(Not activated: `asbestos_abatement`, `lead_abatement`, `biohazard_non_sewage`, `meth_drug_remediation` — per Jeff: low or zero standalone volume; these branch off other job types when relevant or are handled outside SMAI.)

The activation seed is applied via the `/admin/accounts/{accountId}/scenarios` PUT endpoint (bulk activation). Server-side validation enforces that every activated scenario has its parent job type activated for Jeff's tenant per §9A.2; the 5 activated sub-types per §12.4 cover all 17 activated scenarios.

No other tenant is activated for any scenario in v1.

#### 12.6.1 Scenario Deactivation Operation

Per Jeff's onboarding seed and the broader two-layer governance model, scenarios that are not part of v1 scope for Jeff are explicitly deactivated rather than implicitly omitted. The deactivation operation is the same `/admin/accounts/{accountId}/scenarios` PUT endpoint (bulk activation join write), with the relevant rows set to `is_active = false`.

**Deactivation effects:**

- The deactivated scenario disappears from Jeff's operator Scenario picker on subsequent intakes.
- Historical jobs created with the now-deactivated scenario retain their `scenario_key` references per SPEC-03 v1.3.3 §10.3 (historical legibility preserved).
- In-flight campaigns continue to send and remain associated with their original `template_version_id`; the deactivation does not interrupt active campaigns.
- An audit log entry is written per §10.1 with `event_type = tenant_scenario_deactivated`.

**Reactivation:** If a deactivated scenario needs to be reactivated for the tenant later (e.g., Jeff decides to start using Contents in v1.5), the same endpoint flips `is_active` back to true. The reactivation is gated on the tenant's parent job type also being activated; if the parent job type was also deactivated, both must be reactivated (job type first, then scenario). Pre-reactivation, an active template variant must exist for the (`job_type`, `scenario_key`) tuple per §12.7.

**Cascade behavior on parent job type deactivation:** Engineering decision per §17. Product requires that the operator-facing dropdown behavior is correct (deactivated job type does not appear; its scenarios do not appear). Whether the scenario activation join rows are cascaded (auto-deactivated) or remain as orphans is Mark's call.

### 12.7 Campaign Template Variant Seed

Per SPEC-11 v2.0.1 §11 and SPEC-12 v2.0. For Jeff's pilot go-live, at least one active template variant must exist for every activated (`job_type`, `scenario_key`) pair in §12.6 for Jeff's tenant. A missing variant fails loudly at intake per SPEC-11 v2.0.1 §10.3 and PRD-02 v1.5 §8.3; the operator sees "Campaign could not be generated. Contact support." and no campaign is written.

**Scope of the seed:**

- 17 scenarios activated for Jeff (per §12.6) × at least one active variant each = **17 template variants required for Jeff's go-live**.
- Each variant carries a `template_version_id`, `authoring_hypothesis` (required), `authored_by` (SMAI staff), `authored_at`, content (step count, cadence, per-step subject/body with merge fields per SPEC-11 v2.0.1 §7.1), and is activated via the atomic two-step operation (§9B.3).
- Authoring follows SPEC-12 v2.0 pipeline stages (sub-type brief → Jeff async review → Jeff correction call → master prompt execution → human finalization, with legal review for §8 Trauma / Biohazard scenarios).

**Variants not required for Jeff's go-live:** The remaining 16 master scenarios (those not activated for Jeff per §12.5.1 and §12.6) do not require active template variants. Per SPEC-11 v2.0.1 §17 and SPEC-03 v1.3.3 §10.1, master list scenarios that are not activated for any tenant do not require variants. Authoring those variants is gated on a future tenant activating them; until then, they remain in the master list with no active variant, and the §8 lookup contract's loud-failure path is not exercised because no tenant can submit a job for those tuples.

For pilot, the 17-variant seed is the gating item for Jeff's go-live from the Admin Portal side; locations, accounts, job types, and scenarios can all be seeded quickly via API; the 17 templates require the SPEC-12 v2.0 authoring pipeline. Per SPEC-12 v2.0 §11.1, the v1 authoring run elapsed time is roughly 5-8 working days. Kyle and Ethan own the authoring schedule. Mark owns the load-and-activate endpoint surface.

**Loader mechanism:** per SPEC-11 v2.0.1 §13 and §17 of this PRD, options include an admin portal POST endpoint, a CI hook on merge to `smai-specs`, or a manual script. Regardless of mechanism, every loaded variant is inactive by default and must be explicitly activated via the `/admin/template-variants/{templateVersionId}/activate` endpoint (§9B.4).

**Seed verification:** before Jeff's go-live, a verification query confirms that for every row in Jeff's scenario activation join (the 17 activated scenarios per §12.6), there exists exactly one template variant with `is_active = true` matching the (`job_type`, `scenario_key`) pair. This check is part of the onboarding QA gate.

---

## 13. Relationship to Operator Product

The Admin Portal writes configuration. The operator product reads it. The two are tightly coupled at the data layer but isolated at the UI and auth layers.

**What the operator product reads from Admin-Portal-managed data:**

- Account record (`company_name`, `logo_url`), read by SPEC-07 v1.1 signature composition.
- Location record (`display_name`, address fields, `phone_number`), read by SPEC-07 v1.1 and PRD-09 v1.3.1.
- Tenant job type activation join, read by PRD-02 v1.5 New Job intake (Job Type dropdown source).
- Tenant scenario activation join, read by PRD-02 v1.5 New Job intake (Scenario dropdown source, scoped by selected Job Type).
- Active template variant per (`job_type`, `scenario_key`) tuple, read by PRD-03 v1.4.1 campaign engine at intake Submit (template lookup).

The operator product never writes to any of these. Operator-facing edit UI for any of these surfaces does not exist in v1.

---

## 14. Cutover Options for Buc-ee's Go-Live

The go-live gate is backend readiness, not frontend readiness. The `/admin/*` endpoints, schema, validation, and audit logging must be in place so SMAI staff can seed Jeff's tenant correctly. The Admin Portal frontend is not a cutover gate for Buc-ee's.

Three cutover states, in order of preference:

- **Best:** All `/admin/*` backend endpoints (Slices A, B, C, G, H) are complete and callable. SMAI staff exercises them via scripts or curl to seed the three Servpro locations, upload the logo, seed the job type master list, activate the 5 Restoration sub-types for Jeff's tenant per §12.4, seed the scenario master list per §12.5 (all 33 scenarios), activate Jeff's 17 scenarios per §12.6 (with 16 explicitly deactivated per §12.6.1), and load and activate the 17 template variants per §12.7. Every write hits validation and audit logging. Post-pilot changes go through the same endpoints. Tenant #2 waits for the frontend.

- **Acceptable:** Backend endpoints are partial; some capabilities are wired, others require direct DB writes. The Buc-ee's seed is applied through a mix of API calls and migration scripts. Every direct DB write is documented in a cutover log with the SMAI staff member who performed it, what was written, and why the API path was unavailable. Audit log has gaps (direct writes don't flow through audit); note this explicitly. Works for Buc-ee's one-time seed but every missing endpoint becomes debt before tenant #2.

- **Worst:** Backend endpoints are not ready and seed data is applied inconsistently — some locations missing required fields, logo not uploaded, job type activation not seeded, scenario activation not seeded (or activated with unintended scenarios), or template variants not loaded and activated for every (`job_type`, `scenario_key`) pair Jeff is activated for. Campaign generation fails intermittently or uniformly for Jeff's jobs (the missing-template case fails loudly per SPEC-11 v2.0.1 §10.3). This blocks pilot go-live. Mark to flag early if this state is likely.

The Admin Portal frontend (Slices I, J, K, L) is orthogonal to all three cutover states. It ships when it ships, post-pilot, without blocking pilot go-live.

Flag which state we are in as early as possible. Mark confirms which of the §15 backend slices are complete versus in-flight, and Kyle writes the cutover plan against that reality.

---

## 15. Implementation Slices

**Go-live blocking for pilot:** Slices A, B, C, G, and H. These are the backend foundations that SMAI staff exercise via scripts or curl to seed Jeff's tenant.

**Post-pilot (not blocking pilot):** Slices I, J, K, L. These are the Admin Portal frontend. They become necessary when tenant #2 arrives and direct-backend configuration stops being acceptable.

### Slice A, Backend: Account and Location CRUD endpoints ([#106](https://github.com/frizman21/smai-server/issues/106))

**Purpose:** Establish server-side CRUD for the `accounts` and `locations` tables with admin-gated auth and audit logging.

**Components touched:** `accounts` table, `locations` table, GCS bucket for logo storage, audit log table, `/admin/accounts/*` and `/admin/locations/*` endpoint handlers.

**Key behavior:** All endpoints per §7.3 and §8.4. Validation rules per §7.2 and §8.2. Activation gate per §8.3. Audit logging per §10. SMAI staff auth per §11.1.

**Dependencies:** Audit log infrastructure. SMAI staff auth mechanism.

**Excluded:** Frontend. Tenant job type activation. Scenario activation. Template variant activation.

### Slice B, Backend: Logo upload pipeline ([#107](https://github.com/frizman21/smai-server/issues/107))

**Purpose:** Implement the multipart upload, validation, GCS storage, and URL generation per §7.2.

**Components touched:** `/admin/accounts/{accountId}/logo` endpoint handler. GCS bucket. Image validation library.

**Key behavior:** Per §7.2.

**Dependencies:** Slice A complete. GCS bucket provisioned.

**Excluded:** Frontend logo UI.

### Slice C, Backend: Tenant job type activation ([#108](https://github.com/frizman21/smai-server/issues/108))

**Purpose:** Establish the job type master list and the per-tenant activation join, with admin-gated endpoints.

**Components touched:** Job type master list table or enum. Tenant job type activation join table. `/admin/job-types/*` and `/admin/accounts/{accountId}/job-types` endpoint handlers.

**Key behavior:** Per §9.3. Validation per SPEC-03 v1.3.3 §10. Audit logging per §10.

**Dependencies:** Slice A complete. SMAI staff auth.

**Excluded:** Frontend job type activation UI.

### Slice D, Frontend: Account and Location management, **post-pilot**

(Per §14 not blocking pilot. Spec content carried over from v1.2; not in scope for v1.3 patch beyond reference-pointer hygiene.)

### Slice E, Frontend: Logo upload UI, **post-pilot**

(Per §14 not blocking pilot.)

### Slice F, Frontend: Tenant job type activation UI, **post-pilot**

(Per §14 not blocking pilot.)

### Slice G, Backend: Tenant scenario master list and activation ([#109](https://github.com/frizman21/smai-server/issues/109))

**Purpose:** Establish the scenario master list and the per-tenant scenario activation join, with admin-gated endpoints.

**Components touched:** Scenario master list table. Scenario activation join table. `/admin/scenarios/*` and `/admin/accounts/{accountId}/scenarios` endpoint handlers.

**Key behavior:** Per §9A.3. Validation per SPEC-03 v1.3.3 §10 (scenario-scoped-to-job-type rule). Bulk activation/deactivation semantics per §9A.2 and §12.6.1. Audit logging per §10.

**Dependencies:** Slice C complete (tenant job type activation must exist before scenario activation can validate).

**Excluded:** Frontend scenario activation UI. Template variant management.

### Slice H, Backend: Campaign template variant management ([#110](https://github.com/frizman21/smai-server/issues/110))

**Purpose:** Establish the template variant master list and the atomic two-step activation operation per SPEC-11 v2.0.1 §11.2.

**Components touched:** Template variant master list table. `/admin/template-variants/*` endpoint handlers including the atomic activation endpoint.

**Key behavior:** Per §9B. Loading per §9B.2. Activation per §9B.3. Validation per SPEC-11 v2.0.1 §7.1 and §11.1 (immutability, append-only). Audit logging per §10.

Loader mechanism is Mark's engineering decision per SPEC-11 v2.0.1 §13. If Mark chooses an admin portal POST endpoint, that endpoint is part of this slice. If Mark chooses CI hook or script, the activation endpoint is the only required surface here.

**Dependencies:** Slice G complete (scenarios must exist before template variants can reference them).

**Excluded:** Frontend template variant UI. Authoring methodology (SPEC-12 v2.0).

### Slice I, Admin Portal frontend: Account and Location management, **post-pilot**

(Per §14 not blocking pilot.)

### Slice J, Admin Portal frontend: Tenant job type and scenario activation, **post-pilot**

(Per §14 not blocking pilot.)

### Slice K, Admin Portal frontend: Template variant management, **post-pilot**

(Per §14 not blocking pilot.)

### Slice L, Admin Portal frontend: Audit log review, **post-pilot**

(Per §14 not blocking pilot. Direct DB query acceptable for pilot.)

---

## 16. Acceptance Criteria

**Given** SMAI staff with `GLOBAL_ADMIN` auth, **when** they POST a new location for Jeff's account with all required fields per §8.1 present, **then** the location is created with `is_active = false`. The activation endpoint is then called and validation per §8.3 passes; `is_active` flips to true.

**Given** SMAI staff attempt to activate a location missing `phone_number`, **when** the activation endpoint fires, **then** activation fails with a typed error naming the missing field. `is_active` remains false.

**Given** SMAI staff upload a logo via `POST /admin/accounts/{accountId}/logo`, **when** the upload completes, **then** the file is stored in GCS at the path per §7.2, `accounts.logo_url` is updated to the new URL, and an audit log entry with `event_type = account_logo_uploaded` is written.

**Given** the job type master list contains all v1 active values per SPEC-03 v1.3.3 §7.1 (including `trauma_biohazard` per the rename and excluding `environmental_asbestos` as a legacy slug), **when** Jeff's tenant activation is set to the 5 sub-types per §12.4, **then** Jeff's operator Job Type picker shows exactly those 5 options. Contents and Temporary Repairs do not appear.

**Given** Jeff's operator Scenario picker is opened for the activated `general_cleaning` sub-type, **when** the picker renders, **then** it shows exactly the 4 activated scenarios per §12.6: `commercial_deep_clean`, `post_construction_cleanup`, `move_in_move_out`, `odor_remediation`. The deactivated scenarios `hvac_cleaning` and `recurring_commercial_service` do not appear, and the renamed slug `commercial_deep_clean` (not the legacy `commercial_janitorial_deep_clean`) is in the master list.

**Given** SMAI staff attempts to activate a scenario for Jeff whose parent job type is not activated for Jeff's tenant, **when** the request fires, **then** activation fails with a typed error naming the parent job type that must be activated first.

**Given** SMAI staff attempts to activate a `job_type` for a tenant with no scenarios under it currently activated for that tenant, **when** the activation endpoint fires, **then** activation fails with a typed error citing SPEC-03 v1.3.3 §10.3 and naming the constraint violated. Per the symmetric activation gate, a sub-type activation is rejected unless at least one scenario under it is also activated for the tenant.

**Given** SMAI staff deactivates a scenario for Jeff's tenant via the bulk PUT endpoint, **when** the write completes, **then** an audit log entry with `event_type = tenant_scenario_deactivated` is written. Subsequent operator Scenario pickers for Jeff do not show the deactivated scenario. Historical jobs created with that scenario retain their `scenario_key` per SPEC-03 v1.3.3 §10.3.

**Given** SMAI staff loads a new template variant via `POST /admin/template-variants` with all required fields including `authoring_hypothesis` non-empty, **when** the load completes, **then** the variant exists in the master list with `is_active = false`. The activation endpoint must be called separately to flip it to `is_active = true`.

**Given** an active template variant `v1` for the pair (`mold_remediation`, `crawlspace_mold`) and a new variant `v2` loaded for the same pair, **when** SMAI staff invokes `POST /admin/template-variants/{v2.template_version_id}/activate`, **then** within a single database transaction `v2.is_active` flips to true and `v1.is_active` flips to false. Both transitions are reflected in audit logs. At no point does the database contain two rows with `is_active = true` for the same pair.

**Given** a (`job_type`, `scenario_key`) pair with no prior active template variant, **when** SMAI staff invokes the activation endpoint for the first variant ever loaded for that pair, **then** the new variant becomes active. The prior-deactivation step is a no-op because no prior active row exists. The operation succeeds.

**Given** an active template variant `v1` for the pair (`water_mitigation`, `pipe_burst`), **when** a new campaign is generated via PRD-02 v1.5 intake at time T, **then** the resulting `campaigns.template_version_id` references `v1`. **Given** SMAI staff activates a new variant `v2` for the same pair at time T+5min, **when** a second campaign is generated at T+10min, **then** that campaign's `template_version_id` references `v2`. The first campaign retains its `v1` reference; no retroactive update.

**Given** SMAI staff attempts to PUT a content field update to an already-loaded template variant, **when** the request fires, **then** it is rejected with a typed error. Content is write-once per SPEC-11 v2.0.1 §11.1. The only mutable fields on a template variant are `is_active`, `activated_at`, and `deactivated_at`, and those are mutated only via the activation endpoint.

**Given** Jeff's tenant has 17 scenarios activated per §12.6, **when** the seed verification query runs at onboarding QA, **then** for every (`job_type`, `scenario_key`) pair in Jeff's activation join, exactly one template variant row exists with `is_active = true`. The check returns 17 active variants matching Jeff's 17 activated scenarios. If zero or more than one is found for any pair, the onboarding QA gate fails and go-live is blocked.

**Given** the master scenario list contains 33 scenarios, **when** Jeff's activation join is queried, **then** 17 rows are returned with `is_active = true`, and the remaining 16 are absent (or present with `is_active = false`, depending on engineering choice per §12.6.1). The 16 unactivated master scenarios do not require active template variants and the seed verification query does not fail on their absence.

**Given** Jeff's tenant is the only tenant activated for the pair (`water_mitigation`, `pipe_burst`), **when** a different tenant attempts to influence the active template variant for that pair, **then** no path exists to do so from the Admin Portal; template variants are global by (`job_type`, `scenario_key`) and no per-tenant fork exists per §9B.5.

---

## 17. Open Questions, Assumptions, and Engineering Decisions

| Item | Type | Detail |
|------|------|--------|
| Physical form of the job type master list | Engineering decision | Reference table (recommended given scale trajectory) vs. Postgres enum. Requirement: adding a master list entry must not require a code deploy. Carried over from SPEC-03 v1.3.3 §13. |
| Physical form of the scenario master list and scenario activation join | Engineering decision | Same options and same requirement as the job type master list, reference table vs. Postgres enum. Parallel decision, parallel shape. Product recommends the same choice Mark makes for the job type master list to keep the two taxonomies symmetric. Per SPEC-03 v1.3.3 §13. |
| Existing `job_types` table migration path | Engineering decision | Reshape into activation join vs. drop and recreate. Buc-ee's is the first paying tenant; no production data to preserve. Mark to confirm. |
| Cascade behavior on parent job type deactivation | Engineering decision | When a tenant's job type activation is removed, do the scenario activations for that job type auto-deactivate, or remain in the join as orphans? Product requires that the dropdowns behave correctly (deactivated job type does not appear; its scenarios do not appear). The internal join structure is Mark's call. Per SPEC-03 v1.3.3 §10.3. |
| Loader mechanism for template variants | Engineering decision | Per SPEC-11 v2.0.1 §13. Options: admin portal POST endpoint, CI hook on merge to `smai-specs`, or manual script. Product requires that loaded variants are inactive by default and that activation flows through the atomic two-step endpoint. Mark to choose. |
| Caching of active template variants | Engineering decision | Per SPEC-11 v2.0.1 §13. Optional. Templates change rarely; cache invalidation on activation is straightforward. |
| Master list scope vs tenant activation scope | Clarification | Per SPEC-03 v1.3.3 §10.1 and SPEC-11 v2.0.1 §17. Scenarios in the master list have no requirement for an active template variant until they are activated for some tenant. Authoring is gated on tenant activation, not master list presence. Implementation must keep the master list seed (§12.5) independent of the activation seed (§12.6); seeding all 33 master scenarios does not imply 33 variants must exist. |
| Authoring obligation when a new tenant activates a master scenario with no current variant | Operational | Per SPEC-12 v2.0 §11.1, the authoring run for a new tenant follows the same five-stage pipeline. If the tenant activates a master scenario with no current active variant, that variant is authored as part of the new tenant's onboarding. Operational responsibility is on Kyle and Ethan. |
| Audit log review UI | Out of scope for v1 | Direct DB query is acceptable. A future Admin Portal frontend table view is fine but not required. No filtering, export, or search in v1. |
| Support-style impersonation | Out of scope for v1 | SMAI staff cannot log into a tenant's operator product as an operator without being invited normally. Deferred post-pilot. |
| Multi-region, multi-language, multi-currency | Out of scope for v1 | Pilot is US-only, English-only, USD-only. Not addressed. |

---

## 18. System Boundaries

| Responsibility | Owner |
|---------------|-------|
| Admin Portal frontend (codebase TBD per §17), **post-pilot; not blocking pilot** | Frontend / Admin Portal team |
| Admin Portal backend endpoints (`/admin/*`), **go-live blocking for pilot** | smai-backend (Mark) |
| GCS logo upload pipeline | smai-backend (Mark) |
| Audit log infrastructure | smai-backend (Mark) |
| Job type master list schema and seed | smai-backend (Mark), with product seed content per §12.3 |
| Tenant job type activation seed for Jeff (5 sub-types per §12.4) | SMAI internal operations (Kyle, pre-launch) |
| Scenario master list schema and seed (all 33 scenarios per §12.5) | smai-backend (Mark), with product seed content per §12.5; `industry_classification` values per SPEC-03 v1.3.3 §13.2 |
| Scenario master list + activation endpoints (`/admin/scenarios`, `/admin/accounts/{accountId}/scenarios`) | smai-backend (Mark); go-live blocking per Slice G |
| Tenant scenario activation seed for Jeff (17 scenarios per §12.6) | SMAI internal operations (Kyle, pre-launch) |
| Template variant master list + activation endpoint (`/admin/template-variants`, `/admin/template-variants/{id}/activate`) | smai-backend (Mark); go-live blocking per Slice H |
| Template variant content authoring (17 variants for Jeff's go-live) | Kyle + Ethan per SPEC-12 v2.0; authored offline; loaded into master list via Slice H infrastructure |
| Template variant load mechanism decision (POST endpoint vs CI hook vs script) | smai-backend (Mark) per §17 |
| Logo asset for Jeff (Servpro wordmark) | Jeff provides, Kyle uploads |
| Boise and Reno location details | Christian / Jeff provides |
| Operator product reads of Admin-Portal-managed data | smai-backend (Mark); read paths already exist or are added in PRD-07 v1.2, PRD-02 v1.5, PRD-03 v1.4.1, SPEC-07 v1.1 |
| Gmail OAuth flow per location | PRD-09 v1.3.1; not this PRD |
| User creation, role assignment, user field editing | PRD-08 v1.2 operator product; not this PRD |

---

## 19. Out of Scope

- **Admin Portal frontend UI for pilot.** Post-pilot priority. Backend endpoints are the go-live deliverable. See §14.
- Any operator-product or tenant-facing UI for the capabilities covered here.
- Customer self-service account, location, job type, scenario, or template management.
- Billing, invoicing, subscription management.
- Migration tooling for existing production tenants (pilot is the first).
- Multi-region, multi-language, multi-currency.
- Authoring template content for master scenarios not activated for any tenant in v1 (16 master scenarios per §12.5.1 and §12.6 fall here; authoring is gated on tenant activation, deferred to whichever future tenant activates them).
