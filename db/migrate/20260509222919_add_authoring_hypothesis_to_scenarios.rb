class AddAuthoringHypothesisToScenarios < ActiveRecord::Migration[8.1]
  def change
    # Free-form text — sample copy in SPEC-11 / authoring docs runs ~100
    # words, but the field is intentionally open-ended for the operator
    # to capture the why behind a scenario's templated content.
    add_column :scenarios, :authoring_hypothesis, :text
  end
end
