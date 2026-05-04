class AddGmailPollingColumns < ActiveRecord::Migration[8.0]
  def up
    add_column :campaign_instances, :ended_at, :datetime
    add_column :campaign_step_instances, :gmail_send_response, :jsonb
    add_column :campaign_step_instances, :gmail_thread_snapshot, :jsonb

    # Backfill ended_at for any campaign instance already in a terminal
    # state. updated_at is the best proxy we have for "when did this stop"
    # for rows that pre-date the column. Active rows stay nil.
    execute <<~SQL.squish
      UPDATE campaign_instances
      SET ended_at = updated_at
      WHERE status <> #{CampaignInstance.statuses[:active]}
    SQL
  end

  def down
    remove_column :campaign_step_instances, :gmail_thread_snapshot
    remove_column :campaign_step_instances, :gmail_send_response
    remove_column :campaign_instances, :ended_at
  end
end
