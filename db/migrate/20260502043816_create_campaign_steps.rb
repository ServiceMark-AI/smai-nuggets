class CreateCampaignSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_steps do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :sequence_number, null: false
      t.integer :offset_min, null: false
      t.string :template_subject
      t.text :template_body

      t.timestamps
    end

    add_index :campaign_steps, [:campaign_id, :sequence_number], unique: true
  end
end
