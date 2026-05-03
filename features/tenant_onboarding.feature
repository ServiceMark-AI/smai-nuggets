Feature: Tenant onboarding (admin)
  Mirrors docs/user-guide/02-tenant-onboarding.md.

  Background:
    Given I am signed in as a system admin

  Scenario: §2.1 Creating a tenant
    When I open Admin → Tenants
    And I click "New tenant"
    And I create a tenant named "Acme Restoration"
    Then the tenants list should include "Acme Restoration"

  @pending
  Scenario: §2.2 Adding an organization location
    Given the tenant "Acme Restoration" with HQ organization exists
    When I open the location form for that organization
    And I fill in a complete address and phone number
    Then the organization show page should display the new location

  @pending
  Scenario: §2.3 Inviting the first admin user for a tenant
    Given the tenant "Acme Restoration" exists
    When I open the tenant's show page
    And I invite "owner@acme.example" as the first admin
    Then a pending invitation for "owner@acme.example" should appear under that tenant

  @pending
  Scenario: §2.4 Activating job types and scenarios for a tenant
    Given the tenant "Acme Restoration" exists
    When I open Manage activations for that tenant
    And I activate the "Water" job type
    Then the tenant should report "Water" as an active job type
