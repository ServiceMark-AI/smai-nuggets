# Cucumber world helpers shared across all features.
# Loaded automatically by cucumber-rails (via env.rb).

require "devise"
World(Devise::Test::IntegrationHelpers) if defined?(Cucumber::Rails)

# Fixture-style data for cucumber: a small set of helper builders that create
# the records each feature needs. Kept in one place so feature step
# definitions stay focused on the operator-facing language.
module FeatureWorldHelpers
  def admin_user
    @admin_user ||= User.find_or_create_by!(email: "cuke-admin@example.com") do |u|
      u.password = "Password1"
      u.password_confirmation = "Password1"
      u.is_admin = true
      u.is_pending = false
      u.first_name = "Avery"
      u.last_name = "Sloan"
    end
  end

  def tenant_user(tenant: nil, organization: nil, email: "cuke-user@example.com")
    tenant ||= Tenant.find_or_create_by!(name: "Cuke Roofing")
    organization ||= tenant.organizations.find_or_create_by!(name: "HQ")
    user = User.find_or_create_by!(email: email) do |u|
      u.password = "Password1"
      u.password_confirmation = "Password1"
      u.tenant = tenant
      u.is_pending = false
      u.first_name = "Pat"
      u.last_name = "Operator"
    end
    OrganizationalMember.find_or_create_by!(user: user, organization: organization) do |m|
      m.role = "admin"
    end
    user
  end

  def sign_in_via_form(user, password: "Password1")
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: password
    click_button "Log in"
  end
end

World(FeatureWorldHelpers)
World(Rails.application.routes.url_helpers)
