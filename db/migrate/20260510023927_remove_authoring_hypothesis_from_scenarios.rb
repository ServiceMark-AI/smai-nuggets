class RemoveAuthoringHypothesisFromScenarios < ActiveRecord::Migration[8.1]
  # Walk back the column added in 20260509222919. The product decision is
  # to relabel the existing `description` field as "Authoring hypothesis"
  # in the UI rather than carry two near-duplicate text columns.
  def change
    remove_column :scenarios, :authoring_hypothesis, :text
  end
end
