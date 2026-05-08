class AddTitleToUsersAndInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :title, :string
    add_column :invitations, :title, :string
  end
end
