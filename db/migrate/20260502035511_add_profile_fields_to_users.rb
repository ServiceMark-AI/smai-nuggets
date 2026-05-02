class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_reference :users, :tenant, null: true, foreign_key: true
    add_column :users, :first_login_date, :datetime
    add_column :users, :last_login_date, :datetime
    add_column :users, :is_pending, :boolean, default: true, null: false
    add_column :users, :is_admin, :boolean, default: false, null: false
  end
end
