class AddTenantAccountFieldsAndAuditLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :logo_url, :string
    add_column :tenants, :company_name, :string

    create_table :audit_logs do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :actor_user, foreign_key: { to_table: :users }, null: true
      t.string :action, null: false
      t.string :target_type, null: false
      t.bigint :target_id, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :created_at, null: false

      t.index [:target_type, :target_id]
      t.index :action
      t.index :created_at
    end
  end
end
