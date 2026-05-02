class AddScenarioToJobProposals < ActiveRecord::Migration[8.1]
  def change
    add_reference :job_proposals, :scenario, null: true, foreign_key: true
  end
end
