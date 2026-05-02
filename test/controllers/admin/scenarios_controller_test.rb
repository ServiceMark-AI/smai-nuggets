require "test_helper"

class Admin::ScenariosControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @user  = users(:one)
    @job_type = job_types(:one)
    @scenario = scenarios(:sewage_backup)
  end

  # --- access ---

  test "non-admin users are turned away from new" do
    sign_in @user
    get new_admin_job_type_scenario_url(@job_type)
    assert_redirected_to root_path
  end

  test "non-admin users are turned away from show" do
    sign_in @user
    get admin_scenario_url(@scenario)
    assert_redirected_to root_path
  end

  # --- new + create ---

  test "new renders the form without a campaign picker (scenario must be saved first)" do
    sign_in @admin
    get new_admin_job_type_scenario_url(@job_type)
    assert_response :success
    assert_select "input[name='scenario[code]']"
    assert_select "input[name='scenario[short_name]']"
    assert_select "select[name='scenario[campaign_id]']", count: 0
    assert_match(/Save the scenario first/i, response.body)
  end

  test "create persists a scenario under the job type" do
    sign_in @admin
    assert_difference -> { Scenario.count }, 1 do
      post admin_job_type_scenarios_url(@job_type), params: {
        scenario: { code: "pipe_burst", short_name: "Pipe burst", description: "Sudden release." }
      }
    end
    s = @job_type.scenarios.find_by(code: "pipe_burst")
    assert_redirected_to admin_scenario_path(s)
  end

  test "create rejects invalid input" do
    sign_in @admin
    assert_no_difference -> { Scenario.count } do
      post admin_job_type_scenarios_url(@job_type), params: { scenario: { code: "", short_name: "" } }
    end
    assert_response :unprocessable_content
  end

  test "create rejects duplicate code within the same job type" do
    sign_in @admin
    assert_no_difference -> { Scenario.count } do
      post admin_job_type_scenarios_url(@job_type), params: {
        scenario: { code: @scenario.code, short_name: "Different name" }
      }
    end
    assert_response :unprocessable_content
  end

  # --- show ---

  test "show renders the scenario" do
    sign_in @admin
    get admin_scenario_url(@scenario)
    assert_response :success
    assert_match @scenario.short_name, response.body
    assert_match @scenario.code, response.body
  end

  test "show 404s for missing ids" do
    sign_in @admin
    get admin_scenario_url(id: 0)
    assert_response :not_found
  end

  # --- edit + update ---

  test "edit renders the form" do
    sign_in @admin
    get edit_admin_scenario_url(@scenario)
    assert_response :success
    assert_match @scenario.code, response.body
  end

  test "edit campaign picker only lists campaigns attributed to this scenario" do
    other_scenario = @job_type.scenarios.create!(code: "other_code_xyz", short_name: "Other")
    matching = Campaign.create!(name: "Matches Scenario", attributed_to: @scenario)
    other = Campaign.create!(name: "Attributed Elsewhere", attributed_to: other_scenario)
    unattributed = Campaign.create!(name: "Floating Campaign")

    sign_in @admin
    get edit_admin_scenario_url(@scenario)
    assert_response :success
    assert_select "select[name='scenario[campaign_id]'] option", text: matching.name
    assert_select "select[name='scenario[campaign_id]'] option", text: other.name, count: 0
    assert_select "select[name='scenario[campaign_id]'] option", text: unattributed.name, count: 0
  end

  test "update saves changes" do
    sign_in @admin
    patch admin_scenario_url(@scenario), params: { scenario: { short_name: "Renamed" } }
    assert_redirected_to admin_scenario_path(@scenario)
    assert_equal "Renamed", @scenario.reload.short_name
  end

  test "update rejects invalid input" do
    sign_in @admin
    patch admin_scenario_url(@scenario), params: { scenario: { code: "" } }
    assert_response :unprocessable_content
  end

  # --- destroy ---

  test "destroy removes the scenario and returns to the job type page" do
    sign_in @admin
    assert_difference -> { Scenario.count }, -1 do
      delete admin_scenario_url(@scenario)
    end
    assert_redirected_to admin_job_type_path(@job_type)
  end

  # --- job type show integration ---

  test "the job type show page lists its scenarios" do
    sign_in @admin
    get admin_job_type_url(@job_type)
    assert_response :success
    assert_match @scenario.short_name, response.body
    assert_select "a[href=?]", new_admin_job_type_scenario_path(@job_type)
  end
end
