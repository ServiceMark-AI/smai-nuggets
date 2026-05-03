require "test_helper"

class Admin::TenantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
  end

  test "non-admin cannot reach the new tenant form" do
    sign_in @non_admin
    get new_admin_tenant_url
    assert_redirected_to root_path
  end

  test "admin sees the new tenant form" do
    sign_in @admin
    get new_admin_tenant_url
    assert_response :success
    assert_select "form input[name='tenant[name]']"
  end

  test "create makes a tenant and a top-level organization with the same name" do
    sign_in @admin
    assert_difference "Tenant.count", 1 do
      assert_difference "Organization.count", 1 do
        post admin_tenants_url, params: { tenant: { name: "Acme Roofing" } }
      end
    end

    tenant = Tenant.find_by!(name: "Acme Roofing")
    org = tenant.organizations.find_by!(name: "Acme Roofing")
    assert_nil org.parent_id
    assert_redirected_to admin_tenant_path(tenant)
  end

  test "create with a blank name re-renders the form" do
    sign_in @admin
    assert_no_difference "Tenant.count" do
      post admin_tenants_url, params: { tenant: { name: "" } }
    end
    assert_response :unprocessable_content
  end

  test "show renders the invitation form when a tenant exists and the prereqs are met" do
    ApplicationMailbox.create!(provider: "google_oauth2", email: "noreply@app.example.com", access_token: "tok")
    sign_in @admin
    get admin_tenant_url(tenants(:one))
    assert_response :success
    assert_select "form[action=?]", admin_tenant_invitations_path(tenants(:one))
    assert_select "input[name='invitation[email]']"
  end

  test "show replaces the invitation form with a warning when the mailbox isn't connected" do
    sign_in @admin
    get admin_tenant_url(tenants(:one))
    assert_response :success
    assert_select "form[action=?]", admin_tenant_invitations_path(tenants(:one)), count: 0
    assert_match(/Invitations aren't ready to send/i, response.body)
    assert_match(/Gmail account is connected/i, response.body)
  end
end
