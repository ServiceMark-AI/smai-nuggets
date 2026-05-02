class RemoveTenantFromJobTypes < ActiveRecord::Migration[8.1]
  def change
    remove_index :job_types, [:tenant_id, :type_code]
    remove_reference :job_types, :tenant, foreign_key: true, null: false
    add_index :job_types, :type_code, unique: true
  end
end
