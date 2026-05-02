class AddTypeCodeToJobTypes < ActiveRecord::Migration[8.1]
  def change
    add_column :job_types, :type_code, :string, limit: 64
    add_index :job_types, [:tenant_id, :type_code], unique: true, where: "type_code IS NOT NULL"
  end
end
