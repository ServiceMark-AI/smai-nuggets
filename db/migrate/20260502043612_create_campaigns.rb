class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.integer :status, null: false, default: 0
      t.references :approved_by_user, null: true, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.references :paused_by_user, null: true, foreign_key: { to_table: :users }
      t.datetime :paused_at

      t.timestamps
    end
  end
end
