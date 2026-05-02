class CreateJobTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :job_types do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
