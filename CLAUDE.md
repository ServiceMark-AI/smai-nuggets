# CLAUDE.md

## Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for project-wide rules of thumb (e.g., all controllers require an authenticated user). Follow them unless an exception is documented there.

## Running Rails commands

Docker Compose is always running our environment in the background. To run tests
or any other Rails / bundle command, prefix with:

```bash
docker-compose exec web bundle exec
```

Examples:

```bash
docker-compose exec web bundle exec rails db:test:prepare test test:system
docker-compose exec web bundle exec rails test
docker-compose exec web bundle exec rails test:system
docker-compose exec web bundle exec rails db:migrate
docker-compose exec web bundle exec rails console
```

## Testing policy

- **Always run the full test suite before considering any task complete.** Do not report a task as done if tests are failing.
- **If tests fail, update the application code to make them pass** — do not weaken assertions, skip tests, or delete tests to make the suite green. Fix the underlying issue.
- **Write unit tests for every controller you add or change, covering each branch of its logic** — unauthenticated access, empty-state, scoped reads/writes, admin paths, error cases. Don't ship a controller without tests.

## Commit policy

- After completing a significant task, stage all changed files, craft a commit message describing the change, and commit to git.

## User guide maintenance

The operator-facing user guide lives in [docs/user-guide/](docs/user-guide/) and is hosted on GitHub. Treat it as a deliverable, not a side artifact:

- **When a feature ships, changes, or is removed, review the user guide for any section it touches and update it in the same change.** Sections in scope: §0 production setup, §1 job types & campaigns, §2 tenant onboarding, §3 user onboarding & account, §4 campaign maintenance.
- **Audience is operators, not developers.** Use domain language (job types, scenarios, campaigns, proposals, application mailbox) and concrete UI paths (sidebar items, button labels). Do not name model classes, controllers, columns, env vars, or service objects in user-facing prose unless an admin would actually type them — keep that level of detail out of §1–§4 and confine it to §0 (which is infra-facing) or footnoted asides.
- **Keep cross-references live.** Section anchors follow GitHub's slug rules (period stripped from `1.5` → `15`, ` & ` and ` / ` collapse to `--`). When a section is renumbered or renamed, update every link that pointed at it. A quick sweep: `grep -nE '§[0-9]' docs/user-guide/`.
- **If a feature is genuinely "doesn't exist yet," leave the placeholder visible** (see §4e). Do not invent UX that isn't built.
