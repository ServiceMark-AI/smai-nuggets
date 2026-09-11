class AddRefreshFailureColumnsToEmailDelegations < ActiveRecord::Migration[8.1]
  def change
    add_column :email_delegations, :refresh_failed_at, :datetime
    add_column :email_delegations, :refresh_error, :string
  end
end
