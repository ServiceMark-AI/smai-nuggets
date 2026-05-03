# Steps for features/user_onboarding_and_account.feature

Then("I should land on the Job Proposals page") do
  # The user-guide says "after signing in, the sidebar will show Job
  # Proposals and Users." The app currently sends the user to root after
  # sign-in (HomeController#index) — the sidebar provides the path to
  # Job Proposals. This step asserts the sidebar reflects that intent.
  expect(page).to have_css("aside a", text: "Job Proposals")
end

Then("the sidebar shows {string} and {string}") do |label_a, label_b|
  within("aside") do
    expect(page).to have_link(label_a)
    expect(page).to have_link(label_b)
  end
end
