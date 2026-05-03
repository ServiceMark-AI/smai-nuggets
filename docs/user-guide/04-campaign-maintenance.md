# 4. Campaign Maintenance

> Audience: **tenant user**.
>
> Day-to-day work happens against job proposals. Each upload becomes a proposal, the system kicks off the right campaign, and you monitor and intervene from the proposal index.

---

## 4a. Upload a job to start a campaign

1. **Sidebar → Job Proposals**.
2. Click **+ New job** (top right). A drag-and-drop zone appears.
3. Drop your PDF estimate or proposal onto the zone, or click it to pick a file from your computer. The **Upload** button enables once a file is selected.
4. Click **Upload**.

You land back on the **Job Proposals** index with the new row at the top. The system reads the PDF, fills in the customer's name, address, job description, total amount, internal reference, and the inferred job type, and starts the campaign for the matching scenario. The first email goes out on the cadence the admin set up for that campaign.

A few practical notes:

- **Give it a moment.** Reading the PDF takes a few seconds. If the new row's customer name or amount looks blank right after upload, refresh the page.
- **Check the inferred job type.** Open the new row and confirm the **Job Type** matches the work — if extraction misread the document, the wrong campaign would start. Tell an admin if it's consistently wrong on a particular form layout.
- **Job type or scenario not activated for your tenant?** No campaign starts. The proposal is still saved, but it sits idle until your admin activates the matching job type and scenario for your tenant ([§2.4](02-tenant-onboarding.md#24-activate-job-types-and-scenarios)).
- **Upload error?** A red banner at the top of the page explains what went wrong (e.g. unreadable file, missing tenant assignment). Fix the listed issue and try again.

## 4b. The proposal status board

`Sidebar → Job Proposals` is the operating board. Each row represents one proposal.

**Filters (top of page):**

- **Search** — customer name, address fragment, or internal reference.
- **Status** — `new`, `open`, `closed`.
- **Owner** / **Created by** — restrict to a specific teammate.
- **Sort** — column headers for *Proposal value* and *Created* are sortable; the active sort is preserved across filter submits via hidden fields.

**Columns:**

- **Address** — links to the proposal show page.
- **Customer** — first + last name (or `—` if not extracted).
- **Organization** — which org owns the proposal (relevant if your tenant has multiple).
- **Job Type** — derived from extraction; `—` if the model couldn't infer one.
- **Status** — high-level lifecycle: `new` immediately after upload, `open` while a campaign is running, `closed` after a terminal outcome.
- **Proposal value** — extracted total, formatted as currency.
- **Owner** / **Created by** — display names (first + last) with email fallback.
- **Created** — date the proposal was uploaded.

**Underneath the visible columns**, each proposal also carries a `pipeline_stage` (`in_campaign`, `won`, `lost`) and an optional `status_overlay` modifier (`paused`, `customer_waiting`, `delivery_issue`) — these drive the operator state model documented in PRD-01 and SPEC-09. The overlay surfaces in the **Status details** of the show page.

Click any row's address to drill into the proposal show page, where the customer card, job card, ownership card, and (where present) the snapshotted last reply are displayed.

## 4c. Pausing & unpausing a campaign

> Pause a single proposal's campaign run when the customer goes silent for a known good reason (vacation, traveling, in escrow). Pause the *campaign template* (admin-only, [§1.5](01-job-types-and-campaigns.md#15-approve-pause-and-edit-the-campaign)) when content needs a fix.

Today, campaign-instance-level pause / resume is exposed at the data layer — a `CampaignInstance` has `status: active | paused | completed | stopped_on_reply | stopped_on_delivery_issue | stopped_on_closure`. The operator-facing UI to flip an instance between `active` and `paused` from the proposal show page is not yet wired up; the planned interaction:

1. Open the proposal show page.
2. In the **Campaign** card (forthcoming), click **Pause** to set the instance status to `paused`. The next scheduled step does not send.
3. Click **Resume** when you are ready to continue. The cadence picks up from where it left off; missed sends are re-planned forward, not backfilled.

Until that screen ships, an admin can flip status via the Rails console:

```ruby
proposal = JobProposal.find(<id>)
instance = proposal.campaign_instances.last
instance.update!(status: :paused)    # or :active to resume
```

This is intentionally a thin escape hatch — the supported flow will be the proposal show page.

## 4d. Customer responds

Customer replies arrive into the application mailbox and are matched back to the campaign instance via `gmail_thread_id`, which is stamped on every `CampaignStepInstance` at send time.

When a reply is detected:

1. The matching `CampaignInstance` is transitioned to `stopped_on_reply` — the campaign cadence halts immediately and no further sends are attempted on that thread.
2. A snapshot of the inbound message (`from`, `at`, `subject`, `snippet`) is written to `JobProposal.last_reply` (a JSONB column) so the reply is visible on the proposal show page without re-fetching from Gmail.
3. The proposal's `status_overlay` is set to `customer_waiting` — on the index, the row is treated as a needs-attention item.

What you do next:

1. Open the proposal from the index. The **Last reply** card shows the snippet, who it came from, and when.
2. Click into Gmail (the show page exposes a deep link to the thread when one is available) to read the full reply and respond from your operator inbox.
3. Once the conversation is converging on an outcome, mark the proposal won or lost ([§4e](#4e-marking-a-proposal-as-won--lost)).

> Delivery failures (bounces, hard rejections) follow a parallel path: the `CampaignStepInstance.email_delivery_status` flips to `failed` or `bounced`, the `CampaignInstance` transitions to `stopped_on_delivery_issue`, and the proposal's `status_overlay` is set to `delivery_issue`. The right move is usually to fix the email address on the proposal and start a fresh instance.

## 4e. Marking a proposal as won / lost

> *Not yet built.* This subsection is a placeholder. The Mark Won / Mark Lost CTAs and confirmation flows specified in SPEC-09 are not implemented in the current build; this guide will be updated when they ship.
