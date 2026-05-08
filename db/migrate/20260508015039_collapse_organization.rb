class CollapseOrganization < ActiveRecord::Migration[8.1]
  def up
    add_reference :locations, :tenant, foreign_key: true, null: true
    add_reference :job_proposals, :location, foreign_key: true, null: true

    execute <<~SQL
      UPDATE locations
         SET tenant_id = organizations.tenant_id
        FROM organizations
       WHERE organizations.id = locations.organization_id
    SQL

    execute <<~SQL
      UPDATE job_proposals
         SET location_id = users.location_id
        FROM users
       WHERE users.id = job_proposals.created_by_user_id
         AND users.location_id IS NOT NULL
    SQL

    nil_locs = connection.select_value("SELECT COUNT(*) FROM locations WHERE tenant_id IS NULL").to_i
    if nil_locs.positive?
      raise "Refusing to lock locations.tenant_id NOT NULL: #{nil_locs} location(s) still have nil tenant_id"
    end
    change_column_null :locations, :tenant_id, false

    remove_reference :job_proposals, :organization, foreign_key: true, index: true
    remove_reference :invitations, :organization, foreign_key: true, index: true
    remove_reference :locations, :organization, foreign_key: true, index: true

    drop_table :organizational_members
    drop_table :organizations
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Organization collapse is one-way; restore from backup if needed."
  end
end
