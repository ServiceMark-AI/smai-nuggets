require "test_helper"

class PdfProcessingRevisionTest < ActiveSupport::TestCase
  setup do
    @model = Model.create!(model_id: "fake-model", name: "Fake Model", provider: "test")
  end

  test "auto-assigns sequential revision_numbers starting at 1" do
    r1 = PdfProcessingRevision.create!(instructions: "First version.", model: @model)
    r2 = PdfProcessingRevision.create!(instructions: "Second version.", model: @model)
    r3 = PdfProcessingRevision.create!(instructions: "Third version.", model: @model)

    assert_equal 1, r1.revision_number
    assert_equal 2, r2.revision_number
    assert_equal 3, r3.revision_number
  end

  test "is_current returns the highest revision_number record" do
    PdfProcessingRevision.create!(instructions: "v1", model: @model)
    r2 = PdfProcessingRevision.create!(instructions: "v2", model: @model)

    assert_equal r2, PdfProcessingRevision.is_current

    r3 = PdfProcessingRevision.create!(instructions: "v3", model: @model)
    assert_equal r3, PdfProcessingRevision.is_current
  end

  test "is_current returns nil when no revisions exist" do
    assert_nil PdfProcessingRevision.is_current
  end

  test "instructions presence is required" do
    rev = PdfProcessingRevision.new(model: @model)
    assert_not rev.valid?
    assert_includes rev.errors[:instructions], "can't be blank"
  end

  test "model is required" do
    rev = PdfProcessingRevision.new(instructions: "x")
    assert_not rev.valid?
    assert_includes rev.errors[:model], "must exist"
  end
end
