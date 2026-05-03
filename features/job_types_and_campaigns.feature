Feature: Job types and campaigns (admin)
  Mirrors docs/user-guide/01-job-types-and-campaigns.md.
  These activities are admin-only — they configure the catalog that
  every tenant inherits.

  Background:
    Given I am signed in as a system admin

  Scenario: §1.1 Browsing the job-type catalog
    When I open Admin → Job Types
    Then I should see the seeded job types in the catalog

  @pending
  Scenario: §1.2 Editing a scenario
    Given the catalog has a "Sewage backup" scenario
    When I open the scenario's edit page
    And I update its description to "Updated by cuke"
    Then the scenario should display "Updated by cuke"

  @pending
  Scenario: §1.3 Creating a campaign
    When I open Admin → Campaigns
    And I click "+ New campaign"
    And I name the campaign "Spring Outreach 2026"
    Then the campaign should appear in the campaigns list with status "New"

  @pending
  Scenario: §1.4 Adding a step to a campaign
    Given a campaign named "Spring Outreach 2026" exists in status New
    When I open that campaign and click "+ New step"
    And I fill in subject "Following up", body "Hi {customer_first_name}", and offset "0"
    Then the campaign should show one step with sequence number 1

  @pending
  Scenario: §1.5 Approving a campaign
    Given a campaign named "Spring Outreach 2026" with at least one step exists in status New
    When I click "Approve" on the campaign show page
    Then the campaign status should flip to "Approved"

  @pending
  Scenario: §1.6 Attaching a campaign to a scenario
    Given the campaign "Spring Outreach 2026" is attributed to the "Sewage backup" scenario
    When I open the scenario's edit page
    And I pick "Spring Outreach 2026" from the Campaign dropdown and save
    Then the scenario's show page should link to "Spring Outreach 2026"
