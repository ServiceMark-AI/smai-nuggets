# ADR 0002: FAKE-SEND mode and faster dev cron cadence for CampaignSweepJob

- **Status:** Accepted
- **Date:** 2026-05-03
- **Deciders:** Mike (engineering)
- **Applies to:** `app/jobs/campaign_sweep_job.rb`, `config/sidekiq_cron.yml`, `config/initializers/sidekiq.rb`

## Context

`CampaignSweepJob` is the heartbeat for the entire outbound campaign engine. Every five minutes (or every minute in development — see decision below), it scans `CampaignStepInstance` rows whose `planned_delivery_at` has passed, renders each through `MailGenerator`, sends via `GmailSender`, and transitions the parent `CampaignInstance` to `completed` once every step has shipped.

Two friction points emerged when iterating on that engine locally:

1. **The sweep refused to run without a connected `ApplicationMailbox`.** A real connection requires the Google OAuth dance — admin sign-in, "Connect a Gmail account" button, consent flow against an OAuth client whose tester allowlist must include the connecting Gmail address (see ADR-adjacent §0.1 note 4 in the user guide). For an engineer who only wants to verify "does the sweep correctly transition the instance to `completed` after step N fires?", that setup is a multi-step prerequisite that has nothing to do with the question being asked.
2. **The five-minute cron cadence is too coarse for dev iteration.** Setting `planned_delivery_at` to one minute ago and waiting up to five minutes for the next sweep tick is dead time on every change. Reducing the wait closer to the keystroke-to-feedback loop of normal Rails development materially changes the experience.

We need to lower both barriers without weakening the production behavior, and without inventing a third "dev test mode" config knob that operators would have to remember.

## Decision

Two paired changes inside the existing `CampaignSweepJob` and its cron schedule. Both gate on `Rails.env`, not on a new flag.

### 1. FAKE-SEND mode when no `ApplicationMailbox` is connected outside production

When `ApplicationMailbox.current` is `nil`:

- **In production:** unchanged — log a warning and return without processing any step instances. A missing mailbox in prod is a genuine outage condition.
- **In any other environment** (development, test, staging): run the sweep in FAKE-SEND mode. The job:
  - Picks up due step instances normally.
  - Resolves the recipient via the existing `recipient_for` helper (so `TEST_TO_EMAIL` overrides still work, and a blank `customer_email` still triggers the delivery-failure path).
  - Renders the email through `MailGenerator.render`. Unresolved merge fields still raise and the step is marked `failed` — those checks are not bypassed.
  - **Skips the `GmailSender` call entirely.** No HTTP request leaves the process.
  - Marks the step instance `sent`, records `final_subject` / `final_body`, and transitions the parent `CampaignInstance` (potentially to `completed`) — the same lifecycle as a real send.
  - Emits a clear, grep-friendly log line: `[CampaignSweepJob][FAKE-SEND] step <id> -> <recipient>: <subject>`.

The discriminator is `production_environment?` — already a class method on `CampaignSweepJob` and already used elsewhere for safety gating. Re-using it keeps the policy expressed in one place.

### 2. Cron cadence varies by `Rails.env`

`config/sidekiq_cron.yml` resolves the schedule through ERB before YAML parsing. The `campaign_sweep` entry reads:

```yaml
cron: "<%= Rails.env.development? ? '* * * * *' : '*/5 * * * *' %>"
```

In development, the sweep ticks every minute. Anywhere else (test, staging, production) it remains every five minutes. The `config/initializers/sidekiq.rb` loader was updated from `YAML.load_file` to `YAML.safe_load(ERB.new(...).result, aliases: true)` to support the templated value.

## Consequences

**Positive:**

- An engineer can clone the repo, run `bin/rails db:setup`, and watch a campaign progress through its step lifecycle without doing the Google OAuth dance. Previously, no mailbox meant no sweep activity at all.
- The minute cadence in dev compresses the feedback loop on lifecycle changes from up-to-five-minutes to up-to-one-minute. Combined with FAKE-SEND, lifecycle bugs (claim races, completion transitions, instance-status flips) are observable inside a normal coding session.
- The existing safety gates remain effective. With a mailbox connected but `TEST_TO_EMAIL` unset in dev, the sweep still refuses to run — that's the path that protects against an engineer accidentally emailing real customers from their laptop. FAKE-SEND specifically covers the "no mailbox at all" case, which has no risk of customer-facing send.
- Production behavior is identical to before this change: no mailbox = warn + skip, every-5-minutes cadence.

**Negative:**

- "Pretend it works" can mask integration issues. A FAKE-SEND run validates the model state machine and the rendering pipeline, but says nothing about whether Gmail will actually accept the message (rate limits, suppression lists, bounced recipients). Engineers should not interpret "step instance flipped to `sent` in dev" as evidence that a production deploy will succeed against Gmail.
- A reader scanning `final_subject` / `final_body` on a step instance can't tell from the columns alone whether the row came from a real send or a fake one. The mailbox connection on the parent `CampaignInstance.campaign` doesn't track this either. We accept the ambiguity for dev rows since the dev DB is ephemeral; a future stronger contract would record `delivered_via: :fake | :gmail` on the row.
- The single `production_environment?` discriminator means staging behaves the same as dev (FAKE-SEND when no mailbox). If staging ever needs to validate against real Gmail without a mailbox, this policy will need a more nuanced switch.

**Neutral:**

- The minute cadence in dev produces a lot more cron-job log noise. In a typical 8-hour dev session that's ~480 sweep ticks vs. the ~96 a 5-minute cadence would emit. Each tick is a single line if there are no due step instances. Tolerable.
- The ERB-in-YAML pattern for the cron schedule is light, but it does mean the schedule file is no longer pure data — readers need to know it goes through ERB. Documented at the top of the file via the `description` and in this ADR.

## Worked example: campaign-completion test loop in dev

Before this ADR, verifying that `complete_instance_if_done` correctly transitioned an instance to `:completed` when its final step succeeded required:

1. Connect a Gmail account via `/admin/application_mailbox` (OAuth consent, 5+ minutes).
2. Set `TEST_TO_EMAIL=…` in `.env` so the sweep didn't refuse to run.
3. Backdate a `CampaignStepInstance.planned_delivery_at` and wait up to five minutes for the next cron tick.
4. Inspect the resulting `CampaignInstance.status` and the `GmailSender` deliveries log.

After this ADR:

1. Backdate a step instance's `planned_delivery_at` to one minute ago.
2. Wait up to one minute. The dev cron fires.
3. With no mailbox connected, FAKE-SEND mode logs the rendered email and transitions the instance.

## Alternatives considered

1. **Require operators to do the OAuth dance for every dev session.** Rejected. The friction kills iteration speed on engine logic that has nothing to do with the OAuth integration.
2. **A new `FAKE_SEND=true` env var to opt into dev fake-send explicitly.** Rejected. Adding configuration the operator has to remember to set defeats the "just clone and go" property. The natural signal is already in place: a mailbox either is or isn't connected, and a non-prod env is the place where pretending is safe.
3. **A mock `GmailSender` injected only when `Rails.env.development?`.** Rejected. Same observable behavior, more code surface, splits the "what would have been sent" knowledge across the sender and the sweep job.
4. **Run the cron at every-30-seconds in dev.** Rejected. Sidekiq-cron's minimum cadence on most plans is 1 minute; sub-minute would require switching to a different scheduler or polling loop. The minute cadence is sufficient for iteration without that complexity.
5. **Always run the cron at every-1-minute, prod included.** Rejected. The five-minute cadence in prod is a deliberate batching choice — Gmail API rate limits and per-tenant burst budgets rise with frequency. Not changing prod cadence on the back of a dev-iteration win.
