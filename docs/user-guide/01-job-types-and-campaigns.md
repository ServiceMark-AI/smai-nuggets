# 1. Set Up Job Types and Campaigns

> Audience: **system admin**.
>
> These steps live under `/admin/...` and require an account with `is_admin: true`.

The catalog has three layers:

1. **Job types** — broad work categories shared system-wide (e.g. *Water Mitigation*, *Mold Remediation*).
2. **Scenarios** — specific situations within a job type (e.g. *Pipe burst*, *Sewage backup*).
3. **Campaigns** — outbound email cadences. A campaign is *attributed* to one of the catalog entities (today, a scenario) and runs against job proposals as a `CampaignInstance`.

You build them in that order — bottom up — because scenarios live under job types, and campaigns are attributed to scenarios.

---

## 1.1 Create a job type

1. From the sidebar, open **Admin → Job Types**.
2. Click **+ New job type**.
3. Fill in:
   - **Name** — operator-facing label (e.g. *Mold Remediation*).
   - **Type code** — short, unique system identifier (e.g. `mold_remediation`). Used by templates and specs; cannot be reused across job types.
   - **Description** — short paragraph explaining the scope. Shown on the activations and job-type pages.
4. **Save**.

The five seeded restoration job types are present out of the box; you only need this step if you are adding a new category.

## 1.2 Add scenarios under the job type

1. From the **Admin → Job Types** index, click the job type you just created (or any existing one).
2. The show page lists existing scenarios. Click **+ New scenario**.
3. Fill in:
   - **Code** — unique within the job type (e.g. `pipe_burst`). Stored on `Scenario.code`; appears in `JobProposal.scenario_key` and template lookup keys per SPEC-07 / SPEC-11.
   - **Short name** — operator-facing label (e.g. *Pipe burst*).
   - **Description** — used as the scenario's authoring hypothesis / one-sentence summary.
4. **Save changes**.

> The campaign picker on this form is hidden until the scenario is saved — a campaign cannot be attributed to a scenario that does not yet exist. You will return to this picker after building the campaign in step 1.3.

## 1.3 Create a campaign

1. From the sidebar, open **Admin → Campaigns**.
2. Click **+ New campaign**.
3. Fill in:
   - **Name** — operator-facing label (e.g. *Pipe Burst — v1*).
   - **Status** — leave as **New** while you author the steps. The status drives the lifecycle described in §1.5.
   - **Attributed to scenario** — pick the scenario this campaign will run for. This drives the filter on the scenario edit form: only campaigns attributed to a scenario appear in that scenario's campaign picker. Other attribution targets (tenant, job type) will be added later as the polymorphic relationship grows.
4. **Save**.

You land on the campaigns index. Open the campaign you just created to add steps.

## 1.4 Add steps to the campaign

On the campaign show or edit page:

1. Click **Add step**.
2. Fill in:
   - **Sequence number** — order in the cadence; defaults to the next available slot.
   - **Offset (min)** — minutes after the previous send (or after campaign start, for step 1).
   - **Template subject** — email subject; merge fields documented in SPEC-07.
   - **Template body** — email body; same merge-field rules.
3. **Save**.

Repeat for each step. You can drag-reorder rows on the campaign edit page; the **#** column reflects the new sequence after a drop.

## 1.5 Approve, pause, and edit the campaign

The campaign show page exposes lifecycle buttons based on status:

- **New → Approved** — click **Approve**. Required before any campaign instance can run; this is the sign-off that the cadence is ready for production use.
- **Approved → Paused** — click **Pause**. Pauses every running instance of the campaign system-wide. Use this when a template defect is discovered after launch; otherwise, prefer pausing individual instances (§4c).
- **Paused → Approved** — re-open with the **Approve** button.

You can edit the campaign and steps at any status, but content changes do not retroactively rewrite any campaign instance whose content was already snapshotted at instance creation.

## 1.6 Wire the campaign back to its scenario

Once the campaign is approved, return to the scenario:

1. **Admin → Job Types →** *(job type)* **→** *(scenario)*.
2. Click **Edit**.
3. The **Campaign** picker now lists the campaign you attributed to this scenario. Pick it.
4. **Save changes**.

The scenario's `campaign_id` is what `JobProposalProcessor` uses to start a campaign instance against a new proposal (§4a).
