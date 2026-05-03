class CreateIntegrationChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :integration_checks do |t|
      t.string :key, null: false
      t.integer :state, null: false, default: 0
      t.text :details
      t.text :error_message
      t.datetime :last_checked_at

      t.timestamps
    end

    add_index :integration_checks, :key, unique: true
  end
end
