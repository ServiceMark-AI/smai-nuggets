class ReconcileJobProposalSchema < ActiveRecord::Migration[8.1]
  def up
    # Add template_version_id on campaigns per PRD-01 §5 / SPEC-11 v2.0 §7.3.
    # String for now — there's no template_versions table yet (separate PR).
    add_column :campaigns, :template_version_id, :string

    # Backfill nil location_id in three passes, then lock NOT NULL.
    #
    # Pass 1: prefer the tenant's first ACTIVE location.
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

    # Pass 2: tenants without any active location fall back to any
    # location they own (active or not). This handles accounts that
    # have created locations but never flipped them to is_active.
    execute <<~SQL
      UPDATE job_proposals AS jp
         SET location_id = sub.id
        FROM (
          SELECT DISTINCT ON (tenant_id) id, tenant_id
            FROM locations
           ORDER BY tenant_id, id
        ) AS sub
       WHERE jp.tenant_id = sub.tenant_id
         AND jp.location_id IS NULL
    SQL

    # Pass 3: tenants that still have nil-location proposals own no
    # locations at all. Synthesize a placeholder so the migration can
    # complete cleanly. Operators see it in their tenant locations
    # list (with an obvious "placeholder" label) and can edit/replace
    # via the admin tenant page. is_active defaults to false so the
    # placeholder doesn't immediately become a default for anything else.
    placeholder_label = "(Default — placeholder, please update)"
    execute <<~SQL
      WITH new_locations AS (
        INSERT INTO locations
          (tenant_id, display_name, address_line_1, city, state,
           postal_code, phone_number, is_active, created_at, updated_at)
        SELECT DISTINCT jp.tenant_id, #{connection.quote(placeholder_label)},
               'Address pending', 'Pending', 'TX',
               '00000', '(000) 000-0000', false,
               NOW(), NOW()
          FROM job_proposals jp
         WHERE jp.location_id IS NULL
        RETURNING id, tenant_id
      )
      UPDATE job_proposals AS jp
         SET location_id = nl.id
        FROM new_locations nl
       WHERE jp.tenant_id = nl.tenant_id
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
