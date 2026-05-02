class CreateCampaignInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_instances do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :host, polymorphic: true, null: false, index: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
