class AddBlockedReasonToCampaignStepInstances < ActiveRecord::Migration[8.1]
  def change
    add_column :campaign_step_instances, :blocked_reason_key, :string
    add_column :campaign_step_instances, :blocked_reason_detail, :text
  end
end
