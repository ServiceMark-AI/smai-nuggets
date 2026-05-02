require "test_helper"

class Admin::JobTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user  = users(:one)
    @jt_one = job_types(:one)         # tenant: one
    @jt_two = job_types(:two)         # tenant: two
  end

  # --- access ---

  test "redirects unauthenticated visitors to sign-in" do
    get admin_job_types_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin users are turned away" do
    sign_in @user
    get admin_job_types_url
    assert_redirected_to root_path
  end

  # --- index ---

  test "admin sees job types across all tenants" do
    sign_in @admin
    get admin_job_types_url
    assert_response :success
    assert_match @jt_one.name, response.body
    assert_match @jt_two.name, response.body
  end

  test "index links the name to the show page" do
    sign_in @admin
    get admin_job_types_url
    assert_select "a[href=?]", admin_job_type_path(@jt_one), text: @jt_one.name
  end

  test "index shows the type_code and tenant columns" do
    sign_in @admin
    get admin_job_types_url
    assert_match @jt_one.type_code, response.body
    assert_match @jt_one.tenant.name, response.body
  end

  # --- show ---

  test "show renders the job type" do
    sign_in @admin
    get admin_job_type_url(@jt_one)
    assert_response :success
    assert_match @jt_one.name, response.body
    assert_match @jt_one.type_code, response.body
  end

  test "show 404s for missing ids" do
    sign_in @admin
    get admin_job_type_url(id: 0)
    assert_response :not_found
  end

  # --- new + create ---

  test "new renders the form with a tenant selector" do
    sign_in @admin
    get new_admin_job_type_url
    assert_response :success
    assert_select "select[name='job_type[tenant_id]']"
    assert_select "input[name='job_type[name]']"
    assert_select "input[name='job_type[type_code]']"
  end

  test "create persists a job type to the chosen tenant" do
    sign_in @admin
    assert_difference -> { JobType.count }, 1 do
      post admin_job_types_url, params: {
        job_type: {
          tenant_id: tenants(:one).id,
          name: "Water Mitigation",
          type_code: "WTR-MIT",
          description: "Cat-3 cleanup"
        }
      }
    end
    jt = JobType.find_by(type_code: "WTR-MIT")
    assert_redirected_to admin_job_type_path(jt)
    assert_equal tenants(:one), jt.tenant
  end

  test "create rejects invalid input" do
    sign_in @admin
    assert_no_difference -> { JobType.count } do
      post admin_job_types_url, params: { job_type: { tenant_id: tenants(:one).id, name: "", type_code: "" } }
    end
    assert_response :unprocessable_content
  end

  test "create rejects duplicate type_code in the same tenant" do
    sign_in @admin
    assert_no_difference -> { JobType.count } do
      post admin_job_types_url, params: {
        job_type: { tenant_id: @jt_one.tenant_id, name: "Different Name", type_code: @jt_one.type_code }
      }
    end
    assert_response :unprocessable_content
  end

  # --- edit + update ---

  test "edit renders the form" do
    sign_in @admin
    get edit_admin_job_type_url(@jt_one)
    assert_response :success
    assert_match @jt_one.type_code, response.body
  end

  test "update saves changes" do
    sign_in @admin
    patch admin_job_type_url(@jt_one), params: { job_type: { name: "Renamed", type_code: "RNAMD" } }
    assert_redirected_to admin_job_type_path(@jt_one)
    @jt_one.reload
    assert_equal "Renamed", @jt_one.name
    assert_equal "RNAMD", @jt_one.type_code
  end

  test "update rejects invalid input" do
    sign_in @admin
    patch admin_job_type_url(@jt_one), params: { job_type: { name: "" } }
    assert_response :unprocessable_content
    refute_equal "", @jt_one.reload.name
  end

  # --- destroy ---

  test "destroy removes the job type" do
    sign_in @admin
    assert_difference -> { JobType.count }, -1 do
      delete admin_job_type_url(@jt_one)
    end
    assert_redirected_to admin_job_types_path
  end
end
