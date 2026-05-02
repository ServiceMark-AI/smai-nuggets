class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.references :tenant, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :organizations }

      t.timestamps
    end
  end
end
