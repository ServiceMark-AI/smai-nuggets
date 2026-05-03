Feature: Campaign maintenance (tenant user)
  Mirrors docs/user-guide/04-campaign-maintenance.md.

  Background:
    Given I am signed in as a tenant user

  @pending
  Scenario: §4a Uploading a job to start a campaign
    When I open Job Proposals
    And I click "New job"
    And I upload a sample proposal PDF
    Then I should land on the Confirm page for the new proposal
    And the form should be populated with extracted customer fields

  @pending
  Scenario: §4a After confirming, the campaign launches
    Given a freshly uploaded proposal awaiting confirmation
    When I pick a scenario and save the Confirm page
    Then a CampaignInstance should exist for the proposal
    And step instances should be queued with planned delivery times

  Scenario: §4b The proposal status board
    Given my tenant has at least one job proposal
    When I open Job Proposals
    Then I should see the proposal listed with an Action button

  @pending
  Scenario: §4c Pausing & unpausing a single proposal's campaign
    Given a proposal whose campaign is currently active
    When I click "Pause" on the proposal's detail page
    Then no further campaign emails should go out for that proposal
    When I click "Resume campaign" on the proposal's row
    Then the campaign cadence should resume

  Scenario: §4c Resuming an already-paused campaign from the index
    Given a proposal whose campaign instance is paused
    When I open Job Proposals
    And I click "Resume campaign" on the proposal's row
    Then the campaign instance should flip back to active
    And the proposal's status overlay should clear

  Scenario: §4d Customer responds — the row routes me to Gmail
    Given a proposal whose latest state is "customer_waiting"
    When I open Job Proposals
    Then the proposal's Action button should read "Open in Gmail"
    And it should target a new tab pointing at the Gmail thread URL

  @pending
  Scenario: §4e Marking a proposal as won or lost
    Given an in-flight proposal
    When I click "Mark Won" on the proposal's detail page
    Then the proposal's pipeline_stage should be "won"
    And no further campaign emails should go out for that proposal
