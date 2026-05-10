class AddDiscardedAtToCampaignsAndJobProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :discarded_at, :datetime
    add_index  :campaigns, :discarded_at

    add_column :job_proposals, :discarded_at, :datetime
    add_index  :job_proposals, :discarded_at
  end
end
