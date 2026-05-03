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

You land on a **Confirm** page that previews everything the system pulled out of the PDF — the customer's title, name, email, and address; the job type and scenario; the proposal value; and the internal reference. Read it over and fix anything that's wrong. When you're satisfied, click **Save**. The system files the proposal and starts the campaign for the chosen scenario. The first email goes out on the cadence the admin set up for that campaign.

A few practical notes:

- **Confirm before you save.** This is the only chance to correct the data before the first email goes out. Once you save with a scenario picked, the campaign is in flight and the proposal is locked for editing.
- **Reassigning ownership.** If you're uploading on behalf of a teammate (e.g. an assistant uploading for a project manager), use the **Owner** field on the Confirm page to point the proposal at the right person before saving.
- **No scenario yet?** You can save without one — the proposal is filed but no campaign starts. Pick a scenario later from the proposal's edit page when you're ready (note: once a campaign is running, you can't go back and change it).
- **Job type or scenario not activated for your tenant?** No campaign starts. The proposal is still saved, but it sits idle until your admin activates the matching job type and scenario for your tenant ([§2.4](02-tenant-onboarding.md#24-activate-job-types-and-scenarios)).
- **Upload error?** A red banner at the top of the page explains what went wrong (e.g. unreadable file, missing tenant assignment). Fix the listed issue and try again.

## 4b. The proposal status board

**Sidebar → Job Proposals** is your operating board. Each row is one proposal.

**Filter the board** with the controls along the top:

- **Search** — customer name, address fragment, or internal reference.
- **Status** — *new* (just uploaded), *open* (campaign running), or *closed* (won or lost).
- **Owner** / **Created by** — narrow to a specific teammate.
- **Sort** — click the **Proposal value** or **Created** column header to sort. Your filters are kept when you sort, and your sort is kept when you re-filter.

**What each column shows:**

- **Address** — click it to open the proposal.
- **Customer** — first and last name. A dash means the system couldn't pull a name from the file; open the proposal to fill it in.
- **Organization** — which of your tenant's organizations owns the proposal (only matters if you have more than one).
- **Job Type** — what kind of work the system inferred from the upload. A dash means it couldn't tell.
- **Status** — *new*, *open*, or *closed*.
- **Proposal value** — the total amount, formatted as currency.
- **Owner** / **Created by** — who owns the proposal, and who uploaded it.
- **Created** — the day it was uploaded.
- **Action** — a single button telling you what to do next on this row. The button changes based on the proposal's state:
  - **View job** — the campaign is running normally, or the proposal is closed (won/lost). Opens the proposal's detail page.
  - **Open in Gmail** — the customer has replied. Opens the conversation in a new Gmail tab so you can read the full message and respond from your inbox.
  - **Fix delivery issue** — the campaign couldn't deliver an email (bad address, mailbox bounced). Opens the proposal's edit page so you can correct the customer's email.
  - **Resume campaign** — the campaign was paused. Click to resume; the next step picks up on the cadence.

Click an address to open the proposal. The detail page shows a **Customer** card, a **Job** card, an **Ownership** card, and (when the customer has replied) the most recent reply.

## 4c. Pausing & unpausing a campaign

> Pause a single proposal's campaign when the customer asks for a delay or you've learned something that should keep emails from going out (vacation, traveling, escrow, family emergency). Pause the campaign *template* — different action, admin-only ([§1.5](01-job-types-and-campaigns.md#15-approve-pause-and-edit-the-campaign)) — when the content itself needs a fix.

**Pausing.** *Not yet built.* The button to pause an individual proposal's campaign isn't in the product yet. Until it ships, ask an admin to pause for you.

**Resuming.** When a proposal's campaign is paused, its row on the **Job Proposals** index shows a **Resume campaign** button in the **Action** column. Click it; the campaign goes back to running on the cadence the admin set up.

> *Note:* today, after a long pause, any campaign steps whose scheduled time fell inside the pause window will fire on the next sweep — not be retroactively skipped. If that's not what you want, hold off on resuming until the gap is small.

## 4d. Customer responds

When a customer replies to a campaign email, the system stops sending — no more follow-ups go out on that thread. The proposal is flagged as **waiting on the customer** so you can spot it on the board.

What you'll see on the **Job Proposals** index:

- The row's **Action** button reads **Open in Gmail** — click it to jump straight to the conversation in a new tab and reply from your usual inbox.
- The most recent reply (sender, time, subject, and a short preview) appears on the proposal's detail page.

What to do:

1. **Click Open in Gmail** on the proposal's row. Read the full thread and respond.
2. **When the deal is decided**, mark the proposal won or lost ([§4e](#4e-marking-a-proposal-as-won--lost)).

> **Delivery problem instead of a reply?** If the campaign couldn't deliver an email (bad address, the customer's mailbox bounced it), the row's **Action** button reads **Fix delivery issue**. Click it to open the proposal's edit page and correct the customer's email address. *Restarting the campaign from a delivery problem is not yet built* ([#117](https://github.com/frizman21/smai-server/issues/117)) — for now, ask an admin.

## 4e. Marking a proposal as won / lost

> *Not yet built.* The **Mark Won** and **Mark Lost** buttons aren't in the product yet. This guide will be updated when they ship.
