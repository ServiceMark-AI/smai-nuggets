# Conventions

Rules of thumb that apply across the codebase. Exceptions are noted inline.

## Authentication

- **All controllers require an authenticated user.** `ApplicationController` calls `before_action :authenticate_user!` (skipped for Devise's own controllers via `unless: :devise_controller?`). Unauthenticated requests are redirected to the Devise sign-in page.
- If a controller (or specific action) should be reachable without login, opt out explicitly with `skip_before_action :authenticate_user!` and document it here.

### Exceptions

- Devise controllers (sign in, sign up, password reset, etc.) — handled automatically by `unless: :devise_controller?`.
- `Rails::HealthController` (`/up`) — inherits from `ActionController::Base`, not `ApplicationController`, so the rule doesn't apply.
