class CreateApplicationMailboxes < ActiveRecord::Migration[8.1]
  def change
    create_table :application_mailboxes do |t|
      t.string   :provider,      null: false, default: "google"
      t.string   :email,         null: false
      t.text     :access_token,  null: false
      t.text     :refresh_token
      t.datetime :expires_at
      t.text     :scopes
      t.timestamps
    end
  end
end
