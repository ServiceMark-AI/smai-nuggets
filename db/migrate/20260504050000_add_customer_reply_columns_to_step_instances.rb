class AddCustomerReplyColumnsToStepInstances < ActiveRecord::Migration[8.0]
  def change
    add_column :campaign_step_instances, :customer_replied, :boolean, default: false, null: false
    add_column :campaign_step_instances, :gmail_reply_payload, :jsonb
  end
end
