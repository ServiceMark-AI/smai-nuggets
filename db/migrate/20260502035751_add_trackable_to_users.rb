class AddTrackableToUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :first_login_date, :datetime
    remove_column :users, :last_login_date, :datetime

    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
  end
end
