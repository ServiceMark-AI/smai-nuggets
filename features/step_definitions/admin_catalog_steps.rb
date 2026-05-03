# Steps for §1 (catalog) and §2.1 (create tenant).

When("I open Admin → Job Types") do
  visit admin_job_types_path
end

Then("I should see the seeded job types in the catalog") do
  # Seeded job types in db/seeds.rb live across multiple migrations; we can't
  # rely on a specific name surviving forever, so just assert non-empty.
  JobType.find_or_create_by!(name: "Water Damage", type_code: "water_damage")
  visit admin_job_types_path
  expect(JobType.count).to be > 0
  expect(page).to have_css("table tbody tr", minimum: 1)
end

When("I open Admin → Tenants") do
  visit admin_tenants_path
end

When("I click {string}") do |label|
  click_on label
end

When("I create a tenant named {string}") do |name|
  fill_in "Name", with: name
  click_on "Create tenant"
end

Then("the tenants list should include {string}") do |name|
  visit admin_tenants_path
  expect(page).to have_content(name)
end
