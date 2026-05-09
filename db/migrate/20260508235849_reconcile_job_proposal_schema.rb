class ReconcileJobProposalSchema < ActiveRecord::Migration[8.1]
  def up
    # Add template_version_id on campaigns per PRD-01 §5 / SPEC-11 v2.0 §7.3.
    # String for now — there's no template_versions table yet (separate PR).
    add_column :campaigns, :template_version_id, :string

    # Backfill nil location_id with the proposal's tenant's first active
    # location. Then lock NOT NULL.
    execute <<~SQL
      UPDATE job_proposals AS jp
         SET location_id = sub.id
        FROM (
          SELECT DISTINCT ON (tenant_id) id, tenant_id
            FROM locations
           WHERE is_active = true
           ORDER BY tenant_id, id
        ) AS sub
       WHERE jp.tenant_id = sub.tenant_id
         AND jp.location_id IS NULL
    SQL

    nil_location = connection.select_value("SELECT COUNT(*) FROM job_proposals WHERE location_id IS NULL").to_i
    if nil_location.positive?
      raise "Refusing to lock location_id NOT NULL: #{nil_location} proposals still have nil location_id"
    end
    change_column_null :job_proposals, :location_id, false

    # `scenario_key` is being removed in favor of the FK `scenario_id`
    # (which is the AR-native source of truth). Before dropping the
    # column, backfill any proposal that has a scenario_key but a nil
    # scenario_id by looking up the scenario whose code matches.
    execute <<~SQL
      UPDATE job_proposals AS jp
         SET scenario_id = s.id
        FROM scenarios s
       WHERE s.code = jp.scenario_key
         AND jp.scenario_id IS NULL
         AND jp.scenario_key IS NOT NULL
    SQL

    remove_column :job_proposals, :scenario_key
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Schema reconciliation is one-way."
  end
end
