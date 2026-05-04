# ADR 0003: Detect customer replies via Gmail polling with a per-thread snapshot baseline

- **Status:** Accepted
- **Date:** 2026-05-03
- **Deciders:** Mike (engineering)
- **Applies to:** `app/jobs/gmail_reply_poll_job.rb`, `app/jobs/campaign_sweep_job.rb`, `app/services/gmail_sender.rb`, `app/models/campaign_instance.rb`, `app/models/campaign_step_instance.rb`, `config/initializers/omniauth.rb`, `config/sidekiq_cron.yml`

## Context

The campaign engine sends a sequence of emails to a prospective customer over days/weeks. The operator-facing contract is: when the customer replies, the campaign stops sending and the proposal surfaces a "Open in Gmail" CTA so the operator can pick up the conversation by hand. Until this change, that contract was unimplemented — the app sent, but never noticed when the customer wrote back. `CampaignStepInstance.gmail_thread_id` existed as a column and was referenced by the views, but nothing in the codebase ever populated it: `GmailSender#post_send` returned `true`/`false` and discarded the API response that contained the `threadId`.

Two design questions had to be answered together:

1. **How do we get notified about replies?** Gmail offers two primitives: a push integration via Cloud Pub/Sub (Gmail watch + topic + signed JWT push), or polling the Gmail API. Push is "real-time" but requires a GCP project, a topic, a Pub/Sub push subscription, JWT verification on a public webhook, and a daily watch-renewal job (watches expire after 7 days). Polling is bounded-latency but adds no infrastructure.
2. **How do we tell a *reply* apart from any other thread activity?** A naïve "any message from someone other than us = reply" check is fine when we always start a fresh thread, but it's fragile against any future case where the campaign sends onto a thread that already had customer-side traffic (e.g., starting a follow-up sequence on an existing conversation). We want a check that holds even if that changes.

Operator scale is small (a restoration business, low single-digit campaigns/day). Reply latency on the order of minutes is acceptable; reply latency on the order of "we missed it for hours" is not. We also want the reply detector to keep working for a reasonable tail after a campaign technically completes — customers don't always reply within the campaign's send window.

## Decision

A polling job, `GmailReplyPollJob`, runs on its own sidekiq-cron schedule, independent of `CampaignSweepJob`. Each tick the job iterates over a small set of "pollable" campaign instances and asks Gmail for the current state of each one's most recent thread. Reply detection is a cross-reference between two snapshots of the same thread: a baseline captured at send time and the live state read at poll time.

### 1. Polling, not push

`GmailReplyPollJob` runs every 2 minutes in production and every minute in development. The job is independent of the sweep so reply latency isn't gated by send cadence. The query is small enough that 2-minute cadence costs trivial Gmail API quota — one `users.threads.get` per active campaign instance per tick.

We chose polling over Pub/Sub push for v1 because:

- Operator volume doesn't justify GCP project + Pub/Sub topic + signed-JWT webhook + daily watch-renewal scaffolding.
- Polling fits an existing pattern — the sweep job already runs on sidekiq-cron, so there's nothing new for the deploy story to track.
- 2-minute reply latency is acceptable for the restoration-business workflow; sub-minute would not change operator behavior.

We retain the option to add push later. The reply detector's contract (flip `CampaignInstance.status` to `:stopped_on_reply`, set `JobProposal.status_overlay = "customer_waiting"`) is independent of how the trigger fires.

### 2. Snapshot baseline cross-reference

`CampaignSweepJob` now persists three new pieces of metadata after a successful Gmail send:

- `campaign_step_instances.gmail_send_response` (jsonb) — the full body returned by `POST users/me/messages/send` (`id`, `threadId`, `labelIds`).
- `campaign_step_instances.gmail_thread_id` (string, pulled out of the send response for indexable lookups; this column already existed but had never been populated).
- `campaign_step_instances.gmail_thread_snapshot` (jsonb) — the full body returned by `GET users/me/threads/{id}?format=metadata`, fetched immediately after the send.

The snapshot is the baseline of "what the thread looked like the moment we sent." On each poll, `GmailReplyPollJob` calls `users.threads.get` again and compares: if the current thread has more messages than the snapshot AND any of the new messages have a `From` header whose address isn't the connected mailbox, that's a customer reply.

Two robustness properties fall out of this design:

- The detector doesn't have to make assumptions about thread state at send time. If the campaign ever sends onto a thread that already had customer messages, the baseline captures that and only *new* messages count toward the diff.
- A thread-fetch failure at send time is non-fatal: the column is left nil, and the polling job's first pass establishes the baseline (and only flips state on the second-and-later passes). This is the only path where reply detection is delayed by one tick.

### 3. Eligibility: active OR recently-completed, capped at 6 months

The polling query selects step instances whose parent `CampaignInstance.status` is `:active` or `:completed`. For `:completed` instances, `ended_at` must be within the last 6 months (`POLLING_CUTOFF = 6.months`). Active campaigns are never aged out.

`paused`, `stopped_on_reply`, `stopped_on_delivery_issue`, and `stopped_on_closure` are excluded:

- `:stopped_on_reply` — already detected, no work to do.
- `:paused` — operator chose to halt; respecting that choice means not doing anything in the background that would surprise them.
- `:stopped_on_delivery_issue` — bounce/auth/sending fault that blocks the campaign at the *send* layer; reading inbound state is the wrong fix.
- `:stopped_on_closure` — proposal's been won/lost.

A new `campaign_instances.ended_at` datetime column carries the cutoff timestamp. It's set at every status transition out of `:active` (`completed`, `stopped_on_*`, `paused`) and cleared when `paused` returns to `active`. Backfill on the migration set `ended_at = updated_at` for all rows already in a non-active status.

The 6-month constant lives as `GmailReplyPollJob::POLLING_CUTOFF`. When tenant-level configuration is needed, this becomes a column lookup — not a feature now.

### 4. Poll every sent step's thread

The query returns *every* sent step instance on every eligible campaign instance. Each campaign step opens its own Gmail thread (the outbound path doesn't set `In-Reply-To` / `References` headers, so Gmail files each send as a new conversation), which means a customer can reply to any of them independently. Watching only the most recent thread per instance would miss replies the customer sends to an earlier step.

> **Patch note 2026-05-03:** This section originally read "per-instance latest-step polling" with a `DISTINCT ON (campaign_instance_id)` query. That was wrong in practice — production traffic showed customers replying to mid-sequence emails (the one that finally hooked them) while the latest send sat unread. The query was widened to every sent step on every non-won/lost proposal. Per-thread API call cost is acceptable at current operator volume; if it ever isn't, the right fix is to switch to history-API polling per mailbox (one call per tick, regardless of N), not to drop coverage of older threads.

### 5. OAuth scope expansion: `gmail.metadata`

`config/initializers/omniauth.rb` now requests `https://www.googleapis.com/auth/gmail.metadata` in addition to `gmail.send`. Metadata-only scope returns headers (From, Date, Subject) but not message bodies — sufficient for reply detection and the least privilege that satisfies the read path.

Existing connected `ApplicationMailbox` and any `EmailDelegation` accounts will need to disconnect and reconnect once to grant the new scope. There is no way to upgrade an existing token retroactively. The polling job logs and skips on a fetch failure (which is what a missing-scope call surfaces as), so the failure mode is "no replies detected until reconnect" — not a crash loop.

## Consequences

**Positive:**

- The "customer replied" CTA finally works. Until this change the column was wired through the views but never populated; now the data flows end-to-end and the operator sees the right next-step button without manual triage.
- The snapshot baseline makes the reply check robust against future changes to send-time thread state. We don't have to think about it again if the engine ever starts threading replies.
- Send-time and poll-time are decoupled. Poll cadence can change (minute, 2-minute, eventually push) without touching the send path. Conversely, the send path can change templates/timing without affecting the detector.
- The 6-month cutoff makes the polling set bounded over the life of the product. Without it, every completed campaign forever would accrete into the eligibility query, eventually costing real Gmail API quota.

**Negative:**

- Reply latency is bounded by the cron tick (2 minutes in prod). For a restoration-business workflow this is fine; for high-stakes real-time reply use cases it would not be.
- Adding `gmail.metadata` requires every connected mailbox to re-consent. Operators upgrading an existing install will see "no replies detected" until they click through the OAuth flow again. The release notes need to call this out.
- A jsonb snapshot per step instance is non-trivial storage — Gmail's metadata response for a multi-message thread can be a few KB. At current scale this is invisible; at 6 months × thousands of threads/day this would warrant pruning. A future migration could null out `gmail_thread_snapshot` once a campaign is older than the cutoff (the snapshot is only meaningful while the row is still pollable).
- The detector trusts that the From header on a thread message reliably distinguishes "us" from "them." Forwarded replies, mailing-list re-injections, and operator-initiated sends from Gmail's web UI on the same thread will all appear to be replies. Acceptable for v1; a later enrichment could cross-check against `gmail_send_response["id"]` to distinguish messages we actually sent from messages that just look like they're from us.

**Neutral:**

- The existing `CampaignSweepJob` test that asserted "GmailSender returns false" was renamed to "returns nil" — the contract change from boolean to JSON-or-nil propagates to one test name and one helper signature. No production callers needed updates because the truthy/falsy semantics are preserved.

## Worked example: customer reply lifecycle

Before this ADR:

1. Campaign sends step 1, step 2, step 3 over 14 days.
2. Customer replies after step 2.
3. Step 3 sends anyway because nothing watches the thread. Operator gets a reply in their inbox separately and may or may not realize the campaign is still firing.
4. Proposal CTA still says "View job" — there's no signal in the app that the customer engaged.

After this ADR:

1. Campaign sends step 1; the sweep stores the send response, the thread id, and the post-send thread snapshot (single outgoing message).
2. `GmailReplyPollJob` ticks every 2 minutes, fetches the thread, sees one message — same as the snapshot. No-op.
3. Customer replies. The next tick (≤2 min later) fetches the thread, sees two messages, recognizes the new one's From isn't the connected mailbox, and flips:
   - `CampaignInstance.status = :stopped_on_reply`
   - `CampaignInstance.ended_at = Time.current`
   - `JobProposal.status_overlay = "customer_waiting"`
4. Proposal CTA in the list view changes to "Open in Gmail" — clicking jumps the operator straight into the conversation.
5. Step 2's sweep tick sees the campaign instance is no longer `:active` and skips the send. No further emails go out.

## Alternatives considered

1. **Gmail push notifications via Cloud Pub/Sub.** Rejected for v1. Real-time is nice, but it requires a GCP project + Pub/Sub topic + signed-JWT webhook controller + daily watch-renewal cron + a re-consent path for the broader scope (`gmail.modify` for `users.watch`). The scaffolding cost vastly exceeds the latency win at current operator volume. Polling is reversible — we can add push later behind the same `:stopped_on_reply` contract without touching the rest of the system.
2. **"Any message from someone other than us in the thread = reply."** Rejected as fragile. Works today because we always open a fresh thread per send, but breaks the moment the engine threads a follow-up onto an existing conversation. The snapshot baseline costs one extra `users.threads.get` per send and decouples the detector from send-time thread shape.
3. **Use `users.history.list` with the mailbox-level historyId.** Rejected for v1 complexity. The history API is the right primitive at scale (one call returns all changes since a watermark) but it requires storing a watermark per mailbox and reasoning about gaps when the watermark gets too old. Per-thread polling is more code-light and fits the small-N scale we're at.
4. **Use `updated_at` as the campaign-ended timestamp instead of adding `ended_at`.** Rejected. `updated_at` is bumped by any field change, including the reply-detection write itself. Using it as a 6-month cutoff would be self-extending: every poll on a near-cutoff row would push it back into the eligibility window. A dedicated `ended_at` is set once at the terminal transition and means what it says.
5. **Poll only the latest step's thread per campaign instance.** Originally accepted, then reversed (see Patch note 2026-05-03 in §4). The latest-only query was cheaper, but it silently dropped replies to earlier steps in the sequence — exactly the case where the customer engaged with a particular email and left it open while the engine kept sending. A campaign that sent 5 steps does cost 5x the Gmail API calls per tick, but the alternative is missing real replies, which is the whole point of the job.
6. **Hard-stop polling at the moment a campaign completes.** Rejected. Customers reply late — sometimes weeks after the final email lands. Cutting polling at completion would silently drop those late replies on the floor. The 6-month cutoff is a generous tail that respects how restoration customers actually engage.
