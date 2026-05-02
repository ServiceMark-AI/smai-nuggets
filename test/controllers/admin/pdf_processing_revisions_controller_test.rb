require "test_helper"

class Admin::PdfProcessingRevisionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @non_admin = users(:one)
    @model = Model.create!(model_id: "fake-model", name: "Fake Model", provider: "test")
  end

  test "redirects to sign-in when not signed in" do
    get admin_pdf_processing_revisions_url
    assert_redirected_to new_user_session_path
  end

  test "non-admin is redirected away" do
    sign_in @non_admin
    get admin_pdf_processing_revisions_url
    assert_redirected_to root_path
  end

  test "admin index renders empty state" do
    sign_in @admin
    get admin_pdf_processing_revisions_url
    assert_response :success
    assert_match "No revisions yet.", response.body
  end

  test "admin index lists revisions newest first and badges the current one" do
    PdfProcessingRevision.create!(instructions: "v1", model: @model)
    current = PdfProcessingRevision.create!(instructions: "v2", model: @model)
    sign_in @admin

    get admin_pdf_processing_revisions_url
    assert_response :success
    assert_match "v2", response.body
    assert_match "v1", response.body
    assert_match "Current", response.body
    assert response.body.index("v2") < response.body.index("v1"), "v2 should appear before v1"
    assert_equal current, PdfProcessingRevision.is_current
  end

  test "admin sees the new form" do
    sign_in @admin
    get new_admin_pdf_processing_revision_url
    assert_response :success
    assert_select "form textarea[name='pdf_processing_revision[instructions]']"
    assert_select "form select[name='pdf_processing_revision[model_id]']"
  end

  test "new form pre-populates from the current revision when one exists" do
    other_model = Model.create!(model_id: "another-model", name: "Another", provider: "test")
    PdfProcessingRevision.create!(instructions: "Older instructions.", model: @model)
    PdfProcessingRevision.create!(instructions: "The current instructions.", model: other_model)

    sign_in @admin
    get new_admin_pdf_processing_revision_url
    assert_response :success
    assert_select "form textarea[name='pdf_processing_revision[instructions]']", text: "The current instructions."
    assert_select "form select[name='pdf_processing_revision[model_id]'] option[selected][value=?]", other_model.id.to_s
  end

  test "new form is empty when no revisions exist yet" do
    sign_in @admin
    get new_admin_pdf_processing_revision_url
    assert_response :success
    assert_select "form textarea[name='pdf_processing_revision[instructions]']", text: ""
  end

  test "admin create with valid params persists with auto-assigned revision_number" do
    sign_in @admin
    assert_difference "PdfProcessingRevision.count", 1 do
      post admin_pdf_processing_revisions_url, params: {
        pdf_processing_revision: { instructions: "New rev", model_id: @model.id }
      }
    end
    assert_redirected_to admin_pdf_processing_revisions_path
    rev = PdfProcessingRevision.last
    assert_equal "New rev", rev.instructions
    assert_equal 1, rev.revision_number
    assert_equal @model, rev.model
  end

  test "admin create with missing instructions re-renders the form" do
    sign_in @admin
    assert_no_difference "PdfProcessingRevision.count" do
      post admin_pdf_processing_revisions_url, params: {
        pdf_processing_revision: { instructions: "", model_id: @model.id }
      }
    end
    assert_response :unprocessable_content
    assert_match(/can&#39;t be blank/, response.body)
  end

  test "non-admin cannot create" do
    sign_in @non_admin
    assert_no_difference "PdfProcessingRevision.count" do
      post admin_pdf_processing_revisions_url, params: {
        pdf_processing_revision: { instructions: "Sneaky", model_id: @model.id }
      }
    end
    assert_redirected_to root_path
  end
end
