class AddLocationToUsersAndInvitations < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :location, foreign_key: true, null: true
    add_reference :invitations, :location, foreign_key: true, null: true
  end
end
