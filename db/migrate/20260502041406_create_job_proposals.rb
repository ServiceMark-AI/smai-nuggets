class CreateJobProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :job_proposals do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }
      t.references :closed_by_user, null: true, foreign_key: { to_table: :users }
      t.references :job_type, null: true, foreign_key: true

      t.string :customer_first_name
      t.string :customer_last_name
      t.string :customer_title
      t.string :customer_house_number
      t.string :customer_street
      t.string :customer_city
      t.string :customer_state
      t.string :customer_zip

      t.decimal :proposal_value, precision: 12, scale: 2
      t.text :job_description
      t.string :internal_reference

      t.integer :status, null: false, default: 0
      t.string :status_details
      t.string :loss_reason
      t.text :loss_notes
      t.datetime :closed_at

      t.jsonb :last_reply

      t.string :pipeline_stage
      t.string :status_overlay
      t.string :scenario_key

      t.timestamps
    end
  end
end
