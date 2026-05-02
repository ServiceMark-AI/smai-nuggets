class CreateCampaignStepInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_step_instances do |t|
      t.references :campaign_instance, null: false, foreign_key: true
      t.references :campaign_step, null: false, foreign_key: true

      t.string :final_subject
      t.text :final_body

      t.integer :email_delivery_status, null: false, default: 0
      t.string :gmail_thread_id
      t.datetime :planned_delivery_at

      t.timestamps
    end
  end
end
