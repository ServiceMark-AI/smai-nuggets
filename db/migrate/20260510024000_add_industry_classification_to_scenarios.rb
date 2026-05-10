class AddIndustryClassificationToScenarios < ActiveRecord::Migration[8.1]
  def change
    # Free-form string for industry / standards classification (e.g.
    # "IICRC S520 Mold Remediation"). Intentionally not an enum — the
    # taxonomy is wide and per-scenario; operators paste the code/name
    # they want surfaced.
    add_column :scenarios, :industry_classification, :string
  end
end
