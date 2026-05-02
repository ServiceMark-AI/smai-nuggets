class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :display_name, null: false
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :state, null: false, limit: 2
      t.string :postal_code, null: false
      t.string :phone_number, null: false
      t.boolean :is_active, null: false, default: false
      t.references :created_by_user, foreign_key: { to_table: :users }
      t.references :updated_by_user, foreign_key: { to_table: :users }

      t.timestamps
    end

    remove_index :locations, :organization_id
    add_index :locations, :organization_id, unique: true
    add_index :locations, :is_active
  end
end
