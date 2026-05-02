class CreateScenarios < ActiveRecord::Migration[8.1]
  def change
    create_table :scenarios do |t|
      t.references :job_type, null: false, foreign_key: true
      t.references :campaign, foreign_key: true
      t.string :code, null: false, limit: 64
      t.string :short_name, null: false
      t.text :description

      t.timestamps
    end

    add_index :scenarios, [:job_type_id, :code], unique: true
  end
end
