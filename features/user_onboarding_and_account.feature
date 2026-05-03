Feature: User onboarding and account
  Mirrors docs/user-guide/03-user-onboarding-and-account.md.
  Each scenario corresponds to an activity in §3.

  @pending
  Scenario: §3.1 Accepting an invitation lands the user on a password form
    Given an invitation has been sent to "newhire@example.com"
    When I open the invitation link from my email
    Then I should see "Set your password"

  Scenario: §3.2 Signing in
    Given I am a tenant user
    When I sign in with my email and password
    Then I should land on the Job Proposals page
    And the sidebar shows "Job Proposals" and "Users"

  @pending
  Scenario: §3.3 Resetting my password
    Given I am a tenant user
    When I request a password reset for my email
    Then I should receive a reset email with a link
    When I open the reset link and submit a new password
    Then I should be able to sign in with the new password

  @pending
  Scenario: §3.4 Editing my profile
    Given I am signed in as a tenant user
    When I open the Profile page
    And I update my first name to "Quinn"
    Then my profile should show "Quinn" as the first name

  @pending
  Scenario: §3.5 Connecting a Gmail account from my profile
    Given I am signed in as a tenant user
    And Google OAuth credentials are configured
    When I click "Setup G Suite" on my Profile page
    Then I should be redirected through Google sign-in
    And the connected Gmail account should appear on my Profile

  @pending
  Scenario: §3.6 Inviting a teammate
    Given I am signed in as a tenant user
    When I invite "teammate@example.com" from the Users page
    Then a pending invitation row for "teammate@example.com" should appear in the Users list
