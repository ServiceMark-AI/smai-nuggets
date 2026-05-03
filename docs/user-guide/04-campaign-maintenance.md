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

Click an address to open the proposal. The detail page shows a **Customer** card, a **Job** card, an **Ownership** card, and (when the customer has replied) the most recent reply.

If a proposal needs your attention — paused, waiting on a customer reply, or hitting a delivery problem — you'll see a small badge on the row noting which. Open the proposal to see what to do next.

## 4c. Pausing & unpausing a campaign

> Pause a single proposal's campaign when the customer asks for a delay or you've learned something that should keep emails from going out (vacation, traveling, escrow, family emergency). Pause the campaign *template* — different action, admin-only ([§1.5](01-job-types-and-campaigns.md#15-approve-pause-and-edit-the-campaign)) — when the content itself needs a fix.

*Not yet built.* The screen for pausing or resuming an individual proposal's campaign is not in the product yet. Until it ships, ask an admin to pause for you. The planned flow:

1. Open the proposal.
2. In the **Campaign** card on that page, click **Pause**. The next scheduled email won't go out.
3. Click **Resume** when you're ready. The cadence picks back up from where it left off — missed days are not retroactively sent; the timing is shifted forward.

This guide will be updated when the buttons land.

## 4d. Customer responds

When a customer replies to a campaign email, the system stops sending — no more follow-ups go out on that thread. The proposal is flagged as **waiting on the customer** so you can spot it on the board.

What you'll see on the **Job Proposals** index:

- The proposal's row carries a **waiting on customer** badge.
- The most recent reply (sender, time, subject, and a short preview) appears on the proposal's detail page.

What to do:

1. **Open the proposal.** Read the preview on the **Last reply** card.
2. **Reply from your usual inbox.** A link to the conversation in Gmail is available on the detail page when the system can offer one — use it to read the full message and respond. Your reply goes to the customer the same way you'd send any email.
3. **When the deal is decided**, mark the proposal won or lost ([§4e](#4e-marking-a-proposal-as-won--lost)).

> **Delivery problem instead of a reply?** If the campaign couldn't deliver an email (bad address, the customer's mailbox bounced it), the proposal's row carries a **delivery problem** badge instead. Open the proposal, fix the customer's email address, and ask an admin to restart the campaign.

## 4e. Marking a proposal as won / lost

> *Not yet built.* The **Mark Won** and **Mark Lost** buttons aren't in the product yet. This guide will be updated when they ship.
