require "test_helper"

class TenantTest < ActiveSupport::TestCase
  test "activated_job_types returns only those with an active join row" do
    tenant = tenants(:one)
    assert_includes tenant.activated_job_types, job_types(:one)
    assert_not_includes tenant.activated_job_types, job_types(:two)
  end

  test "activated_job_types excludes job_types whose join row is inactive" do
    tenant = tenants(:one)
    tenant_job_types(:one_active).update!(is_active: false)
    assert_not_includes tenant.activated_job_types, job_types(:one)
  end

  test "activated_scenarios returns only those with an active join row" do
    tenant = tenants(:one)
    assert_includes tenant.activated_scenarios, scenarios(:sewage_backup)
    assert_not_includes tenant.activated_scenarios, scenarios(:clean_water)
  end

  test "activated_scenarios excludes scenarios whose join row is inactive" do
    tenant = tenants(:one)
    tenant_scenarios(:sewage_active_for_one).update!(is_active: false)
    assert_not_includes tenant.activated_scenarios, scenarios(:sewage_backup)
  end

  test "tenants with no activations get an empty collection, not nil" do
    tenant = tenants(:two)
    assert_equal [], tenant.activated_job_types.to_a
    assert_equal [], tenant.activated_scenarios.to_a
  end

  # --- logo resolution ---------------------------------------------------

  test "logo_image_url returns the manual logo_url when no file is attached" do
    tenant = tenants(:one)
    tenant.update!(logo_url: "https://example.com/logo.png")
    assert_equal "https://example.com/logo.png", tenant.logo_image_url
  end

  test "logo_image_url returns nil when neither attachment nor manual URL is set" do
    tenant = tenants(:one)
    tenant.update!(logo_url: nil)
    assert_nil tenant.logo_image_url
  end

  test "logo_image_url prefers an attached blob over the manual URL" do
    tenant = tenants(:one)
    tenant.update!(logo_url: "https://example.com/manual.png")
    tenant.logo.attach(io: StringIO.new("fake image"), filename: "uploaded.png", content_type: "image/png")
    assert_match(/rails\/active_storage\/blobs/, tenant.logo_image_url)
    refute_match(/manual.png/, tenant.logo_image_url)
  end
end
