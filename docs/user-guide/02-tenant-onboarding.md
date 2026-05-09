# 2. Onboarding a Tenant

> Audience: **system admin**.
>
> A tenant is one customer company. Everything that company touches — its users, locations, and proposals — lives under the tenant. Onboarding takes four steps: create the tenant, add at least one location, invite the first user, and turn on the job types and scenarios that company is allowed to use.

---

## 2.1 Create the tenant

1. **Sidebar → Platform Admin → Tenant / Account**.
2. Click **New tenant**.
3. Enter the **Name** — the customer's company name as it should appear inside the admin UI (e.g. *Demo Roofing Co.*).
4. Click **Create tenant**.

You land on the tenant page. From here you can add locations, invite users, edit the customer-facing branding, and manage activations.

## 2.2 Fill in the tenant's customer-facing details

Click **Edit** at the top right of the tenant page to open the tenant edit form. The fields here flow into every campaign email the company sends, so set them up early:

- **Account name (internal)** — the same name you typed in §2.1. Shown only in the admin UI; safe to use a short nickname.
- **Company name (customer-facing)** — what shows up in email signatures (e.g. *Demo Roofing Co.*). If left blank, the account name is used.
- **Logo (upload)** — drop a PNG, JPG, or SVG. Replaces any existing upload.
- **Logo URL (manual override)** — used only when no file is uploaded. Point at a logo hosted elsewhere.
- **Require DASH job number** — turn on for restoration tenants who track every job in DASH. When on, every proposal needs a DASH number before it can be approved, and the number is prefixed onto every campaign email subject so the thread stays threaded in DASH.

Click **Save** when you're done.

## 2.3 Add a location

The location's address and phone number show up at the bottom of every campaign email the company sends, so set this up before inviting users — without it, the first emails go out missing the office details customers expect to see.

1. On the tenant page, find the **Locations** card and click **Add location**.
2. Fill in:
   - **Display name** — how the location should appear in the operator UI and email signatures (e.g. *NE Dallas*).
   - **Address line 1**, optional **Address line 2**, **City**, **State** (two-letter US code), **Postal code**.
   - **Phone number** — office phone, used in email signatures.
   - **Active** — check this box so users can be assigned here and the location is visible to operators. A location stays inactive until every required field above is filled in.
3. Click **Create Location**.

You land back on the tenant page with the new location in the **Locations** card. Add more locations the same way for tenants with multiple branches.

## 2.4 Invite the first user

The first invitation usually goes to the company's account admin (often the owner or office manager) so they can invite the rest of the team themselves.

1. On the tenant page, find the **Invite a user** card on the right and click **Invite user**. A dialog opens.
2. Fill in:
   - **First name** and **Last name**.
   - **Email address**.
   - **Title** — shown in the email signature (e.g. *Estimator*).
   - **Phone number**.
   - **Is Account Admin** — check this for the first invitee. Account admins aren't tied to a single location and can invite the rest of the team. Leave it unchecked for an originator, then pick the **Location** they should belong to.
3. Click **Send invite**.

The invitation email goes out immediately and includes a link that expires in seven days. Once sent, the email shows up in the **Pending invitations** list on this page along with when it was sent and when it will expire. If the invitee never uses the link, click **Revoke** to retract it.

> If the **Invite user** button is hidden and the card shows a yellow warning, the install isn't ready to send invitations yet — typically because the application mailbox isn't connected ([§0.9](00-production-setup.md#09-connect-the-application-mailbox)) or `APP_HOST` isn't set ([§0.5](00-production-setup.md#05-production-url-host)). Fix the listed blockers and the button comes back.
>
> Once a user has accepted, they can invite the rest of their team themselves from the **Team** page — see [§3.6](03-user-onboarding-and-account.md#36-inviting-teammates).

## 2.5 Activate job types and scenarios

Each tenant only sees the job types and scenarios you turn on for them. This lets you onboard a roofing company differently from a restoration company, even though both use the same install.

1. On the tenant page, click **Manage activations** (top right).
2. You'll see a table of every job type with each scenario indented underneath.
3. For each job type the customer should use:
   - Click **Activate** next to the job type itself.
   - Then either click **Activate all** to turn on every scenario under it, or click **Activate** on the individual scenarios you want.
4. Click **Deactivate** to turn one off. Deactivating a job type also turns off every scenario under it.

A scenario can't be activated unless its parent job type is already active — the page will show an error and ignore the click.

The pre-built **Demo Roofing Co.** tenant has all five restoration job types and all seventeen scenarios already activated, so you can use it as a reference for what a fully-set-up tenant looks like.

## 2.6 Confirm the result

Back on the tenant page, you should see:

- The **Locations** card populated with at least one active location.
- The invitation you sent under **Pending invitations**, with sent and expiry times.
- The **Users** list will fill in as people accept their invitations ([§3.1](03-user-onboarding-and-account.md#31-accepting-an-invitation)).
- The **Manage activations** link reflects the count of what you turned on in [§2.5](#25-activate-job-types-and-scenarios).

The tenant is ready. The next time someone there uploads a proposal, the system will recognize the work, pick the matching scenario, and start the right campaign.
