# PRD-09: Gmail Layer
**Version:** 1.3.1  
**Date:** April 22, 2026  
**Status:** Ready for build  
**Owner:** Kyle (product lead)  
**Tech lead:** Mark (FM Comms / smai-comms owner)  
**Implementation base:** `smai-comms` (Kotlin/Micronaut 4.4, port 8081, GCP Cloud Run `us-central1`)  
**Source truth:** Gmail Layer Spec v1 (April 5, 2026, Mark catch-up session); Forensic Audit April 4, 2026 (direct code inspection of smai-comms, zero TODOs confirmed); Session State v6.0; subdomain standard decision (Session State v6.0); SPEC-07 v1.1 (Originator Identity in Sent Emails); Reconciliation Report 2026-04-16; Mark's signature-read recommendation 2026-04-17; v1.3 cycle canonical schema (PRD-01 v1.4.1)  
**Supersedes:** DL-011 (sales@ shared inbox model, fully superseded by this PRD; DL-017 pending formal log)  
**Related PRDs:** PRD-01 v1.4.1 (Job Record; canonical `pipeline_stage`, `status_overlay`; `cta_type` computed at query time), PRD-03 v1.4.1 (Campaign Engine), PRD-06 v1.3.1 (Job Detail), PRD-08 v1.2 (Settings)  
**Revision note (v1.1):** Replaced `gmail.modify` scope with `gmail.settings.basic` per DECISION 3 and SPEC-07 §7.3. Final v1 scope set is `gmail.send`, `gmail.readonly`, `gmail.settings.basic` (plus the three OpenID identity scopes). Consolidated inbound reply writes (§8.5) and delivery failure writes (§10.2) from the old `job_status_history` + `event_logs` pair to `job_proposal_history` rows discriminated by `event_type`, per PRD-01 v1.2 §12. Added SPEC-07 cross-references for originator identity in the outbound send flow (§9.3). Added physical table naming clarifier to §4 source truth.  
**Revision note (v1.2):** Removed `gmail.settings.basic` from the OAuth scope set. SPEC-07 v1.1 dropped the Gmail signature read in favor of a signature constructed from SMAI data at campaign generation time. The scope was only needed to enable that read. Final v1 scope set is now `gmail.send`, `gmail.readonly`, plus the three OpenID identity scopes. No other changes.  
**Revision note (v1.3):** Verification pass against the v1.3 cycle (PRD-01 v1.4, PRD-03 v1.4, PRD-04 v1.2, PRD-06 v1.3, PRD-08 v1.2; SPEC-03 v1.3, SPEC-11 v2.0, SPEC-12 v1.0; PRD-10 v1.2). Surgical scope: only what the v1.3 canonical schema drives. No behavior changes from v1.2's intent; one contract correction that was a real builder trap.

1. **`cta_type` corrected from stored to computed.** Per PRD-01 v1.4 §7 (and its v1.4.1 OQ-01 alignment), `cta_type` is computed at query time from `jobs.pipeline_stage` and `jobs.status_overlay` only. It is NOT a stored column on the `jobs` table, and `job_campaigns.status` is NOT a CTA input. v1.2 of this PRD incorrectly instructed smai-backend to write `jobs.cta_type = ...` on reply (§8.5), on delivery failure (§10.2), and on refresh token revocation (§7.3). These writes are removed. Only `status_overlay` changes (and campaign status changes) are persisted to the canonical tables. The `cta_type` surfaces correctly at query time; there is no behavioral change for the operator, the builder, or the recipient. This corrects a contract misstatement, not a behavior. (v1.3.1 correction: the v1.3 formula narrative in this point previously read "`pipeline_stage` + `status_overlay` + campaign status"; the third input was aligned out per PRD-01 v1.4 §7 and v1.4.1 OQ-01.)

2. **Version references refreshed.** PRD-01 v1.2 → PRD-01 v1.4 in §4 and §8.5. PRD-03 references now carry `v1.4`. PRD-06 references now carry `v1.3`. PRD-08 references now carry `v1.2`. New §4 locked constraint row explicitly locks the computed-not-stored contract for `cta_type` so the misstatement cannot recur.

Material section changes in v1.3: header (version, status, date, related PRDs); §4 (added `cta_type` computed-not-stored locked constraint row; PRD-01 v1.4 reference); §7.3 (removed `cta_type` write; kept the rest of the revocation sequence); §8.5 (removed `cta_type` write; kept reply stop sequence and all `job_proposal_history` writes); §10.2 (removed `cta_type` write; kept delivery-failure stop sequence and all `job_proposal_history` writes); §16 (removed `cta_type` from the list of fields smai-backend writes on reply). All other sections unchanged.

**Revision note (v1.3.1, 2026-04-22):** Three surgical corrections; no behavioral change. (1) B-04: the `cta_type` formula narrative in the v1.3 revision note point 1 and in the §4 locked-constraint row both referenced `pipeline_stage` + `status_overlay` + campaign status. Per PRD-01 v1.4 §7 (and v1.4.1 OQ-01 alignment), `cta_type` is computed from `pipeline_stage` and `status_overlay` only. Campaign status is not a CTA input. The formula is corrected in both places. The writes description on the §4 row retains "(and campaign status changes)" because that remains a legitimate operational note about what smai-backend persists to the canonical tables. (2) M-13 (folded into B-04): §4 authority label on the `cta_type` row changed from "PRD-01 v1.4; PRD-04 v1.2 canonical CTA enum" to "PRD-01 v1.4 §7 canonical CTA mapping" — PRD-01 §7 is the canonical governance; PRD-04's table is a subset (non-surfacing CTAs excluded). (3) H-06: OBO terminology disambiguated in §1. Added a short note at first use of "OBO" distinguishing PRD-09's Gmail delegated OAuth token from the eliminated `on_behalf_of_user_id` job-attribution field referenced in earlier drafts of PRD-01 and PRD-02. Part of the 2026-04-22 v1.3 consistency cleanup (ref: CONSISTENCY-REVIEW-2026-04-22 B-04, H-06, M-13).

**Patch note (2026-04-23):** H2P-01 cross-doc version-reference sweep. Operational references updated: `PRD-01 v1.4` → `PRD-01 v1.4.1`, `PRD-03 v1.4` → `PRD-03 v1.4.1`, `PRD-06 v1.3` → `PRD-06 v1.3.1` to match the parallel patches. Audit-trail revision-note text preserved byte-exact. PRD-09 source-truth contains no out-of-repo Spec orphans (it references in-repo SPEC-07 and PRD-01, plus implementation artifacts), so M2P-08 L-01 annotations are not applicable here. No version bump on PRD-09 (sweep is pointer-hygiene only). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-01.

**Patch note (2026-04-23, H2P-05 enum-casing convention applied):** PRD-09 §9.1 line 364 (Firestore email log status machine `PENDING → SENDING → SENT`) and §9.2 / §10.1 / §10.2 references confirmed already aligned to the canonical enum-casing convention now documented at PRD-01 §12. Per Mark (transcribed call 2026-04-23), all enum values are uppercase on the backend (Firestore and Postgres alike); PRD/SPEC text references enums in lowercase for readability with no contradiction. The CONSISTENCY-REVIEW-2026-04-23 H2P-05 finding flagged divergent casing between PRD-09's uppercase Firestore and PRD-03's lowercase Postgres references; the divergence was a brief Postgres-side regression Mark is reverting in code, not a doc problem. PRD-09's uppercase Firestore notation reflects backend reality and remains unchanged. No operational text edits needed in PRD-09. Also documented: `messages.status = 'delivered'` is no longer in the canonical enum (PRD-07 §8.1 and §13.3 dropped this in the parallel Wave 6D patch). PRD-09 does not write `delivered` anywhere, so no edit required here. No version bump on PRD-09 (convention confirmation; no behavioral or text change). Ref: CONSISTENCY-REVIEW-2026-04-23 H2P-05; PRD-01 §12 canonical enum-casing convention; transcribed call with Mark 2026-04-23.

---

## 1. What This Is in Plain English

The Gmail Layer is the trust-critical infrastructure that sends every campaign email and detects every customer reply. It sits between smai-backend (which decides what to send and when) and the Gmail API (which carries out the send). If it fails silently, emails go out from the wrong identity or customer replies disappear. Neither is acceptable.

The model: each location gets one dedicated Gmail mailbox. That mailbox belongs to the customer's Google Workspace — not to SMAI. SMAI holds an encrypted OAuth token for that mailbox, uses it to call the Gmail API on behalf of the customer (OBO), and monitors the same mailbox for inbound replies via Pub/Sub push. The customer's end recipient sees email from a real address that belongs to the operator's business, with the originator's name in the From display and the originator's Gmail signature at the bottom per SPEC-07. SMAI does not appear in the From field. SMAI does not route email through its own mail infrastructure.

**Terminology note on "OBO":** Throughout this PRD, "OBO" and "OBO token" refer exclusively to the Gmail delegated OAuth mechanism described above — the location-scoped OAuth token stored in the `obo-accounts` Firestore collection and used by smai-comms to call the Gmail API on behalf of the customer's mailbox. This is NOT the same as the eliminated `on_behalf_of_user_id` job-attribution field referenced in earlier drafts of PRD-01 and PRD-02 (which tracked which user a job record was created on behalf of at intake time). The two concepts are unrelated: PRD-09's OBO is a Gmail transport authorization; the eliminated `on_behalf_of_user_id` was a user-attribution field that no longer exists in the canonical job schema.

`smai-comms` is the implementation. The forensic audit (April 4) confirmed: zero TODOs, all core services implemented and deployed to Cloud Run. This is not a greenfield build. This PRD is the governing spec that defines what is built, what rules it must follow, what the configuration is for Jeff's three locations, and what the operational contract is for every location onboarded after Jeff.

---

## 2. What Builders Must Not Misunderstand

1. **smai-comms is built and clean.** The April 4 forensic audit found zero TODOs in smai-comms — it is the cleanest codebase in the system. `EmailSendingService`, `OboTokenService`, `GoogleKmsService`, `GmailService`, `GmailPushController`, `InboundMessageProcessor`, `WatchRenewalService`, `MachineOpenDetector`, and `SuppressionService` are all present and deployed. This PRD reconciles against confirmed reality, not a planned build.

2. **The `mail` subdomain is the standard. Jeff's three addresses are locked.** The operational mailbox for every SMAI location must be on a dedicated `mail` subdomain of the customer's primary domain. The specific addresses for Jeff's pilot are defined in Section 5.2. They are not recommendations — they are the canonical addresses that smai-comms connects to.

3. **Sending happens through the Gmail API with the OBO token. SMAI's servers are not in the send path.** `smai-comms` calls `gmail.users.messages.send` with the customer's OAuth token. Google's mail servers deliver the email. DKIM, SPF, and DMARC all pass because Google signs with the customer's domain keys. SMAI does not own or proxy the SMTP delivery.

4. **The Gmail watch expires every 7 days.** `WatchRenewalService` renews it proactively. If a watch lapses, customer replies are not detected. The campaign continues sending but stop conditions do not fire. This is a trust-contract breach. Watch health is a monitored operational metric, not a "nice to have."

5. **Agent 09 is a CRITICAL governance gap and must be resolved before go-live.** The forensic audit found Agent 09 (Inbox Manager) had `gmail_send` tool access and ran 6x daily against a single `GOOGLE_REFRESH_TOKEN` in the Railway environment — not the OBO token model. RESOLVED April 8, 2026 (see §13). Retained in this list as a permanent reminder that autonomous send tooling violates the approval-first trust contract. Any future addition of similar tooling triggers the same review.

6. **Machine-generated auto-responses must not trigger campaign stop.** `MachineOpenDetector` is the filter. Out-of-office replies, read receipts, and delivery status notifications do not constitute a customer reply. A campaign that stops because of an autoresponder is a defect.

7. **Google Groups cannot be used as an operational mailbox.** A Group has no mailbox behind it. The Gmail API authenticates to a mailbox, calls its send endpoint, and monitors its inbox via push subscription. There is no inbox behind a Group address. This is a hard technical boundary with no workaround.

8. **Personal Gmail accounts (`@gmail.com`) are not supported.** Google Workspace is required. Locked in DL-010.

9. **Suppression is permanent within the location scope.** A hard bounce suppresses the address. The operator's Fix Issue flow updates the job contact record, but that does not automatically un-suppress the address in `SuppressionService`. SMAI admin must manually clear a suppression if an operator has corrected a previously bounced address and believes it is now deliverable.

10. **The pre-send checklist runs at send time, not at scheduling time.** The Cloud Task is enqueued at campaign activation. Whether to actually send is decided when the task fires. Job state can change between enqueue and fire. The checklist is the gate that catches those changes.

11. **OIDC authentication governs the smai-backend → smai-comms call.** Per the forensic audit (G.2), smai-comms receives the send request via OIDC-authenticated internal call. No API keys in transit. Service accounts handle the trust.

12. **OAuth scope set is final and narrow.** `gmail.send`, `gmail.readonly`. No `gmail.modify`. No `gmail.settings.basic`. No contacts, no calendar, no Drive. SPEC-07 v1.1 uses a signature constructed from SMAI data at campaign generation time, removing the v1.1 dependency on `gmail.settings.basic`. See §6.3.

13. **Originator identity in sent emails is governed by SPEC-07, not this PRD.** The From display name, signature block, and send-as construction are SPEC-07's jurisdiction. This PRD defines the mailbox, token, scope, transport, and reply path. Sections §9.3 and §6.3 cross-reference SPEC-07 where the two specs touch.

---

## 3. Purpose, Scope, and Non-Goals

**This PRD covers:**
- The mailbox architecture: one per location, `mail` subdomain standard
- Jeff's three locked addresses and the DNS requirements for the `mail` subdomain
- Who creates the mailbox and who completes OAuth (what requires Workspace admin vs. what does not)
- OAuth scopes, the connection flow, and `OboAccountController` / `OboCallbackController` behavior
- Token lifecycle: access token refresh, refresh token storage, KMS encryption, revocation handling
- The `obo-accounts` Firestore document schema
- Gmail watch lifecycle: establishment, the 7-day expiry, `WatchRenewalService`, watch failure monitoring
- The complete inbound reply detection sequence: Pub/Sub push → `GmailPushController` → `InboundMessageProcessor` → thread matching → `MachineOpenDetector` → job state change
- The complete outbound send sequence: Cloud Task → smai-backend → smai-comms → pre-send checklist → `EmailSendingService` → `OboTokenService` → `GmailService` → Gmail API
- The pre-send checklist: all seven conditions in order with failure behavior for each
- Suppression rules: `SuppressionService`, what triggers suppression, what does not, recovery
- The optional delegation layer: what it is, what SMAI does not do with it
- Connection states and their system-wide effects
- The onboarding sequence for a new location
- All failure states and recovery paths
- The Agent 09 governance gap: why it was a go-live blocker and how it was closed

**This PRD does not cover:**
- Campaign Engine scheduling logic and Cloud Task enqueue (PRD-03)
- The Fix Issue operator flow and email correction UI (PRD-06)
- The Gmail connection status display in the operator Settings screen (PRD-08)
- Microsoft 365, Exchange, or custom SMTP (permanently out of scope — DL-010)
- Per-user OBO sending identity (location-level by design)
- Operator self-serve Gmail connection in the operator product (v1 is SMAI-admin-initiated via admin portal)
- SMS sending (separate spec)
- Originator identity: From display name, signature block, signature priority chain (SPEC-07 governs)

---

## 4. Source Truth and Locked Constraints

| Constraint | Source |
|---|---|
| One operational mailbox per location. Not per user, not per account. | Gmail Layer Spec v1, forensic audit confirmed |
| Subdomain standard: `{location-identifier}@mail.{customer-primary-domain}` | Session State v6.0, Mark's subdomain recommendation |
| `mail` is the required subdomain prefix. Not `email`, `campaigns`, or primary domain. | Session State v6.0 |
| Jeff's three addresses are locked: see Section 5.2. | Session State v6.0 |
| Google Workspace required. Personal `@gmail.com` not supported. | DL-010 |
| Google Groups not supported. Hard technical boundary. | Gmail Layer Spec v1 |
| OAuth scopes: `gmail.send`, `gmail.readonly` — exactly these two, plus OpenID identity scopes. `gmail.modify` and `gmail.settings.basic` are both explicitly not requested. | DECISION 3 / Reconciliation Report 2026-04-16; SPEC-07 v1.1 (no Gmail signature read) |
| Tokens encrypted via Cloud KMS (`obo-keyring/obo-refresh-token-key`). Stored in Firestore `smai-comms-db`, collection `obo-accounts`. | Forensic audit confirmed resource names |
| smai-comms is the implementation base. Zero TODOs confirmed by forensic audit. | Forensic audit April 4, 2026 |
| Gmail watch expires every 7 days. `WatchRenewalService` renews proactively. Scheduled via Cloud Scheduler `gmail-watch-renewal-job` (daily midnight UTC). | Forensic audit confirmed (Section A.5, F.1) |
| Pub/Sub topic: `gmail-watch`. Subscription pushes to smai-comms `/api/v1/internal/gmail/push`. | Forensic audit confirmed (Section F.1, G.3) |
| Pre-send checklist runs at send time. `sm-comms-email-send` Cloud Tasks queue. | Forensic audit confirmed (Section F.1, G.2) |
| smai-backend → smai-comms call is OIDC authenticated. No API keys in transit. | Forensic audit confirmed (Section G.2) |
| AllowList is disabled in production (`AllowListConfiguration.enabled = false`). All recipients permitted in prod. Suppression lists are the only recipient guardrail. | Forensic audit confirmed (Section B.2, H.2) |
| Agent 09 can send email autonomously without Board approval gate. CRITICAL go-live blocker. §6 added to spec; code gate required before prod deploy (bd: HR-27-agent09-email-gate). | Forensic audit finding C2; bd ticket HR-27-agent09-email-gate |
| DL-011 (sales@ shared inbox model) is fully superseded by this PRD. | Session State v6.0 |
| Originator identity (From display name, signature block) governed by SPEC-07. PRD-09 covers transport; SPEC-07 covers identity composition. | SPEC-07 |
| History writes consolidated to `job_proposal_history` with `event_type` discriminator. Prose in this PRD continues to say "jobs" and references Firestore `messages` and `email_log` collections for smai-comms-side storage. Physical table names: `job_proposals` (jobs), `campaigns` (job_campaigns), `job_proposal_history`. | PRD-01 v1.4.1 §12, DL-026, DL-027 |
| `cta_type` is computed at query time from `jobs.pipeline_stage` + `jobs.status_overlay`. It is NOT a stored column on the `jobs` table. smai-backend writes `status_overlay` changes (and campaign status changes) to the canonical tables and `job_proposal_history`. The `cta_type` surfaces automatically at read time. No handler in PRD-09 writes a `cta_type` field. | PRD-01 v1.4.1 §7 canonical CTA mapping |

---

## 5. The Mailbox Architecture

### 5.1 One mailbox per location

Every active location in the SMAI system has exactly one dedicated operational Gmail mailbox. This mailbox:

- Is created by the customer in their Google Workspace — not by SMAI
- Requires one licensed Google Workspace seat (~$7-14/month at current pricing — this is the customer's cost, not SMAI's; it must be disclosed clearly before onboarding, never surfaced as a surprise after commitment)
- Is purpose-built for SMAI campaign sending and reply monitoring
- Is not a shared inbox, not an individual employee's personal address, not a Google Group
- Is the `From:` address on every outbound campaign email for that location
- Is the monitored inbox for all inbound replies from that location's active jobs

The scope is location-level.

### 5.2 Jeff's three locked addresses

The three addresses for Jeff's pilot locations are locked. They are canonical and hard-coded into the smai-comms configuration for the Buc-ee's pilot.

| Location | Mailbox address | Subdomain DNS requirement |
|---|---|---|
| Northeast Dallas | `nedallas@mail.servpro-nedallas.com` | `mail.servpro-nedallas.com` with MX, SPF, DKIM configured |
| Boise | `boise@mail.servpro-boise.com` | `mail.servpro-boise.com` with MX, SPF, DKIM configured |
| Reno | `reno@mail.servpro-reno.com` | `mail.servpro-reno.com` with MX, SPF, DKIM configured |

These addresses are not placeholders. They are the production addresses.

### 5.3 Why the `mail` subdomain

Deliverability and domain reputation isolation. Sending campaign volume from the primary domain puts the entire business at risk: a deliverability incident on the campaign mailbox would cascade to all email from the primary domain (`@servpro-nedallas.com`). Isolating to a `mail` subdomain means campaign-scoped deliverability incidents stay scoped. DKIM signatures are per-subdomain. SPF and DMARC policies can be tuned separately.

Additionally, the `mail` subdomain signals "this is a mail origin" clearly to receiving MTAs, which is marginally helpful for bulk-send reputation building.

### 5.4 DNS requirements for the `mail` subdomain

The customer's Workspace admin completes these steps before onboarding. SMAI does not touch the customer's DNS.

| Record | Value |
|---|---|
| MX record for `mail.{domain}` | Points to Google's mail servers (same as primary domain MX, but scoped to subdomain) |
| SPF TXT for `mail.{domain}` | `v=spf1 include:_spf.google.com ~all` |
| DKIM TXT for `mail.{domain}` | Generated in Google Workspace admin panel, published as TXT record |
| DMARC TXT for `mail.{domain}` (recommended, not required) | `v=DMARC1; p=quarantine; rua=mailto:admin@{domain}` |

A Workspace admin who has done this before can complete all four steps in approximately 15 minutes.

### 5.5 Who needs Workspace admin rights — and for what

**Requires Workspace admin rights (one-time setup):**
- Creating the operational mailbox user account in Google Workspace
- Configuring the `mail` subdomain DNS records and verifying the domain in Workspace
- Setting up DKIM for the `mail` subdomain

**Does not require Workspace admin rights:**
- Completing the OAuth consent screen during SMAI onboarding (any user who can log into the operational mailbox can complete the consent flow)
- Granting delegated Gmail access to the customer's team after setup (this is a Workspace admin action, but optional and separate from the SMAI connection)

For Jeff's pilot: Christian is the Workspace admin for the entire ownership group. Christian must be present (or have pre-completed the admin steps) before onboarding day. Jeff can complete the OAuth consent screen himself once Christian has created the mailboxes and configured DNS.

---

## §6 Email Send Approval Gate (REQUIRED for go-live)

**Status:** SPEC-ONLY — code gate required before Agent 09 production deployment.  
**Blocker:** bd ticket HR-27-agent09-email-gate tracks implementation requirement.

Agent 09 MUST NOT send any outbound email without a Board `/decide` vote.

### Gate flow

1. Agent 09 composes email → writes draft gate artifact (`status: pending_board_vote`)
2. Calls `POST /decide` with:
   ```json
   {
     "summary": "Agent 09 email send request",
     "artifacts": [{ "type": "email_draft", "subject": "<subject>", "recipient_count": <n>, "body_preview": "<first 200 chars>" }],
     "priority": "P2"
   }
   ```
3. Polls `/audit/{id}` every 5 seconds — proceeds only on Board `approved` response
4. On rejection: discard draft, log rejection reason, notify requestor via Discord
5. On timeout (>10 min): escalate to CEO via COS DM; do not send

### Scope
This gate applies to ALL Agent 09 outbound sends with no exceptions.

### Implementation note
`board_decide()` must be implemented in the Agent 09 send path before go-live. The implementation is tracked by bd ticket HR-27-agent09-email-gate, which blocks Agent 09 production deployment.

---

## 6. OAuth Connection Flow

### 6.1 Who initiates it

A SMAI admin initiates the OAuth flow from the Location detail view in the internal admin portal (`app.servicemark.ai`). This is not operator self-serve in v1. The operator product does not contain a Gmail connection flow. The connection is established by SMAI staff, walked through on a screen share with the customer.

### 6.2 Step-by-step flow

1. SMAI admin opens the Location detail view in the internal admin portal.
2. Navigates to the OBO Gmail connection section for that location.
3. Initiates the OAuth flow. `OboAccountController` in smai-comms generates the OAuth authorization URL with the three required Gmail scopes plus standard OpenID scopes (see §6.3).
4. The customer's designated person (Workspace admin or user with credentials to the operational mailbox) opens the URL in a browser.
5. Google's OAuth consent screen presents the requested scopes. The user authenticates as the operational mailbox account (e.g., `nedallas@mail.servpro-nedallas.com`) and grants consent.
6. Google redirects to `OboCallbackController` with an authorization code.
7. smai-comms exchanges the authorization code for an access token and a refresh token via Google's token endpoint.
8. `OboTokenService` calls `GoogleKmsService` to encrypt both tokens using Cloud KMS key `obo-keyring/obo-refresh-token-key`.
9. Encrypted tokens are written to Firestore database `smai-comms-db`, collection `obo-accounts`, document keyed by `location_id`.
10. smai-comms calls the Gmail API (`gmail.users.watch`) to establish a Pub/Sub watch on the operational mailbox, subscribing to the `gmail-watch` topic.
11. `watch_expiry` is set to `now() + 7 days`. `watch_history_id` is stored.
12. Connection status updates to `connected`. The location is now email-capable.

### 6.3 Required OAuth scopes (exactly these)

Final v1 Gmail scope set is exactly two Gmail scopes, plus the three standard OpenID identity scopes.

| Scope | Purpose |
|---|---|
| `https://www.googleapis.com/auth/gmail.send` | Outbound campaign email sends via Gmail API |
| `https://www.googleapis.com/auth/gmail.readonly` | Read inbound messages for reply detection |
| `openid` | OpenID authentication |
| `https://www.googleapis.com/auth/userinfo.email` | Authenticated user's email address |
| `https://www.googleapis.com/auth/userinfo.profile` | Authenticated user's name and profile |

SMAI requests no other Google scopes. No `gmail.modify`. No `gmail.settings.basic`. No contacts, no calendar, no Drive, no account-level access beyond these.

**Why `gmail.modify` is not requested.** The forensic audit listed `gmail.modify` as part of the scope set. Reconciliation concluded it is not required for v1:
- Outbound send is covered by `gmail.send`.
- Inbound read and thread state inspection are covered by `gmail.readonly`.
- No SMAI workflow currently writes labels, moves messages between folders, or marks messages as read via the API. If that workflow is ever added, the scope can be requested at that time.

**Why `gmail.settings.basic` is not requested.** The v1.1 version of this PRD required `gmail.settings.basic` to read the originator's Gmail signature per SPEC-07 v1.0 §7.3. SPEC-07 v1.1 removed that read path in favor of a signature constructed from SMAI data (user record, assigned location or job location, and account logo) at campaign generation time. With no Gmail signature read, there is no need for the scope. Removing it narrows OAuth audit surface and simplifies the consent screen without losing any functionality the MVP actually needs.

---

## 7. Token Lifecycle

### 7.1 Firestore `obo-accounts` document schema

One document per connected location, in the `smai-comms-db` Firestore database, `obo-accounts` collection.

```
obo-accounts/{location_id}
  location_id:                string       // FK → locations table PK (Cloud SQL)
  account_id:                 string       // FK → accounts table PK (Cloud SQL)
  mailbox_address:            string       // e.g., "nedallas@mail.servpro-nedallas.com"
  connection_status:          string       // "connected" | "token_refresh_pending" | "disconnected"
  encrypted_access_token:     bytes        // Cloud KMS encrypted (key: obo-keyring/obo-refresh-token-key)
  encrypted_refresh_token:    bytes        // Cloud KMS encrypted
  access_token_expires_at:    timestamp    // short-lived; typically now() + 1 hour
  kms_key_version:            string       // Cloud KMS key version used for encryption
  watch_expiry:               timestamp    // Gmail watch expiry; now() + 7 days from last renewal
  watch_history_id:           string       // Gmail Pub/Sub watch history ID for incremental fetch
  pub_sub_topic:              string       // "projects/{project}/topics/gmail-watch"
  connected_at:               timestamp    // when OAuth was first completed for this location
  last_token_refresh_at:      timestamp
  last_watch_renewal_at:      timestamp
  created_at:                 timestamp
  updated_at:                 timestamp
```

`connection_status` is the source of truth for a location's email capability.

### 7.2 Access token refresh

Access tokens from Google are short-lived (typically 1 hour). `OboTokenService` handles refresh transparently: when a send or read is requested and the cached access token is expired, the service calls Google's token endpoint with the encrypted refresh token, obtains a fresh access token, writes it back to Firestore with the new expiry, and proceeds with the original request.

No email send fails due to an expired access token that could have been refreshed.

### 7.3 Refresh token revocation

Refresh tokens can be revoked by the customer at any time (via Google Account security settings). When `OboTokenService` receives an `invalid_grant` error on refresh attempt:

1. `connection_status` is set to `disconnected`.
2. smai-comms notifies smai-backend (Cloud Tasks `sm-comms-backend-events`).
3. smai-backend sets all active jobs at this location to `status_overlay = delivery_issue`. The `cta_type = fix_delivery_issue` surfaces automatically at query time per PRD-01 v1.4.1 (computed from `pipeline_stage` + `status_overlay`); no `cta_type` field is written.
4. All pending Cloud Tasks for this location's campaign steps will fail pre-send check 1 and drop silently.
5. The disconnected state is surfaced in the operator Settings screen (PRD-08 v1.2 §7.3) with the Reconnect link.
6. A SMAI admin must re-initiate the OAuth flow with the customer to restore service.

SMAI does not discover revocation in real time — it is discovered on the next refresh attempt or send attempt.

---

## 8. Gmail Watch and Inbound Reply Detection

### 8.1 Watch establishment

A Gmail watch is established on the operational mailbox immediately after OAuth callback completes (§6.2, step 10). The watch subscribes the mailbox to the `gmail-watch` Pub/Sub topic. Inbound messages to the mailbox trigger a push notification to smai-comms.

### 8.2 Watch renewal

Gmail watches expire 7 days after establishment. `WatchRenewalService` runs daily at midnight UTC (Cloud Scheduler job `gmail-watch-renewal-job`) and renews any watch with `watch_expiry` within 24 hours. Renewal calls `gmail.users.watch` again and updates `watch_expiry` and `watch_history_id`.

If renewal fails, an alert fires. The watch may still be active (recovery window). If repeated failures occur, SMAI admin intervention is required.

If a watch lapses entirely (`watch_expiry < now()` with no successful renewal), reply detection for the location stops. Campaigns continue sending but stop conditions do not fire on replies. This is a trust-contract breach and must be treated as a sev-1 operational incident.

### 8.3 Inbound message processing sequence

1. Customer sends a reply to the operational mailbox. Gmail delivers the message to the mailbox and publishes a notification to the `gmail-watch` Pub/Sub topic.
2. `GmailPushController` decodes the notification to extract the `mailbox_address` and the Gmail `historyId`.
3. smai-comms calls the Gmail API (`gmail.users.history.list`) using the OBO token, fetching all messages since the last `watch_history_id` for this mailbox. Updates `watch_history_id` in Firestore.
4. For each new inbound message retrieved:
   a. `MachineOpenDetector` evaluates the message. If the message is a machine-generated response (out-of-office, delivery status notification, read receipt, auto-reply), it is logged and discarded. No job state change occurs.
   b. If the message passes `MachineOpenDetector`: `InboundMessageProcessor` attempts thread-to-job resolution.

### 8.4 Thread-to-job resolution

`InboundMessageProcessor` resolves the inbound Gmail message to a SMAI job using two methods, tried in order:

**Method 1: Gmail thread ID matching.** The outbound campaign emails store the Gmail `messageId` in the `messages` table (`external_message_id` field). Gmail threads all replies under the same `threadId` as the original message. `InboundMessageProcessor` matches the inbound message's `threadId` against the `external_message_id` values in the `messages` table to find the associated `job_id`.

**Method 2: Subject line prefix matching (fallback).** If thread ID matching fails (e.g., the customer started a new thread), extract the `[{job_number}]` prefix from the subject line. Match against `jobs.job_number` to find the associated `job_id`. This fallback handles customers who forward or reply from a different email client that breaks thread continuity. The `[{job_number}]` prefix is set on the outbound subject when `internalRef` is present on the job per DECISION 4.

**If no match is found:** Log the inbound message as an unmatched orphan. Store the message in Firestore with `job_id = null`. No job state change occurs. Log for SMAI internal investigation. This is not surfaced as an error to the operator.

### 8.5 Actions on matched reply

When `InboundMessageProcessor` successfully resolves an inbound message to a `job_id`:

1. Store the inbound message in Firestore (email log).
2. Notify smai-backend via Cloud Tasks queue `sm-comms-backend-events`.
3. smai-backend performs the following atomically (same as PRD-03 v1.4.1 §10.1):
   - Write `messages` row: `direction = inbound`, `channel = email`, body = message text.
   - Set `jobs.status_overlay = customer_waiting`. The `cta_type = open_in_gmail` surfaces automatically at query time per PRD-01 v1.4.1; no `cta_type` field is written.
   - Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = null`, `new_status = customer_waiting`, `details = customer_replied`, `changed_by = null`.
   - Set `job_campaigns.status = stopped_on_reply`.
   - Write `job_proposal_history` row: `event_type = customer_replied`, `changed_by = null`.
   - Write `job_proposal_history` row: `event_type = job_needs_attention_flagged`, `changed_by = null`.

**Stop is immediate.** No batch processing. No delay. The campaign is stopped in the same processing cycle as the push notification.

### 8.6 Machine open detection

`MachineOpenDetector` evaluates inbound messages before any job state change. The following are treated as machine-generated and discarded:

- Messages with `Auto-Submitted` header set to any value other than `no`
- Messages with `X-Auto-Response-Suppress` header present
- Messages matching Out-of-Office subject patterns (e.g., subject begins with "Out of Office", "Auto:", "Automatic reply:", "Autoreply:")
- Messages where the sender is a no-reply address (`noreply@`, `no-reply@`, `donotreply@`, `mailer-daemon@`)
- Messages with `Content-Type: multipart/report` (delivery status notifications / NDRs)
- Messages with `X-Google-Group-Id` header (Google Groups notifications)

A message that passes all `MachineOpenDetector` checks is treated as a genuine customer reply and proceeds through the resolution sequence (Section 8.5).

---

## 9. Outbound Send Flow

### 9.1 The full path

```
smai-backend (CampaignWorkerController)
  → Cloud Tasks queue: sm-comms-email-send
    → smai-comms CommunicationController (OIDC authenticated)
      → EmailSendingService.sendEmail()
        → Pre-send checklist (Section 9.2) — all 7 checks must pass
        → OboTokenService.getAccessToken(oboAccountId)
          → Firestore: retrieve encrypted_access_token for location_id
          → GoogleKmsService: decrypt token via Cloud KMS
        → GmailService.sendEmail(oboToken, emailPayload)
          → Construct Gmail message (headers, body, attachments, thread headers)
          → Resolve From display name and signature per SPEC-07 v1.1 §7
          → Call gmail.users.messages.send with oboToken
          → Google mail servers deliver from operational mailbox
        → Inject tracking pixel (TrackingTokenService)
        → Update Firestore email log: PENDING → SENDING → SENT
        → Cloud Tasks queue: sm-comms-backend-events
          → smai-backend notified of send success
          → Write messages row to Cloud SQL
          → Write job_proposal_history row: event_type = campaign_step_sent
```

### 9.2 Pre-send checklist

All seven checks run at send time, in this order. If any check fails, the send is blocked. The failure is logged with the specific check that failed. The Cloud Task is not retried unless the failure is transient (network errors on token refresh). Deterministic failures (job in wrong state, address suppressed) are permanent blocks until the underlying condition is resolved.

| # | Check | Pass condition | Fail behavior |
|---|---|---|---|
| 1 | OBO connection status | `obo-accounts.connection_status = connected` for this location | Block send. Log WARN. Trigger delivery failure path (Section 10.2). |
| 2 | Job pipeline stage | `jobs.pipeline_stage = in_campaign` | Drop task silently. Log. No send, no delivery issue triggered. |
| 3 | Job status overlay | `jobs.status_overlay = null` | Drop task silently. Log. No send. |
| 4 | Campaign run status | `job_campaigns.status = active` | Drop task silently. Log. No send. |
| 5 | Idempotency guard | No existing `messages` row for this `job_campaign_id` and `step_order` with `status = sent` | Drop task silently. Log. Duplicate delivery protection. |
| 6 | Contact email present | `job_contacts.customer_email` is non-null and valid email format | Trigger delivery failure path. Set `delivery_issue`. |
| 7 | Suppression check | `SuppressionService` confirms address is not on hard bounce, unsubscribe, or spam complaint list for this location | Trigger delivery failure path. Set `delivery_issue`. |

**Check 1 fail note:** A disconnected OBO connection is a different failure class from checks 2-7. It blocks all sends for the location, not just this job. The admin portal must alert immediately when `connection_status != connected`.

**Check 5 (idempotency) is non-negotiable.** Cloud Tasks delivers with at-least-once semantics. Without this guard, Cloud Task retries could send duplicate emails to customers. Check 5 must run before any Gmail API call.

### 9.3 What the recipient sees

The recipient-facing identity composition is governed by SPEC-07. Summarizing for transport context:

From name: the originator's full name from their SMAI user record (e.g., "Arturo Mendez"), not a location-level display name. See SPEC-07 v1.1 §7.

From address: the operational mailbox address (e.g., `nedallas@mail.servpro-nedallas.com`).

Reply-To: the same operational mailbox address. Customer replies return to the monitored mailbox.

Subject line: when `internalRef` is present on the job, the subject is prefixed with `[{job_number}]` per DECISION 4. This prefix supports the Method 2 thread-to-job fallback in §8.4.

Signature block: constructed at campaign generation time from the originator's SMAI user record (first name, last name, title, cell phone), the job's location record (display name, address, office phone), and the account record (logo). The composition is stored in the campaign context. See SPEC-07 v1.1 §7 for the full construction rule.

Thread continuity: `GmailService` sets `References` and `In-Reply-To` headers using the Gmail `messageId` from the prior sent message in the campaign sequence. All four campaign emails appear in one Gmail thread to both the customer and the operator.

SMAI branding: invisible. No SMAI domain, no SMAI From address, no SMAI attribution in the email headers.

### 9.4 Service-to-service auth

smai-backend calls smai-comms via OIDC tokens issued by GCP service accounts (`smai-comms-sa`). No API keys pass through the request. The smai-comms Cloud Run service validates the OIDC token on every inbound request. This is the authentication mechanism confirmed by the forensic audit.

---

## 10. Delivery Failure Handling

### 10.1 What constitutes a delivery failure

A delivery failure is any of the following:
- Gmail API returns an error response on `gmail.users.messages.send` (invalid address, API error, rate limit exceeded)
- Gmail reports a hard bounce via Pub/Sub (the sent message generates a delivery status notification indicating permanent failure)
- Pre-send check 1 fails: OBO token invalid or connection disconnected
- Pre-send check 6 fails: contact email missing
- Pre-send check 7 fails: address suppressed

### 10.2 Delivery failure path

When a delivery failure is detected, smai-comms notifies smai-backend via the `sm-comms-backend-events` Cloud Tasks queue. smai-backend executes the delivery failure writes (per PRD-03 v1.4.1 §10.2):

1. Write `delivery_issues` row: `job_id`, `message_id` (if a message row was created before failure), `channel = email`, `issue_type` (one of: `invalid_address`, `bounced`, `blocked`, `unknown`), `resolved = false`.
2. Set `jobs.status_overlay = delivery_issue`. The `cta_type = fix_delivery_issue` surfaces automatically at query time per PRD-01 v1.4.1; no `cta_type` field is written.
3. Set `job_campaigns.status = stopped_on_delivery_issue`.
4. Write `job_proposal_history` row: `event_type = status_overlay_changed`, `old_status = null`, `new_status = delivery_issue`, `details = delivery_failed`, `changed_by = null`.
5. Write `job_proposal_history` row: `event_type = delivery_issue_detected`, `changed_by = null`, `metadata = { issue_type }`.
6. Write `job_proposal_history` row: `event_type = job_needs_attention_flagged`, `changed_by = null`.

All subsequent Cloud Tasks for this job's campaign steps will fail the pre-send checklist at check 3 (`status_overlay != null`) and be dropped silently.

### 10.3 Delivery failure recovery (Fix Issue → Resume)

When the operator corrects the customer email via the Fix Issue flow (PRD-06 v1.3.1 §11.2), smai-backend:
1. Updates `job_contacts.customer_email`.
2. Marks all unresolved `delivery_issues` rows as resolved.
3. Creates a new `job_campaigns` row (`status = active`).
4. Calls smai-comms to begin a new campaign run from the next unsent step.
5. smai-comms schedules new Cloud Tasks.

Note: SuppressionService is not automatically cleared when a contact email is corrected. If the original address was hard-bounced and added to the suppression list, and the operator corrects to the same address, the pre-send check 7 will still block. A SMAI admin must manually clear the suppression for the original address if appropriate.

---

## 11. Suppression Rules

`SuppressionService` in smai-comms maintains a per-location suppression list in Firestore. Suppression is scoped to the `account_id` + `mailbox_address` combination.

### 11.1 Auto-suppressed events

| Event | Suppression type | Effect |
|---|---|---|
| Hard bounce (Gmail API reports `550 5.1.1` or equivalent) | Permanent | Address added to suppression list. Pre-send check 7 blocks all future sends to this address from this location. |
| Explicit unsubscribe (recipient clicks unsubscribe link in any SMAI email) | Permanent | Address added to suppression list. |
| Spam complaint (Gmail marks message as spam, reported via Pub/Sub) | Permanent | Address added to suppression list. |

### 11.2 Not suppressed

| Event | Behavior |
|---|---|
| Soft bounce (temporary failure, e.g., mailbox full) | Not suppressed. Campaign step retried per Cloud Tasks retry config (5 attempts, exponential backoff). If all retries fail, treated as hard bounce. |
| Customer reply | Campaign stops but address is not suppressed. Future jobs can send to the same address. |
| Operator Fix Issue with same address | Does not clear suppression automatically. |

### 11.3 Suppression recovery

Manual only. A SMAI admin can clear a suppression entry from `SuppressionService` via the admin portal. No operator-facing suppression management exists in the operator product.

---

## 12. The Delegation Layer (Optional, Customer-Managed)

Once the operational mailbox is connected to SMAI, the customer can independently grant their team members delegated Gmail access to that mailbox via Google Workspace admin controls.

**What delegation gives the customer's team:** The ability to read, send from, and manage the operational mailbox directly in their own Gmail client. An estimator can see what went out, read customer replies, respond manually from the same address if needed.

**What delegation does not affect:** SMAI's OAuth token and connection. The two access paths are completely independent. Google delegation operates at the mailbox access level. SMAI's OAuth operates at the API level via the stored KMS-encrypted token. One cannot break the other.

**What SMAI does regarding delegation:** Nothing. SMAI does not configure it, manage it, or monitor it. We surface a note during onboarding: "Your team can access this mailbox directly in Gmail if they need visibility into what's going out or to respond manually. Ask your Workspace admin to grant delegated access to the operational mailbox." That is the full extent of SMAI's involvement.

This is additive, not structural. The delegate model means: SMAI holds the API token. The customer owns the mailbox. The customer's team can be granted human-level access to the same mailbox independently.

---

## 13. Agent 09 Governance Gap — Closed

**Finding from forensic audit (April 4, 2026) — CRITICAL:**

Agent 09 (Inbox Manager) had `gmail_send` tool access in `servicemark-cloud`. It ran 6 times daily (08:00, 10:00, 12:00, 14:00, 16:00, 18:00 CT via Railway scheduler). It sent email via a single `GOOGLE_REFRESH_TOKEN` stored in the Railway environment — not via the OBO token model, not via smai-comms, and not via the Gmail Pub/Sub integration. There was no human approval gate before a send. No rate limit on sends during a shift. The token was a single shared credential for all agent Gmail access.

**Why this was a trust-contract violation:**

The SMAI trust contract is approval-first. No outbound email without explicit operator approval of the campaign plan. Agent 09 violated this by having the capability to send autonomous outbound email — from a system account, not even from the operator's OBO mailbox — with no human in the loop.

**Resolution.** `gmail_send` was removed from Agent 09's tools array in the `servicemark-cloud` scheduler configuration. Ethan confirmed April 8, 2026. This go-live blocker is closed.

**Governance precedent.** Any future addition of autonomous send tooling (to any agent, service, or automation) must be reviewed against the approval-first trust contract before deployment. The existence of the v1.0 finding is preserved here as a permanent reference.

---

## 14. Onboarding Sequence for a New Location

This is the complete sequence a SMAI admin follows to bring a new location online. For v1, this is a guided screen share — not a self-serve flow.

**Pre-call customer checklist (send to the customer before the onboarding call):**

- [ ] Create a dedicated Gmail mailbox at `{location-identifier}@mail.{your-domain}.com` in your Google Workspace (requires one licensed Workspace seat, ~$7-14/month — this is your cost)
- [ ] Set up the `mail` subdomain in Workspace: MX record, SPF, DKIM (your Workspace admin can complete these in ~15 minutes)
- [ ] Confirm your Workspace admin's name and availability for the OAuth step (or confirm who will have login credentials to the new mailbox on the call)
- [ ] Optional: decide which team members should have delegated Gmail access to the mailbox after setup, and ask your Workspace admin to set that up after we're done

**SMAI admin steps during onboarding call:**

1. Create the organization in the admin portal (if not already created).
2. Create the location under the organization. Set `location_id`, `name`, `mailbox_address`.
3. Confirm the customer has created the dedicated mailbox and completed DNS setup. Do not proceed if DNS is not in place — SPF/DKIM failures will hurt deliverability from day one.
4. Confirm who will complete the OAuth consent screen on the call (ideally: the person who can log into the operational mailbox directly).
5. Navigate to the Location detail view in the admin portal. Initiate the OBO OAuth flow.
6. Have the customer complete the Google consent screen while sharing their screen. Confirm the consent screen shows exactly the scopes defined in §6.3 (Gmail: send, readonly; plus OpenID identity).
7. Confirm `connection_status = connected` in the admin portal after the callback completes.
8. Confirm `watch_expiry` is set approximately 7 days from now.
9. Create the operator user accounts (Admin and Originators). Assign roles and location access per PRD-08.
10. Confirm login works end to end for at least one operator.
11. Seed a test job and walk through the full campaign flow (estimate upload → campaign activation → Email 1 confirmation in the operational mailbox) before declaring go-live ready.

**Go-live gate:** Do not declare go-live until Email 1 has been confirmed as sent and received in the test customer's inbox with the correct From display name (originator name), correct subject line format (including `[{job_number}]` prefix when applicable per DECISION 4), correct signature block per SPEC-07 v1.1, and correct estimate attachment.

---

## 15. Failure States and Recovery

| Failure | Detection | Effect on operator product | Recovery |
|---|---|---|---|
| Refresh token revoked | `OboTokenService` gets `invalid_grant` error | `connection_status = disconnected`. All active jobs at location enter Delivery Issue overlay. Needs Attention surfaces for all affected jobs. | SMAI admin re-initiates OAuth flow with customer's Workspace admin. |
| Watch lapsed (renewal failure) | `watch_expiry < now()` and no successful renewal | Reply detection stops for the location. Campaigns continue sending but customer replies are not detected. Campaign stop conditions do not fire. | `WatchRenewalService` retry. If persistent: manual `gmail.users.watch` call via admin tooling. |
| Watch renewal failure (before expiry) | `WatchRenewalService` renewal attempt fails | Alert fires. Watch still active until expiry. Recovery window exists before reply detection stops. | `WatchRenewalService` retry. Escalate if repeated failures. |
| Hard bounce on send | Gmail API delivery failure response | Job enters Delivery Issue overlay. Campaign stops. Operator sees Fix Delivery Issue CTA. | Operator fixes customer email via Fix Issue flow (PRD-06 v1.3.1 §11.2). SMAI admin may need to clear suppression if same address was hard-bounced before. |
| Operational mailbox deleted from Workspace | All Gmail API calls for location fail | Same as refresh token revoked. | Customer recreates mailbox. SMAI admin re-initiates OAuth flow. |
| Pub/Sub push delivery failure | Pub/Sub dead-letter or push failure logging | Reply may not be detected for that specific notification. Gmail `historyId` mechanism catches up on next successful push. | Push subscription retry (Pub/Sub handles retries automatically). If persistent: manual `gmail.users.history.list` catchup. |
| Cloud Tasks queue backlog | Delayed task execution | Campaign step emails delayed relative to scheduled timing. | Queue backlog monitoring. Cloud Tasks rate limits: 10 dispatches/sec, 20 concurrent (per forensic audit). |

---

## 16. System Boundaries

| Responsibility | Owner |
|---|---|
| OAuth flow initiation and callback | smai-comms (`OboAccountController`, `OboCallbackController`) |
| Token encryption/decryption | smai-comms (`OboTokenService`, `GoogleKmsService`) via Cloud KMS `obo-keyring/obo-refresh-token-key` |
| Token storage | Firestore `smai-comms-db` `obo-accounts` collection |
| Gmail watch establishment | smai-comms (on OAuth callback completion) |
| Watch renewal | smai-comms (`WatchRenewalService`) triggered by Cloud Scheduler `gmail-watch-renewal-job` |
| Pub/Sub push receipt | smai-comms (`GmailPushController`) |
| Machine open filtering | smai-comms (`MachineOpenDetector`) |
| Thread-to-job resolution | smai-comms (`InboundMessageProcessor`) |
| Backend notification on reply | smai-comms → Cloud Tasks `sm-comms-backend-events` → smai-backend |
| Job state changes on reply (`status_overlay`, campaign stop, `job_proposal_history` rows; `cta_type` surfaces at query time per PRD-01 v1.4.1) | smai-backend |
| Campaign step Cloud Task enqueue | smai-backend (on campaign activation per PRD-03) |
| Pre-send checklist execution | smai-comms (`EmailSendingService`) |
| OBO token retrieval at send time | smai-comms (`OboTokenService`) |
| Gmail API send call | smai-comms (`GmailService`) |
| From display name and signature composition | smai-backend at campaign generation, per SPEC-07 v1.1 |
| Subject line `[{job_number}]` prefix construction | smai-backend at campaign generation per DECISION 4 |
| Tracking pixel injection | smai-comms (`TrackingTokenService`) |
| Firestore email log update | smai-comms |
| Backend notification on send result | smai-comms → Cloud Tasks `sm-comms-backend-events` → smai-backend |
| `messages` row write on send success | smai-backend |
| `job_proposal_history` row write (`event_type = campaign_step_sent`) on send success | smai-backend |
| `delivery_issues` row write and `job_proposal_history` rows on failure | smai-backend |
| Suppression list management | smai-comms (`SuppressionService`) in Firestore |
| Suppression admin override | SMAI admin via admin portal (smai-platform) |
| DNS setup for `mail` subdomain | Customer's Workspace admin |
| Operational mailbox creation | Customer's Workspace admin |
| Optional delegation to customer's team | Customer's Workspace admin (SMAI does not touch) |
| Connection status display in operator Settings | smai-frontend reads from smai-backend which reads `obo-accounts` `connection_status` |

---

## 17. Acceptance Criteria

**AC-01: OBO send identity**
Given a campaign step Cloud Task fires for a job at the Northeast Dallas location, when `GmailService` executes the send, then the Gmail API call uses the token associated with `nedallas@mail.servpro-nedallas.com`. The sent email's `From:` header resolves to `nedallas@mail.servpro-nedallas.com`. No SMAI domain appears in any email header.

**AC-02: Pre-send checklist — connection status check**
Given a location where `connection_status = disconnected`, when a campaign step Cloud Task fires for any job at that location, then no Gmail API call is made, the failure is logged with `check_failed = obo_connection`, and smai-backend is notified to trigger the delivery failure path.

**AC-03: Pre-send checklist — idempotency guard**
Given a Cloud Task for step 2 of a campaign that is delivered twice (simulated at-least-once delivery), when the second execution runs, then the pre-send checklist finds an existing `messages` row with `status = sent` for this `job_campaign_id` and `step_order = 2`, drops the task silently, and no second email is sent to the customer.

**AC-04: Reply detection — human reply stops campaign**
Given a customer sends a genuine reply to an operational mailbox, when the Pub/Sub push is received and processed, then within 30 seconds: the `messages` table has an inbound row for the reply, `jobs.status_overlay = customer_waiting`, `job_campaigns.status = stopped_on_reply`, and `job_proposal_history` contains rows for `event_type = status_overlay_changed`, `event_type = customer_replied`, and `event_type = job_needs_attention_flagged`. The job surfaces `cta_type = open_in_gmail` on the next read per PRD-01 v1.4.1 (computed from `pipeline_stage` + `status_overlay`); no `cta_type` field is written to `jobs`.

**AC-05: Reply detection — machine response does not stop campaign**
Given an out-of-office auto-reply is received at the operational mailbox for a job in campaign, when the Pub/Sub push is processed by `MachineOpenDetector`, then no job state change occurs, `status_overlay` remains `null`, and the campaign continues.

**AC-06: Thread continuity**
Given Email 1 has been sent for a campaign, when Email 2 is sent, then Email 2's `References` and `In-Reply-To` headers contain the Gmail `messageId` from Email 1, placing them in the same Gmail thread visible to the customer.

**AC-07: Watch renewal**
Given a Gmail watch is 6 days old (`watch_expiry` is within 24 hours), when `WatchRenewalService` runs, then a new `gmail.users.watch` call is made, `watch_expiry` is updated to `now() + 7 days`, and `last_watch_renewal_at` is updated in Firestore.

**AC-08: Token refresh**
Given an access token that has expired, when smai-comms needs to send an email, then `OboTokenService` calls Google's token endpoint with the encrypted refresh token to obtain a new access token before making the Gmail API call. No email fails due to an expired access token that could have been refreshed.

**AC-09: Hard bounce suppression**
Given a send results in a Gmail API hard bounce response for a customer email address, when the failure is processed, then the customer's email address is added to `SuppressionService` for that location, `delivery_issues` has an unresolved row for the job, `jobs.status_overlay = delivery_issue`, and `job_proposal_history` contains rows for `event_type = status_overlay_changed`, `event_type = delivery_issue_detected`, and `event_type = job_needs_attention_flagged`.

**AC-10: Fix Issue does not auto-clear suppression**
Given a customer email address is suppressed due to a prior hard bounce, when the operator corrects the email to the same address via Fix Issue and retries, then the pre-send check 7 fails (address still suppressed), the send is blocked, and a SMAI admin must manually clear the suppression before the campaign can resume to that address.

**AC-11: Connection status visible in operator Settings**
Given a location where `connection_status = disconnected`, when the operator views the Settings screen team list, then the Gmail status indicator for the user associated with that location shows the amber disconnected state with the Reconnect link per PRD-08 v1.2 §7.3.

**AC-12: Three locations, three independent connections**
Given Jeff's pilot with three locations (Northeast Dallas, Boise, Reno), when all three OAuth flows are completed, then Firestore `obo-accounts` has three distinct documents keyed by their respective `location_id` values, each with their own encrypted tokens, their own `watch_expiry`, and their own `watch_history_id`. A disconnected state on one location does not affect the other two.

**AC-13: OAuth consent screen — scope set matches §6.3**
Given a SMAI admin initiates the OAuth flow for a new location, when the Google consent screen renders, then exactly the following Google permissions are requested: send email (`gmail.send`), read email (`gmail.readonly`), and basic OpenID identity (`openid`, `userinfo.email`, `userinfo.profile`). No `gmail.modify` permission appears. No `gmail.settings.basic` permission appears. No Drive, Calendar, or Contacts permissions appear.

**AC-14: Signature block constructed from SMAI data at campaign generation**
Given a campaign is generated for a job, when the signature block is composed, then it is constructed from SMAI data only: the originator's user record (first name, last name, title, cell phone), the job's location record (display name, address, office phone), and the account record (logo). The result is stored in the campaign context per SPEC-07 v1.1 §7. No Gmail API call to `users.settings.sendAs.list` or equivalent is made at any point.

**AC-15: Subject line `[{job_number}]` prefix enables fallback match**
Given a customer replies by starting a new Gmail thread (breaking thread ID continuity) to a campaign email whose subject began with `[{job_number}]`, when `InboundMessageProcessor` runs and Method 1 fails, then Method 2 extracts `{job_number}` from the subject, matches `jobs.job_number`, resolves the correct `job_id`, and the reply is processed per §8.5. No orphan is logged.

---

## 18. Open Questions and Implementation Decisions

**OQ-01: Agent 09 resolution path**
RESOLVED. `gmail_send` has been removed from Agent 09's tools array in the servicemark-cloud scheduler configuration. Ethan confirmed April 8, 2026. This go-live blocker is closed. Retained in §2 and §13 as a governance precedent for any future autonomous send tooling.

**OQ-02: Suppression clearing in Fix Issue flow**
Section 10.3 specifies that SuppressionService is not automatically cleared when an operator corrects a customer email via Fix Issue. This is conservative and correct for hard bounces. However, if the operator is correcting a genuinely wrong email address to a valid one, requiring SMAI admin intervention to clear suppression adds friction. Engineering should confirm whether there is a case where automatic suppression clearing on Fix Issue is safe. Current position: manual clear only, SMAI admin required.

**OQ-03: Pub/Sub push authentication**
RESOLVED. `GmailPushController` validates via OIDC. Two additional security improvements are being implemented per ADR-001-comms-ingress-allUsers.md. The ADR is the governing document for this implementation. Mark confirmed April 8, 2026.

**OQ-04: DL-017 formal log**
DL-011 is superseded by this PRD. The Decision Ledger entry DL-017 formalizing the dedicated OBO mailbox per location model was flagged as "pending — to be logged at PRD session start" in Session State v6.0. It should be logged now that this PRD is written.

**OQ-05: AllowList in production**
The forensic audit found `AllowListConfiguration.enabled = false` in production — all recipients are permitted. This is intentional by design (the allow-list is a development safeguard only). Executive awareness: the only production-side recipient guardrail is the suppression list. There is no per-account rate limit on sends beyond the Cloud Tasks queue config (10 dispatches/sec, 20 concurrent). For Buc-ee's scale this is fine. For any account with unusual volume, this should be revisited.

---

## 19. Out of Scope

- Operator self-serve Gmail connection in the operator product (v1 is SMAI-admin-initiated; self-serve is a post-MVP build requiring a customer-facing OAuth flow)
- Microsoft 365, Exchange, or custom SMTP (permanently out of scope — DL-010)
- Per-user OBO sending identity (location-level by design; per-user OBO would require one OAuth connection per user per location)
- SMS sending (separate spec)
- Email open rate tracking via tracking pixel (implemented in `TrackingTokenService` but not used for campaign stop decisions in Buc-ee's — open detection is informational only)
- Unsubscribe link mechanics (implemented in `SuppressionService` but the operator product does not surface unsubscribe management — SMAI-internal admin only)
- Email domain warmup (not automated; customer should ensure the `mail` subdomain mailbox has some prior send history before campaign volume starts — covered in onboarding guidance)
- Campaign email preview for operators (post-MVP; defined in Buc-ee's out of scope per CC-06)
- Internal admin portal Gmail management UI (smai-platform — separate codebase, not part of this PRD)
- Originator identity composition (From display name, signature priority chain) — governed by SPEC-07, not PRD-09
- Gmail signature read via API. SPEC-07 v1.1 uses a signature constructed from SMAI data (user record, location record, account record) at campaign generation. The v1.1 version of this PRD required `gmail.settings.basic` for this read; v1.2 removes it.
- Label/folder management, "mark as read" via API, or any other `gmail.modify`-scope operations — deferred; requires scope re-request if ever needed
