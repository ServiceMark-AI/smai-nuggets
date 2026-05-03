# 3. User Onboarding & Account Maintenance

> Audience: **tenant user** (operator).
>
> This section covers the flows you control yourself: claiming an invitation, signing in, recovering a forgotten password, editing your profile, connecting Google accounts for outbound mail, and inviting teammates.

---

## 3.1 Accepting an invitation

When an admin sends you an invitation, you receive an email with a link of the form:

```
https://app.example.com/invitations/<token>
```

The token is unique and expires after seven days.

**If you do not yet have a SMAI account:**

1. Click the link.
2. You are redirected to the sign-up page with your email pre-filled.
3. Choose a password and submit.
4. Your tenant and organization are set automatically; you are signed in and redirected home.

**If you already have a SMAI account:**

1. Sign in first if you are not already.
2. Click the link.
3. You are added to the tenant and organization on the spot and redirected home with a welcome message.

The invitation is marked accepted on success; the same link cannot be reused.

## 3.2 Signing in

Sign-in is at `/users/sign_in`. Use the email address that received the invite (or the one stored on your account) and the password you set during signup.

> The sidebar shows **Job Proposals** and **Users** for every tenant user. The **Admin** group is only visible to system admins.

## 3.3 I forgot my password

Password reset is handled by Devise's standard recoverable flow.

1. From the sign-in page, click **Forgot your password?** (route: `/users/password/new`).
2. Enter your email and submit. A reset email is sent if the email exists in the system.
3. Click the link in that email. You land on the reset form (route: `/users/password/edit?reset_password_token=...`).
4. Choose a new password, confirm it, and submit. You are signed in on success.

The reset token expires after Devise's default window (typically six hours). If it expires, request a new one from step 1.

> The in-app **Change password** screen at `/change_password` is for users already signed in who want to rotate their password without going through email — not for password recovery.

## 3.4 Editing your profile and organization

- **Profile** — `/profile/edit`. Update your first and last name, email, and other personal fields. The **display name** that appears on the proposal index and pending-invitation lists is `first_name + last_name` if set, otherwise the email.
- **Change password** — `/change_password`. Asks for the current password and a new one. Use this when you are signed in and want to rotate.
- **My Organization** — `/my_organization`. Read-only summary of your organization's tenant, parent (if any), and location. Only the location is editable from here (**Edit** / **+ Add Location** in the location card).

## 3.5 Connected email accounts

> This is the section to read first if outbound mail is misbehaving. Both invitations and campaign step emails depend on the OAuth flow described here, so a broken mailbox connection silently halts the campaign sweep.

There are two kinds of Google connection in the system, and they share a single OAuth callback (`/auth/google_oauth2/callback`). Knowing which one you are looking at is the difference between fixing it in five minutes and chasing your tail.

### What sends what (today)

| Outbound mail | Sender | Lives on |
|---|---|---|
| Invitations | Application mailbox | Singleton `ApplicationMailbox` row |
| Campaign step emails | Application mailbox | Same |
| Personal delegations | (not used for sending today) | `email_delegations` per user |

Every outbound message — invitations from the **Users** page ([§3.6](#36-inviting-teammates)), invitations from a tenant page ([§2.3](02-tenant-onboarding.md#23-invite-the-first-user)), and the per-step campaign sends fired by `CampaignSweepJob` every five minutes — flows through `GmailSender.new(ApplicationMailbox.current).send_email(...)`. If the application mailbox is missing or its tokens have been revoked, the sweep job logs a warning and exits without sending anything that tick.

Personal email delegations are still stored on a user's profile (and visible there), but the current build does not use them as a sending source. Connecting one is a no-op for outbound mail right now; the table is kept so per-user "send as" flows can be added later without a schema change.

### The Google Workspace (GSuite) callback flow

When an admin clicks **Connect a Gmail account** at **Admin → Mailbox**, or a user clicks **Connect Gmail** on their profile, the same six-step OAuth handshake runs:

1. The form posts a hidden `target` parameter (`application_mailbox` for the admin path, absent for the personal path).
2. The browser is redirected to Google's authorization endpoint with the client id from `GOOGLE_CLIENT_ID` and the scope `email profile https://www.googleapis.com/auth/gmail.send`. (Configured in `config/initializers/omniauth.rb`.)
3. The user signs in to the Google account that should be the sender and grants consent. **For Workspace accounts**, your Workspace admin may need to allow third-party access to that scope, or pre-approve the OAuth app, before consent will succeed.
4. Google redirects back to `/auth/google_oauth2/callback` (which must be a registered redirect URI in the Google Cloud Console — see [§0.1](00-production-setup.md#01-external-services-to-provision)).
5. `EmailDelegationsController#create` reads the `target` param off the OmniAuth callback. If it is `application_mailbox`, the tokens are written to the singleton `ApplicationMailbox` row; otherwise they are written to a per-user `EmailDelegation`.
6. The user lands back on the originating page with a flash confirming the connected email address.

The redirect URI must match exactly between Google Cloud Console and the host the app is running on. If you set up a custom domain ([§0.6](00-production-setup.md#06-optional-custom-domain-and-ssl)), add a second redirect URI for that host, or expect every Connect attempt to fail with `redirect_uri_mismatch`.

### Token refresh and revocation

OAuth credentials carry an access token (short-lived) and a refresh token (long-lived). `GmailSender` refreshes the access token transparently when it has expired but the refresh token is still valid. The refresh token is invalidated in three situations you should watch for:

1. The Google account holder explicitly revokes access from [Google Account → Security → Third-party apps](https://myaccount.google.com/permissions).
2. The Workspace admin removes the OAuth app from the org's allow-list, or the user account is deactivated.
3. The Google Cloud project's OAuth consent screen is moved between **Testing** and **Production**, or the client secret is rotated.

When a refresh fails, the next sweep cycle logs the error and the campaign instance for the affected step is transitioned to `stopped_on_delivery_issue`. The fix is always the same: revisit **Admin → Mailbox** and click **Connect a Gmail account** again to write fresh tokens. The campaign instance does not auto-resume; an admin reactivates it explicitly once the mailbox is healthy again.

### Choosing the mailbox identity

For production deployments the application mailbox is usually one of:

- A dedicated Workspace user (recommended) — `noreply@yourcompany.com` or similar. Stable address, not tied to a person who might leave the company.
- A Workspace shared mailbox aliased to a regular account.
- A personal Gmail (only acceptable for early staging — Gmail rate limits are stricter than Workspace).

Whatever you pick, the address shown on outbound campaign emails is the one connected here, so it should match the operator brand customers expect.

## 3.6 Inviting teammates

Once you are a tenant user, you can invite others without admin help.

1. **Sidebar → Users**.
2. Click **Invite user** (top right).
3. In the modal, enter the teammate's email and **Send invite**.

Behind the scenes:

- The invitation is attached to your tenant and the tenant's root organization (or first organization if no root exists).
- The token email is sent through the application mailbox ([§3.5](#35-connected-email-accounts)). The recipient gets a link that expires in seven days.
- Pending invites show up on the **Users** page with the sender, sent-at, and expiry.

You cannot invite anyone if your account is not yet assigned to a tenant — the **Users** page shows an info message in that state, and the **Invite user** button is hidden.
