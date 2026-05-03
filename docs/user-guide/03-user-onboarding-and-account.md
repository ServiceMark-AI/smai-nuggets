# 3. User Onboarding & Account Maintenance

> Audience: **tenant user** (operator).
>
> This section covers the flows you control yourself: claiming an invitation, signing in, recovering a forgotten password, editing your profile, and inviting teammates.

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
- **Connected email accounts** — managed under your profile. Connecting a Gmail account via OAuth gives you a delegation that previously powered outbound invitations from your address; the system now sends invitations from a shared **application mailbox** (admin-managed at **Admin → Mailbox**), so a personal delegation is no longer required to invite teammates.

## 3.5 Inviting teammates

Once you are a tenant user, you can invite others without admin help.

1. **Sidebar → Users**.
2. Click **Invite user** (top right).
3. In the modal, enter the teammate's email and **Send invite**.

Behind the scenes:

- The invitation is attached to your tenant and the tenant's root organization (or first organization if no root exists).
- The token email is sent through the application mailbox if one is connected. If not, the invitation is still created — a flash will tell you the email did not go out, and you can ask an admin to connect a mailbox at **Admin → Mailbox** and have you resend.
- Pending invites show up on the **Users** page with the sender, sent-at, and expiry.

You cannot invite anyone if your account is not yet assigned to a tenant — the **Users** page shows an info message in that state, and the **Invite user** button is hidden.
