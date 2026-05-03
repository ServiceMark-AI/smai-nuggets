# Auth + identity steps used across most features.

Given("I am a tenant user") do
  @current_user = tenant_user
end

Given("I am signed in as a tenant user") do
  @current_user = tenant_user
  sign_in_via_form(@current_user)
end

Given("I am signed in as a system admin") do
  @current_user = admin_user
  sign_in_via_form(@current_user)
end

When("I sign in with my email and password") do
  sign_in_via_form(@current_user)
end
