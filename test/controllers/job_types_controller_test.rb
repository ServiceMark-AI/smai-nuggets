require "test_helper"

class JobTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)               # tenant: one
    @other_tenant_user = users(:two)  # tenant: two
    @app_admin = users(:admin)        # is_admin
    @jt_one = job_types(:one)         # tenant: one
    @jt_two = job_types(:two)         # tenant: two
  end

  # --- index ---

  test "index redirects unauthenticated visitors to sign-in" do
    get job_types_url
    assert_redirected_to new_user_session_path
  end

  test "index redirects users with no tenant to root" do
    lonely = User.create!(email: "lonely_jt@example.com", password: "Password1")
    sign_in lonely
    get job_types_url
    assert_redirected_to root_path
  end

  test "index lists only the user's tenant's job types" do
    sign_in @user
    get job_types_url
    assert_response :success
    assert_match @jt_one.name, response.body
    assert_no_match @jt_two.name, response.body
  end

  test "index shows the type_code column" do
    sign_in @user
    get job_types_url
    assert_response :success
    assert_match @jt_one.type_code, response.body
  end

  test "index links the name to the show page" do
    sign_in @user
    get job_types_url
    assert_select "a[href=?]", job_type_path(@jt_one), text: @jt_one.name
  end

  # --- show ---

  test "show renders for a job type in the user's tenant" do
    sign_in @user
    get job_type_url(@jt_one)
    assert_response :success
    assert_match @jt_one.name, response.body
    assert_match @jt_one.type_code, response.body
  end

  test "show 404s for a job type outside the user's tenant" do
    sign_in @user
    get job_type_url(@jt_two)
    assert_response :not_found
  end

  # --- new + create ---

  test "new renders the form" do
    sign_in @user
    get new_job_type_url
    assert_response :success
    assert_select "form input[name='job_type[name]']"
    assert_select "form input[name='job_type[type_code]']"
  end

  test "create persists a job type to the user's tenant" do
    sign_in @user
    assert_difference -> { @user.tenant.job_types.count }, 1 do
      post job_types_url, params: { job_type: { name: "Water Mitigation", type_code: "WTR-MIT", description: "Cat-3 cleanup" } }
    end
    jt = @user.tenant.job_types.find_by(type_code: "WTR-MIT")
    assert_redirected_to jt
    assert_equal "Water Mitigation", jt.name
  end

  test "create rejects invalid input and re-renders the form" do
    sign_in @user
    assert_no_difference -> { JobType.count } do
      post job_types_url, params: { job_type: { name: "", type_code: "" } }
    end
    assert_response :unprocessable_content
    assert_match "can&#39;t be blank", response.body
  end

  test "create rejects duplicate type_code in the same tenant" do
    sign_in @user
    assert_no_difference -> { JobType.count } do
      post job_types_url, params: { job_type: { name: "Different Name", type_code: @jt_one.type_code } }
    end
    assert_response :unprocessable_content
  end

  # --- edit + update ---

  test "edit renders for a job type in the user's tenant" do
    sign_in @user
    get edit_job_type_url(@jt_one)
    assert_response :success
    assert_match @jt_one.type_code, response.body
  end

  test "edit 404s for a job type outside the user's tenant" do
    sign_in @user
    get edit_job_type_url(@jt_two)
    assert_response :not_found
  end

  test "update saves changes" do
    sign_in @user
    patch job_type_url(@jt_one), params: { job_type: { name: "Renamed", type_code: "RNAMD" } }
    assert_redirected_to @jt_one
    @jt_one.reload
    assert_equal "Renamed", @jt_one.name
    assert_equal "RNAMD", @jt_one.type_code
  end

  test "update rejects invalid input" do
    sign_in @user
    patch job_type_url(@jt_one), params: { job_type: { name: "" } }
    assert_response :unprocessable_content
    refute_equal "", @jt_one.reload.name
  end

  # --- destroy ---

  test "destroy removes the job type" do
    sign_in @user
    assert_difference -> { JobType.count }, -1 do
      delete job_type_url(@jt_one)
    end
    assert_redirected_to job_types_path
  end

  test "destroy 404s for a job type outside the user's tenant" do
    sign_in @user
    assert_no_difference -> { JobType.count } do
      delete job_type_url(@jt_two)
    end
    assert_response :not_found
  end
end
