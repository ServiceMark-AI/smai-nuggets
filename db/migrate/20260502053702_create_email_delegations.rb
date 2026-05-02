class CreateEmailDelegations < ActiveRecord::Migration[8.1]
  def change
    create_table :email_delegations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false, default: "google"
      t.string :email, null: false
      t.text :access_token, null: false
      t.text :refresh_token
      t.datetime :expires_at
      t.text :scopes

      t.timestamps
    end

    add_index :email_delegations, [:user_id, :provider, :email], unique: true
  end
end
