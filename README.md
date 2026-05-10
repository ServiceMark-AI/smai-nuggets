# smai-nuggets

Beaver Nuggets are the iconic Buc-ee's snack, so the Texas/beaver reference lands instantly for anyone in the know but stays subtle enough for external use. "Nugget" also evokes something small and valuable — exactly the spirit of an MVP. And it sounds great in a Rails context ("deploying Nugget v0.1," "the Nugget mailer queue"). Bonus: easy to say in standup, looks good on a Slack channel (#proj-nugget), and the eventual v2 practically names itself (Project Brisket).

The Rails server behind ServiceMark AI — multi-tenant, Postgres-backed, Sidekiq for background work, Gmail send-on-behalf-of for outbound campaigns.

## User guide

Operator-facing documentation — production setup, tenant onboarding, account management, and day-to-day campaign work — lives in [`docs/user-guide/`](docs/user-guide/README.md).

## For developers

### How we plan: specs → issues → milestones

Three layers, each with one job.

**1. PRDs in [`docs/prd/`](docs/prd/) are the durable behavior contract.**
PRDs are the source of truth for what the product does — operator-facing behavior, validation rules, edge cases, audit events, the works. They are revised in place (look for `**Revision note**` and `**Patch note**` blocks at the top of each one). When a PRD and an issue disagree, the PRD wins. When the PRD is revised, issue checklists either absorb the change or get closed and replaced.

**2. GitHub issues are the unit of work.**
Each PRD's `## Implementation Slices` section is decomposed into one issue per slice. Every issue carries the shared [`prd`](https://github.com/frizman21/smai-server/labels/prd) label and references its PRD in the title (e.g. `PRD-01 Slice A: Core job record and contact schema`). Each PRD also has a `Tracking issues` line in its metadata block so you can jump from the doc to the live issues, and each Slice heading carries a `(#NN)` link inline.

The body of every issue is structured the same way:

- **What this implements** — one or two plain sentences.
- **Acceptance criteria (the "what")** — testable behavior assertions, the only checkboxes in the issue.
- **Design suggestions from the PRD (the "how" — guidance, not gates)** — layout hints, color rules, copy. Useful for orientation; reviewers don't gate on them.
- **First-pass codebase review** — what already exists in the repo, no boxes ticked.
- **PRD reference** — the path and section.

The pattern, the rationale, and the alternatives we rejected are in [`docs/adr/0001-spec-decomposition-and-issue-tracking.md`](docs/adr/0001-spec-decomposition-and-issue-tracking.md).

**3. Milestones group issues into ship targets.**
[Milestones](https://github.com/frizman21/smai-server/milestones) are how we prioritize. An issue is "this needs to happen at some point"; a milestone is "this needs to happen before [date] for [reason]." Current milestones:

- [`v0.1 - Happy Path`](https://github.com/frizman21/smai-server/milestone/1) — PDF upload, data-defined drip campaigns, OBO Gmail send.
- [`v0.2 - Analytics`](https://github.com/frizman21/smai-server/milestone/2) — reports + analytics for admins and tenant leaders.

A useful default move when picking up work: start at the next milestone, look at its open issues sorted by ID (lowest first — earlier slices usually set up context for later ones), pick one whose dependencies are met, and read its PRD section before opening the editor. The issue's *PRD reference* line tells you which doc and which section.

### Setting up the development environment

The full stack runs under Docker Compose: Postgres 17, Redis 7, the Rails web server on Ruby 3.3, and Sidekiq.

**Prerequisites**

- Docker (Desktop or Engine) with Compose v2.
- A clone of this repo.
- The credentials listed in [`.env.example`](.env.example) — Gemini API key, Google OAuth client ID/secret, optionally AWS for Active Storage and Sentry for error reporting.

**First-time setup**

```bash
cp .env.example .env       # then fill in the values
docker compose up          # builds the bundle cache, runs db:prepare, starts web on :3000
```

The first boot installs the bundle into a named volume (`bundle_cache`) and runs `bin/rails db:prepare`, which creates and migrates both the development and test databases. Subsequent boots reuse the cache and are fast.

**Running things inside the container**

Per the project's testing policy, every Rails / bundle command runs inside the `web` container so it picks up the same gems and DB connection the server uses:

```bash
docker compose exec web bundle exec rails console
docker compose exec web bundle exec rails db:migrate
docker compose exec web bundle exec rails test
docker compose exec web bundle exec rails test:system
docker compose exec web bundle exec rails db:test:prepare test test:system
```

**Background jobs**

Sidekiq runs as its own service (`sidekiq` in `compose.yaml`), sharing the bundle cache and the same Postgres / Redis. It comes up automatically with `docker compose up`. Logs stream alongside the web logs.

**Daily flow**

- `docker compose up` — start the stack.
- `docker compose down` — stop everything (named volumes persist; data survives).
- `docker compose exec web bundle exec rails ...` — run any Rails command.
- App available at <http://localhost:3000>.

### Common developer CLI commands

A recipe book for the things you'll reach for most. Everything that touches Rails, the database, or the bundle runs inside the `web` container so it picks up the same gems and DB the server is using.

**Starting and stopping the stack**

```bash
docker compose up                       # start the stack in the foreground
docker compose up -d                    # start in the background
docker compose down                     # stop everything (named volumes persist; data survives)
docker compose down -v                  # stop AND wipe Postgres + Redis volumes (destructive)
docker compose restart web              # restart just the web service (after a config change)
docker compose restart sidekiq          # restart just sidekiq (after editing a job class)
docker compose logs -f web              # tail web logs
docker compose logs -f sidekiq          # tail sidekiq logs
```

**Database**

```bash
docker compose exec web bundle exec rails db:migrate          # run pending migrations
docker compose exec web bundle exec rails db:rollback         # roll back the last migration
docker compose exec web bundle exec rails db:seed             # idempotent seed (db/seeds.rb)
docker compose exec web bundle exec rails db:reset            # drop, recreate, migrate, seed (dev DB)
docker compose exec web bundle exec rails db:test:prepare     # rebuild the test DB to match schema
docker compose exec web bundle exec rails db:prepare          # create + migrate if needed (idempotent)
```

`db:seed` is idempotent — it uses `find_or_create_by!`, so re-running it is safe. To rebuild the dev database from scratch, `db:reset` is the one-shot command.

**Tests**

```bash
docker compose exec web bundle exec rails test                                # unit + integration tests
docker compose exec web bundle exec rails test:system                         # system (browser) tests
docker compose exec web bundle exec rails db:test:prepare test test:system    # full suite, fresh test DB
docker compose exec web bundle exec rails test test/models/user_test.rb       # one file
docker compose exec web bundle exec rails test test/models/user_test.rb:42    # one test by line number
```

Per the [testing policy](CLAUDE.md#testing-policy): always run the full suite before considering a task complete; if tests fail, fix the underlying code rather than weakening the assertion.

**Console and one-offs**

```bash
docker compose exec web bundle exec rails console            # interactive console (development)
docker compose exec web bundle exec rails console -e test    # console against the test DB
docker compose exec web bundle exec rails routes             # all routes
docker compose exec web bundle exec rails routes -g admin    # filtered to a controller / namespace
docker compose exec web bash                                 # shell in the web container
```

**Bundle and code generation**

```bash
docker compose exec web bundle install                          # install/update gems after editing the Gemfile
docker compose exec web bundle exec rails generate migration ...
docker compose exec web bundle exec rails generate model ...
docker compose exec web bundle exec rubocop -a                  # lint with autocorrect
```

**When something looks wrong**

```bash
docker compose ps                       # which services are up, are any unhealthy
docker compose logs --tail=200 web      # last 200 lines of the web logs
docker compose down && docker compose up   # full restart of the stack
docker compose down -v && docker compose up   # nuclear: wipe DB + Redis and rebuild
```

`down -v` is the destructive option — it deletes the Postgres data volume. Reach for it when the schema is in a state Rails migrations can't fix; otherwise stick with `db:reset`, which preserves Redis and the bundle cache.

### Conventions

Project-wide rules of thumb (e.g. all controllers require an authenticated user) live in [`CONVENTIONS.md`](CONVENTIONS.md). When in doubt, follow them; document any exceptions inline there.
