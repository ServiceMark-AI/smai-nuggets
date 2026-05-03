# 2. Onboarding a Tenant

> Audience: **system admin**.
>
> A tenant is one customer company. Everything that company touches — its users, organizations, locations, and proposals — lives under the tenant. Onboarding takes three steps: create the tenant, invite the first user, and turn on the job types and scenarios that company is allowed to use.

---

## 2.1 Create the tenant

1. **Sidebar → Admin → Tenants**.
2. Click **+ New tenant**.
3. Enter the **Name** — the customer's company name as it should appear in the product (e.g. *Demo Roofing Co.*).
4. Click **Save**.

You land on the tenant page. A top-level organization with the same name is created automatically; this is the company's default org. If the customer has branches or business units, more organizations can be added later from this page.

## 2.2 Add a location for the organization

The location's address and phone number show up at the bottom of every campaign email the company sends, so set this up now — without it, the first emails go out missing the office details customers expect to see.

1. From the tenant page, click **Organizations →** *(the organization)* **→ Locations → + Add Location**.
2. Fill in:
   - **Display name** — how the location should appear (e.g. *Naperville HQ*).
   - **Address** — street, city, state, postal code.
   - **Phone**.
   - **Active** — check this so emails use this location.
3. Click **Save**.

The customer can edit their own location later from their **My Organization** page (see [§3.4](03-user-onboarding-and-account.md#34-editing-your-profile-and-organization)).

## 2.3 Invite the first user

The first invitation usually goes to the company owner or office manager so they can invite the rest of the team themselves.

1. On the tenant page, find the **Invite a user** card on the right.
2. Enter the recipient's email address and click **Send invite**.

The invitation email goes out immediately and includes a link that expires in seven days. Once sent, the email shows up in the **Pending invitations** list on this page along with when it was sent and when it will expire.

> Once a user has accepted, they can invite the rest of their team themselves from the **Users** page — see [§3.6](03-user-onboarding-and-account.md#36-inviting-teammates).

## 2.4 Activate job types and scenarios

Each tenant only sees the job types and scenarios you turn on for them. This lets you onboard a roofing company differently from a restoration company, even though both use the same SMAI install.

1. On the tenant page, click **Manage activations** (top right).
2. You'll see a table of every job type with each scenario indented underneath.
3. For each job type the customer should use:
   - Click **Activate** next to the job type itself.
   - Then either click **Activate all** to turn on every scenario under it, or click **Activate** on the individual scenarios you want.
4. Click **Deactivate** to turn one off. Deactivating a job type also turns off every scenario under it.

A scenario can't be activated unless its parent job type is already active — the page will show an error and ignore the click.

The pre-built **Demo Roofing Co.** tenant has all five restoration job types and all seventeen scenarios already activated, so you can use it as a reference for what a fully-set-up tenant looks like.

## 2.5 Confirm the result

Back on the tenant page, you should see:

- The organization with a populated **Location** card.
- The invitation you sent under **Pending invitations**, with sent and expiry times.
- The **Users** list will fill in as people accept their invitations ([§3.1](03-user-onboarding-and-account.md#31-accepting-an-invitation)).
- The **Manage activations** link reflects the count of what you turned on in [§2.4](#24-activate-job-types-and-scenarios).

The tenant is ready. The next time someone there uploads a proposal, the system will recognize the work, pick the matching scenario, and start the right campaign.
