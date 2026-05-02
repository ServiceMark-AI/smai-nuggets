class AddAttributedToToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_reference :campaigns, :attributed_to, polymorphic: true, null: true, index: true
  end
end
