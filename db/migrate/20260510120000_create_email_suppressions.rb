class CreateEmailSuppressions < ActiveRecord::Migration[8.1]
  def change
    create_table :email_suppressions do |t|
      t.references :location, null: false, foreign_key: true
      t.string :email, null: false
      t.string :reason, null: false
      t.text :notes
      t.timestamps
    end

    add_index :email_suppressions, [:location_id, :email], unique: true
  end
end
