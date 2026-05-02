# CLAUDE.md

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

## Commit policy

- After completing a significant task, stage all changed files, craft a commit message describing the change, and commit to git.
