class AddInviteeProfileToInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :invitations, :first_name, :string
    add_column :invitations, :last_name, :string
    add_column :invitations, :phone_number, :string
  end
end
