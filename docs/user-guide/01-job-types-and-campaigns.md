# 1. Set Up Job Types and Campaigns

> Audience: **system admin**.
>
> Everything in this section is under the **Admin** group in the sidebar — only admins see it. If you don't see the Admin group, you don't have admin rights yet.

There are three layers to set up, in this order:

1. **Job types** — broad categories of work (e.g. *Water Mitigation*, *Mold Remediation*).
2. **Scenarios** — specific situations within a job type (e.g. *Pipe burst*, *Sewage backup*).
3. **Campaigns** — the outbound email sequences customers receive. Each campaign is tied to one scenario today, so build the scenario first.

The five restoration job types and seventeen restoration scenarios are present out of the box, so most installs only ever need to create new campaigns (§1.3) and tie them to scenarios (§1.6).

---

## 1.1 Create a job type

1. **Sidebar → Admin → Job Types**.
2. Click **+ New job type**.
3. Fill in:
   - **Name** — what teammates and tenants see in the product (e.g. *Mold Remediation*).
   - **Type code** — a short, lowercase identifier with underscores (e.g. *mold_remediation*). Used internally to match scenarios to email templates; once chosen, do not change it.
   - **Description** — a short paragraph explaining the scope. Shown on the job type page and the tenant activations page.
4. Click **Save**.

You only need this step when adding a new category beyond the five that ship with the product.

## 1.2 Add scenarios under the job type

1. **Sidebar → Admin → Job Types**, then click the job type to open it.
2. The page lists the scenarios already under it. Click **+ New scenario**.
3. Fill in:
   - **Code** — short, lowercase, with underscores (e.g. *pipe_burst*). Must be unique within this job type. Used internally to match the scenario to its email template; once chosen, do not change it.
   - **Short name** — what teammates see when picking a scenario in the product (e.g. *Pipe burst*).
   - **Description** — a one- or two-sentence summary of the situation.
4. Click **Save changes**.

> The **Campaign** picker on this form is empty until the scenario is saved. You'll come back here in §1.6 after building the campaign in [§1.3](#13-create-a-campaign).

## 1.3 Create a campaign

1. **Sidebar → Admin → Campaigns**.
2. Click **+ New campaign**.
3. Fill in:
   - **Name** — a label only admins see when picking the campaign (e.g. *Pipe Burst — v1*).
   - **Status** — leave as **New** while you're still writing the steps. You'll move it to **Approved** in [§1.5](#15-approve-pause-and-edit-the-campaign).
   - **Attributed to scenario** — pick which scenario this campaign is for. Only one campaign can be attributed to a scenario at a time, and only campaigns attributed to a scenario will be selectable on that scenario's edit page.
4. Click **Save**.

You land on the campaigns list. Open the campaign you just created to add steps.

## 1.4 Add steps to the campaign

On the campaign page:

1. Click **Add step**.
2. Fill in:
   - **Sequence number** — the position in the sequence. The form defaults to the next slot, so usually you can leave this alone.
   - **Offset (min)** — how many minutes after the previous step's send the next email should go out. For step 1, it's the wait after the campaign starts (use *0* to send immediately).
   - **Template subject** — the email subject line. You can include merge fields (e.g. for the customer's name); your template author will know which ones are available.
   - **Template body** — the email body. Same merge-field rules as the subject.
3. Click **Save**.

Repeat for each step. To reorder steps, drag the row by the handle on the left — the numbers update to match.

## 1.5 Approve, pause, and edit the campaign

The buttons at the top of the campaign page change based on its current status:

- **Approve** (visible when the campaign is **New**) — flips it to **Approved**. The campaign won't be used for any tenant uploads until you do this.
- **Pause** (visible when the campaign is **Approved**) — flips it to **Paused**. Every running customer email sequence on this campaign halts. Reach for this when you've spotted something wrong with the content; for one-off pauses on a single proposal use [§4c](04-campaign-maintenance.md#4c-pausing--unpausing-a-campaign) instead.
- **Approve** again (visible when the campaign is **Paused**) — flips it back to **Approved**, and running sequences resume from where they left off.

You can edit the campaign name and steps at any status. Already-running customer sequences keep using the version of the content they started with — your edits affect new sequences only.

## 1.6 Wire the campaign back to its scenario

Once the campaign is **Approved**, finish the loop:

1. **Sidebar → Admin → Job Types →** *(the job type)* **→** *(the scenario)*.
2. Click **Edit**.
3. The **Campaign** picker now lists the campaign you attributed to this scenario in §1.3. Pick it.
4. Click **Save changes**.

That scenario will now use this campaign for any new proposal that comes in matching it ([§4a](04-campaign-maintenance.md#4a-upload-a-job-to-start-a-campaign)).
