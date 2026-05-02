class CreateTenantActivationJoins < ActiveRecord::Migration[8.1]
  def change
    create_table :tenant_job_types do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :job_type, null: false, foreign_key: true
      t.boolean :is_active, null: false, default: false
      t.timestamps
    end
    add_index :tenant_job_types, [:tenant_id, :job_type_id], unique: true

    create_table :tenant_scenarios do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :scenario, null: false, foreign_key: true
      t.boolean :is_active, null: false, default: false
      t.timestamps
    end
    add_index :tenant_scenarios, [:tenant_id, :scenario_id], unique: true
  end
end
