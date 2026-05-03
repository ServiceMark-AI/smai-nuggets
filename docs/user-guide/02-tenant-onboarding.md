# 2. Onboarding a Tenant

> Audience: **system admin**.
>
> A tenant is the company-level container — its users, organizations, locations, and proposals all hang under it. Onboarding a tenant is a three-step ritual: create the tenant + root org, invite the first user, and activate the catalog the tenant is allowed to use.

---

## 2.1 Create the tenant

1. **Admin → Tenants**.
2. Click **+ New tenant**.
3. Enter the **Name** (the operator-facing company name, e.g. *Demo Roofing Co.*) and **Save**.

Behind the scenes the create action wraps two writes in a transaction: it creates the `Tenant` and a top-level `Organization` of the same name. You land on the tenant show page.

> If the tenant has multiple branches or business units, additional organizations can be added later. The first one created (parent_id is null) is treated as the root.

## 2.2 Add a location for the root organization

Office address and phone number flow into outbound campaign emails (per SPEC-07). Set them now so the tenant's first emails do not go out with `nil` placeholders.

1. From the tenant show page, follow **Organizations →** *(root org)* **→ Locations → + Add Location**.
2. Fill in display name, street address, city/state/postal code, phone, and active flag.
3. **Save**.

The location is also editable later via the tenant user's **My Organization** page (see [§3.4](03-user-onboarding-and-account.md#34-editing-your-profile-and-organization)).

## 2.3 Invite the first user

The first invitation usually goes to the company owner so they can self-service the rest of the team.

1. From the tenant show page, find the **Invite a user** card on the right.
2. Enter the recipient's email and click **Send invite**.

Two outcomes are possible:

- **Application mailbox is connected.** The invite email goes out from the system mailbox. The recipient gets a token link that expires in seven days.
- **No application mailbox is connected.** The invitation row is still created, but no email is sent. A flash explains this — connect a mailbox at **Admin → Mailbox** and re-send.

Pending invitations are listed on the tenant show page with their sent-at and expiry timestamps.

> Tenant users with an existing account can also send invites from the tenant-side **Users** page once they are members; see [§3.5](03-user-onboarding-and-account.md#35-inviting-teammates).

## 2.4 Activate job types and scenarios

Tenants only see the catalog entries you activate for them. Activations are stored as `TenantJobType` and `TenantScenario` join records with an `is_active` flag.

1. From the tenant show page, click **Manage activations** (top right).
2. The activations table lists every job type system-wide. For each one you want the tenant to use:
   - Click **Activate** to flip the parent on.
   - Either expand its scenarios and **Activate** them individually, or click **Activate all** to flip every scenario at once.
3. Inactive job types hide their scenarios; activating a scenario whose parent is inactive is rejected with a flash alert.
4. Deactivating a job type cascades — every scenario under it is set inactive in the same operation.

The seeded **Demo Roofing Co.** tenant ships with all five restoration job types and all 17 scenarios pre-activated, so you can use it as a reference.

## 2.5 Confirm the result

On the tenant show page you should now see:

- The root organization (and any others you added) with a **Location** card filled in.
- One or more pending invitations under **Pending invitations**.
- A populated **Users** list once invitations are accepted ([§3.1](03-user-onboarding-and-account.md#31-accepting-an-invitation)).
- An activation count at **Manage activations** matching what you turned on in [§2.4](#24-activate-job-types-and-scenarios).

The tenant is now ready to use the system end-to-end.
