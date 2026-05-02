class CreateOrganizationalMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :organizational_members do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :organizational_members, [:organization_id, :user_id], unique: true
  end
end
