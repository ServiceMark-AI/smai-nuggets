# 3. User Onboarding & Account Maintenance

> Audience: **tenant user** (operator).
>
> This section covers the things you handle yourself: accepting an invitation, signing in, password reset, editing your profile, connecting a Google account so the system can send email, and inviting teammates.

---

## 3.1 Accepting an invitation

When someone invites you, you'll get an email with a link to join. The link works for seven days.

**If you don't have an account yet:**

1. Click the link in the email.
2. You'll land on a sign-up page with your email already filled in.
3. Pick a password and submit.
4. You're signed in. Your company and (if you were invited as an originator) your location are set automatically.

**If you already have an account:**

1. Sign in first if you aren't already.
2. Click the link in the email.
3. You'll be added to the company right away, and you'll see a welcome message.

Each invitation link can only be used once. If yours has expired or you can't find it, ask whoever invited you to resend.

## 3.2 Signing in

Go to the sign-in page and enter your email and password. After signing in, where you land depends on your role:

- **Account admins and platform staff** see a home page with cards for **Proposals**, **Needs Attention**, **Team**, and **Analytics**, and the sidebar shows **Needs Attention**, **Jobs**, **Analytics**, and **Team**. Platform staff also see a **Platform Admin** group below those.
- **Originators** (users assigned to a single location) skip the home page and land directly on **Needs Attention** — the same items they'll need to act on most days.

## 3.3 I forgot my password

1. From the sign-in page, click **Forgot your password?**
2. Enter your email and submit. If your email is on file, you'll get a reset link.
3. Click the link in the email and choose a new password.
4. You're signed in.

The reset link expires after about six hours. If yours has expired, just request another one.

> If you're already signed in and just want to change your password — for example, you're rotating it on a schedule — use the **Change password** link in your profile menu instead.

## 3.4 Your profile

Open the menu in the top-right corner of any page and pick **Profile**.

The profile page shows your name, title, phone, email, the company you belong to, your location (blank for account admins), your role, when you last signed in, and any Google accounts you've connected for sending email.

- **Edit** (top right of the Profile card) — update your first name, last name, title, and phone number. Your name and title are what teammates see on the **Jobs** index and what shows up in the email signature on every campaign email you send. If you don't have a name set, your email is shown instead and a banner reminds you to fill it in.
- **Change password** (in the top-right menu) — rotate your password. You'll need your current password to confirm.
- **Role badges** — your profile shows **Application Admin** if you're platform staff, **Tenant Admin** if you're an account admin for your company, or no badge if you're an originator. These are managed by your admin and can't be changed from the profile page.

## 3.5 Connected email accounts

> Read this section first if invitations or campaign emails stop going out. The system can only send mail when its Google account is connected, and a broken connection makes everything go quiet without an obvious error.

The system uses a Google account to send mail. There are two places a Google account gets connected, and they're for different things:

- **The application mailbox** (admin-only, **Platform Admin → Mailbox**). This is the Google account the *system* sends from — every customer-facing campaign email and every invitation goes from this address. There is one application mailbox for the whole install.
- **Your personal Google connection** (under your profile, the **Email sending** card). You can connect your own Google account here, but at the moment the system doesn't send from personal accounts — the option is there for future "send as you" features and connecting one today doesn't change anything.

For day-to-day work, the only Google connection that matters is the application mailbox. If it's connected and healthy, mail goes out. If it isn't, nothing does.

### When mail stops going out

The most common cause is a revoked or expired Google connection on the application mailbox. Connections can break when:

- Whoever owns the connected Google account revokes access from their Google account settings.
- A Google Workspace admin removes the app from the workspace's allow-list, or deactivates the connected user.
- The connected account is deleted or rotated.

When this happens, the system stops sending campaign emails for affected proposals. Customer-reply detection still works, but new outbound steps wait silently. There's no email alert today; the way you find out is that someone notices customers haven't been hearing from them.

> **Quick check:** an admin can open **Platform Admin → Integrations** to see the live status of the application mailbox along with every other external service the app depends on. A red **Missing** row on the mailbox is the unambiguous tell.

**The fix is always the same:**

1. An admin opens **Platform Admin → Mailbox**.
2. Clicks **Connect a Gmail account**.
3. Signs in to the Google account that should be the sender and approves the access request.
4. After connecting, an admin should also resume any campaigns that were marked as having a delivery problem — see [§4d](04-campaign-maintenance.md#4d-customer-responds).

### Choosing the right Google account

For production, it's worth using a dedicated Google Workspace user (something like `outreach@yourcompany.com`) rather than someone's personal Gmail. Three reasons:

1. **Stability.** A personal account leaves with the person; a dedicated address stays.
2. **Sender identity.** The "from" line on every campaign email is the connected address paired with the proposal owner's name, so the address should match the brand customers expect.
3. **Scale.** Workspace accounts have higher sending limits than personal Gmail. Personal Gmail is fine for testing or staging but isn't a good production choice.

If you're on Google Workspace, ask your Workspace admin to allow the app for that account before connecting — otherwise consent may be blocked at sign-in.

## 3.6 Inviting teammates

Once you have an account *and* you're an account admin, you can invite teammates yourself. Originators (users tied to a single location) don't see the invite button — ask your account admin to invite the new teammate.

1. **Sidebar → Team**.
2. Click **Invite user** (top right). A dialog opens.
3. Fill in:
   - **First name** and **Last name**.
   - **Email address**.
   - **Title** — shown in the email signature (e.g. *Estimator*).
   - **Phone number**.
   - **Is Account Admin** — check this if the invitee should be able to invite other teammates and see proposals across every location. Leave it unchecked for an originator, then pick the **Location** they should belong to.
4. Click **Send invite**.

The invitation goes out right away. The new person gets the same link-based flow described in [§3.1](#31-accepting-an-invitation), and the link expires in seven days. Their pending invite shows up under **Pending invitations** with who sent it and when it expires. Click **Revoke** if you sent it to the wrong address or no longer want them to join.

The **Team** table also shows a **Role** column (Admin / Originator) and a **Gmail** column (Linked / Not linked) so you can see at a glance who can do what.

If the **Invite user** button is hidden and the dialog shows a yellow warning instead of the form, the install isn't ready to send invitations yet — most often because the application mailbox isn't connected. Ask your admin to check **Platform Admin → Integrations**.
